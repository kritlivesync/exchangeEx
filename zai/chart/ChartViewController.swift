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


class ChartViewController : UIViewController, CandleChartDelegate, BitCoinDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let account = getAccount()!
        self.bitcoint = BitCoin(api: account.activeExchange.api)
        
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
        //self.candleChart.delegate = self
        self.bitcoint.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        //self.candleChart.delegate = nil
        self.bitcoint.delegate = nil
    }
    
    // CandleChartDelegate
    func recievedChart(chart: CandleChart, shifted: Bool) {
        guard let chartView = self.candleStickChartView else {
            return
        }
        var entries = [CandleChartDataEntry]()
        let formatter = XValueFormatter()
        for i in 0 ..< chart.candles.count {
            let candle = chart.candles[i]
            if candle.isEmpty {
                continue
            }
            let entry = CandleChartDataEntry(x: Double(i), shadowH: candle.highPrice!, shadowL: candle.lowPrice!, open: candle.openPrice!, close: candle.lastPrice!)
            entries.append(entry)
            
            formatter.times[i] = formatHms(timestamp: candle.startDate)
        }
        let dataSet = CandleChartDataSet(values: entries, label: "1分足")
        dataSet.axisDependency = YAxis.AxisDependency.left;
        
        dataSet.shadowColorSameAsCandle = true
        dataSet.shadowWidth = 0.7
        dataSet.decreasingColor = Color.askQuoteColor
        dataSet.decreasingFilled = true
        dataSet.increasingColor = Color.bidQuoteColor
        dataSet.increasingFilled = true
        dataSet.neutralColor = UIColor.black
        
        chartView.xAxis.valueFormatter = formatter
        chartView.rightAxis.valueFormatter = YValueFormatter()
        
        chartView.data = CandleChartData(dataSet: dataSet)
    }
    
    // BitCoinDelegate
    func recievedBestJpyBid(price: Int, amount: Double) {
        self.bestBidPriceLabel.text = formatValue(price)
        self.bestBidAmountLabel.text = formatValue(amount)
    }
    
    func recievedBestJpyAsk(price: Int, amount: Double) {
        self.bestAskPriceLabel.text = formatValue(price)
        self.bestAskAmountLabel.text = formatValue(amount)
    }
    
    var bitcoint: BitCoin!
    
    var candleChart: CandleChart!
    @IBOutlet weak var candleStickChartView: CandleStickChartView!

    @IBOutlet weak var bestAskPriceLabel: UILabel!
    @IBOutlet weak var bestAskAmountLabel: UILabel!
    @IBOutlet weak var bestBidPriceLabel: UILabel!
    @IBOutlet weak var bestBidAmountLabel: UILabel!
    @IBOutlet weak var takeAskButton: UIButton!
    @IBOutlet weak var takeBidButton: UIButton!
    
}
