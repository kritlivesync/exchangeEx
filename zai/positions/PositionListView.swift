//
//  PositionListView.swift
//  zai
//
//  Created by 渡部郷太 on 9/4/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

import ZaifSwift


class PositionListView : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(view: UITableView, api: PrivateApi) {
        self.api = api
        self.view = view
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TraderRepository.getInstance().count()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("traderListViewCell", forIndexPath: indexPath) as! TraderListViewCell
        let trader = self.traders[indexPath.row]
        cell.setTrader(trader)
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.delegate != nil {
            self.delegate!.didSelectTrader(self.traders[indexPath.row])
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    internal func reloadTraders(currentTraderName: String) {
        var allTraders = TraderRepository.getInstance().getAllTraders(self.api)
        for trader in allTraders {
            if trader.name == currentTraderName {
                let index = allTraders.indexOf(trader)
                allTraders.removeAtIndex(index!)
                allTraders.insert(trader, atIndex: 0)
                break
            }
        }
        self.traders = allTraders
    }
    
    private var traders: [Trader] = []
    internal var delegate: TraderListViewDelegate? = nil
    private let api: PrivateApi
    private let view: UITableView
}