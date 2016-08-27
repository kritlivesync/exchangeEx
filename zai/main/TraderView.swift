//
//  TraderView.swift
//  zai
//
//  Created by 渡部郷太 on 8/26/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

import ZaifSwift


class TraderView : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(view: UITableView, traderName: String, api: PrivateApi) {
        self.traderName = traderName
        self.trader = TraderRepository.getInstance().findTraderByName(traderName, api: api)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("traderViewCell", forIndexPath: indexPath) as! TraderViewCell
        cell.setTrader(self.trader)
        
        return cell
    }
    
    private let traderName: String
    private let trader: Trader?
}