//
//  File.swift
//  zai
//
//  Created by 渡部郷太 on 8/27/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


@objc protocol TraderListViewDelegate {
    func didSelectTrader(_ trader: Trader)
}


class TraderListView : NSObject, UITableViewDelegate, UITableViewDataSource {

    init(view: UITableView, api: PrivateApi) {
        self.api = api
        self.view = view
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TraderRepository.getInstance().count()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "traderListViewCell", for: indexPath as IndexPath) as! TraderListViewCell
        let trader = self.traders[indexPath.row]
        cell.setTrader(trader)
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.delegate != nil {
            self.delegate!.didSelectTrader(self.traders[(indexPath as NSIndexPath).row])
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    internal func reloadTraders(_ currentTraderName: String) {
        var allTraders = TraderRepository.getInstance().getAllTraders(self.api)
        for trader in allTraders {
            if trader.name == currentTraderName {
                let index = allTraders.index(of: trader)
                allTraders.remove(at: index!)
                allTraders.insert(trader, at: 0)
                break
            }
        }
        self.traders = allTraders
    }
    
    fileprivate var traders: [Trader] = []
    internal var delegate: TraderListViewDelegate? = nil
    fileprivate let api: PrivateApi
    fileprivate let view: UITableView
}
