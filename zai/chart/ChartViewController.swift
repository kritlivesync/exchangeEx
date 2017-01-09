//
//  Chart.swift
//  zai
//
//  Created by 渡部郷太 on 1/4/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

import Charts


class ChartViewController : UIViewController, CandleChartDelegate, BitCoinDelegate, PositionDelegate, FundDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.bestAskPriceLabel.text = "0"
        self.bestAskAmountLabel.text = "0.0"
        self.bestBidPriceLabel.text = "0"
        self.bestBidAmountLabel.text = "0.0"
        self.takeAskButton.backgroundColor = Color.keyColor
        self.takeBidButton.backgroundColor = Color.keyColor
        
        let api = getAccount()!.activeExchange.api
        self.bitcoint = BitCoin(api: api)
        self.fund = Fund(api: api)
        
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
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.bitcoint.delegate = self
        self.fund.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.bitcoint.delegate = nil
        self.fund.delegate = nil
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
    
    // BitCoinDelegate
    func recievedBestJpyBid(price: Int, amount: Double) {
        self.bestBidPriceLabel.text = formatValue(price)
        self.bestBidAmountLabel.text = formatValue(amount)
        self.bestBidPrice = Double(price)
        self.bestBidAmount = amount
    }
    
    func recievedBestJpyAsk(price: Int, amount: Double) {
        self.bestAskPriceLabel.text = formatValue(price)
        self.bestAskAmountLabel.text = formatValue(amount)
        self.bestAskPrice = Double(price)
        self.bestAskAmount = amount
    }
    
    // PositionDelegate
    func opendPosition(position: Position) {
        return
    }
    func unwindPosition(position: Position) {
        return
    }
    func closedPosition(position: Position) {
        return
    }
    
    // FundDelegate
    func recievedJpyFund(jpy: Int) {
        DispatchQueue.main.async {
            self.fundLabel.text = formatValue(jpy)
        }
    }
    
    @IBAction func pushTakeBestAskButton(_ sender: Any) {
        let price = self.bestAskPrice
        let amount = min(self.bestAskAmount, 1.0)
        
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        
        trader.createLongPosition(.BTC_JPY, price: price, amount: amount) { (err, position) in
            if let e = err {
                print(e.message)
            } else {
                position?.delegate = self
            }
        }
    }

    @IBAction func pushTakeBestBidButton(_ sender: Any) {
        let price = self.bestAskPrice
        let amount = min(self.bestAskAmount, 1.0)
        
        guard let trader = getAccount()?.activeExchange.trader else {
            return
        }
        let app = UIApplication.shared.delegate as! AppDelegate
        if app.config.sellMaxProfitPosition {
            trader.unwindMaxProfitPosition(price: price, amount: amount) { (err, position) in
                if err != nil {
                    position?.delegate = self
                }
            }
        } else {
            trader.unwindMinProfitPosition(price: price, amount: amount) { (err, position) in
                if err != nil {
                    position?.delegate = self
                }
            }
        }
    }
    
    
    fileprivate var fund: Fund!
    fileprivate var bitcoint: BitCoin!
    fileprivate var bestAskPrice: Double = 0.0
    fileprivate var bestAskAmount: Double = 0.0
    fileprivate var bestBidPrice: Double = 0.0
    fileprivate var bestBidAmount: Double = 0.0
    
    var candleChart: CandleChart!
    @IBOutlet weak var candleStickChartView: CandleStickChartView!


    @IBOutlet weak var fundLabel: UILabel!
    @IBOutlet weak var bestAskPriceLabel: UILabel!
    @IBOutlet weak var bestAskAmountLabel: UILabel!
    @IBOutlet weak var bestBidPriceLabel: UILabel!
    @IBOutlet weak var bestBidAmountLabel: UILabel!
    @IBOutlet weak var takeAskButton: UIButton!
    @IBOutlet weak var takeBidButton: UIButton!
    
}
