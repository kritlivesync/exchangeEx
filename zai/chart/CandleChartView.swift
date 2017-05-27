//
//  CandleChartView.swift
//  zai
//
//  Created by 渡部郷太 on 3/27/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation

import Charts


protocol CandleChartViewDelegate {
    func recievedChart(chartData: CandleChartData, xFormatter: XValueFormatter, yFormatter: YValueFormatter, chart: CandleChart, shifted: Bool)
}


class CandleChartView : CandleChartDelegate {
    
    init() {
        self.chartDataContainer = [String:CandleChartData]()
        self.chartContainer = getApp().candleCharts
    }
    
    func activateChart(chartName: String, interval: UpdateInterval) {
        self.chartContainer.activateChart(chartName: chartName, interval: interval, delegate: self)
    }
    
    func deactivateCharts() {
        self.chartContainer.deactivateCharts()
    }
    
    func switchChartIntervalType(type: ChandleChartType) {
        self.chartContainer.switchChartIntervalType(type: type)
    }
    
    func getChart(chartName: String) -> CandleChart? {
        return self.getChart(chartName: chartName)
    }
    
    // CandleChartDelegate
    func recievedChart(chart: CandleChart, shifted: Bool, chartName: String) {
        guard let chartColors = self.chartContainer.getChartColors(chartName: chartName) else {
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
                let h = candle.highPrice
                let l = candle.lowPrice
                let o = candle.openPrice
                let lp = candle.lastPrice
                let entry = CandleChartDataEntry(x: Double(i), shadowH: h!, shadowL: l!, open: o!, close: lp!)
                entries.append(entry)
            }
            
            formatter.times[i] = formatHms(timestamp: candle.startDate)
        }
        
        let dataSet = CandleChartDataSet(values: entries, label: "data")
        dataSet.axisDependency = YAxis.AxisDependency.left;
        dataSet.shadowColorSameAsCandle = true
        dataSet.shadowWidth = 0.7
        dataSet.decreasingColor = chartColors.askColor
        dataSet.decreasingFilled = true
        dataSet.increasingColor = chartColors.bidColor
        dataSet.increasingFilled = true
        dataSet.neutralColor = UIColor.black
        dataSet.setDrawHighlightIndicators(false)
        
        let emptyDataSet = CandleChartDataSet(values: emptyEntries, label: "empty")
        emptyDataSet.axisDependency = YAxis.AxisDependency.left;
        emptyDataSet.shadowColorSameAsCandle = true
        emptyDataSet.shadowWidth = 0.7
        emptyDataSet.decreasingColor = chartColors.askColor
        emptyDataSet.decreasingFilled = true
        emptyDataSet.increasingColor = chartColors.bidColor
        emptyDataSet.increasingFilled = true
        emptyDataSet.neutralColor = UIColor.white
        emptyDataSet.setDrawHighlightIndicators(false)
        
        var dataSets = [IChartDataSet]()
        if dataSet.entryCount > 0 {
            dataSets.append(dataSet)
        }
        if emptyDataSet.entryCount > 0 {
            dataSets.append(emptyDataSet)
        }
        let chartData = CandleChartData(dataSets: dataSets)
        self.chartDataContainer[chartName] = chartData
        
        self.delegate?.recievedChart(chartData: chartData, xFormatter: formatter, yFormatter: YValueFormatter(), chart: chart, shifted: shifted)
    }
    
    var chartDataContainer: [String:CandleChartData]
    var chartContainer: CandleChartContainer!
    var delegate: CandleChartViewDelegate?
}
