//
//  File.swift
//  zai
//
//  Created by Kyota Watanabe on 12/7/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//


import SwiftyJSON
import ZaifSwift


fileprivate func floorValue(value: Double, digit: Double) -> Double{
    return floor(value * digit) / digit
}


struct Quote {
    public enum QuoteType : String {
        case ASK = "ask"
        case BID = "bid"
    }
    
    init(price: Double, amount: Double, type: QuoteType) {
        self.price = floorValue(value: price, digit: self.priceDigit)
        self.amount = floorValue(value: amount, digit: self.amountDigit)
        self.type = type
    }
    
    func equalPrice(value: Double) -> Bool {
        return abs(self.price - value) < self.priceError
    }
    
    func equalAmount(value: Double) -> Bool {
        return abs(self.amount - value) < self.amountError
    }

    
    let price: Double
    let amount: Double
    let type: QuoteType
    
    private let priceDigit = 10000.0 // 4digit
    private let priceError = 0.0001
    private let amountDigit = 100000.0 // 5digit
    private let amountError = 0.00001
}


protocol BoardDelegate : MonitorableDelegate {
    func recievedBoard(err: ZaiErrorType?, board: Board?)
}


class Board {
    init() {
        self.asks = []
        self.bids = []
    }
    
    func sort() {
        self.asks = self.asks.sorted{ $1.price < $0.price }
        self.bids = self.bids.sorted{ $1.price < $0.price }
    }
    
    func trunc(size: Int) {
        self.asks = Array<Quote>(self.asks.suffix(size))
        self.bids = Array<Quote>(self.bids.prefix(size))
    }
    
    func update(diff: Board) {
        var newAsks = [Quote]()
        for i in 0 ..< diff.askCount {
            let quote = diff.getAsk(index: i)!
            var isNewQuote = true
            for j in 0 ..< self.askCount {
                let curQuote = self.getAsk(index: j)!
                if curQuote.equalPrice(value: quote.price) {
                    self.removeAsk(index: j)
                    if quote.equalAmount(value: 0.0) == false {
                        self.addAsk(price: quote.price, amount: quote.amount)
                    }
                    isNewQuote = false
                    break
                }
            }
            if isNewQuote {
                newAsks.append(Quote(price: quote.price, amount: quote.amount, type: quote.type))
            }
        }
        for quote in newAsks {
            self.addAsk(price: quote.price, amount: quote.amount)
        }
        
        var newBids = [Quote]()
        for i in 0 ..< diff.bidCount {
            let quote = diff.getBid(index: i)!
            var isNewQuote = true
            for j in 0 ..< self.bidCount {
                let curQuote = self.getBid(index: j)!
                if curQuote.equalPrice(value: quote.price) {
                    self.removeBid(index: j)
                    if quote.equalAmount(value: 0.0) == false {
                        self.addBid(price: quote.price, amount: quote.amount)
                    }
                    isNewQuote = false
                    break
                }
            }
            if isNewQuote {
                newBids.append(Quote(price: quote.price, amount: quote.amount, type: quote.type))
            }
        }
        for quote in newBids {
            self.addBid(price: quote.price, amount: quote.amount)
        }
        self.sort()
    }
    
    func addAsk(price: Double, amount: Double) {
        let quote = Quote(price: price, amount: amount, type: .ASK)
        self.asks.append(quote)
    }
    
    func removeAsk(index: Int) {
        guard let _ = self.getAsk(index: index) else {
            return
        }
        self.asks.remove(at: index)
    }
    
    func getAsk(index: Int) -> Quote? {
        if self.asks.count < index {
            return nil
        } else {
            return self.asks[index]
        }
    }
    
    func getBestAsk() -> Quote? {
        return self.asks.last
    }
    
    func calculateAskMomentum() -> Double {
        let ema = Ema(term: 5)
        for ask in self.asks {
            ema.addSample(value: ask.amount)
        }
        return ema.calculate()
    }
    
    func addBid(price: Double, amount: Double) {
        let quote = Quote(price: price, amount: amount, type: .BID)
        self.bids.append(quote)
    }
    
    func getBid(index: Int) -> Quote? {
        if self.bids.count < index {
            return nil
        } else {
            return self.bids[index]
        }
    }
    
