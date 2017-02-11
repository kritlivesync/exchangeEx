//
//  MainViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 6/25/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation

import ZaifSwift

class BoardViewController: UIViewController, FundDelegate, BoardDelegate, BoardViewDelegate, AppBackgroundDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        if let image = self.tabBarController?.tabBar.items?[0].selectedImage {
            self.tabBarController?.tabBar.items?[0].selectedImage = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }
        if let image = self.tabBarController?.tabBar.items?[0].image {
            self.tabBarController?.tabBar.items?[0].image = image.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        }

        self.boardHeaderLabel.backgroundColor = Color.keyColor2
        self.askMomentumBar.backgroundColor = Color.askQuoteColor.withAlphaComponent(0.4)
        self.bidMomentumBar.backgroundColor = Color.bidQuoteColor.withAlphaComponent(0.4)
        
        self.boardView = BoardView(view: self.boardTableView)
        self.boardView.delegate = self
        
        self.jpyFundLabel.text = "-"
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.start()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stop()
    }
    
    fileprivate func start() {
        setBackgroundDelegate(delegate: self)
        let account = getAccount()!
        let api = account.activeExchange.api
        let currencyPair = ApiCurrencyPair(rawValue: account.activeExchange.currencyPair)!
        if self.board == nil {
            self.board = BoardMonitor(currencyPair: currencyPair, api: api)
            self.board.updateInterval = getBoardConfig().boardUpdateIntervalType
            self.board.delegate = self
        }
        if self.fund == nil {
            self.fund = Fund(api: api)
            self.fund.monitoringInterval = getAppConfig().footerUpdateIntervalType
            self.fund.delegate = self
        }
        self.trader = account.activeExchange.trader
        self.trader.startWatch()
    }
    
    fileprivate func stop() {
        if self.board != nil {
            self.board.delegate = nil
            self.board = nil
        }
        if self.fund != nil {
            self.fund.delegate = nil
            self.fund = nil
        }
    }
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "BoardViewController"
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
    
    func orderBuy(quote: Quote, bestBid: Quote, bestAsk: Quote, callback: @escaping () -> Void) {
        self.trader!.createLongPosition(.BTC_JPY, price: quote.price, amount: quote.amount) { (err, position) in
            callback()
            if let e = err {
                print(e.message)
                let errorView = createErrorModal(title: e.errorType.toString(), message: e.message)
                self.present(errorView, animated: false, completion: nil)
            }
        }
    }
    
    func orderSell(quote: Quote, bestBid: Quote, bestAsk: Quote, callback: @escaping () -> Void) {
        switch getAppConfig().unwindingRuleType {
        case .mostBenefit:
            self.trader.unwindMaxProfitPosition(price: quote.price, amount: quote.amount, marketPrice: bestBid.price) { (err, position) in
                callback()
                if let e = err {
                    let errorView = createErrorModal(message: e.message)
                    self.present(errorView, animated: false, completion: nil)
                }
            }
        case .mostLoss:
            self.trader.unwindMaxLossPosition(price: quote.price, amount: quote.amount, marketPrice: bestBid.price) { (err, position) in
                callback()
                if let e = err {
                    let errorView = createErrorModal(message: e.message)
                    self.present(errorView, animated: false, completion: nil)
                }
            }
        case .mostRecent:
            self.trader.unwindMostRecentPosition(price: quote.price, amount: quote.amount) { (err, position) in
                callback()
                if let e = err {
                    let errorView = createErrorModal(message: e.message)
                    self.present(errorView, animated: false, completion: nil)
                }
            }
        case .mostOld:
            self.trader.unwindMostOldPosition(price: quote.price, amount: quote.amount) { (err, position) in
                callback()
                if let e = err {
                    let errorView = createErrorModal(message: e.message)
                    self.present(errorView, animated: false, completion: nil)
                }
            }
        }
    }
    
    // AppBackgroundDelegate
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.start()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.stop()
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
