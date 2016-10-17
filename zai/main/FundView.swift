//
//  FundView.swift
//  zai
//
//  Created by 渡部郷太 on 8/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

protocol FundViewDelegate {
    func didUpdateMarketCapitalization(_ view: String)
    func didUpdateBtcJpyPrice(_ view: String)
}


internal class FundView {
    
    init(account: Account) {
        self.account = account
        
        self.updateCapitalizationTimer = Timer.scheduledTimer(
            timeInterval: self.UPDATE_CAPITALIATION_INTERVAL,
            target: self,
            selector: #selector(FundView.updateMarketCapitalization),
            userInfo: nil,
            repeats: true)
        
        self.updateBtcJpyTimer = Timer.scheduledTimer(
            timeInterval: self.UPDATE_BTCJPY_INTERVAL,
            target: self,
            selector: #selector(FundView.updateBtcJpyPrice),
            userInfo: nil,
            repeats: true)
        
        self.updateMarketCapitalization()
        self.updateBtcJpyPrice()
    }
    
    @objc func updateMarketCapitalization() {
        self.createMarketCapitalizationView() { (err, view) in
            if err == nil && self.delegate != nil {
                self.delegate!.didUpdateMarketCapitalization(view)
            }
        }
    }
    
    @objc func updateBtcJpyPrice() {
        let app = UIApplication.shared.delegate as! AppDelegate
        if let d = self.delegate {
            d.didUpdateBtcJpyPrice(self.formatValue(Int((app.analyzer?.marketPrice.btcJpy)!)))
        }
    }
    
    fileprivate func createMarketCapitalizationView(_ cb: @escaping (ZaiError?, String) -> Void) {
        self.account.getMarketCapitalization() { (err, value) in
            if let e = err {
                cb(e, "-")
            } else {
                cb(nil, self.formatValue(value))
            }
        }
    }
    
    fileprivate func formatValue(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value))!
    }
    
    fileprivate let account: Account
    fileprivate var updateCapitalizationTimer: Timer?
    fileprivate var updateBtcJpyTimer: Timer?
    var delegate: FundViewDelegate? = nil
    fileprivate let UPDATE_CAPITALIATION_INTERVAL = 10.0
    fileprivate let UPDATE_BTCJPY_INTERVAL = 1.0
}
