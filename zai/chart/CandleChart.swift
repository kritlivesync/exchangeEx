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

struct Tick {
    
    init(lastPrice: Double, highPrice: Double, lowPrice: Double, vwap: Double, volume: Double, bid: Double, ask: Double) {
        self.lastPrice = lastPrice
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        self.vwap = vwap
        self.volume = volume
        self.bid = bid
        self.ask = ask
    }

    init() {
        self.init(lastPrice: 0.0, highPrice: 0.0, lowPrice: 0.0, vwap: 0.0, volume: 0.0, bid: 0.0, ask: 0.0)
    }
    
    let lastPrice: Double
    let highPrice: Double
    let lowPrice: Double
    let vwap: Double
    let volume: Double
    let bid: Double
    let ask: Double
}


class Candle {
    init(startDate: Int64, endDate: Int64) {
        self.startDate = startDate
        self.endDate = endDate
        self.trades = [Trade]()
    }
    
    func add(trade: Trade) -> Bool {
        if trade.timestamp < self.startDate || self.endDate <= trade.timestamp {
            return false
        }
        self.trades.append(trade)
        return true
    }
    
    var isEmpty: Bool {
        get {
            return self.trades.count == 0
        }
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
    

    var startDate: Int64
    var endDate: Int64
    var trades: [Trade]
}


protocol CandleChartDelegate : MonitorableDelegate {
    func recievedChart(chart: CandleChart, shifted: Bool)
}


class CandleChart : Monitorable {
    init(currencyPair: ApiCurrencyPair, interval: ChandleChartType, candleCount: Int, api: Api) {
        self.currencyPair = currencyPair
        self.interval = interval
        self.candleCount = candleCount
        self.api = api
        self.candles = [Candle]()
        
        super.init(target: "Candle")
        
        self.monitoringInterval = getChartConfig().autoUpdateInterval
        
        let now = Int64(Date().timeIntervalSince1970)
        let period = self.calculatePeriod(date: now)
        var startDate = period.0
        var endDate = period.1
        self.candles = [Candle]()
        for _ in 0 ..< self.candleCount {
            let candle = Candle(startDate: startDate, endDate: endDate)
            self.candles.append(candle)
            startDate -= interval.seconds
            endDate -= interval.seconds
        }
        self.candles = self.candles.reversed()
    }
    
    open func copyTrades(chart: CandleChart) {
        for candle in chart.candles {
            for trade in candle.trades {
                _ = self.addTrade(trade: trade)
            }
        }
    }
    
    open func addTrade(trade: Trade) -> Bool {
        if trade.timestamp < self.candles.first!.startDate {
            return false
        } else if self.candles.last!.endDate < trade.timestamp {
            let period = self.calculatePeriod(date: trade.timestamp)
            let candle = Candle(startDate: period.0, endDate: period.1)
            _ = candle.add(trade: trade)
            let blankPeriodCount = (candle.startDate - self.candles.last!.endDate) / self.interval.seconds
            for _ in 0 ..< blankPeriodCount {
                self.addNextPeriod()
            }
            self.candles.removeFirst()
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
    
    fileprivate func addNextPeriod() {
        let naxtStartDate = self.candles.last!.endDate
        let candle = Candle(startDate: naxtStartDate, endDate: naxtStartDate + self.interval.seconds)
        self.candles.removeFirst()
        self.candles.append(candle)
    }
    
    open var average: Double {
        get {
            var sum = 0.0
            var validCount = 0.0
            for candle in self.candles {
                if candle.isEmpty == false {
                    sum += ((candle.highPrice! + candle.lowPrice!) / 2)
                    validCount += 1.0
                }
            }
            return sum / validCount
        }
    }
    
    fileprivate func calculatePeriod(date: Int64) -> (Int64, Int64) {
        let startDate = date - (date % Int64(self.interval.seconds))
        let endDate = startDate + self.interval.seconds
        return (startDate, endDate)
    }
    
    override func monitor() {
        guard let delegate = self.delegate as? CandleChartDelegate else {
            return
        }
        
        if self.isHeighPrecision {
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
            self.isHeighPrecision = false
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
    let interval: ChandleChartType
    let candleCount: Int
    var candles: [Candle]
    var isHeighPrecision = true
    var lastTradeId = String()
}
