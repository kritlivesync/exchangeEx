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


enum TechnicalIndexType : Int{
    case sma5 = 0
    case sma25 = 1
    case sma5_25 = 2
    case bollingerBand = 3
    case none = -1
}


class ChartViewController : UIViewController, CandleChartViewDelegate, FundDelegate, BitCoinDelegate, BestQuoteViewDelegate, AppBackgroundDelegate, TechncalIndexStateDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        self.navigationController?.navigationBar.items?[0].title = LabelResource.chartViewTitle
        
        self.capacityLabel.text = LabelResource.funds
        self.fundLabel.text = "-"
        
        self.oneMinuteButton.setTitle(LabelResource.candleChart(interval: 1), for: UIControlState.normal)
        self.fiveMinutesButton.setTitle(LabelResource.candleChart(interval: 5), for: UIControlState.normal)
        self.fifteenMinutesButton.setTitle(LabelResource.candleChart(interval: 15), for: UIControlState.normal)
        self.thirtyMinutesButton.setTitle(LabelResource.candleChart(interval: 30), for: UIControlState.normal)
        
        self.technicalSegmentControl.setTitle(LabelResource.technicalSma5, forSegmentAt: TechnicalIndexType.sma5.rawValue)
        self.technicalSegmentControl.setTitle(LabelResource.technicalSma25, forSegmentAt: TechnicalIndexType.sma25.rawValue)
        self.technicalSegmentControl.setTitle(LabelResource.technicalSma5_25, forSegmentAt: TechnicalIndexType.sma5_25.rawValue)
        self.technicalSegmentControl.setTitle(LabelResource.technicalBollingerBand, forSegmentAt: TechnicalIndexType.bollingerBand.rawValue)
        self.technicalSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment
        
        self.bestQuoteView = BestQuoteView(view: bestQuoteTableView)
        self.bestQuoteView.delegate = self
        
        self.chartSelectorView.backgroundColor = Color.keyColor2
        self.heilightChartButton(type: getChartConfig().selectedCandleChartType)
        
        self.candleStickChartView.legend.enabled = false
        self.candleStickChartView.chartDescription?.enabled = false
        self.candleStickChartView.pinchZoomEnabled = false
        self.candleStickChartView.maxVisibleCount = 0
        self.candleStickChartView.drawBordersEnabled = false
        
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
        
        if self.candleChartView == nil {
            account.activeExchange.stopWatch()
            self.candleChartView = CandleChartView(chart: account.activeExchange.candleChart)
            self.candleChartView.delegate = self
            self.candleChartView.monitoringInterval = config.chartUpdateIntervalType
            self.candleChartView.switchChartIntervalType(type: config.selectedCandleChartType)
        }
        if self.technicalIndexState == nil {
            self.technicalIndexState = TechncalIndexState(index: TechnicalIndexType.none)
            self.technicalIndexState.delegate = self
            self.technicalIndexState.changeIndex(index: TechnicalIndexType(rawValue: self.technicalSegmentControl.selectedSegmentIndex)!)
        }
        
        let trader = account.activeExchange.trader
        trader.startWatch()
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
        if self.candleChartView != nil {
            self.candleChartView.delegate = nil
            self.candleChartView = nil
            getAccount()?.activeExchange.startWatch()
        }
        if self.technicalIndexState != nil {
            self.technicalIndexState.delegate = nil
            self.technicalIndexState = nil
        }
    }
    
    // CandleChartViewDelegate
    func recievedChart(chartData: CandleChartData, xFormatter: XValueFormatter, yFormatter: YValueFormatter, chart: CandleChart) {
        
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
        DispatchQueue.main.async {
            self.fundLabel.text = formatValue(available)
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
    
    // TechncalIndexStateDelegate
    func clearTechnicalIndex() {
        self.candleChartView.showSma5 = false
        self.candleChartView.showSma25 = false
        self.candleChartView.showBollingerBand = false
        self.technicalSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment
    }
    
    func setTechnicalIndex(index: TechnicalIndexType) {
        self.candleChartView.showSma5 = false
        self.candleChartView.showSma25 = false
        self.candleChartView.showBollingerBand = false
        
        switch index {
        case TechnicalIndexType.sma5:
            self.candleChartView.showSma5 = true
        case TechnicalIndexType.sma25:
            self.candleChartView.showSma25 = true
        case TechnicalIndexType.sma5_25:
            self.candleChartView.showSma5 = true
            self.candleChartView.showSma25 = true
        case TechnicalIndexType.bollingerBand:
            self.candleChartView.showBollingerBand = true
        default:
            self.technicalSegmentControl.selectedSegmentIndex = UISegmentedControlNoSegment
        }
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
    
    @IBAction func changedTechnicalSegment(_ sender: Any) {
        self.technicalIndexState.changeIndex(index: TechnicalIndexType(rawValue: self.technicalSegmentControl.selectedSegmentIndex)!)
    }
    
    fileprivate var fund: Fund!
    fileprivate var bitcoin: BitCoin!
    var bestQuoteView: BestQuoteView!
    var candleChartView: CandleChartView!
    var technicalIndexState: TechncalIndexState!

    @IBOutlet weak var chartSelectorView: UIView!
    @IBOutlet weak var candleStickChartView: CandleStickChartView!
    
    @IBOutlet weak var oneMinuteButton: UIButton!
    @IBOutlet weak var fiveMinutesButton: UIButton!
    @IBOutlet weak var thirtyMinutesButton: UIButton!
    @IBOutlet weak var fifteenMinutesButton: UIButton!
    
    @IBOutlet weak var capacityLabel: UILabel!
    @IBOutlet weak var fundLabel: UILabel!
    @IBOutlet weak var bestQuoteTableView: UITableView!
    
    @IBOutlet weak var technicalSegmentControl: TouchSegmentControl!
    
}

protocol TechncalIndexStateDelegate {
    func clearTechnicalIndex()
    func setTechnicalIndex(index: TechnicalIndexType)
}

class TechncalIndexState {
    init(index: TechnicalIndexType) {
        self.currentIndex = index
    }
    
    func changeIndex(index: TechnicalIndexType) {
        if self.currentIndex == index || index == TechnicalIndexType.none {
            self.delegate?.clearTechnicalIndex()
            self.currentIndex = TechnicalIndexType.none
            return
        } else {
            self.delegate?.setTechnicalIndex(index: index)
            self.currentIndex = index
        }
    }
    
    var currentIndex = TechnicalIndexType.none
    var delegate: TechncalIndexStateDelegate?
}

class TouchSegmentControl : UISegmentedControl {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let curIndex = self.selectedSegmentIndex
        super.touchesEnded(touches, with: event)
        if curIndex == self.selectedSegmentIndex {
            sendActions(for: .valueChanged)
        }
    }
}