    func removeBid(index: Int) {
        guard let _ = self.getBid(index: index) else {
            return
        }
        self.bids.remove(at: index)
    }
    
    func getBestBid() -> Quote? {
        return self.bids.first
    }
    
    func calculateBidMomentum() -> Double {
        let ema = Ema(term: 5)
        let rev = self.bids.reversed()
        for bid in rev {
            ema.addSample(value: bid.amount)
        }
        return ema.calculate()
    }
    
    func getQuote(index: Int) -> Quote? {
        if index < self.asks.count {
            return self.asks[index]
        } else if index < self.quoteCount {
            return self.bids[index - self.asks.count]
        } else {
            return nil
        }
    }
    
    var quoteCount: Int {
        get { return self.asks.count + self.bids.count }
    }
    
    var askCount: Int {
        get { return self.asks.count }
    }
    
    var bidCount: Int {
        get { return self.bids.count }
    }
    
    private var asks: [Quote]
    private var bids: [Quote]
}

class BoardMonitor : BoardDelegate {
    
    init(currencyPair: ApiCurrencyPair, api: Api) {
        self.monitorableBoard = MonitorableBoard(currencyPair: currencyPair, api: api)
        self.streamingBoard = StreamingBoard(currencyPair: currencyPair, api: api)
    }
    
    var delegate: BoardDelegate? = nil {
        didSet {
            if self.delegate != nil {
                if self.updateInterval == UpdateInterval.realTime {
                    self.streamingBoard.delegate = self
                    self.monitorableBoard.delegate = nil
                } else {
                    self.monitorableBoard.monitoringInterval = self.updateInterval
                    self.monitorableBoard.delegate = self
                    self.streamingBoard.delegate = nil
                }
            } else {
                self.streamingBoard.delegate = nil
                self.monitorableBoard.delegate = nil
            }
        }
    }

    
    // BoardDelegate
    func recievedBoard(err: ZaiErrorType?, board: Board?) {
        self.delegate?.recievedBoard(err: err, board: board)
    }
    
    
    var updateInterval = UpdateInterval.fiveSeconds
    let monitorableBoard: MonitorableBoard
    let streamingBoard: StreamingBoard
}


class MonitorableBoard : Monitorable {
    
    init(currencyPair: ApiCurrencyPair, api: Api) {
        self.api = api
        self.currencyPair = currencyPair
        super.init(target: "Board")
    }
    
    override func monitor() {
        let delegate = self.delegate as? BoardDelegate
        api.getBoard(currencyPair: self.currencyPair, maxSize: 50) { (err, board) in
            DispatchQueue.main.async {
                delegate?.recievedBoard(err: nil, board: board)
            }
        }
    }
    
    let api: Api
    let currencyPair: ApiCurrencyPair
}


class StreamingBoard {
    
    init(currencyPair: ApiCurrencyPair, api: Api) {
        self.api = api
        self.currencyPair = currencyPair
    }
    
    var delegate: BoardDelegate? = nil {
        willSet {
            if newValue != nil {
                self.streamApi = self.api.createBoardStream(currencyPair: self.currencyPair, maxSize: 50, onOpen: self.onOpen, onClose: self.onClose, onError: self.onError, onData: self.onData)

            } else {
                if let stream = self.streamApi {
                    stream.close()
                }
            }
        }
    }
    
    fileprivate func onOpen(err: ApiError?) -> Void {
        print(getNow() + " opened btc_jpy streaming")
    }
    
    fileprivate func onClose(err: ApiError?) {
        print(getNow() + " closed btc_jpy streaming")
    }
    
    fileprivate func onError(err: ApiError?) {
        print(getNow() +  "error in streaming")
        self.delegate?.recievedBoard(err: .ZAIF_CONNECTION_ERROR, board: nil)
    }
    
    fileprivate func onData(_ err: ApiError?, board: Board) {
        if let e = err {
            print(e.message)
            return
        }
        self.delegate?.recievedBoard(err: nil, board: board)
    }
    
    var streamApi: StreamApi?
    let api: Api
    let currencyPair: ApiCurrencyPair
}
