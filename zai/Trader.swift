//
//  Trader.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


internal protocol TraderProtocol {
    var name: String { get }
    var account: Account { get }
    var positions: [PositionProtocol] { get }
}


internal class StrongTrader : TraderProtocol {
    
    internal static func create(acount: Account, cb: (ZaiError, StrongTrader) -> Void) {

    }
    
    private init(name: String, account: Account) {
        self.name = name
        self.account = account
        self.positions = []
    }
    
    func ss() {
        self.positions.removeAll()
    }
    
    let name: String
    let account: Account
    var positions: [PositionProtocol]
}
