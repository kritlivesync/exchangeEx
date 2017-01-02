//
//  File.swift
//  zai
//
//  Created by 渡部郷太 on 12/7/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//


import SwiftyJSON
import ZaifSwift


struct Quote {
    public enum QuoteType : String {
        case ASK = "ask"
        case BID = "bid"
    }
    
    init(price: Double, amount: Double, type: QuoteType) {
        self.price = price
        self.amount = amount
        self.type = type
    }
    
    let price: Double
    let amount: Double
    let type: QuoteType
}


protocol BoardDelegate {
    func recievedBoard(err: ZaiErrorType?, board: Board?)
}

class Board {
    init() {
        self.asks = []
        self.bids = []
    }
    
    func addAsk(price: Double, amount: Double) {
        let quote = Quote(price: price, amount: amount, type: .ASK)
        self.asks.append(quote)
        self.asks = self.asks.sorted{ $1.price < $0.price }
    }
    
    func getAsk(index: Int) -> Quote? {
        if self.asks.count < index {
            return self.asks[index]
        } else {
            return nil
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
        self.bids = self.bids.sorted{ $1.price < $0.price }
    }
    
    func getBid(index: Int) -> Quote? {
        if self.bids.count < index {
            return self.bids[index]
        } else {
            return nil
        }
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
    
    var delegate : BoardDelegate? {
        get { return self.delegate }
        set {
            if let val = newValue {
                self.dlgt = val
                self.stream = StreamingApi.stream(.BTC_JPY, openCallback: self.onOpen)
                self.stream!.onError(callback: self.onError)
                self.stream!.onData(callback: self.onData)
            } else {
                if let s = self.stream {
                    s.close()
                }
                self.dlgt = nil
            }
        }
    }
    
    func onOpen(_ err: ZSError?, _ res: JSON?) {
        print("opened btc_jpy streaming")
    }
    
    func onError(_ err: ZSError?, _ res: JSON?) {
        print("error in streaming")
        if let d = self.dlgt {
            d.recievedBoard(err: .ZAIF_CONNECTION_ERROR, board: nil)
        }
        
    }
    
    func onData(_ err: ZSError?, _ res: JSON?) {
        if let e = err {
            print(e.message)
            return
        }
        
        let board = Board()
        let asks = res!["asks"].arrayValue
        for ask in asks {
            let a = ask.arrayValue
            board.addAsk(price: a[0].doubleValue, amount: a[1].doubleValue)
        }
        
        let bids = res!["bids"].arrayValue
        for bid in bids {
            let b = bid.arrayValue
            board.addBid(price: b[0].doubleValue, amount: b[1].doubleValue)
        }
        if let d = self.dlgt {
            d.recievedBoard(err: nil, board: board)
        }
    }
    
    private var asks: [Quote]
    private var bids: [Quote]
    var stream: ZaifSwift.Stream? = nil
    var dlgt: BoardDelegate? = nil
}
