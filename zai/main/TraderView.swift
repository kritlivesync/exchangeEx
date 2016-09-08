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


@objc protocol TraderViewDelegate {
    func didTouchTraderView()
}


class TraderView : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(view: UITableView, api: PrivateApi) {
        self.api = api
        
        super.init()
        self.view = view
        self.view.delegate = self
        self.view.dataSource = self
    }
    
    func reloadData() {
        self.view.reloadData()
    }
    
    func reloadTrader(traderName: String) {
        self.trader = TraderRepository.getInstance().findTraderByName(traderName, api: self.api)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("traderViewCell", forIndexPath: indexPath) as! TraderViewCell
        cell.setTrader(self.trader)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let d = self.delegate {
            d.didTouchTraderView()
        }
    }
    
    internal var trader: Trader?
    private var view: UITableView! = nil
    private let api: PrivateApi
    internal var delegate: TraderViewDelegate?
}