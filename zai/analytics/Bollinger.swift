//
//  Bollinger.swift
//  zai
//
//  Created by 渡部郷太 on 5/27/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation


class Bollinger {
    init(size: Int) {
        self.size = size
    }
    
    func add(sample: Double) {
        self.samples.append(sample)
        if (self.samples.count > self.size) {
            self.samples.removeFirst()
        }
        self.ave = self.samples.reduce(0.0, +) / Double(self.samples.count)
        let ave2 = pow(self.ave, 2)
        let samples2 = self.samples.map { pow($0, 2) }
        let samples2Ave = samples2.reduce(0.0, +) / Double(samples2.count)
        self.sd = sqrt(samples2Ave - ave2)
    }
    
    func clear() {
        self.samples.removeAll()
        self.ave = 0.0
        self.sd = 0.0
    }
    
    func getSigmaUpper(level: Int) -> Double {
        return self.ave + self.sd * Double(level)
    }
    
    func getSigmaLower(level: Int) -> Double {
        return self.ave - self.sd * Double(level)
    }
    
    var sigma1Upper: Double {
        return self.ave + self.sd
    }
    var sigma1Lower: Double {
        return self.ave - self.sd
    }
    var sigma2Upper: Double {
        return self.ave + self.sd * 2.0
    }
    var sigma2Lower: Double {
        return self.ave - self.sd * 2.0
    }
    var sigma3Upper: Double {
        return self.ave + self.sd * 3.0
    }
    var sigma3Lower: Double {
        return self.ave - self.sd * 3.0
    }
    
    let size: Int
    var samples = [Double]()
    var ave = 0.0
    var sd = 0.0
}
