//
//  MainViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

class MainViewController: UIViewController, SelectTraderViewDelegate, TraderViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.currentTraderName.isEmpty {
            self.currentTraderName = Config.currentTraderName
        }
        
        self.fundView = FundView(account: self.account)
        self.traderView = TraderView(view: self.traderTableView, api: self.account.privateApi)
        self.traderView.reloadTrader(self.currentTraderName)
        self.traderView.reloadData()
        self.traderView.delegate = self
        
        self.fundView.createMarketCapitalizationView() { err, data in
            self.marketCapitalization.text = data
            dispatch_async(dispatch_get_main_queue()) {
                self.marketCapitalization.setNeedsDisplay()
            }
        }
    }
    
    // SelectTraderViewDelegate
    func setCurrentTrader(traderName: String) {
        self.currentTraderName = traderName
        self.traderView.reloadTrader(self.currentTraderName)
        self.traderView.reloadData()
    }
    
    // TraderViewDelegate
    func didTouchTraderView() {
        self.performSegueWithIdentifier(self.positionsSegue, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        switch segue.identifier! {
        case self.selectTraderSegue:
            let destController = segue.destinationViewController as! SelectTraderViewController
            destController.account = account!
            destController.delegate = self
        case self.positionsSegue:
            let destController = segue.destinationViewController as! PositionsViewController
            destController.trader = self.traderView.trader
        default: break
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case self.selectTraderLabelTag:
                self.performSegueWithIdentifier(self.selectTraderSegue, sender: self)
            default:
                break
            }
        }
    }
    
    @IBAction func pushBuyButton(sender: AnyObject) {
        let trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        if trader == nil {
            return
        }
        let priceText = self.buyPriceText.text!
        let amountText = "0.0001"//self.buyAmountText.text!
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
    
    @IBAction func pushSellButton(sender: AnyObject) {
    }
    
    
    
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {}
    
    internal var account: Account!
    private var fundView: FundView!
    private var traderView: TraderView!
    private var currentTraderName: String = ""
    
    @IBOutlet weak var buyPriceText: UITextField!
    @IBOutlet weak var buyAmountText: UITextField!
    @IBOutlet weak var sellPriceText: UITextField!
    @IBOutlet weak var sellAmountText: UITextField!
    
    
    private let selectTraderLabelTag = 1
    private let selectTraderSegue = "selectTraderSegue"
    private let positionsSegue = "positionsSegue"
    
    @IBOutlet weak var marketCapitalization: UILabel!
    @IBOutlet weak var traderTableView: UITableView!

}