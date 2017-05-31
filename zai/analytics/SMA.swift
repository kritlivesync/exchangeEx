//
//  SMA.swift
//  zai
//
//  Created by 渡部郷太 on 6/1/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation


class SMA {
    init(size: Int) {
        self.size = size
        self.samples = [Double]()
    }
    
    func add(sample: Double) {
        if self.samples.count == self.size {
            self.samples.removeFirst()
        }
        self.samples.append(sample)
    }
    
    func clear() {
        self.samples.removeAll()
    }
    
    var value: Double {
        return self.samples.reduce(0.0, +) / Double(self.samples.count)
    }
    
    fileprivate let size: Int
    fileprivate var samples: [Double]
}
