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
    
    func reloadTrader(_ traderName: String) {
        self.trader = TraderRepository.getInstance().findTraderByName(traderName)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "traderViewCell", for: indexPath) as! TraderViewCell
        cell.setTrader(self.trader)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let d = self.delegate {
            d.didTouchTraderView()
        }
    }
    
    internal var trader: Trader?
    fileprivate var view: UITableView! = nil
    fileprivate let api: PrivateApi
    internal var delegate: TraderViewDelegate?
}
