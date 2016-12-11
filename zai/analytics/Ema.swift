//
//  Ema.swift
//  zai
//
//  Created by 渡部郷太 on 12/11/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


class Ema {
    init(term: Int) {
        self.term = term
    }
    
    func addSample(value: Double) {
        self.samples.append(value)
    }
    
    func calculate() -> Double {
        if self.samples.count < self.term {
            return 0.0
        }
        let slice = Array(self.samples.prefix(self.term))
        var ema = slice.reduce(0, +) / Double(slice.count)
        let rest = Array(self.samples.suffix(self.samples.count - self.term))
        for value in rest {
            let grad = value - ema
            let alpha = 2.0 / (Double(self.term) + 1.0)
            ema = ema + alpha * grad
        }
        return ema
    }
    
    var term: Int
    var samples = [Double]()
}
