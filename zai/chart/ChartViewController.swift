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


class ChartViewController : UIViewController, CandleChartDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let account = getAccount()!
        self.chart = CandleChart(currencyPair: .BTC_JPY, interval: .oneMinute, candleCount: 20, api: account.activeExchange.api)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        self.chart.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        self.chart.delegate = nil
    }
    
    // CandleChartDelegate
    func recievedChart(chart: CandleChart, shifted: Bool) {
        return
    }
    
    var chart: CandleChart!
    @IBOutlet weak var candleStickChartView: CandleStickChartView!
}
