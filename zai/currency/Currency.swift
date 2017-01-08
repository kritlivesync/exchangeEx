//
//  Currency.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

@objc protocol MonitorableDelegate {
    
}

internal class Monitorable {
    
    init() {
        self.queue = DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default)
        self.addMonitorOperation()
    }
    
    @objc func addMonitorOperation() {
        self.queue.async {
            self.monitor()
        }
    }
    
    func monitor() {
        return
    }
    
    var delegate: MonitorableDelegate? = nil {
        willSet {
            if newValue == nil {
                self.timer?.invalidate()
                self.timer = nil
            } else {
                if self.timer == nil {
                    self.timer = Timer.scheduledTimer(
                        timeInterval: self.monitoringInterval,
                        target: self,
                        selector: #selector(Monitorable.addMonitorOperation),
                        userInfo: nil,
                        repeats: true)
                }
            }
        }
        didSet {
            self.monitor()
        }
    }
    
    let queue: DispatchQueue!
    var timer: Timer?
    var monitoringInterval: Double = 5.0
    
}

