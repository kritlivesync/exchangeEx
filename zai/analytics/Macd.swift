//
//  Macd.swift
//  zai
//
//  Created by 渡部郷太 on 9/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


class Sample {
    init(value: Double, shortTermEma: Double, longTermEma: Double, signal: Double) {
        self.value = value
        self.shortTermEma = shortTermEma
        self.longTermEma = longTermEma
        self.signal = signal
    }
    
    func macd() -> Double {
        return self.shortTermEma - self.longTermEma
    }
    
    func macdSignal() -> Double {
        return self.signal
    }
    
    let value: Double
    let shortTermEma: Double
    let longTermEma: Double
    let signal: Double
}


class Macd {
    
    init(shortTerm: Int = 12, longTerm: Int = 26, signalTerm: Int = 9) {
        self.shortTerm = shortTerm
        self.longTerm = longTerm
        self.signalTerm = signalTerm
        self.samples = []
    }
    
    func addSampleValue(_ value: Double) {
        let sampleCount = self.samples.count + 1 // + 1 for new value
        
        var shortEma = 0.0
        if self.shortTerm <= sampleCount {
            shortEma = self.calculateShortEma(value)
        }
        var longEma = 0.0
        if self.longTerm <= sampleCount {
            longEma = self.calculateLongEma(value)
        }
        var signal = 0.0
        if self.signalTerm <= sampleCount {
            let macd = shortEma - longEma
            signal = self.calculateSignal(macd)
        }
        self.samples.append(Sample(value: value, shortTermEma: shortEma, longTermEma: longEma, signal: signal))
            
        let maxTerm = max(max(self.shortTerm, self.longTerm), self.signalTerm)
        self.valid = (maxTerm <= self.samples.count)
        
        if self.HISTORY_SIZE < self.samples.count {
            self.samples.remove(at: 0)
        }
    }
    
    func isGoldenCross() -> Bool {
        if !self.valid {
            return false
        }
        let last = self.samples.last!
        if last.macd() - last.macdSignal() <= 0 {
            return false
        }
        for sample in self.samples.prefix(self.samples.count - 1).reversed() {
            let diff = sample.macd() - sample.macdSignal()
            if diff < 0 {
                return true
            } else if 0 < diff {
                return false
            }
        }
        return false
    }
    
    func isDeadCross() -> Bool {
        if !self.valid {
            return false
        }
        let last = self.samples.last!
        if last.macdSignal() - last.macd() <= 0 {
            return false
        }
        for sample in self.samples.prefix(self.samples.count - 1).reversed() {
            let diff =  sample.macdSignal() - sample.macd()
            if diff < 0 {
                return true
            } else if 0 < diff {
                return false
            }
        }
        return false
    }
    
    func getLatestMacdValue() -> Double {
        if self.valid {
            let last = self.samples.last!
            return last.macd()
        } else {
            return 0.0
        }
    }
    
    func getPreviousMacdValue() -> Double {
        if self.valid {
            let slice = Array(self.samples.suffix(2))
            let prev = slice[0]
            return prev.macd()
        } else {
            return 0.0
        }
    }
    
    func average(_ interval: Int) -> Double {
        if self.valid {
            let slice = Array(self.samples.suffix(interval))
            var sum = 0.0
            for sample in slice {
                sum += sample.macd()
            }
            return sum / Double(interval)
        } else {
            return 0.0
        }
    }
    
    func getLatestSignalValue() -> Double {
        if self.valid {
            let last = self.samples.last!
            return last.macdSignal()
        } else {
            return 0.0
        }
    }
    
    func getPreviousSignalValue() -> Double {
        if self.valid {
            let prev = self.samples.suffix(2)[0]
            return prev.macdSignal()
        } else {
            return 0.0
        }
    }
    
    fileprivate func calculateShortEma(_ value: Double) -> Double {
        let sampleCount = self.samples.count
        if sampleCount + 1 == self.shortTerm {
            var sum = 0.0
            for sample in self.samples {
                sum += sample.value
            }
            sum += value
            return sum / Double(self.shortTerm)
        } else {
            let lastEma = self.samples.last!.shortTermEma
            let grad = value - lastEma
            let alpha = 2.0 / (Double(self.shortTerm) + 1.0)
            return lastEma + alpha * grad
        }
    }
    
    fileprivate func calculateLongEma(_ value: Double) -> Double {
        let sampleCount = self.samples.count
        if sampleCount + 1 == self.longTerm {
            var sum = 0.0
            for sample in self.samples {
                sum += sample.value
            }
            sum += value
            return sum / Double(self.longTerm)
        } else {
            let lastEma = self.samples.last!.longTermEma
            let grad = value - lastEma
            let alpha = 2.0 / (Double(self.longTerm) + 1.0)
            return lastEma + alpha * grad
        }
    }
    
    fileprivate func calculateSignal(_ macd: Double) -> Double {
        var sum = 0.0
        for sample in self.samples.suffix(self.signalTerm - 1) {
            sum += sample.macd()
        }
        sum += macd
        return sum / Double(self.signalTerm)
    }
    
    internal var valid = false
    fileprivate var samples: [Sample]
    fileprivate let shortTerm: Int
    fileprivate let longTerm: Int
    fileprivate let signalTerm: Int
    fileprivate let HISTORY_SIZE = 100
}
