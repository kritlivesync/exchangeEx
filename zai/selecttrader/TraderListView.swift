//
//  File.swift
//  zai
//
//  Created by 渡部郷太 on 8/27/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


class TraderListView : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(view: UITableView, activeTraderName: String, api: PrivateApi) {
        self.activeTraderName = activeTraderName
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TraderRepository.getInstance().count()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("traderListViewCell", forIndexPath: indexPath) as! TraderViewCell
        let trader = self.traders[indexPath.row]
        cell.setTrader(trader)
        return cell
    }
    
    private let activeTraderName: String
    private lazy var traders: [Trader] = {
        var allTraders = TraderRepository.getInstance().getAllTraders()
        for trader in allTraders {
            if trader.name == self.activeTraderName {
                let index = allTraders.indexOf(trader)
                allTraders.removeAtIndex(index!)
                allTraders.insert(trader, atIndex: 0)
                break
            }
        }
        return allTraders
    }()
}