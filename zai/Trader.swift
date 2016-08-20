//
//  Trader.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


internal class StrongTrader {
    
    internal static func create(acount: Account, cb: (ZaiError, StrongTrader) -> Void) {

    }
    
    private init(name: String) {
        self.name = name
        self.positions = []
    }
    
    internal let name: String
    private let positions: [PositionProtocol]
}
