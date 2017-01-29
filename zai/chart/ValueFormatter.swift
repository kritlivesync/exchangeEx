//
//  ValueFormatter.swift
//  zai
//
//  Created by Kyota Watanabe on 1/5/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation


import Charts


class XValueFormatter : NSObject, IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let date = self.times[Int(value)] else {
            return ""
        }
        return date
    }
    
    var times = [Int:String]()
}

class YValueFormatter : NSObject, IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return Int(value).description
    }
    
}
