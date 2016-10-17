//
//  MainViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

class MainViewController: UIViewController, SelectTraderViewDelegate, TraderViewDelegate, FundViewDelegate, AnalyzerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.marketCapitalization.text = "-"
        self.btcJpyMarketPrice.text = "-"
        self.momentumLabel.text = "-"
        self.bullMarketLabel.text = "OFF"
        self.countDownLabel.text = "-"
        
        if self.currentTraderName.isEmpty {
            self.currentTraderName = Config.currentTraderName
        }
        
        self.fundView = FundView(account: self.account)
        self.traderView = TraderView(view: self.traderTableView, api: self.account.privateApi)
        self.traderView.reloadTrader(self.currentTraderName)
        self.traderView.reloadData()
        self.traderView.delegate = self
        self.fundView.delegate = self
        
        let app = UIApplication.shared.delegate as! AppDelegate
        app.analyzer!.delegate = self
    }
    
    // SelectTraderViewDelegate
    func setCurrentTrader(_ traderName: String) {
        self.currentTraderName = traderName
        self.traderView.reloadTrader(self.currentTraderName)
        self.traderView.reloadData()
    }
    
    // TraderViewDelegate
    func didTouchTraderView() {
        self.performSegue(withIdentifier: self.positionsSegue, sender: self)
    }
    
    // FundViewDelegate
    func didUpdateBtcJpyPrice(_ view: String) {
        self.btcJpyMarketPrice.text = view
        DispatchQueue.main.async {
            self.marketCapitalization.setNeedsDisplay()
        }
    }
    
    func didUpdateMarketCapitalization(_ view: String) {
        self.marketCapitalization.text = view
        DispatchQueue.main.async {
            self.marketCapitalization.setNeedsDisplay()
        }
    }
    
    // AnalyzerDelegate
    func signaledBuy() {
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
        let fund = JPYFund(api: self.account.privateApi)
        fund.calculateHowManyAmountCanBuy(.BTC, rate: 0.9) { (err, amount) in
            trader!.createLongPosition(.BTC_JPY, price: nil, amount: amount) { err in
                if let e = err {
                    print(e.message)
                }
                self.traderView.reloadData()
            }
        }
    }
    
    func signaledSell() {
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
        for position in trader!.positions {
            let p = position as? Position
            p?.unwind(nil, price: nil) { (err) in
                if let e = err {
                    print(e.message)
                }
                self.traderView.reloadData()
            }
        }
    }
    
    func didUpdateSignals(_ momentum: Double, isBullMarket: Bool) {
        self.momentumLabel.text = momentum.description
        self.bullMarketLabel.text = isBullMarket.description
        DispatchQueue.main.async {
            self.momentumLabel.setNeedsDisplay()
            self.bullMarketLabel.setNeedsDisplay()
        }
    }
    
    func didUpdateCount(_ count: Int) {
        self.countDownLabel.text = count.description
        DispatchQueue.main.async {
            self.countDownLabel.setNeedsDisplay()
        }
    }
    
    func didUpdateInterval(_ interval: Int) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case self.selectTraderSegue:
            let destController = segue.destination as! SelectTraderViewController
            destController.account = account!
            destController.delegate = self
        case self.positionsSegue:
            let destController = segue.destination as! PositionsViewController
            destController.trader = self.traderView.trader
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
    
    @IBAction func pushBuyButton(_ sender: AnyObject) {
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
        let priceText = self.buyPriceText.text!
        let amountText = self.buyAmountText.text!
        var price: Double? = nil
        var amount: Double = 0.0
        if !priceText.isEmpty {
            price = Double(priceText)
        }
        if amountText.isEmpty {
            let fund = JPYFund(api: self.account.privateApi)
            fund.calculateHowManyAmountCanBuy(.BTC) { (err, amount) in
                trader!.createLongPosition(.BTC_JPY, price: price, amount: amount) { err in
                    if let e = err {
                        print(e.message)
                    }
                    self.traderView.reloadData()
                }
            }
        } else {
            amount = Double(amountText)!
            trader!.createLongPosition(.BTC_JPY, price: price, amount: amount) { err in
                if let e = err {
                    print(e.message)
                }
                self.traderView.reloadData()
            }
        }
        
    }
    
    @IBAction func pushSellButton(_ sender: AnyObject) {
    }
    
    
    
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {}
    
    internal var account: Account!
    fileprivate var fundView: FundView!
    fileprivate var traderView: TraderView!
    fileprivate var currentTraderName: String = ""
    
    @IBOutlet weak var buyPriceText: UITextField!
    @IBOutlet weak var buyAmountText: UITextField!
    @IBOutlet weak var sellPriceText: UITextField!
    @IBOutlet weak var sellAmountText: UITextField!
    
    @IBOutlet weak var momentumLabel: UILabel!
    @IBOutlet weak var bullMarketLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    fileprivate let selectTraderLabelTag = 1
    fileprivate let selectTraderSegue = "selectTraderSegue"
    fileprivate let positionsSegue = "positionsSegue"
    
    @IBOutlet weak var marketCapitalization: UILabel!
    @IBOutlet weak var btcJpyMarketPrice: UILabel!
    @IBOutlet weak var traderTableView: UITableView!

}
