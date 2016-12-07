//
//  MainViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

class MainViewController: UIViewController, SelectTraderViewDelegate, FundViewDelegate, AnalyzerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.marketCapitalization.text = "-"
        self.btcJpyMarketPrice.text = "-"
        self.btcFundLabel.text = "-"
        
        if self.currentTraderName.isEmpty {
            self.currentTraderName = Config.currentTraderName
        }
        self.trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        self.positionListView = PositionListView(view: self.positionTableView, trader: self.trader)
        
        self.fundView = FundView(account: self.account)
        self.fundView.delegate = self
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.analyzer!.delegate = self
    }
    
    // SelectTraderViewDelegate
    func setCurrentTrader(_ traderName: String) {
        self.currentTraderName = traderName
    }
    
    // TraderViewDelegate
    func didTouchTraderView() {
        self.performSegue(withIdentifier: self.positionsSegue, sender: self)
    }
    
    // FundViewDelegate
    func didUpdateBtcJpyPrice(_ view: String) {
        self.btcJpyMarketPrice.text = view
        DispatchQueue.main.async {
            self.btcJpyMarketPrice.setNeedsDisplay()
        }
    }
    
    func didUpdateMarketCapitalization(_ view: String) {
        self.marketCapitalization.text = view
        DispatchQueue.main.async {
            self.marketCapitalization.setNeedsDisplay()
        }
    }
    
    func didUpdateBtcFund(_ view: String) {
        self.btcFundLabel.text = view
        DispatchQueue.main.async {
            self.btcFundLabel.setNeedsDisplay()
        }
    }
    
    // AnalyzerDelegate    
    func signaledBuy() {
        self.messageLabel.text = "Recieved Signal Buy"
        DispatchQueue.main.async {
            self.messageLabel.setNeedsDisplay()
        }
        /*
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
         */
        let fund = JPYFund(api: self.account.privateApi)
        fund.calculateHowManyAmountCanBuy(.BTC, rate: 0.85) { (err, amount, price) in
            var amt = amount
            if amt > 0.2 {
                amt = 0.2
            }
            let order = BuyOrder(currencyPair: .BTC_JPY, price: price, amount: amt, api: self.account.privateApi)!
            order.excute() { (err, orderId) in
                if let e = err {
                    self.messageLabel.text = e.message
                    DispatchQueue.main.async {
                        self.messageLabel.setNeedsDisplay()
                    }
                } else {
                    order.waitForPromise(timeout: 60) { (err, promised) in
                        if let e = err {
                            self.messageLabel.text = e.message
                            DispatchQueue.main.async {
                                self.messageLabel.setNeedsDisplay()
                            }
                        } else if !promised {
                            self.account.privateApi.cancelOrder(order.orderId) { _ in }
                        }
                    }
                    
                }
            }
            
            /*
            trader!.createLongPosition(.BTC_JPY, price: nil, amount: amount) { err in
                if let e = err {
                    print(e.message)
                    self.messageLabel.text = e.message
                    DispatchQueue.main.async {
                        self.messageLabel.setNeedsDisplay()
                    }
                }
                self.traderView.reloadData()
            }
             */
        }
    }
    
    func signaledSell() {
        self.messageLabel.text = "Recieved Signal Sell"
        DispatchQueue.main.async {
            self.messageLabel.setNeedsDisplay()
        }
        /*
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
        */
        
        let fund = JPYFund(api: self.account.privateApi)
        fund.getBtcFund() { (err, btc) in
            let amount = Double(Int(btc * 10000)) / 10000.0
            let order = SellOrder(
                currencyPair: CurrencyPair.BTC_JPY,
                price: Double(self.btcJpyMarketPrice.text!),
                amount: amount,
                api: self.account.privateApi)!
            
            order.excute() { (err, _) in
                if let e = err {
                    print(e.message)
                    self.messageLabel.text = e.message
                    DispatchQueue.main.async {
                        self.messageLabel.setNeedsDisplay()
                    }
                } else {
                    order.waitForPromise(timeout: 10) { (err, promised) in
                        if let e = err {
                            self.messageLabel.text = e.message
                            DispatchQueue.main.async {
                                self.messageLabel.setNeedsDisplay()
                            }
                        } else if !promised{
                            self.account.privateApi.cancelOrder(order.orderId) { _ in
                                self.signaledSell()
                            }
                        }
                    }
                    
                }
            }
        }

        
        /*
        for position in trader!.positions {
            let p = position as? Position
            p?.unwind(nil, price: nil) { (err) in
                if let e = err {
                    print(e.message)
                }
                self.traderView.reloadData()
            }
        }
         */
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case self.selectTraderSegue:
            let destController = segue.destination as! SelectTraderViewController
            destController.account = account!
            destController.delegate = self
        default: break
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case self.selectTraderLabelTag:
                self.performSegue(withIdentifier: self.selectTraderSegue, sender: self)
            default:
                break
            }
        }
    }
    
    @IBAction func pushMakerBuyButton(_ sender: Any) {
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
        BitCoin.getBestAskQuote(.JPY) { (err, price, amount) in
            let amt = min(amount, 1.0)
            let prc = price - 5
            trader!.createLongPosition(.BTC_JPY, price: prc, amount: amt) { err in
                if let e = err {
                    print(e.message)
                } else {
                    self.positionListView = PositionListView(view: self.positionTableView, trader: self.trader)
                    DispatchQueue.main.async {
                        self.positionListView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func pushMakerSellButton(_ sender: Any) {
        BitCoin.getBestBidQuote(.JPY) { (err, price, amount) in
            var amt = amount
            let maxAmount = Double(self.btcFundLabel.text!)!
            if maxAmount < amt {
                amt = maxAmount
            }
            let prc = price + 5
            self.sell(price: prc, amount: amt)
        }
    }
    
    @IBAction func pushBuyButton(_ sender: AnyObject) {
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
        BitCoin.getBestAskQuote(.JPY) { (err, price, amount) in
            let amt = min(amount, 1.0)
            trader!.createLongPosition(.BTC_JPY, price: price, amount: amt) { err in
                if let e = err {
                    print(e.message)
                } else {
                    self.positionListView = PositionListView(view: self.positionTableView, trader: self.trader)
                    DispatchQueue.main.async {
                        self.positionListView.reloadData()
                    }
                }
            }
        }
    }
    
    @IBAction func pushSellButton(_ sender: AnyObject) {
        BitCoin.getBestBidQuote(.JPY) { (err, price, amount) in
            var amt = amount
            let maxAmount = Double(self.btcFundLabel.text!)!
            if maxAmount < amt {
                amt = maxAmount
            }
            self.sell(price: price, amount: amt)
        }
    }
    
    func sell(price: Double?, amount: Double) {
        let order = SellOrder(
            currencyPair: CurrencyPair.BTC_JPY,
            price: price,
            amount: amount,
            api: self.account.privateApi)!
        
        order.excute() { (err, _) in
            if let e = err {
                print(e.message)
                self.messageLabel.text = e.message
                DispatchQueue.main.async {
                    self.messageLabel.setNeedsDisplay()
                }
            } else {
                order.waitForPromise(timeout: 30) { (err, promised) in
                    if let e = err {
                        self.messageLabel.text = e.message
                        DispatchQueue.main.async {
                            self.messageLabel.setNeedsDisplay()
                        }
                    } else if !promised{
                        self.account.privateApi.cancelOrder(order.orderId) { _ in
                            self.sell(price: nil, amount: amount)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {}
    
    internal var account: Account!
    fileprivate var fundView: FundView!
    @IBOutlet weak var positionTableView: UITableView!
    fileprivate var currentTraderName: String = ""
    var positionListView: PositionListView! = nil
    var trader: Trader! = nil
    
    
    @IBOutlet weak var buyPriceText: UITextField!
    @IBOutlet weak var buyAmountText: UITextField!
    @IBOutlet weak var sellPriceText: UITextField!
    @IBOutlet weak var sellAmountText: UITextField!
    
    fileprivate let selectTraderLabelTag = 1
    fileprivate let selectTraderSegue = "selectTraderSegue"
    fileprivate let positionsSegue = "positionsSegue"
    
    @IBOutlet weak var marketCapitalization: UILabel!
    @IBOutlet weak var btcJpyMarketPrice: UILabel!
    @IBOutlet weak var btcFundLabel: UILabel!

    @IBOutlet weak var messageLabel: UILabel!
}
