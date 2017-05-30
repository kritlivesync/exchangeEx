//
//  PromiseMonitor.swift
//  zai
//
//  Created by 渡部郷太 on 3/2/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation


struct PromisedOrder {
    let orderId: String
    let currencyPair: String
    let action: String
    let price: Double
    let promisedAmount: Double
    let newlyPromisedAmount: Double
    let timestamp: Int64
    let isPartially: Bool
}


protocol PromiseMonitorDelegate : MonitorableDelegate {
    func promised(promisedOrder: PromisedOrder)
    func partiallyPromisedOrder(promisedOrder: PromisedOrder)
    func invalidated()
}


class PromiseMonitor : Monitorable {
    init(order: Order, api: Api) {
        self.order = order
        self.api = api
        super.init(target: "PromiseMonitor", addOperation: false)
    }
    
    override func monitor() {
        let delegate = self.delegate as? PromiseMonitorDelegate
        if delegate == nil {
            return
        }
        self.api.isPromised(order: self.order) { (err, promisedOrder) in
            DispatchQueue.main.async {
                if let e = err {
                    if e.errorType == .INVALID_ORDER || e.errorType == .ORDER_CANCELLED || e.errorType == .ORDER_NOT_ACTIVE {
                        delegate?.invalidated()
                    }
                } else {
                    if let promised = promisedOrder {
                        if promised.isPartially {
                            delegate?.partiallyPromisedOrder(promisedOrder: promised)
                        } else {
                            delegate?.promised(promisedOrder: promised)
                        }
                    }
                }
            }
        }
    }
    
    let order: Order
    let api: Api
}
