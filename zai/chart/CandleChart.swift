//
//  CandleChart.swift
//  zai
//
//  Created by 渡部郷太 on 1/4/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation


struct Trade {
    let id: String
    let price: Double
    let amount: Double
    let currencyPair: String
    let action: String
    let timestamp: Int64
}


class Candle {
    init(startDate: Int64, endDate: Int64) {
        self.startDate = startDate
        self.endDate = endDate
        self.trades = [Trade]()
    }
    
    func add(trade: Trade) -> Bool {
        if trade.timestamp < self.startDate || self.endDate < trade.timestamp {
            return false
        }
        self.trades.append(trade)
        return true
    }

    var openPrice: Double? {
        get {
            return self.trades.first?.price
        }
    }
    
    var lastPrice: Double? {
        get {
            return self.trades.last?.price
        }
    }
    
    var highPrice: Double? {
        get {
            if self.trades.count == 0 {
                return nil
            }
            var max: Double? = nil
            for trade in self.trades {
                guard let m = max else {
                    max = trade.price
                    continue
                }
                if m < trade.price {
                   max = trade.price
                }
            }
            return max!
        }
    }
    
    var lowPrice: Double? {
        get {
            if self.trades.count == 0 {
                return nil
            }
            var min: Double? = nil
            for trade in self.trades {
                guard let m = min else {
                    min = trade.price
                    continue
                }
                if trade.price < m {
                    min = trade.price
                }
            }
            return min!
        }
    }
    
    var priceAevrage: Double? {
        get {
            if self.trades.count == 0 {
                return nil
            }
            var sum = 0.0
            for trade in self.trades {
                sum += trade.price
            }
            return sum / Double(self.trades.count)
        }
    }
    

    let startDate: Int64
    let endDate: Int64
    var trades: [Trade]
}


enum ChartInterval: Int64 {
    case oneMinute=60
    case fiveMinute=300
}


protocol CandleChartDelegate : MonitorableDelegate {
    func recievedChart(chart: CandleChart, shifted: Bool)
}


class CandleChart : Monitorable {
    init(currencyPair: ApiCurrencyPair, interval: ChartInterval, candleCount: Int, api: Api) {
        self.currencyPair = currencyPair
        self.interval = interval
        self.candleCount = candleCount
        self.api = api
        self.candles = [Candle]()
        
        super.init()
        
        let now = Int64(Date().timeIntervalSince1970)
        let period = self.calculatePeriod(date: now)
        var startDate = period.0
        var endDate = period.1
        self.candles = [Candle]()
        for _ in 0 ..< self.candleCount {
            let candle = Candle(startDate: startDate, endDate: endDate)
            self.candles.append(candle)
            startDate -= interval.rawValue
            endDate -= interval.rawValue
        }
        self.candles = self.candles.reversed()
    }
    
    func addTrade(trade: Trade) -> Bool {
        if trade.timestamp < self.candles.first!.startDate {
            return false
        } else if self.candles.last!.endDate < trade.timestamp {
            let period = self.calculatePeriod(date: trade.timestamp)
            let candle = Candle(startDate: period.0, endDate: period.1)
            _ = candle.add(trade: trade)
            self.candles.remove(at: 0)
            self.candles.append(candle)
            return true
        } else {
            for candle in self.candles {
                if candle.add(trade: trade) {
                    return false
                }
            }
            return false
        }
    }
    
    fileprivate func calculatePeriod(date: Int64) -> (Int64, Int64) {
        let startDate = date - (date % self.interval.rawValue)
        let endDate = startDate + self.interval.rawValue
        return (startDate, endDate)
    }
    
    override func monitor() {
        guard let delegate = self.delegate as? CandleChartDelegate else {
            return
        }
        
        if self.isFirstUpdate {
            self.api.getTrades(currencyPair: self.currencyPair) { (err, trades) in
                if err != nil {
                    return
                }
                var shifted = false
                for trade in trades {
                    if self.lastTradeId == trade.id {
                        break
                    }
                    shifted = self.addTrade(trade: trade)
                }
                self.lastTradeId = trades.first!.id
                delegate.recievedChart(chart: self, shifted: shifted)
            }
            //self.isFirstUpdate = false
        } else {
            self.api.getPrice(currencyPair: self.currencyPair) { (err, price) in
                let trade = Trade(id: "", price: price, amount: 0.0, currencyPair: self.currencyPair.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                let shifted = self.addTrade(trade: trade)
                delegate.recievedChart(chart: self, shifted: shifted)
            }
        }
    }
    
    let api: Api
    let currencyPair: ApiCurrencyPair
    let interval: ChartInterval
    let candleCount: Int
    var candles: [Candle]
    var isFirstUpdate = true
    var lastTradeId = String()
}
