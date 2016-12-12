//
//  MainViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

class MainViewController: UIViewController, FundDelegate, BitCoinDelegate, BoardDelegate, BoardViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btcJpyMarketPrice.text = "-"
        
        if self.currentTraderName.isEmpty {
            self.currentTraderName = Config.currentTraderName
        }
        self.trader = TraderRepository.getInstance().findTraderByName(self.currentTraderName, api: self.account.privateApi)
        
        self.bitcoin = BitCoin()
        self.bitcoin.delegate = self
        self.board = Board()
        self.board.delegate = self
        self.fund = Fund(api: self.account.privateApi)
        self.fund.delegate = self
    }
    
    // FundDelegate
    func didUpdateBtcJpyPrice(_ view: String) {
        self.btcJpyMarketPrice.text = view
        DispatchQueue.main.async {
            self.btcJpyMarketPrice.setNeedsDisplay()
        }
    }
    func recievedMarketCapitalization(jpy: Int) {
        return
    }
    
    func recievedBtcFund(btc: Double) {
        self.btcFund = btc
    }
    
    // BitCoinDelegate
    func recievedJpyPrice(price: Int) {
        self.btcJpyMarketPrice.text = formatValue(price)
    }
    
    // BoardDelegate
    func recievedBoard(err: ZaiErrorType?, board: Board?) {
        if let _ = err {
            DispatchQueue.main.async {
                self.messageLabel.text = "Failed to connect to Zaif"
                self.messageLabel.textColor = UIColor.red
            }
        } else {
            self.boardView = BoardView(view: self.boardTableView, board: board!)
            self.boardView.delegate = self
            self.boardView.reloadData()
            let askMomentum = board!.calculateAskMomentum()
            let bidMomentum = board!.calculateBidMomentum()
            let askWidth = askAmountMomentumLabel.layer.bounds.width
            let ratio = bidMomentum / askMomentum
            let bidWidth = CGFloat(Double(askWidth) * (ratio) * 0.5)
            self.bidMomentumWidth.constant = min(bidWidth, askWidth)
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
            DispatchQueue.main.async {
                self.messageLabel.text = "Promised. Price: " + formatValue(Int(quote.price)) + " Amount: " + formatValue(amt)
                self.messageLabel.textColor = UIColor(red: 0.7, green: 0.4, blue: 0.4, alpha: 1.0)
            }
        }
    }
    
    func orderSell(quote: Quote) {
        let amt = min(quote.amount, self.btcFund)
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
                DispatchQueue.main.async {
                    self.messageLabel.text = e.message
                    self.messageLabel.textColor = UIColor.red
                }
            } else {
                order.waitForPromise(timeout: 30) { (err, promised) in
                    if let e = err {
                        DispatchQueue.main.async {
                            self.messageLabel.text = e.message
                            self.messageLabel.textColor = UIColor.red
                        }
                    } else if !promised{
                        self.account.privateApi.cancelOrder(order.orderId) { _ in
                            self.sell(price: nil, amount: amount)
                        }
                    } else {
                        DispatchQueue.main.async {
                            let prc = (price == nil) ? "market" : formatValue(Int(price!))
                            self.messageLabel.text = "Promised. Price: " + prc + " Amount: " + formatValue(amount)
                            self.messageLabel.textColor = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0)
                        }
                    }
                }
            }
        }
    }
    
    
    internal var account: Account!
    fileprivate var fund: Fund!
    fileprivate var currentTraderName: String = ""
    var boardView: BoardView! = nil
    var trader: Trader! = nil
    
    var bitcoin: BitCoin!
    var btcFund: Double = 0.0
    
    var board: Board!
    
    @IBOutlet weak var boardTableView: UITableView!
    
    @IBOutlet weak var btcJpyMarketPrice: UILabel!

    @IBOutlet weak var askAmountMomentumLabel: UILabel!
    @IBOutlet weak var bidMomentumWidth: NSLayoutConstraint!
    
    @IBOutlet weak var messageLabel: UILabel!
}
