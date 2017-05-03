//
//  Chart.swift
//  zai
//
//  Created by Kyota Watanabe on 1/4/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit

import Charts


class ChartViewController : UIViewController, CandleChartViewDelegate, FundDelegate, BitCoinDelegate, BestQuoteViewDelegate, AppBackgroundDelegate, ZaiAnalyticsDelegate, PositionDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.fundLabel.text = "-"
        self.lossLimitLabel.text = self.lossLimit.description
        self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
        self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
        
        self.candleChartView = CandleChartView()
        self.candleChartView.delegate = self
        
        self.bestQuoteView = BestQuoteView(view: bestQuoteTableView)
        self.bestQuoteView.delegate = self
        
        self.chartSelectorView.backgroundColor = Color.keyColor2
        self.heilightChartButton(type: getChartConfig().selectedCandleChartType)
        
        self.candleStickChartView.legend.enabled = false
        self.candleStickChartView.chartDescription?.enabled = false
        self.candleStickChartView.maxVisibleCount = 60
        self.candleStickChartView.pinchZoomEnabled = false
        
        self.candleStickChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        self.candleStickChartView.xAxis.drawGridLinesEnabled = false
        self.candleStickChartView.xAxis.labelCount = 5
        self.candleStickChartView.xAxis.granularityEnabled = true
        
        self.candleStickChartView.leftAxis.enabled = false
        
        self.candleStickChartView.rightAxis.labelCount = 5
        self.candleStickChartView.rightAxis.drawGridLinesEnabled = true
        self.candleStickChartView.rightAxis.drawAxisLineEnabled = true
        
        let account = getAccount()!
        let api = account.activeExchange.api
        self.bollingerChartAve = CandleChart(chartName: "bollingerAve", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart1L = CandleChart(chartName: "bollinger1L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart1U = CandleChart(chartName: "bollinger1U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart2L = CandleChart(chartName: "bollinger2L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart2U = CandleChart(chartName: "bollinger2U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart3L = CandleChart(chartName: "bollinger3L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart3U = CandleChart(chartName: "bollinger3U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart5L = CandleChart(chartName: "bollinger5L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart5U = CandleChart(chartName: "bollinger5U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        
        self.autoSwitch.isOn = false
        self.analyticsClient.delegate = self
        
        if let prevController = getActiveChartController() {
            prevController.unsetTimer()
        }
        if self.autoSwitch.isOn {
            //self.analyticsClient.open()
            self.setTimer()
        } else {
            //self.analyticsClient.close()
            self.unsetTimer()
        }
        setActiveChartController(controller: self)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.start()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //self.stop()
    }
    
    fileprivate func start() {
        setBackgroundDelegate(delegate: self)
        let account = getAccount()!
        let api = account.activeExchange.api
        if self.fund == nil {
            self.fund = Fund(api: api)
            self.fund.delegate = self
        }
        self.fund.monitoringInterval = getAppConfig().footerUpdateIntervalType
        
        let config = getChartConfig()
        if self.bitcoin == nil {
            self.bitcoin = BitCoin(api: api)
            self.bitcoin.delegate = self
        }
        self.bitcoin.monitoringInterval = config.chartUpdateIntervalType
        
        if self.zaifBtc == nil {
            self.zaifBtc = BitCoin(api: account.getExchange(exchangeName: "Zaif")!.api)
        }
        if self.bfBtc == nil {
            self.bfBtc = BitCoin(api: account.getExchange(exchangeName: "bitFlyer")!.api)
        }

        self.candleChartView.deactivateCharts()
        self.candleChartView.activateChart(chartName: account.activeExchangeName, interval: config.chartUpdateIntervalType)
        //self.candleChartView.activateChart(chartName: "bitFlyer", interval: config.chartUpdateIntervalType)
        self.candleChartView.switchChartIntervalType(type: config.selectedCandleChartType)
        
        let trader = account.activeExchange.trader
        trader.startWatch()
        
        if self.gapMonTimer == nil {
            self.gapMonTimer = Timer.scheduledTimer(
                timeInterval: 10.0,
                target: self,
                selector: #selector(ChartViewController.updateAnalytics),
                userInfo: nil,
                repeats: true)
        }
        if self.volMonTimer == nil {
            self.volMonTimer = Timer.scheduledTimer(
                timeInterval: 900.0,
                target: self,
                selector: #selector(ChartViewController.checkVolatility),
                userInfo: nil,
                repeats: true)
        }
        if self.buyThread == nil {
            self.buyThread = Timer.scheduledTimer(
                timeInterval: 10.0,
                target: self,
                selector: #selector(ChartViewController.buy),
                userInfo: nil,
                repeats: true)
        }
        if self.sellThread == nil {
            self.sellThread = Timer.scheduledTimer(
                timeInterval: 20.0,
                target: self,
                selector: #selector(ChartViewController.sell),
                userInfo: nil,
                repeats: true)
        }
    }
    
    fileprivate func stop() {
        if self.fund != nil {
            self.fund.delegate = nil
            self.fund = nil
        }
        if self.bitcoin != nil {
            self.bitcoin.delegate = nil
            self.bitcoin = nil
        }
        
        if self.zaifBtc != nil {
            self.zaifBtc = nil
        }
        if self.bfBtc != nil {
            self.bfBtc = nil
        }
    }
    
    // CandleChartViewDelegate
    func recievedChart(chartData: CandleChartData, xFormatter: XValueFormatter, yFormatter: YValueFormatter, chart: CandleChart, shifted: Bool) {
        
        guard let chartView = self.candleStickChartView else {
            return
        }
        
        var bollingerL = self.bollingerChartAve
        if self.levelLower == 1 {
            bollingerL = self.bollingerChart1L
        } else if self.levelLower == 2 {
            bollingerL = self.bollingerChart2L
        } else if self.levelLower == 3 {
            bollingerL = self.bollingerChart3L
        } else if self.levelLower == 5 {
            bollingerL = self.bollingerChart5L
        }
        var entriesL = [CandleChartDataEntry]()
        for i in 0 ..< bollingerL!.candles.count {
            let candle = bollingerL!.candles[i]
            if !candle.isEmpty {
                let h = candle.lastPrice
                let l = candle.lastPrice
                let o = candle.lastPrice
                let lp = candle.lastPrice
                let entry = CandleChartDataEntry(x: Double(i), shadowH: h!, shadowL: l!, open: o!, close: lp!)
                entriesL.append(entry)
            }
        }
        
        let dataSetL = CandleChartDataSet(values: entriesL, label: "data")
        dataSetL.axisDependency = YAxis.AxisDependency.left;
        dataSetL.shadowColorSameAsCandle = true
        dataSetL.shadowWidth = 0.7
        dataSetL.decreasingColor = UIColor.black
        dataSetL.decreasingFilled = true
        dataSetL.increasingColor = UIColor.black
        dataSetL.increasingFilled = true
        dataSetL.neutralColor = UIColor.red
        dataSetL.setDrawHighlightIndicators(false)
        
        var bollingerU = self.bollingerChartAve
        if self.levelUpper == 1 {
            bollingerU = self.bollingerChart1U
        } else if self.levelUpper == 2 {
            bollingerU = self.bollingerChart2U
        } else if self.levelUpper == 3 {
            bollingerU = self.bollingerChart3U
        } else if self.levelUpper == 5 {
            bollingerU = self.bollingerChart5U
        }
        var entriesU = [CandleChartDataEntry]()
        for i in 0 ..< bollingerU!.candles.count {
            let candle = bollingerU!.candles[i]
            if !candle.isEmpty {
                let h = candle.lastPrice
                let l = candle.lastPrice
                let o = candle.lastPrice
                let lp = candle.lastPrice
                let entry = CandleChartDataEntry(x: Double(i), shadowH: h!, shadowL: l!, open: o!, close: lp!)
                entriesU.append(entry)
            }
        }
        
        let dataSetU = CandleChartDataSet(values: entriesU, label: "data")
        dataSetU.axisDependency = YAxis.AxisDependency.left;
        dataSetU.shadowColorSameAsCandle = true
        dataSetU.shadowWidth = 0.7
        dataSetU.decreasingColor = UIColor.black
        dataSetU.decreasingFilled = true
        dataSetU.increasingColor = UIColor.black
        dataSetU.increasingFilled = true
        dataSetU.neutralColor = UIColor.red
        dataSetU.setDrawHighlightIndicators(false)
        
        var dataSets = [IChartDataSet]()
        for dataSet in chartData.dataSets {
            dataSets.append(dataSet)
        }
        if dataSetL.entryCount > 0 {
            dataSets.append(dataSetL)
        }
        if dataSetU.entryCount > 0 {
            dataSets.append(dataSetU)
        }

        let data = CandleChartData(dataSets: dataSets)

        chartView.xAxis.valueFormatter = xFormatter
        chartView.rightAxis.valueFormatter = YValueFormatter()
        chartView.data = data
    }
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "ChartViewController"
    }
    
    // FundDelegate
    func recievedJpyFund(jpy: Int, available: Int) {
        self.availableJpy = available
        DispatchQueue.main.async {
            self.fundLabel.text = formatValue(self.availableJpy)
        }
    }
    
    // BitCoinDelegate
    func recievedBestJpyBid(price: Int, amount: Double) {
        let quote = Quote(price: Double(price), amount: amount, type: .BID)
        self.bestQuoteView.setBestBid(quote: quote)
    }
    
    func recievedBestJpyAsk(price: Int, amount: Double) {
        let quote = Quote(price: Double(price), amount: amount, type: .ASK)
        self.bestQuoteView.setBestAsk(quote: quote)
    }
    
    // BestQuoteViewDelegate
    func orderBuy(quote: Quote, callback: @escaping () -> Void) {
        let price = quote.price
        let amount = quote.amount
        
        guard let trader = getAccount()?.activeExchange.trader else {
            callback()
            return
        }
        
        trader.createLongPosition(.BTC_JPY, price: price, amount: amount) { (err, position) in
            DispatchQueue.main.async {
                callback()
                if let e = err {
                    print(e.message)
                    let errorView = createErrorModal(title: e.errorType.toString(), message: e.message)
                    self.present(errorView, animated: false, completion: nil)
                }
            }
        }
    }
    
    // PositionDelegate
    func opendPosition(position: Position, promisedOrder: PromisedOrder) {
        let intSigma = Int(self.stdZaif.sigma1Upper)
        let price = intSigma - (intSigma % 5)
        position.unwind(nil, price: Double(price)) { (_, _) in }
    }
    func unwindPosition(position: Position, promisedOrder: PromisedOrder) {
        
    }
    func closedPosition(position: Position, promisedOrder: PromisedOrder?) {
        
    }

    func orderSell(quote: Quote, callback: @escaping () -> Void) {
        guard let trader = getAccount()?.activeExchange.trader else {
            callback()
            return
        }
        guard let bestBid = self.bestQuoteView.getBestBid() else {
            callback()
            return
        }
        
        let price = quote.price
        let amount = quote.amount
        let rule = getAppConfig().unwindingRuleType
        trader.ruledUnwindPosition(price: price, amount: amount, marketPrice: bestBid.price, rule: rule) { (err, position, orderedAmount) in
            callback()
            if let e = err {
                let errorView = createErrorModal(message: e.message)
                self.present(errorView, animated: false, completion: nil)
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
    
    // BoardDelegate
    func recievedBoard(err: ZaiErrorType?, board: Board?, sender: Any?) {
        let askMomentum = board!.calculateAskMomentum()
        let bidMomentum = board!.calculateBidMomentum()
        let pres = bidMomentum / (askMomentum + bidMomentum)
        self.pressureHistory.append(pres)
        if self.pressureHistory.count > 5 {
            self.pressureHistory = Array(self.pressureHistory.suffix(5))
        }
        var sum = 0.0
        for val in self.pressureHistory {
            sum += val
        }
        self.bidPressure = sum / Double(self.pressureHistory.count)
        
        self.fiveMinutesButton.setTitle(self.bidPressure.description, for: UIControlState.normal)
    }
    
    func firedBuySignal(price: Double, amount: Double) {
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        trader.createLongPosition(.BTC_JPY, price: price, amount: amount) { (err, position) in
            DispatchQueue.main.async {
                if let e = err {
                    print(e.message)
                }
            }
        }
    }
    
    func firedBuySignalDual(price: Double, amount: Double, sellPrice: Double) {
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        trader.createLongPosition(.BTC_JPY, price: price, amount: amount) { (err, position) in
            DispatchQueue.main.async {
                if let e = err {
                    print(e.message)
                } else {
                    //position?.delegate2 = self
                }
            }
        }
    }
    
    // ZaiAnalyticsDelegate
    func recievedBuySignal() {
        /*
        if self.bidPressure < 0.6 {
            print("low pressure: " + self.bidPressure.description)
            return
        }
        print("high pressure: " + self.bidPressure.description)
        */
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        guard let bestAsk = self.bestQuoteView.getBestAsk() else {
            return
        }
        
        //let amount = Double(self.availableJpy) * 0.5 / bestAsk.price
        /*
        var amt = 0.2
        if bestAsk.amount < amt {
            amt = bestAsk.amount
        }
        */
        
        trader.createLongPosition(.BTC_JPY, price: bestAsk.price, amount: bestAsk.amount) { (err, position) in
            DispatchQueue.main.async {
                if let e = err {
                    print(e.message)
                }
            }
        }
        
        /*
        sleep(UInt32(getChartConfig().chartUpdateIntervalType.int))
        
        guard let bestAsk2 = self.bestQuoteView.getBestAsk() else {
            return
        }
        
        trader.createLongPosition(.BTC_JPY, price: bestAsk2.price, amount: bestAsk2.amount) { (err, position) in
            DispatchQueue.main.async {
                if let e = err {
                    print(e.message)
                }
            }
        }
 */
    }
    
    func firedSellSignal() {
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        guard let bestBid = self.bestQuoteView.getBestBid() else {
            return
        }
        
        trader.calncelAllBuyOrders()
        
        DispatchQueue.main.async {
            trader.unwindAllPositions(price: bestBid.price) { (err, position, orderedAmount) in
                if let e = err {
                    print(e.message)
                }
            }
        }
    }
    
    func forceSell() {
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        trader.cancelAllOrders()
        
        trader.unwindAllPositions(price: nil) { (err, position, orderedAmount) in
            if let e = err {
                print(e.message)
            }
        }
    }
    
    func recievedSellSignal() {
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        guard let bestBid = self.bestQuoteView.getBestBid() else {
            return
        }
        trader.cancelAllOrders()
        
        DispatchQueue.main.async {
            trader.unwindAllPositions(price: bestBid.price) { (err, position, orderedAmount) in
                if let e = err {
                    print(e.message)
                }
            }
        }
        
        /*
        let rule = getAppConfig().unwindingRuleType
        trader.ruledUnwindPosition(price: bestBid.price, amount: bestBid.amount, marketPrice: bestBid.price, rule: rule) { (err, position, orderedAmount) in
            if let e = err {
                print(e.message)
            }
        }
 */
    }
    
    fileprivate func setTimer() {
        if self.timer == nil {
            self.oneMinuteButton.setTitle(self.interval.description, for: UIControlState.normal)
            self.timer = Timer.scheduledTimer(
                timeInterval: 7.0,
                target: self,
                selector: #selector(ChartViewController.checkGap3Sigma),
                userInfo: nil,
                repeats: true)
        }
        
        if self.lossTimer == nil {
            self.lossTimer = Timer.scheduledTimer(
                timeInterval: 3.0,
                target: self,
                selector: #selector(ChartViewController.lossCut),
                userInfo: nil,
                repeats: true)
        }
        
        if self.cleanupTimer == nil {
            self.cleanupTimer = Timer.scheduledTimer(
                timeInterval: 300.0,
                target: self,
                selector: #selector(ChartViewController.cleanup),
                userInfo: nil,
                repeats: true)
        }
        
    }
    
    fileprivate func unsetTimer() {
        self.timer?.invalidate()
        self.timer = nil
        
        self.lossTimer?.invalidate()
        self.lossTimer = nil
        
        self.purgeTimer?.invalidate()
        self.purgeTimer = nil
        
        self.cleanupTimer?.invalidate()
        self.cleanupTimer = nil
    }
    
    @objc fileprivate func checkVolatility() {
        DispatchQueue.main.async {
            self.levelLower = 0
            if self.isSigma1LowerReached {
                self.levelLower = 1
                self.isSigma1LowerReached = false
            }
            if self.isSigma2LowerReached {
                self.levelLower = 2
                self.isSigma2LowerReached = false
            }
            if self.isSigma3LowerReached {
                self.levelLower = 3
                self.isSigma3LowerReached = false
            }
            
            self.levelUpper = 0
            if self.isSigma1UpperReached {
                self.levelUpper = 1
                self.isSigma1UpperReached = false
            }
            if self.isSigma2UpperReached {
                self.levelUpper = 2
                self.isSigma2UpperReached = false
            }
            if self.isSigma3UpperReached {
                self.levelUpper = 3
                self.isSigma3UpperReached = false
            }
            
            self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
            self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
        }
    }
    
    @objc fileprivate func updateAnalytics() {
        if getAccount()!.activeExchangeName != "Zaif" {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
                return
            }
            DispatchQueue.main.async {
                
                self.stdZaif.add(sample: zaifPrice)
                
                var trade = Trade(id: "", price: self.stdZaif.sigma1Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart1L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma1Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart1U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma2Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart2L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma2Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart2U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma3Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart3L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma3Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart3U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma5Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart5L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma5Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart5U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.ave, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChartAve.addTrade(trade: trade)
            }
        }
    }
    
    @objc fileprivate func checkGap3Sigma() {
        if getAccount()!.activeExchangeName != "Zaif" {
            return
        }
        if self.stdZaif.samples.count == 0 {
            return
        }
        DispatchQueue.main.async {
            var sigma3L = self.stdZaif.ave
            if self.levelLower == 1 {
                sigma3L = self.stdZaif.sigma1Lower
            } else if self.levelLower == 2 {
                sigma3L = self.stdZaif.sigma2Lower
            } else if self.levelLower == 3 {
                sigma3L = self.stdZaif.sigma3Lower
            } else if self.levelLower == 5 {
                sigma3L = self.stdZaif.sigma5Lower
            }
            var sigma3U = self.stdZaif.ave
            if self.levelUpper == 1 {
                sigma3U = self.stdZaif.sigma1Upper
            } else if self.levelUpper == 2 {
                sigma3U = self.stdZaif.sigma2Upper
            } else if self.levelUpper == 3 {
                sigma3U = self.stdZaif.sigma3Upper
            } else if self.levelUpper == 5 {
                sigma3U = self.stdZaif.sigma5Upper
            }

            let zaifPrice = self.stdZaif.samples.last!
            
            self.bfPrice.text = "None"
            self.lossLimitLabel.text = "None"
            self.buyPrice.text = Int(sigma3L).description
            self.sellPrice.text = Int(sigma3U).description
            
            if self.stdZaif.samples.count < 10 {
                self.thirtyMinutesButton.setTitle("Prepare", for: UIControlState.normal)
                return
            }
            self.thirtyMinutesButton.setTitle("Active", for: UIControlState.normal)
            
            
            if zaifPrice <= sigma3L {
                self.queueForSell.async {
                    self.sellQueue.removeAll()
                }
                self.queueForBuy.async {
                    self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                }
                
                self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
            } else if zaifPrice >= sigma3U {
                self.queueForBuy.async {
                    self.buyQueue.removeAll()
                }
                self.queueForSell.async {
                    self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                }
                self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
            }
            
            
            if zaifPrice <= self.stdZaif.sigma3Lower {
                self.isSigma3LowerReached = true
            }
            if zaifPrice >= self.stdZaif.sigma3Upper {
                self.isSigma3UpperReached = true
            }
            if zaifPrice <= self.stdZaif.sigma2Lower {
                self.isSigma2LowerReached = true
            }
            if zaifPrice >= self.stdZaif.sigma2Upper {
                self.isSigma2UpperReached = true
            }
            if zaifPrice <= self.stdZaif.sigma1Lower {
                self.isSigma1LowerReached = true
            }
            if zaifPrice >= self.stdZaif.sigma1Upper {
                self.isSigma1UpperReached = true
            }
        }
    }
    
    @objc fileprivate func buy() {
        self.queueForBuy.async {
            if self.buyQueue.count == 0 {
                return
            }
            let quote = self.buyQueue.removeFirst()
            self.firedBuySignal(price: quote.price, amount: quote.amount)
        }
    }

    @objc fileprivate func sell() {
        self.queueForSell.async {
            if self.sellQueue.count == 0 {
                return
            }
            let _ = self.sellQueue.removeFirst()
            self.recievedSellSignal()
        }
    }
    
    @objc fileprivate func lossCut() {
        if self.stdZaif.samples.count == 0 {
            return
        }
        if self.priceAtBuy <= 0 {
            return
        }
        DispatchQueue.main.async {
            let zaifPrice = self.stdZaif.samples.last!
            if zaifPrice <= self.lossLimit {
                if self.lossTimer == nil {
                    return
                }
                //self.lossTimer?.invalidate()
                //self.lossTimer = nil
                self.forceSell()
                
                if self.purgeTimer == nil {
                    self.thirtyMinutesButton.setTitle("Purge", for: UIControlState.normal)
                    
                    self.levelLower = 5
                    self.levelUpper = 5
                    self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
                    self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
                    
                    self.purgeTimer = Timer.scheduledTimer(
                        timeInterval: 10.0,
                        target: self,
                        selector: #selector(ChartViewController.purge),
                        userInfo: nil,
                        repeats: true)
                }
            }
        }
    }
    
    @objc fileprivate func purge() {
        DispatchQueue.main.async {
            let account = getAccount()!
            let count = account.activeExchange.trader.activePositions.count
            if count == 0 {
                self.purgeTimer?.invalidate()
                self.purgeTimer = nil
                self.thirtyMinutesButton.setTitle("", for: UIControlState.normal)
                return
            } else {
                if self.purgeTimer == nil {
                    return
                }
                self.forceSell()
            }
        }
    }
    
    @IBAction func puschEmergencyButton(_ sender: Any) {
        recievedSellSignal()
    }
    
    fileprivate func heilightChartButton(type: ChandleChartType) {
        self.oneMinuteButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.oneMinuteButton.isEnabled = true
        self.fiveMinutesButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.fiveMinutesButton.isEnabled = true
        self.fifteenMinutesButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.fifteenMinutesButton.isEnabled = true
        self.thirtyMinutesButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        self.thirtyMinutesButton.isEnabled = true
        switch type {
        case .oneMinute:
            self.oneMinuteButton.setTitleColor(Color.antiKeyColor2, for: UIControlState.normal)
            self.oneMinuteButton.isEnabled = false
        case .fiveMinutes:
            self.fiveMinutesButton.setTitleColor(Color.antiKeyColor2, for: UIControlState.normal)
            self.fiveMinutesButton.isEnabled = false
        case .fifteenMinutes:
            self.fifteenMinutesButton.setTitleColor(Color.antiKeyColor2, for: UIControlState.normal)
            self.fifteenMinutesButton.isEnabled = false
        case .thirtyMinutes:
            self.thirtyMinutesButton.setTitleColor(Color.antiKeyColor2, for: UIControlState.normal)
            self.thirtyMinutesButton.isEnabled = false
        }
    }
    
    @objc fileprivate func cleanup() {
        DispatchQueue.main.async {
            let account = getAccount()!
            let count = account.activeExchange.trader.activePositions.count
            if count > 0 {
                return
            }
            
            self.purgeTimer?.invalidate()
            self.purgeTimer = nil
            
            self.thirtyMinutesButton.setTitle("CleanUp", for: UIControlState.normal)
            self.fund.getBtcFund() { (err, btc) in
                let api = account.activeExchange.api
                if btc.available < api.orderUnit(currencyPair: .BTC_JPY) {
                    return
                }
                let order = OrderRepository.getInstance().createSellOrder(currencyPair: .BTC_JPY, price: nil, amount: btc.available, api: api)
                order.excute() { (_, _) in }
            }
        }
    }
    
    @IBAction func pushOneMinuteChart(_ sender: Any) {
        let type = ChandleChartType.oneMinute
        self.candleChartView.switchChartIntervalType(type: type)
        self.heilightChartButton(type: type)
        let config = getChartConfig()
        config.selectedCandleChartType = type
    }
    
    @IBAction func pushFiveMinutesChart(_ sender: Any) {
        let type = ChandleChartType.fiveMinutes
        self.candleChartView.switchChartIntervalType(type: type)
        self.heilightChartButton(type: type)
        let config = getChartConfig()
        config.selectedCandleChartType = type
    }
    
    @IBAction func pushFifteenMinutesChart(_ sender: Any) {
        let type = ChandleChartType.fifteenMinutes
        self.candleChartView.switchChartIntervalType(type: type)
        self.heilightChartButton(type: type)
        let config = getChartConfig()
        config.selectedCandleChartType = type
    }
    
    @IBAction func pushThirtyMinutesChart(_ sender: Any) {
        let type = ChandleChartType.thirtyMinutes
        self.candleChartView.switchChartIntervalType(type: type)
        self.heilightChartButton(type: type)
        let config = getChartConfig()
        config.selectedCandleChartType = type
    }
    
    @IBAction func pushSettingsButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let settings = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! UINavigationController
        self.present(settings, animated: true, completion: nil)
    }

    @IBAction func switchAuto(_ sender: Any) {
        let swtch = sender as! UISwitch
        if swtch.isOn {
            //self.analyticsClient.open()
            self.setTimer()
        } else {
            //self.analyticsClient.close()
            self.unsetTimer()
        }
    }
    @IBAction func pushZaifButton(_ sender: Any) {
        let account = getAccount()!
        account.setActiveExchange(exchangeName: "Zaif")
        self.stop()
        self.start()
    }
    @IBAction func pushBFButton(_ sender: Any) {
        let account = getAccount()!
        account.setActiveExchange(exchangeName: "bitFlyer")
        self.stop()
        self.start()
    }
    @IBAction func pushCleanupButton(_ sender: Any) {
        cleanup()
    }
    @IBAction func pushLvButton(_ sender: Any) {
        if self.levelLower == 1 {
            self.levelLower = 2
        } else if self.levelLower == 2 {
            self.levelLower = 3
        } else if self.levelLower == 3 {
            self.levelLower = 0
        } else if self.levelLower == 0{
            self.levelLower = 1
        }
        self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
    }
    @IBAction func pushUpperLvButton(_ sender: Any) {
        if self.levelUpper == 1 {
            self.levelUpper = 2
        } else if self.levelUpper == 2 {
            self.levelUpper = 3
        } else if self.levelUpper == 3 {
            self.levelUpper = 0
        } else if self.levelUpper == 0{
            self.levelUpper = 1
        }
        self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
    }

    
    fileprivate var fund: Fund!
    fileprivate var bitcoin: BitCoin!
    fileprivate var availableJpy = 0

    fileprivate var bidPressure = 0.0
    fileprivate var pressureHistory = [Double]()
    
    fileprivate var isFirstTick = false
    fileprivate var isSecondTick = false
    
    var interval = 20.0
    var minInterval = 20.0
    var zaifBtc: BitCoin!
    var bfBtc: BitCoin!
    var timer: Timer?
    var lossTimer: Timer?
    var purgeTimer: Timer?
    var cleanupTimer: Timer?
    var gapMonTimer: Timer?
    var volMonTimer: Timer?
    var isLargeGap = false
    var lowerGap = 100.0
    var upperGap = 50.0
    
    var buyThread: Timer?
    var buyQueue = [Quote]()
    let queueForBuy = DispatchQueue(label: "queueForBuy")
    var sellThread: Timer?
    var sellQueue = [Quote]()
    let queueForSell = DispatchQueue(label: "queueForSell")
    
    var bollingerChartAve: CandleChart!
    var bollingerChart1L: CandleChart!
    var bollingerChart1U: CandleChart!
    var bollingerChart2L: CandleChart!
    var bollingerChart2U: CandleChart!
    var bollingerChart3L: CandleChart!
    var bollingerChart3U: CandleChart!
    var bollingerChart5L: CandleChart!
    var bollingerChart5U: CandleChart!
    
    var levelUpper = 2
    var levelLower = 2
    
    var isSigma3LowerReached = false
    var isSigma3UpperReached = false
    var isSigma2LowerReached = false
    var isSigma2UpperReached = false
    var isSigma1LowerReached = false
    var isSigma1UpperReached = false
    
    var lossLimit = 30.0
    var minLossLimit = 30.0
    
    var isBear = false
    var priceAtBuy = -1.0
    var gaps = [Double]()
    let gapSize = 20
    let aveSize = 10
    var curZaif = 0.0
    var curBf = 0.0
    var quietZone = 50.0
    var highLowGapLimit = 20.0
    
    var orderTurn = true
    
    var stdZaif = Bollinger(size: 120)
    var stdBf = Bollinger(size: 120)
    var stdGap = Bollinger(size: 120)
    
    var candleChartView: CandleChartView!
    var bestQuoteView: BestQuoteView!
    var analyticsClient = ZaiAnalyticsClient()

    @IBOutlet weak var chartSelectorView: UIView!
    @IBOutlet weak var candleStickChartView: CandleStickChartView!
    
    @IBOutlet weak var oneMinuteButton: UIButton!
    @IBOutlet weak var fiveMinutesButton: UIButton!
    @IBOutlet weak var thirtyMinutesButton: UIButton!
    @IBOutlet weak var fifteenMinutesButton: UIButton!
    
    @IBOutlet weak var fundLabel: UILabel!
    @IBOutlet weak var bestQuoteTableView: UITableView!
    
    @IBOutlet weak var autoSwitch: UISwitch!
    @IBOutlet weak var lossLimitLabel: UILabel!
    @IBOutlet weak var bfPrice: UILabel!
    @IBOutlet weak var buyPrice: UILabel!
    @IBOutlet weak var sellPrice: UILabel!

    @IBOutlet weak var levelButton: UIButton!
    @IBOutlet weak var upperLevelButton: UIButton!

}


class Bollinger {
    init(size: Int) {
        self.size = size
    }
    
    func add(sample: Double) {
        self.samples.append(sample)
        if (self.samples.count > self.size) {
            self.samples.removeFirst()
        }
        self.ave = self.samples.reduce(0.0, +) / Double(self.samples.count)
        let ave2 = pow(self.ave, 2)
        let samples2 = self.samples.map { pow($0, 2) }
        let samples2Ave = samples2.reduce(0.0, +) / Double(samples2.count)
        self.sd = sqrt(samples2Ave - ave2)
    }
    
    var sigma1Upper: Double {
        return self.ave + self.sd
    }
    var sigma1Lower: Double {
        return self.ave - self.sd
    }
    var sigma2Upper: Double {
        return self.ave + self.sd * 2.0
    }
    var sigma2Lower: Double {
        return self.ave - self.sd * 2.0
    }
    var sigma3Upper: Double {
        return self.ave + self.sd * 3.0
    }
    var sigma3Lower: Double {
        return self.ave - self.sd * 3.0
    }
    var sigma4Upper: Double {
        return self.ave + self.sd * 4.0
    }
    var sigma4Lower: Double {
        return self.ave - self.sd * 4.0
    }
    var sigma5Upper: Double {
        return self.ave + self.sd * 5.0
    }
    var sigma5Lower: Double {
        return self.ave - self.sd * 5.0
    }
    
    let size: Int
    var samples = [Double]()
    var ave = 0.0
    var sd = 0.0
}
