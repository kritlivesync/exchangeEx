//
//  Account.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import SwiftyJSON

import ZaifSwift


internal class Account {
    init(api: PrivateApi) {
        self.privateApi = api
    }
    
    func getMarketCapitalization(cb: ((ZaiError?, Int) -> Void)) {
        let fund = JPYFund(api: self.privateApi)
        fund.getMarketCapitalization(cb)
    }
    
    private let privateApi: PrivateApi
}