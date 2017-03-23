//
//  Currency.swift
//  zai
//
//  Created by Kyota Watanabe on 8/19/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation

import ZaifSwift

@objc protocol MonitorableDelegate {
    @objc optional func getDelegateName() -> String
}

internal class Monitorable : NSObject {
    
    init(target: String, addOperation: Bool=true) {
        self.target = target
        self.queue = DispatchQueue.global()
        
        super.init()
        
        if addOperation {
            self.addMonitorOperation()
        }
    }
    
    @objc func addMonitorOperation() {
        DispatchQueue.main.async {
            var log = "\(getNow()) do monitoring \(self.target) delegate: "
            if let _ = self.delegate?.getDelegateName {
                log += (self.delegate?.getDelegateName!())!
            }
            print(log)
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
                self.timer = nil
                var log = "\(getNow()) start monitoring \(self.target) interval: \(self._monitoringInterval.string) delegate: "
                if let _ = self.delegate?.getDelegateName {
                    log += (self.delegate?.getDelegateName!())!
                }
                print(log)
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
                var log = "\(getNow()) end monitoring \(self.target) delegate: "
                if let _ = self.delegate?.getDelegateName {
                    log += (self.delegate?.getDelegateName!())!
                }
                print(log)
                self.timer?.invalidate()
                self.timer = nil
            } else {
                if self.timer == nil {
                    var log = "\(getNow()) start monitoring \(self.target) interval: \(self._monitoringInterval.string) delegate: "
                    if let _ = self.delegate?.getDelegateName {
                        log += (self.delegate?.getDelegateName!())!
                    }
                    print(log)
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

