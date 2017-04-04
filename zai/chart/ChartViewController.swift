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


class ChartViewController : UIViewController, CandleChartViewDelegate, FundDelegate, BitCoinDelegate, BestQuoteViewDelegate, AppBackgroundDelegate, ZaiAnalyticsDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.fundLabel.text = "-"
        
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
        
        self.autoSwitch.isOn = false
        self.analyticsClient.delegate = self
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

        self.candleChartView.activateChart(chartName: "Zaif", interval: config.chartUpdateIntervalType)
        //self.candleChartView.activateChart(chartName: "bitFlyer", interval: config.chartUpdateIntervalType)
        self.candleChartView.switchChartIntervalType(type: config.selectedCandleChartType)
        
        let trader = account.activeExchange.trader
        trader.startWatch()
        
        if self.autoSwitch.isOn && account.activeExchangeName == "Zaif" {
            self.analyticsClient.open()
        } else {
            self.analyticsClient.close()
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
    }
    
    // CandleChartViewDelegate
    func recievedChart(chartData: CandleChartData, xFormatter: XValueFormatter, yFormatter: YValueFormatter) {
        guard let chartView = self.candleStickChartView else {
            return
        }
        chartView.xAxis.valueFormatter = xFormatter
        chartView.rightAxis.valueFormatter = YValueFormatter()
        chartView.data = chartData
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
    
    // ZaiAnalyticsDelegate
    func recievedBuySignal() {
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        guard let bestAsk = self.bestQuoteView.getBestAsk() else {
            return
        }
        
        //let amount = Double(self.availableJpy) * 0.5 / bestAsk.price
        
        trader.createLongPosition(.BTC_JPY, price: bestAsk.price, amount: bestAsk.amount * 3.0) { (err, position) in
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
        if swtch.isOn && getAccount()!.activeExchangeName == "Zaif" {
            self.analyticsClient.open()
        } else {
            self.analyticsClient.close()
        }
    }
    
    fileprivate var fund: Fund!
    fileprivate var bitcoin: BitCoin!
    fileprivate var availableJpy = 0
    
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
}
