//
//  File.swift
//  zai
//
//  Created by 渡部郷太 on 12/7/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//


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
