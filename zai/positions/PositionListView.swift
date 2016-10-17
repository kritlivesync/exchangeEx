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


@objc protocol PositionListViewDelegate {
    func didSelectPosition(_ position: Position)
}


class PositionListView : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(view: UITableView, trader: Trader, btcJpyPrice: Double) {
        self.trader = trader
        self.view = view
        self.btcJpyPrice = btcJpyPrice
        self.tappedRow = -1
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trader.positions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "positionListViewCell", for: indexPath) as! PositionListViewCell
        cell.setPosition(self.trader.positions[(indexPath as NSIndexPath).row] as? Position, btcJpyPrice: self.btcJpyPrice)
        cell.closeButton.addTarget(self, action: #selector(PositionListView.pushCloseButton(_:event:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tappedRow = (indexPath as NSIndexPath).row
        if self.delegate != nil {
            self.delegate!.didSelectPosition(self.trader.positions[(indexPath as NSIndexPath).row] as! Position)
        }
    }
    
    func pushCloseButton(_ sender: AnyObject, event: UIEvent?) {
        var row = -1
        for touch in (event?.allTouches)! {
            let point = touch.location(in: self.view)
            row = (self.view.indexPathForRow(at: point)! as NSIndexPath).row
        }
        if 0 <= row && row < self.trader.positions.count {
            let position = self.trader.positions[row] as? Position
            position?.unwind(nil, price: nil) { err in
                if let e = err {
                    return
                }
            }
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    internal var delegate: PositionListViewDelegate? = nil
    fileprivate let trader: Trader
    fileprivate let view: UITableView
    fileprivate let btcJpyPrice: Double
    fileprivate var tappedRow: Int
}
