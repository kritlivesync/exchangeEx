//
//  Utils.swift
//  zai
//
//  Created by 渡部郷太 on 10/30/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


func getNow() -> String {
    let now = NSDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return formatter.string(from: now as Date)
}
