//
//  MainViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import AMScrollingNavbar
import ZaifSwift

class BoardViewController: UIViewController, FundDelegate, BoardDelegate, BoardViewDelegate, PositionDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        let account = getAccount()!
        self.trader = account.activeExchange.trader

        self.boardHeaderLabel.backgroundColor = Color.keyColor2
        self.askMomentumBar.backgroundColor = Color.askQuoteColor.withAlphaComponent(0.4)
        self.bidMomentumBar.backgroundColor = Color.bidQuoteColor.withAlphaComponent(0.4)
        
        self.boardView = BoardView(view: self.boardTableView)
        self.boardView.delegate = self
        
        self.jpyFundLabel.text = "-"
        
        let api = account.activeExchange.api
        let currencyPair = ApiCurrencyPair(rawValue: account.activeExchange.currencyPair)!
        self.board = BoardMonitor(currencyPair: currencyPair, api: api)
        self.fund = Fund(api: api)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let interval = getBoardConfig().autoUpdateInterval
        self.board.updateInterval = interval
        self.board.delegate = self
        self.fund.monitoringInterval = interval
        self.fund.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.board.delegate = nil
        self.fund.delegate = nil
    }
    
    // FundDelegate
    func recievedJpyFund(jpy: Int) {
        DispatchQueue.main.async {
            self.jpyFundLabel.text = formatValue(jpy)
        }
    }
    
    // BoardDelegate
    func recievedBoard(err: ZaiErrorType?, board: Board?) {
        if let _ = err {
            /*
            DispatchQueue.main.async {
                self.messageLabel.text = "Failed to connect to Zaif"
                self.messageLabel.textColor = UIColor.red
            }*/
        } else {
            self.boardView.update(board: board!)
            let askMomentum = board!.calculateAskMomentum()
            let bidMomentum = board!.calculateBidMomentum()
            let ratio = bidMomentum / askMomentum
            let barWidth = self.momentumBar.layer.bounds.width
            let bidWidth = CGFloat(Double(barWidth) * (ratio) * 0.5)
            self.bidMomentumWidth.constant = min(bidWidth, barWidth)
            self.askMomentumWidth.constant = CGFloat(barWidth) - self.bidMomentumWidth.constant
        }
    }
    
    // PositionDelegate
    func opendPosition(position: Position) {
        /*
        DispatchQueue.main.async {
            self.messageLabel.text = "Promised. Price: " + formatValue(Int(position.price)) + " Amount: " + formatValue(position.balance)
            self.messageLabel.textColor = UIColor(red: 0.7, green: 0.4, blue: 0.4, alpha: 1.0)
        }*/
    }
    
    func unwindPosition(position: Position) {
        /*
        DispatchQueue.main.async {
            guard let log = position.lastTrade else {
                return
            }
            self.messageLabel.text = "Promised. Price: " + formatValue(Int(log.price)) + " Amount: " + formatValue(log.amount.doubleValue)
            self.messageLabel.textColor = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0)
        }*/
    }
    
    func closedPosition(position: Position) {
        /*
        DispatchQueue.main.async {
            guard let log = position.lastTrade else {
                return
            }
            self.messageLabel.text = "Promised. Price: " + formatValue(Int(log.price)) + " Amount: " + formatValue(log.amount.doubleValue)
            self.messageLabel.textColor = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0)
        }*/
    }
    
    func orderBuy(quote: Quote, bestBid: Quote, bestAsk: Quote) {
        let amt = min(quote.amount, 1.0)
        self.trader!.createLongPosition(.BTC_JPY, price: quote.price, amount: amt) { (err, position) in
            if let e = err {
                print(e.message)
            } else {
                position?.delegate = self
            }
        }
    }
    
    func orderSell(quote: Quote, bestBid: Quote, bestAsk: Quote) {
        switch getAppConfig().unwindingRule {
        case .mostBenefit:
            self.trader.unwindMaxProfitPosition(price: quote.price, amount: quote.amount, marketPrice: bestBid.price) { (err, position) in
                if err != nil {
                    position?.delegate = self
                }
            }
        case .mostLoss:
            self.trader.unwindMaxLossPosition(price: quote.price, amount: quote.amount, marketPrice: bestBid.price) { (err, position) in
                if err != nil {
                    position?.delegate = self
                }
            }
        case .mostRecent:
            self.trader.unwindMostRecentPosition(price: quote.price, amount: quote.amount) { (err, position) in
                if err != nil {
                    position?.delegate = self
                }
            }
        case .mostOld:
            self.trader.unwindMostOldPosition(price: quote.price, amount: quote.amount) { (err, position) in
                if err != nil {
                    position?.delegate = self
                }
            }
        }
    }

    @IBAction func pushSettingsButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let settings = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! UINavigationController
        self.present(settings, animated: true, completion: nil)
    }
    
    
    var trader: Trader!

    fileprivate var currentTraderName: String = ""
    var boardView: BoardView! = nil
    
    fileprivate var fund: Fund!
    fileprivate var board: BoardMonitor!
    
    @IBOutlet weak var boardHeaderLabel: UILabel!
    @IBOutlet weak var boardTableView: UITableView!
    
    @IBOutlet weak var jpyFundLabel: UILabel!

    @IBOutlet weak var momentumBar: UIView!
    @IBOutlet weak var askMomentumBar: UILabel!
    @IBOutlet weak var bidMomentumBar: UILabel!
    @IBOutlet weak var askMomentumWidth: NSLayoutConstraint!
    @IBOutlet weak var bidMomentumWidth: NSLayoutConstraint!

}
