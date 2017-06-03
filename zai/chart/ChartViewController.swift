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
        self.bollingerChart15L = CandleChart(chartName: "bollinger15L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart05U = CandleChart(chartName: "bollinger1U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart1U = CandleChart(chartName: "bollinger1U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart2L = CandleChart(chartName: "bollinger2L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart25L = CandleChart(chartName: "bollinger25L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart15U = CandleChart(chartName: "bollinger1U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart2U = CandleChart(chartName: "bollinger2U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart3L = CandleChart(chartName: "bollinger3L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart35L = CandleChart(chartName: "bollinger35L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart25U = CandleChart(chartName: "bollinger1U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart3U = CandleChart(chartName: "bollinger3U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart4L = CandleChart(chartName: "bollinger4L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart45L = CandleChart(chartName: "bollinger45L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart35U = CandleChart(chartName: "bollinger1U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart4U = CandleChart(chartName: "bollinger3U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart5L = CandleChart(chartName: "bollinger5L", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
        self.bollingerChart45U = CandleChart(chartName: "bollinger1U", currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 60, api: api)
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
                timeInterval: 5.0,
                target: self,
                selector: #selector(ChartViewController.updateAnalytics),
                userInfo: nil,
                repeats: true)
        }
        
        if self.volMonTimer == nil {
            self.volMonTimer = Timer.scheduledTimer(
                timeInterval: 1.0,
                target: self,
                selector: #selector(ChartViewController.checkVolatility),
                userInfo: nil,
                repeats: true)
        }
        if self.buyThread == nil {
            self.buyThread = Timer.scheduledTimer(
                timeInterval: 5.0,
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
        if self.fixProfitTimer == nil {
            self.sellThread = Timer.scheduledTimer(
                timeInterval: 2.0,
                target: self,
                selector: #selector(ChartViewController.fixProfit),
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
        
        self.lastCandle = chart.lastCandle
        
        var bollingerL = self.bollingerChartAve
        if self.levelLower == 1 {
            bollingerL = self.bollingerChart1L
        } else if self.levelLower == 2 {
            bollingerL = self.bollingerChart2L
        } else if self.levelLower == 3 {
            bollingerL = self.bollingerChart3L
        } else if self.levelLower == 4 {
            bollingerL = self.bollingerChart4L
        } else if self.levelLower == 5 {
            bollingerL = self.bollingerChart5L
        } else if self.levelLower == -1 {
            bollingerL = self.bollingerChart1U
        } else if self.levelLower == -2 {
            bollingerL = self.bollingerChart2U
        } else if self.levelLower == -3 {
            bollingerL = self.bollingerChart3U
        } else if self.levelLower == -4 {
            bollingerL = self.bollingerChart4U
        } else if self.levelLower == -5 {
            bollingerL = self.bollingerChart5U
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
            bollingerU = self.bollingerChart05U
        } else if self.levelUpper == 2 {
            bollingerU = self.bollingerChart1U
        } else if self.levelUpper == 3 {
            bollingerU = self.bollingerChart15U
        } else if self.levelUpper == 4 {
            bollingerU = self.bollingerChart2U
        } else if self.levelUpper == 5 {
            bollingerU = self.bollingerChart25U
        } else if self.levelUpper == 6 {
            bollingerU = self.bollingerChart3U
        } else if self.levelUpper == 7 {
            bollingerU = self.bollingerChart35U
        } else if self.levelUpper == 8 {
            bollingerU = self.bollingerChart4U
        } else if self.levelUpper == 9 {
            bollingerU = self.bollingerChart45U
        } else if self.levelUpper == 10 {
            bollingerU = self.bollingerChart5U
        } else if self.levelUpper == -1 {
            bollingerU = self.bollingerChart1L
        } else if self.levelUpper == -2 {
            bollingerU = self.bollingerChart2L
        } else if self.levelUpper == -3 {
            bollingerU = self.bollingerChart3L
        } else if self.levelUpper == -4 {
            bollingerU = self.bollingerChart4L
        } else if self.levelUpper == -5 {
            bollingerU = self.bollingerChart5L
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
        
        var bollingerB = self.bollingerChartAve
        if self.levelBear == 1 {
            bollingerB = self.bollingerChart05U
        } else if self.levelBear == 2 {
            bollingerB = self.bollingerChart1U
        } else if self.levelBear == 3 {
            bollingerB = self.bollingerChart15U
        } else if self.levelBear == 4 {
            bollingerB = self.bollingerChart2U
        } else if self.levelBear == 5 {
            bollingerB = self.bollingerChart25U
        } else if self.levelBear == 6 {
            bollingerB = self.bollingerChart3U
        } else if self.levelBear == 7 {
            bollingerB = self.bollingerChart35U
        } else if self.levelBear == 8 {
            bollingerB = self.bollingerChart4U
        } else if self.levelBear == 9 {
            bollingerB = self.bollingerChart45U
        } else if self.levelBear == 10 {
            bollingerB = self.bollingerChart5U
        } else if self.levelBear == -1 {
            bollingerB = self.bollingerChart15L
        } else if self.levelBear == -2 {
            bollingerB = self.bollingerChart25L
        } else if self.levelBear == -3 {
            bollingerB = self.bollingerChart35L
        } else if self.levelBear == -4 {
            bollingerB = self.bollingerChart45L
        } else if self.levelBear == -5 {
            bollingerB = self.bollingerChart5L
        }

        var entriesB = [CandleChartDataEntry]()
        for i in 0 ..< bollingerB!.candles.count {
            let candle = bollingerB!.candles[i]
            if !candle.isEmpty {
                let h = candle.lastPrice
                let l = candle.lastPrice
                let o = candle.lastPrice
                let lp = candle.lastPrice
                let entry = CandleChartDataEntry(x: Double(i), shadowH: h!, shadowL: l!, open: o!, close: lp!)
                entriesB.append(entry)
            }
        }
        
        let dataSetB = CandleChartDataSet(values: entriesB, label: "data")
        dataSetB.axisDependency = YAxis.AxisDependency.left;
        dataSetB.shadowColorSameAsCandle = true
        dataSetB.shadowWidth = 0.7
        dataSetB.decreasingColor = UIColor.black
        dataSetB.decreasingFilled = true
        dataSetB.increasingColor = UIColor.black
        dataSetB.increasingFilled = true
        dataSetB.neutralColor = UIColor.blue
        dataSetB.setDrawHighlightIndicators(false)
        
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
        if dataSetB.entryCount > 0 {
            dataSets.append(dataSetB)
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
                timeInterval: 1.0,
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
        self.volMonCounter -= 1
        self.lossLimitLabel.text = self.volMonCounter.description
        if self.volMonCounter > 0 {
            return
        }
        self.volMonCounter = self.volMonCount
        DispatchQueue.main.async {
            /*
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
            */
            
            
            let price = self.stdZaif.ave
            self.levelUpper = 10
            
            if price < self.stdZaif.sigma5Upper {
                self.levelUpper = 10
            }
            if price < self.stdZaif.sigma45Upper {
                self.levelUpper = 9
            }
            if price < self.stdZaif.sigma4Upper {
                self.levelUpper = 8
            }
            if price < self.stdZaif.sigma35Upper {
                self.levelUpper = 7
            }
            if price < self.stdZaif.sigma3Upper {
                self.levelUpper = 6
            }
            if price < self.stdZaif.sigma25Upper {
                self.levelUpper = 5
            }
            if price < self.stdZaif.sigma2Upper {
                self.levelUpper = 4
            }
            if price < self.stdZaif.sigma15Upper {
                self.levelUpper = 3
            }
            if price < self.stdZaif.sigma1Upper {
                self.levelUpper = 2
            }
            if price < self.stdZaif.sigma05Upper {
                self.levelUpper = 1
            }
            if price < self.stdZaif.ave {
                self.levelUpper = 0
            }
            if price < self.stdZaif.sigma1Lower {
                self.levelUpper = -2
            }
            if price < self.stdZaif.sigma2Lower {
                self.levelUpper = -3
            }
            if price < self.stdZaif.sigma3Lower {
                self.levelUpper = -4
            }
            if price < self.stdZaif.sigma4Lower {
                self.levelUpper = -5
            }
            
            
            /*
            if self.stdZaif.sigma5Lower < self.upperReachPrice {
                self.levelUpper = -4
            }
            if self.stdZaif.sigma4Lower < self.upperReachPrice {
                self.levelUpper = -3
            }
            if self.stdZaif.sigma3Lower < self.upperReachPrice {
                self.levelUpper = -2
            }
            if self.stdZaif.sigma2Lower < self.upperReachPrice {
                self.levelUpper = -1
            }
            if self.stdZaif.sigma1Lower < self.upperReachPrice {
                self.levelUpper = 0
            }
            
            if self.stdZaif.sigma05Upper < self.upperReachPrice {
                self.levelUpper = 1
            }
            if self.stdZaif.sigma1Upper < self.upperReachPrice {
                self.levelUpper = 2
            }
            if self.stdZaif.sigma15Upper < self.upperReachPrice {
                self.levelUpper = 3
            }
            if self.stdZaif.sigma2Upper < self.upperReachPrice {
                self.levelUpper = 4
            }
            if self.stdZaif.sigma25Upper < self.upperReachPrice {
                self.levelUpper = 5
            }
            if self.stdZaif.sigma3Upper < self.upperReachPrice {
                self.levelUpper = 6
            }
            if self.stdZaif.sigma35Upper < self.upperReachPrice {
                self.levelUpper = 7
            }
            if self.stdZaif.sigma4Upper < self.upperReachPrice {
                self.levelUpper = 8
            }
            if self.stdZaif.sigma45Upper < self.upperReachPrice {
                self.levelUpper = 9
            }
            if self.stdZaif.sigma5Upper < self.upperReachPrice {
                self.levelUpper = 10
            }*/
            
            self.levelLower = 0
            /*
            if self.lowerReachPrice < self.stdZaif.sigma5Upper {
                self.levelLower = -4
            }
            if self.lowerReachPrice < self.stdZaif.sigma4Upper {
                self.levelLower = -3
            }
            if self.lowerReachPrice < self.stdZaif.sigma3Upper {
                self.levelLower = -2
            }
            if self.lowerReachPrice < self.stdZaif.sigma2Upper {
                self.levelLower = -1
            }
            if self.lowerReachPrice < self.stdZaif.sigma1Upper {
                self.levelLower = 0
            }
            */
            if self.lowerReachPrice < self.stdZaif.sigma1Lower {
                self.levelLower = 1
            }
            if self.lowerReachPrice < self.stdZaif.sigma2Lower {
                self.levelLower = 2
            }
            if self.lowerReachPrice < self.stdZaif.sigma3Lower {
                self.levelLower = 3
            }
            if self.lowerReachPrice < self.stdZaif.sigma4Lower {
                self.levelLower = 4
            }
            if self.lowerReachPrice < self.stdZaif.sigma5Lower {
                self.levelLower = 5
            }
            
            self.lowerReachPrice = 99999999999.9
            self.upperReachPrice = 0.0
            
            self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
            self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
        }
    }
    
    @objc fileprivate func updateAnalytics() {
        guard let account = getAccount() else {
            return
        }
        if account.activeExchangeName != "Zaif" {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
                return
            }
            DispatchQueue.main.async {
                
                //self.stdZaif.add(sample: zaifPrice)
                
                guard let candle = self.lastCandle else {
                    return
                }
                self.stdZaif.add(sample: candle.priceAevrage!)
                
                var trade = Trade(id: "", price: self.stdZaif.sigma1Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart1L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma15Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart15L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma1Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart1U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma05Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart05U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma2Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart2L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma25Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart25L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma2Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart2U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma15Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart15U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma3Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart3L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma35Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart35L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma3Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart3U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma25Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart25U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma4Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart4L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma45Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart45L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma4Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart4U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma35Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart35U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma5Lower, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart5L.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma5Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart5U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.sigma45Upper, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChart45U.addTrade(trade: trade)
                trade = Trade(id: "", price: self.stdZaif.ave, amount: 0.0, currencyPair: ApiCurrencyPair.BTC_JPY.rawValue, action: "bid", timestamp: Int64(Date().timeIntervalSince1970))
                self.bollingerChartAve.addTrade(trade: trade)
            }
        }
    }
    
    /*　#1 弱気相場では買いと同時に売る
    @objc fileprivate func checkGap3Sigma() {
        if getAccount()!.activeExchangeName != "Zaif" {
            return
        }
        if self.stdZaif.samples.count == 0 {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
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
                    if self.levelUpper < self.levelLower {
                        self.thirtyMinutesButton.setTitle("BearBuy", for: UIControlState.normal)
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: -1, amount: 0.2, type: Quote.QuoteType.ASK))
                        }
                    } else {
                        self.queueForSell.async {
                            self.sellQueue.removeAll()
                        }
                        self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                    }
                    self.queueForBuy.async {
                        self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                    }
                    self.upLowerLevel()
                } else if zaifPrice >= sigma3U {
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                    }
                    self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                    self.upUpperLevel()
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
    }
    */
    
    /* #2 弱気相場では買わずに売る
    @objc fileprivate func checkGap3Sigma() {
        if getAccount()!.activeExchangeName != "Zaif" {
            return
        }
        if self.stdZaif.samples.count == 0 {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
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
                    if self.levelUpper < self.levelLower {
                        self.thirtyMinutesButton.setTitle("Bear", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                        }
                    } else {
                        self.queueForSell.async {
                            self.sellQueue.removeAll()
                        }
                        
                        self.queueForBuy.async {
                            self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                        }
                        self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                    }
                    
                    self.upLowerLevel()
                } else if zaifPrice >= sigma3U {
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                    }
                    self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                    self.upUpperLevel()
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
    }*/
    
    // BearLevelに達したら回下がらない
    /*
    @objc fileprivate func checkGap3Sigma() {
        if getAccount()!.activeExchangeName != "Zaif" {
            return
        }
        if self.stdZaif.samples.count == 0 {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
                return
            }
            DispatchQueue.main.async {
                var sigmaL = self.stdZaif.ave
                if self.levelLower == 1 {
                    sigmaL = self.stdZaif.sigma1Lower
                } else if self.levelLower == 2 {
                    sigmaL = self.stdZaif.sigma2Lower
                } else if self.levelLower == 3 {
                    sigmaL = self.stdZaif.sigma3Lower
                } else if self.levelLower == 5 {
                    sigmaL = self.stdZaif.sigma5Lower
                }
                var sigmaU = self.stdZaif.ave
                if self.levelUpper == 1 {
                    sigmaU = self.stdZaif.sigma1Upper
                } else if self.levelUpper == 2 {
                    sigmaU = self.stdZaif.sigma2Upper
                } else if self.levelUpper == 3 {
                    sigmaU = self.stdZaif.sigma3Upper
                } else if self.levelUpper == 5 {
                    sigmaU = self.stdZaif.sigma5Upper
                }
                var sigmaB = self.stdZaif.ave
                if self.levelBear == 1 {
                    sigmaB = self.stdZaif.sigma1Lower
                } else if self.levelBear == 2 {
                    sigmaB = self.stdZaif.sigma2Lower
                } else if self.levelBear == 3 {
                    sigmaB = self.stdZaif.sigma3Lower
                } else if self.levelBear == 4 {
                    sigmaB = self.stdZaif.sigma4Lower
                } else if self.levelBear == 5 {
                    sigmaB = self.stdZaif.sigma5Lower
                }
                
                self.bfPrice.text = Int(sigmaB).description
                self.buyPrice.text = Int(sigmaL).description
                self.sellPrice.text = Int(sigmaU).description
                
                if self.stdZaif.samples.count < 10 {
                    self.thirtyMinutesButton.setTitle("Prepare", for: UIControlState.normal)
                    return
                }
                self.thirtyMinutesButton.setTitle("Active", for: UIControlState.normal)
                
                if self.isBear {
                    self.thirtyMinutesButton.setTitle("Bear", for: UIControlState.normal)
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                    }
                } else if self.levelUpper < self.levelLower {
                    self.thirtyMinutesButton.setTitle("Bear", for: UIControlState.normal)
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                    }
                } else if zaifPrice <= sigmaB {
                    self.thirtyMinutesButton.setTitle("Bear", for: UIControlState.normal)
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                    }
                    //self.upLowerLevel()
                    self.isBear = true
                } else if zaifPrice <= sigmaL && zaifPrice > sigmaB {
                    self.queueForSell.async {
                        self.sellQueue.removeAll()
                    }
                    self.queueForBuy.async {
                        self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                    }
                    self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                } else if zaifPrice >= sigmaU {
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                    }
                    self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                    self.upUpperLevel()
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
    }*/
    
    /*
    @objc fileprivate func checkGap3Sigma() {
        if getAccount()!.activeExchangeName != "Zaif" {
            return
        }
        if self.stdZaif.samples.count == 0 {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
                return
            }
            DispatchQueue.main.async {
                var sigmaL = self.stdZaif.ave
                if self.levelLower == 1 {
                    sigmaL = self.stdZaif.sigma1Lower
                } else if self.levelLower == 2 {
                    sigmaL = self.stdZaif.sigma2Lower
                } else if self.levelLower == 3 {
                    sigmaL = self.stdZaif.sigma3Lower
                } else if self.levelLower == 5 {
                    sigmaL = self.stdZaif.sigma5Lower
                }
                var sigmaU = self.stdZaif.ave
                if self.levelUpper == 1 {
                    sigmaU = self.stdZaif.sigma1Upper
                } else if self.levelUpper == 2 {
                    sigmaU = self.stdZaif.sigma2Upper
                } else if self.levelUpper == 3 {
                    sigmaU = self.stdZaif.sigma3Upper
                } else if self.levelUpper == 5 {
                    sigmaU = self.stdZaif.sigma5Upper
                }
                var sigmaB = self.stdZaif.ave
                if self.levelBear == 1 {
                    sigmaB = self.stdZaif.sigma1Lower
                } else if self.levelBear == 2 {
                    sigmaB = self.stdZaif.sigma2Lower
                } else if self.levelBear == 3 {
                    sigmaB = self.stdZaif.sigma3Lower
                } else if self.levelBear == 4 {
                    sigmaB = self.stdZaif.sigma4Lower
                } else if self.levelBear == 5 {
                    sigmaB = self.stdZaif.sigma5Lower
                }
                
                self.bfPrice.text = Int(sigmaB).description
                self.buyPrice.text = Int(sigmaL).description
                self.sellPrice.text = Int(sigmaU).description
                
                if self.stdZaif.samples.count < 10 {
                    self.thirtyMinutesButton.setTitle("Prepare", for: UIControlState.normal)
                    return
                }
                
                if self.isBear {
                    self.thirtyMinutesButton.setTitle("Bear", for: UIControlState.normal)
                } else {
                    self.thirtyMinutesButton.setTitle("Active", for: UIControlState.normal)
                }
                
                if zaifPrice <= sigmaB {
                    self.thirtyMinutesButton.setTitle("Bear", for: UIControlState.normal)
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                    }
                    self.isBear = true
                } else if zaifPrice <= sigmaL && zaifPrice > sigmaB {
                    if self.isBear {
                        self.thirtyMinutesButton.setTitle("Bear", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                        }
                    } else if self.levelUpper < self.levelLower {
                        self.thirtyMinutesButton.setTitle("BearLevel", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                        }
                    } else {
                        self.queueForSell.async {
                            self.sellQueue.removeAll()
                        }
                        self.queueForBuy.async {
                            self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                        }
                        self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                    }
                } else if zaifPrice >= sigmaU {
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                    }
                    self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                    self.upUpperLevel()
                    if self.levelLower < self.levelUpper {
                        self.isBear = false
                    }
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
    }*/
    /*
    @objc fileprivate func checkGap3Sigma() {
        guard let account = getAccount() else {
            return
        }
        if account.activeExchangeName != "Zaif" {
            return
        }
        if self.stdZaif.samples.count == 0 {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
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
                } else if self.levelLower == 4 {
                    sigma3L = self.stdZaif.sigma4Lower
                } else if self.levelLower == 5 {
                    sigma3L = self.stdZaif.sigma5Lower
                } else if self.levelLower == -1 {
                    sigma3L = self.stdZaif.sigma1Upper
                } else if self.levelLower == -2 {
                    sigma3L = self.stdZaif.sigma2Upper
                } else if self.levelLower == -3 {
                    sigma3L = self.stdZaif.sigma3Upper
                } else if self.levelLower == -4 {
                    sigma3L = self.stdZaif.sigma4Upper
                } else if self.levelLower == -5 {
                    sigma3L = self.stdZaif.sigma5Upper
                }
                
                var sigma3U = self.stdZaif.ave
                if self.levelUpper == 1 {
                    sigma3U = self.stdZaif.sigma1Upper
                } else if self.levelUpper == 2 {
                    sigma3U = self.stdZaif.sigma2Upper
                } else if self.levelUpper == 3 {
                    sigma3U = self.stdZaif.sigma3Upper
                } else if self.levelUpper == 4 {
                    sigma3U = self.stdZaif.sigma4Upper
                } else if self.levelUpper == 5 {
                    sigma3U = self.stdZaif.sigma5Upper
                } else if self.levelUpper == -1 {
                    sigma3U = self.stdZaif.sigma1Lower
                } else if self.levelUpper == -2 {
                    sigma3U = self.stdZaif.sigma2Lower
                } else if self.levelUpper == -3 {
                    sigma3U = self.stdZaif.sigma3Lower
                } else if self.levelUpper == -4 {
                    sigma3U = self.stdZaif.sigma4Lower
                } else if self.levelUpper == -5 {
                    sigma3U = self.stdZaif.sigma5Lower
                }

                var sigmaB = self.stdZaif.ave
                if self.levelBear == 1 {
                    sigmaB = self.stdZaif.sigma05Upper
                } else if self.levelBear == 2 {
                    sigmaB = self.stdZaif.sigma15Upper
                } else if self.levelBear == 3 {
                    sigmaB = self.stdZaif.sigma25Upper
                } else if self.levelBear == 4 {
                    sigmaB = self.stdZaif.sigma35Upper
                } else if self.levelBear == 5 {
                    sigmaB = self.stdZaif.sigma45Upper
                }
                
                self.bfPrice.text = Int(sigmaB).description
                self.buyPrice.text = Int(sigma3L).description
                self.sellPrice.text = Int(sigma3U).description
                
                if self.stdZaif.samples.count < 10 {
                    self.thirtyMinutesButton.setTitle("Prepare", for: UIControlState.normal)
                    return
                }
                
                
                if self.isBull {
                    if zaifPrice <= sigmaB {
                        self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: zaifPrice, amount: -1.0, type: Quote.QuoteType.ASK))
                        }
                        self.levelLower = self.levelUpper
                        if self.levelLower > 5 {
                            self.levelLower = 5
                        }
                        self.isBull = false
                    } else {
                        self.thirtyMinutesButton.setTitle("Bull", for: UIControlState.normal)
                        
                        self.queueForSell.async {
                            self.sellQueue.removeAll()
                        }
                        self.queueForBuy.async {
                            self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                        }
                        self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                        if zaifPrice >= sigma3U {
                            self.upUpperLevel()
                            self.levelBear = self.levelUpper - 1
                        }
                    }
                } else {
                    
                    self.thirtyMinutesButton.setTitle("Active", for: UIControlState.normal)
                    
                    
                    if zaifPrice >= sigma3U {
                        self.upUpperLevel()
                        
                        self.queueForSell.async {
                            self.sellQueue.removeAll()
                        }
                        self.queueForBuy.async {
                            self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                        }
                        self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                        self.isBull = true
                        self.levelBear = self.levelUpper - 1
                    } else {
                        self.upLowerLevel()
                        
                        self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.ASK))
                        }
                    }
                    if zaifPrice <= sigma3L {
                        
                    } else {
                        
                    }
                    
                    if self.levelLower < self.levelUpper {
                        
                    } else {
                        
                    }
                }
                
                
                self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
                self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
                
                if zaifPrice < self.lowerReachPrice {
                    self.lowerReachPrice = zaifPrice
                }
                if self.upperReachPrice < zaifPrice {
                    self.upperReachPrice = zaifPrice
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
    }*/
    @objc fileprivate func checkGap3Sigma() {

        
        guard let account = getAccount() else {
            return
        }
        if account.activeExchangeName != "Zaif" {
            return
        }
        if self.stdZaif.samples.count == 0 {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
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
                } else if self.levelLower == 4 {
                    sigma3L = self.stdZaif.sigma4Lower
                } else if self.levelLower == 5 {
                    sigma3L = self.stdZaif.sigma5Lower
                } else if self.levelLower == -1 {
                    sigma3L = self.stdZaif.sigma1Upper
                } else if self.levelLower == -2 {
                    sigma3L = self.stdZaif.sigma2Upper
                } else if self.levelLower == -3 {
                    sigma3L = self.stdZaif.sigma3Upper
                } else if self.levelLower == -4 {
                    sigma3L = self.stdZaif.sigma4Upper
                } else if self.levelLower == -5 {
                    sigma3L = self.stdZaif.sigma5Upper
                }
                
                var sigma3U = self.stdZaif.ave
                if self.levelUpper == 1 {
                    sigma3U = self.stdZaif.sigma05Upper
                } else if self.levelUpper == 2 {
                    sigma3U = self.stdZaif.sigma1Upper
                } else if self.levelUpper == 3 {
                    sigma3U = self.stdZaif.sigma15Upper
                } else if self.levelUpper == 4 {
                    sigma3U = self.stdZaif.sigma2Upper
                } else if self.levelUpper == 5 {
                    sigma3U = self.stdZaif.sigma25Upper
                } else if self.levelUpper == 6 {
                    sigma3U = self.stdZaif.sigma3Upper
                } else if self.levelUpper == 7 {
                    sigma3U = self.stdZaif.sigma35Upper
                } else if self.levelUpper == 8 {
                    sigma3U = self.stdZaif.sigma4Upper
                } else if self.levelUpper == 9 {
                    sigma3U = self.stdZaif.sigma45Upper
                } else if self.levelUpper == 10 {
                    sigma3U = self.stdZaif.sigma5Upper
                } else if self.levelUpper == -1 {
                    sigma3U = self.stdZaif.sigma1Lower
                } else if self.levelUpper == -2 {
                    sigma3U = self.stdZaif.sigma2Lower
                } else if self.levelUpper == -3 {
                    sigma3U = self.stdZaif.sigma3Lower
                } else if self.levelUpper == -4 {
                    sigma3U = self.stdZaif.sigma4Lower
                } else if self.levelUpper == -5 {
                    sigma3U = self.stdZaif.sigma5Lower
                }
                
                var sigmaB = self.stdZaif.ave
                if self.levelBear == 1 {
                    sigmaB = self.stdZaif.sigma05Upper
                } else if self.levelBear == 2 {
                    sigmaB = self.stdZaif.sigma1Upper
                } else if self.levelBear == 3 {
                    sigmaB = self.stdZaif.sigma15Upper
                } else if self.levelBear == 4 {
                    sigmaB = self.stdZaif.sigma2Upper
                } else if self.levelBear == 5 {
                    sigmaB = self.stdZaif.sigma25Upper
                } else if self.levelBear == 6 {
                    sigmaB = self.stdZaif.sigma3Upper
                } else if self.levelBear == 7 {
                    sigmaB = self.stdZaif.sigma35Upper
                } else if self.levelBear == 8 {
                    sigmaB = self.stdZaif.sigma4Upper
                } else if self.levelBear == 9 {
                    sigmaB = self.stdZaif.sigma45Upper
                } else if self.levelBear == 10 {
                    sigmaB = self.stdZaif.sigma5Upper
                } else if self.levelBear == -1 {
                    sigmaB = self.stdZaif.sigma15Lower
                } else if self.levelBear == -2 {
                    sigmaB = self.stdZaif.sigma25Lower
                } else if self.levelBear == -3 {
                    sigmaB = self.stdZaif.sigma35Lower
                } else if self.levelBear == -4 {
                    sigmaB = self.stdZaif.sigma45Lower
                } else if self.levelBear == -5 {
                    sigmaB = self.stdZaif.sigma5Lower
                }
                
                let price = self.lastCandle!.priceAevrage!
                self.fifteenMinutesButton.setTitle(Int(price).description, for: UIControlState.normal)
                
                
                self.bfPrice.text = Int(sigmaB).description
                self.buyPrice.text = Int(sigma3L).description
                self.sellPrice.text = Int(sigma3U).description
                
                if self.stdZaif.samples.count < 10 {
                    self.thirtyMinutesButton.setTitle("Prepare", for: UIControlState.normal)
                    return
                }
                
                
                self.thirtyMinutesButton.setTitle("Active", for: UIControlState.normal)
                
                if price >= sigma3U {
                    self.upUpperLevel()
                    
                    self.levelBear = self.levelUpper - 3
                    if self.levelBear < -5 {
                        self.levelBear = -5
                    }
                } else if price <= sigma3L {
                    self.upLowerLevel()
                }
                if self.isBull {
                    if price <= sigmaB {
                        self.upLowerLevel()
                    }
                }
                
                let upLevel = Double(self.levelUpper) / 2.0
                
                if Double(self.levelLower) < upLevel {
                    self.thirtyMinutesButton.setTitle("Bull", for: UIControlState.normal)
                    
                    self.queueForBuy.async {
                        self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                    }
                    self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                    
                    self.isBull = true
                } else if Double(self.levelLower) > upLevel {
                    self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                    self.queueForBuy.async {
                        self.buyQueue.removeAll()
                    }
                    self.queueForSell.async {
                        self.sellQueue.append(Quote(price: sigmaB, amount: -1.0, type: Quote.QuoteType.ASK))
                    }
                    
                    self.isBull = false
                }
                
                /*
                if self.isBull {
                    if price <= sigmaB {
                        self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: sigmaB, amount: -1.0, type: Quote.QuoteType.ASK))
                        }
                        self.levelLower = self.levelUpper
                        if self.levelLower > 5 {
                            self.levelLower = 5
                        }
                        self.isBull = false
                    } else {
                        self.thirtyMinutesButton.setTitle("Bull", for: UIControlState.normal)
  
                        self.queueForBuy.async {
                            self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                        }
                        self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                        if price >= sigma3U {
                            self.upUpperLevel()
                            self.levelBear = self.levelUpper - 3
                            if self.levelBear < -5 {
                                self.levelBear = -5
                            }
                        }
                    }
                } else {
                    
                    self.thirtyMinutesButton.setTitle("Active", for: UIControlState.normal)
                    
                    
                    if price >= sigma3U {
                        self.upUpperLevel()
                        self.queueForSell.async {
                            self.sellQueue.removeAll()
                        }
                        self.queueForBuy.async {
                            self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                        }
                        self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                        self.isBull = true
                        self.levelBear = self.levelUpper - 3
                        if self.levelBear < -5 {
                            self.levelBear = -5
                        }
                    } else {
                        if price <= sigma3L {
                            self.upLowerLevel()
                        }
                        
                        self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: -1.0, amount: 0.2, type: Quote.QuoteType.ASK))
                        }
                    }
                }*/
                
                
                self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
                self.upperLevelButton.setTitle("ULv." + upLevel.description, for: UIControlState.normal)
                
                if zaifPrice < self.lowerReachPrice {
                    self.lowerReachPrice = zaifPrice
                }
                if self.upperReachPrice < zaifPrice {
                    self.upperReachPrice = zaifPrice
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
    }
    /*
    @objc fileprivate func checkGap3Sigma() {
        
        
        guard let account = getAccount() else {
            return
        }
        if account.activeExchangeName != "Zaif" {
            return
        }
        if self.stdZaif.samples.count == 0 {
            return
        }
        self.zaifBtc.getPriceFor(ApiCurrency.JPY) { (err, zaifPrice) in
            if err != nil {
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
                } else if self.levelLower == 4 {
                    sigma3L = self.stdZaif.sigma4Lower
                } else if self.levelLower == 5 {
                    sigma3L = self.stdZaif.sigma5Lower
                } else if self.levelLower == -1 {
                    sigma3L = self.stdZaif.sigma1Upper
                } else if self.levelLower == -2 {
                    sigma3L = self.stdZaif.sigma2Upper
                } else if self.levelLower == -3 {
                    sigma3L = self.stdZaif.sigma3Upper
                } else if self.levelLower == -4 {
                    sigma3L = self.stdZaif.sigma4Upper
                } else if self.levelLower == -5 {
                    sigma3L = self.stdZaif.sigma5Upper
                }
                
                var sigma3U = self.stdZaif.ave
                if self.levelUpper == 1 {
                    sigma3U = self.stdZaif.sigma1Upper
                } else if self.levelUpper == 2 {
                    sigma3U = self.stdZaif.sigma2Upper
                } else if self.levelUpper == 3 {
                    sigma3U = self.stdZaif.sigma3Upper
                } else if self.levelUpper == 4 {
                    sigma3U = self.stdZaif.sigma4Upper
                } else if self.levelUpper == 5 {
                    sigma3U = self.stdZaif.sigma5Upper
                } else if self.levelUpper == -1 {
                    sigma3U = self.stdZaif.sigma1Lower
                } else if self.levelUpper == -2 {
                    sigma3U = self.stdZaif.sigma2Lower
                } else if self.levelUpper == -3 {
                    sigma3U = self.stdZaif.sigma3Lower
                } else if self.levelUpper == -4 {
                    sigma3U = self.stdZaif.sigma4Lower
                } else if self.levelUpper == -5 {
                    sigma3U = self.stdZaif.sigma5Lower
                }
                
                var sigmaB = self.stdZaif.ave
                if self.levelBear == 1 {
                    sigmaB = self.stdZaif.sigma05Upper
                } else if self.levelBear == 2 {
                    sigmaB = self.stdZaif.sigma15Upper
                } else if self.levelBear == 3 {
                    sigmaB = self.stdZaif.sigma25Upper
                } else if self.levelBear == 4 {
                    sigmaB = self.stdZaif.sigma35Upper
                } else if self.levelBear == 5 {
                    sigmaB = self.stdZaif.sigma45Upper
                } else if self.levelBear == -1 {
                    sigmaB = self.stdZaif.sigma15Lower
                } else if self.levelBear == -2 {
                    sigmaB = self.stdZaif.sigma25Lower
                } else if self.levelBear == -3 {
                    sigmaB = self.stdZaif.sigma35Lower
                } else if self.levelBear == -4 {
                    sigmaB = self.stdZaif.sigma45Lower
                } else if self.levelBear == -5 {
                    sigmaB = self.stdZaif.sigma5Lower
                }
                
                let price = self.lastCandle!.priceAevrage!
                self.fifteenMinutesButton.setTitle(Int(price).description, for: UIControlState.normal)
                
                
                self.bfPrice.text = Int(sigmaB).description
                self.buyPrice.text = Int(sigma3L).description
                self.sellPrice.text = Int(sigma3U).description
                
                if self.stdZaif.samples.count < 10 {
                    self.thirtyMinutesButton.setTitle("Prepare", for: UIControlState.normal)
                    return
                }
                
                
                self.thirtyMinutesButton.setTitle("Active", for: UIControlState.normal)
                
                
                if self.isBull {
                    if price <= sigmaB {
                        self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: sigmaB, amount: -1.0, type: Quote.QuoteType.ASK))
                        }
                        self.levelLower = self.levelUpper
                        if self.levelLower > 5 {
                            self.levelLower = 5
                        }
                        self.isBull = false
                    } else if price <= (sigma3U + sigmaB) / 2.0 {
                        self.thirtyMinutesButton.setTitle("Bull", for: UIControlState.normal)
                        
                        self.queueForBuy.async {
                            self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                        }
                        self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                    } else if price >= sigma3U {
                        self.upUpperLevel()
                        self.levelBear = self.levelUpper - 2
                        if self.levelBear < -5 {
                            self.levelBear = -5
                        }
                    }
                } else {
                    
                    self.thirtyMinutesButton.setTitle("Active", for: UIControlState.normal)
                    
                    
                    if price >= sigma3U {
                        self.upUpperLevel()
                        if self.levelLower < self.levelUpper {
                            self.queueForSell.async {
                                self.sellQueue.removeAll()
                            }
                            self.queueForBuy.async {
                                self.buyQueue.append(Quote(price: zaifPrice, amount: 0.2, type: Quote.QuoteType.BID))
                            }
                            self.thirtyMinutesButton.setTitle("Buy", for: UIControlState.normal)
                            self.isBull = true
                            self.levelBear = self.levelUpper - 2
                            if self.levelBear < -5 {
                                self.levelBear = -5
                            }
                        }
                    } else {
                        if price <= sigma3L {
                            self.upLowerLevel()
                        }
                        
                        self.thirtyMinutesButton.setTitle("Sell", for: UIControlState.normal)
                        self.queueForBuy.async {
                            self.buyQueue.removeAll()
                        }
                        self.queueForSell.async {
                            self.sellQueue.append(Quote(price: -1.0, amount: 0.2, type: Quote.QuoteType.ASK))
                        }
                    }
                }
                
                
                self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
                self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
                
                if zaifPrice < self.lowerReachPrice {
                    self.lowerReachPrice = zaifPrice
                }
                if self.upperReachPrice < zaifPrice {
                    self.upperReachPrice = zaifPrice
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
    }*/
 

    @objc fileprivate func buy() {
        self.queueForBuy.async {
            if self.buyQueue.count == 0 {
                return
            }
            let _ = self.buyQueue.removeFirst()
            
            guard let bestAsk = self.bestQuoteView.getBestAsk() else {
                return
            }
            self.firedBuySignal(price: bestAsk.price, amount: 0.2)
        }
    }

    @objc fileprivate func fixProfit() {
        DispatchQueue.main.async {
            guard let account = getAccount() else {
                return
            }
            guard let bestBid = self.bestQuoteView.getBestBid() else {
                return
            }
            for position in account.activeExchange.trader.activePositions {
                if position.calculateUnrealizedProfit(marketPrice: bestBid.price) > 10.0 {
                    position.unwind(nil, price: bestBid.price) { (_, _) in }
                }
            }
        }
    }
    
    @objc fileprivate func sell() {
        self.queueForSell.async {
            if self.sellQueue.count == 0 {
                return
            }
            let quote = self.sellQueue.removeFirst()
            
            guard let trader = getAccount()?.activeExchange.trader else {
                return
            }
            guard let bestBid = self.bestQuoteView.getBestBid() else {
                return
            }
            trader.cancelAllOrders()
            
            DispatchQueue.main.async {
                if quote.price < 0 {
                    trader.unwindAllPositions(price: bestBid.price) { (err, position, orderedAmount) in
                        if let e = err {
                            print(e.message)
                        }
                    }
                } else {
                    trader.unwindAllPositions(price: quote.price) { (err, position, orderedAmount) in
                        if let e = err {
                            print(e.message)
                        }
                    }
                }
                
            }
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
            guard let trader = getAccount()?.activeExchange.trader else {
                return
            }
            trader.cancelAllOrders()
            
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
    
    fileprivate func downBearLevel() {
        self.levelBear -= 1
        if self.levelBear < -5 {
            self.levelBear = -5
        }
    }
    
    fileprivate func upUpperLevel() {
        self.levelUpper += 1
        if self.levelUpper > 10 {
            self.levelUpper = 10
        }
        self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
    }
    fileprivate func downUpperLevel() {
        self.levelUpper -= 1
        if self.levelUpper < -5 {
            self.levelUpper = -5
        }
        self.upperLevelButton.setTitle("ULv." + self.levelUpper.description, for: UIControlState.normal)
    }
    
    fileprivate func upLowerLevel() {
        self.levelLower += 1
        if self.levelLower > 10 {
            self.levelLower = 10
        }
        
        self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
    }
    fileprivate func downLowerLevel() {
        self.levelLower -= 1
        if self.levelLower < -5 {
            self.levelLower = -5
        }
        
        self.levelButton.setTitle("LLv." + self.levelLower.description, for: UIControlState.normal)
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
    var volMonCount = 300
    var volMonCounter = 300
    var volMonTimer: Timer?
    var fixProfitTimer: Timer?
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
    var bollingerChart15L: CandleChart!
    var bollingerChart05U: CandleChart!
    var bollingerChart1U: CandleChart!
    var bollingerChart2L: CandleChart!
    var bollingerChart25L: CandleChart!
    var bollingerChart15U: CandleChart!
    var bollingerChart2U: CandleChart!
    var bollingerChart3L: CandleChart!
    var bollingerChart35L: CandleChart!
    var bollingerChart25U: CandleChart!
    var bollingerChart3U: CandleChart!
    var bollingerChart4L: CandleChart!
    var bollingerChart45L: CandleChart!
    var bollingerChart35U: CandleChart!
    var bollingerChart4U: CandleChart!
    var bollingerChart5L: CandleChart!
    var bollingerChart45U: CandleChart!
    var bollingerChart5U: CandleChart!
    
    var levelUpper = 2
    var levelLower = 2
    var levelBear = 0
    var bearLevelGap = 1
    
    var isSigma3LowerReached = false
    var isSigma3UpperReached = false
    var isSigma2LowerReached = false
    var isSigma2UpperReached = false
    var isSigma1LowerReached = false
    var isSigma1UpperReached = false
    
    var lowerReachPrice = 99999999999.9
    var upperReachPrice = 0.0
    
    var lossLimit = 30.0
    var minLossLimit = 30.0
    
    var isBear = false
    var isBull = false
    
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
    
    var lastCandle: Candle?

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
    var sigma05Upper: Double {
        return self.ave + self.sd * 0.5
    }
    var sigma1Lower: Double {
        return self.ave - self.sd
    }
    var sigma05Lower: Double {
        return self.ave - self.sd * 0.5
    }
    var sigma2Upper: Double {
        return self.ave + self.sd * 2.0
    }
    var sigma15Upper: Double {
        return self.ave + self.sd * 1.5
    }
    var sigma2Lower: Double {
        return self.ave - self.sd * 2.0
    }
    var sigma15Lower: Double {
        return self.ave - self.sd * 1.5
    }
    var sigma3Upper: Double {
        return self.ave + self.sd * 3.0
    }
    var sigma25Upper: Double {
        return self.ave + self.sd * 2.5
    }
    var sigma3Lower: Double {
        return self.ave - self.sd * 3.0
    }
    var sigma25Lower: Double {
        return self.ave - self.sd * 2.5
    }
    var sigma4Upper: Double {
        return self.ave + self.sd * 4.0
    }
    var sigma35Upper: Double {
        return self.ave + self.sd * 3.5
    }
    var sigma4Lower: Double {
        return self.ave - self.sd * 4.0
    }
    var sigma35Lower: Double {
        return self.ave - self.sd * 3.5
    }
    var sigma5Upper: Double {
        return self.ave + self.sd * 5.0
    }
    var sigma45Upper: Double {
        return self.ave + self.sd * 4.5
    }
    var sigma5Lower: Double {
        return self.ave - self.sd * 5.0
    }
    var sigma45Lower: Double {
        return self.ave - self.sd * 4.5
    }
    
    let size: Int
    var samples = [Double]()
    var ave = 0.0
    var sd = 0.0
}
