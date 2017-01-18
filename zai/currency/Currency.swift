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
    
    init(target: String) {
        self.target = target
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
    
    var monitoringInterval: UpdateInterval {
        get {
            return self._monitoringInterval
        }
        set {
            self._monitoringInterval = newValue
            if self.timer != nil {
                self.timer?.invalidate()
                print(getNow() + " start monitoring " + self.target + " interval: " + self._monitoringInterval.string)
                self.timer = Timer.scheduledTimer(
                    timeInterval: self._monitoringInterval.double,
                    target: self,
                    selector: #selector(Monitorable.addMonitorOperation),
                    userInfo: nil,
                    repeats: true)
            }
        }
    }
    
    var delegate: MonitorableDelegate? = nil {
        willSet {
            if newValue == nil {
                print(getNow() + " end monitoring " + self.target)
                self.timer?.invalidate()
                self.timer = nil
            } else {
                if self.timer == nil {
                    print(getNow() + " start monitoring " + self.target + " interval: " + self._monitoringInterval.string)
                    self.timer = Timer.scheduledTimer(
                        timeInterval: self._monitoringInterval.double,
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
    
    
    let target: String
    let queue: DispatchQueue!
    var timer: Timer?
    var _monitoringInterval = UpdateInterval.fiveSeconds
    
}

