//
//  MainViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

class MainViewController: UIViewController, FundViewDelegate, BoardViewDelegate, AnalyzerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.marketCapitalization.text = "-"
        self.btcJpyMarketPrice.text = "-"
        self.btcFundLabel.text = "-"
        
        if self.currentTraderName.isEmpty {
            self.currentTraderName = Config.currentTraderName
        }
        self.trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        
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
    
    func recievedBoard(board: Board) {
        self.boardView = BoardView(view: self.boardTableView, board: board)
        self.boardView.delegate = self
        self.boardView.reloadData()
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
    
    func orderBuy(quote: Quote) {
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
        let amt = min(quote.amount, 1.0)
        trader!.createLongPosition(.BTC_JPY, price: quote.price, amount: amt) { err in
            if let e = err {
                print(e.message)
            }
        }
    }
    
    func orderSell(quote: Quote) {
        let maxAmount = Double(self.btcFundLabel.text!)!
        let amt = min(quote.amount, maxAmount)
        self.sell(price: quote.price, amount: amt)
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
    @IBOutlet weak var boardTableView: UITableView!
    fileprivate var currentTraderName: String = ""
    var boardView: BoardView! = nil
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
