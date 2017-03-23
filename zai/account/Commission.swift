//
//  Commission.swift
//  zai
//
//  Created by 渡部郷太 on 3/12/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation


protocol CommissionDelegate : MonitorableDelegate {
    func recievedCommmission(commission: Double)
}


internal class Commission : Monitorable {
    init(currencyPair: ApiCurrencyPair, api: Api) {
        self.currencyPair = currencyPair
        self.api = api
        super.init(target: "Commission")
    }
    
    override func monitor() {
        let delegate = self.delegate as? CommissionDelegate
        if delegate?.recievedCommmission != nil {
            self.api.getCommission(currencyPair: self.currencyPair) { (err, commission) in
                if err == nil {
                    delegate?.recievedCommmission(commission: commission)
                }
            }
        }
    }
    
    let currencyPair: ApiCurrencyPair
    fileprivate let api: Api
}
