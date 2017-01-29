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


class ChartViewController : UIViewController, CandleChartDelegate, FundDelegate, BitCoinDelegate, BestQuoteViewDelegate, AppBackgroundDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.bestQuoteView = BestQuoteView(view: bestQuoteTableView)
        self.bestQuoteView.delegate = self
        
        self.chartSelectorView.backgroundColor = Color.keyColor2
        self.heilightChartButton(type: self.candleChart.interval)
        
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
        let api = getAccount()!.activeExchange.api
        if self.fund == nil {
            self.fund = Fund(api: api)
            self.fund.monitoringInterval = getAppConfig().footerUpdateIntervalType
            self.fund.delegate = self
        }
        
        let config = getChartConfig()
        if self.bitcoin == nil {
            self.bitcoin = BitCoin(api: api)
            self.bitcoin.monitoringInterval = config.chartUpdateIntervalType
            self.bitcoin.delegate = self
        }
        self.candleChart.monitoringInterval = config.chartUpdateIntervalType
        let trader = getAccount()!.activeExchange.trader
        trader.fund.delegate = trader
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
        
    }
    
    // CandleChartDelegate
    func recievedChart(chart: CandleChart, shifted: Bool) {
        guard let chartView = self.candleStickChartView else {
            return
        }
        var entries = [CandleChartDataEntry]()
        var emptyEntries = [CandleChartDataEntry]()
        let formatter = XValueFormatter()
        for i in 0 ..< chart.candles.count {
            let candle = chart.candles[i]
            if candle.isEmpty {
               let average = chart.average
                let entry = CandleChartDataEntry(x: Double(i), shadowH: average, shadowL: average, open: average, close: average)
                emptyEntries.append(entry)
            } else {
                let entry = CandleChartDataEntry(x: Double(i), shadowH: candle.highPrice!, shadowL: candle.lowPrice!, open: candle.openPrice!, close: candle.lastPrice!)
                entries.append(entry)
            }
            
            formatter.times[i] = formatHms(timestamp: candle.startDate)
        }
        let dataSet = CandleChartDataSet(values: entries, label: "data")
        dataSet.axisDependency = YAxis.AxisDependency.left;
        dataSet.shadowColorSameAsCandle = true
        dataSet.shadowWidth = 0.7
        dataSet.decreasingColor = Color.askQuoteColor
        dataSet.decreasingFilled = true
        dataSet.increasingColor = Color.bidQuoteColor
        dataSet.increasingFilled = true
        dataSet.neutralColor = UIColor.black
        dataSet.setDrawHighlightIndicators(false)
        
        let emptyDataSet = CandleChartDataSet(values: emptyEntries, label: "empty")
        emptyDataSet.axisDependency = YAxis.AxisDependency.left;
        emptyDataSet.shadowColorSameAsCandle = true
        emptyDataSet.shadowWidth = 0.7
        emptyDataSet.decreasingColor = Color.askQuoteColor
        emptyDataSet.decreasingFilled = true
        emptyDataSet.increasingColor = Color.bidQuoteColor
        emptyDataSet.increasingFilled = true
        emptyDataSet.neutralColor = UIColor.white
        emptyDataSet.setDrawHighlightIndicators(false)
        
        chartView.xAxis.valueFormatter = formatter
        chartView.rightAxis.valueFormatter = YValueFormatter()
        
        var dataSets = [IChartDataSet]()
        if dataSet.entryCount > 0 {
            dataSets.append(dataSet)
        }
        if emptyDataSet.entryCount > 0 {
            dataSets.append(emptyDataSet)
        }
        chartView.data = CandleChartData(dataSets: dataSets)
    }
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "ChartViewController"
    }
    
    // FundDelegate
    func recievedJpyFund(jpy: Int) {
        DispatchQueue.main.async {
            self.fundLabel.text = formatValue(jpy)
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
        let amount = min(quote.amount, 1.0)
        
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

    func orderSell(quote: Quote, callback: @escaping () -> Void) {
        let price = quote.price
        let amount = min(quote.amount, 1.0)
        
        guard let trader = getAccount()?.activeExchange.trader else {
            callback()
            return
        }

        switch getAppConfig().unwindingRuleType {
        case .mostBenefit:
            guard let bestBid = self.bestQuoteView.getBestBid() else {
                callback()
                return
            }
            trader.unwindMaxProfitPosition(price: price, amount: amount, marketPrice: bestBid.price) { (err, position) in
                callback()
                if let e = err {
                    let errorView = createErrorModal(title: e.errorType.toString(), message: e.message)
                    self.present(errorView, animated: false, completion: nil)
                }
            }
        case .mostLoss:
            guard let bestBid = self.bestQuoteView.getBestBid() else {
                callback()
                return
            }
            trader.unwindMaxLossPosition(price: price, amount: amount, marketPrice: bestBid.price) { (err, position) in
                callback()
                if let e = err {
                    let errorView = createErrorModal(title: e.errorType.toString(), message: e.message)
                    self.present(errorView, animated: false, completion: nil)
                }
            }
        case .mostRecent:
            trader.unwindMostRecentPosition(price: price, amount: amount) { (err, position) in
                callback()
                if let e = err {
                    let errorView = createErrorModal(title: e.errorType.toString(), message: e.message)
                    self.present(errorView, animated: false, completion: nil)
                }
            }
        case .mostOld:
            trader.unwindMostOldPosition(price: price, amount: amount) { (err, position) in
                callback()
                if let e = err {
                    let errorView = createErrorModal(title: e.errorType.toString(), message: e.message)
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
    
    fileprivate func switchChart(type: ChandleChartType, currencyPair: ApiCurrencyPair, api: Api) {
        if type == self.candleChart.interval {
            return
        }
        let prevChart = self.candleChart
        prevChart?.delegate = nil
        self.candleChart = CandleChart(currencyPair: currencyPair, interval: type, candleCount: 60, api: api)
        self.candleChart.copyTrades(chart: prevChart!)
        self.candleChart.delegate = self
        
        self.heilightChartButton(type: type)
        
        let config = getChartConfig()
        config.selectedCandleChartType = type
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
    
    @IBAction func pushOneMinuteChart(_ sender: Any) {
        let currencyPair = self.candleChart.currencyPair
        let api = getAccount()!.activeExchange.api
        self.switchChart(type: .oneMinute, currencyPair: currencyPair, api: api)
    }
    
    @IBAction func pushFiveMinutesChart(_ sender: Any) {
        let currencyPair = self.candleChart.currencyPair
        let api = getAccount()!.activeExchange.api
        self.switchChart(type: .fiveMinutes, currencyPair: currencyPair, api: api)
    }
    
    @IBAction func pushFifteenMinutesChart(_ sender: Any) {
        let currencyPair = self.candleChart.currencyPair
        let api = getAccount()!.activeExchange.api
        self.switchChart(type: .fifteenMinutes, currencyPair: currencyPair, api: api)
    }
    
    @IBAction func pushThirtyMinutesChart(_ sender: Any) {
        let currencyPair = self.candleChart.currencyPair
        let api = getAccount()!.activeExchange.api
        self.switchChart(type: .thirtyMinutes, currencyPair: currencyPair, api: api)
    }
    
    @IBAction func pushSettingsButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let settings = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! UINavigationController
        self.present(settings, animated: true, completion: nil)
    }

    
    fileprivate var fund: Fund!
    fileprivate var bitcoin: BitCoin!
    var candleChart: CandleChart!
    var bestQuoteView: BestQuoteView!

    @IBOutlet weak var chartSelectorView: UIView!
    @IBOutlet weak var candleStickChartView: CandleStickChartView!
    
    @IBOutlet weak var oneMinuteButton: UIButton!
    @IBOutlet weak var fiveMinutesButton: UIButton!
    @IBOutlet weak var thirtyMinutesButton: UIButton!
    @IBOutlet weak var fifteenMinutesButton: UIButton!
    
    @IBOutlet weak var fundLabel: UILabel!
    @IBOutlet weak var bestQuoteTableView: UITableView!
    
}
