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
    func didSelectPosition(position: Position)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trader.positions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("positionListViewCell", forIndexPath: indexPath) as! PositionListViewCell
        cell.setPosition(self.trader.positions[indexPath.row] as? Position, btcJpyPrice: self.btcJpyPrice)
        cell.closeButton.addTarget(self, action: #selector(PositionListView.pushCloseButton(_:event:)), forControlEvents: .TouchUpInside)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tappedRow = indexPath.row
        if self.delegate != nil {
            self.delegate!.didSelectPosition(self.trader.positions[indexPath.row] as! Position)
        }
    }
    
    func pushCloseButton(sender: AnyObject, event: UIEvent?) {
        var row = -1
        for touch in (event?.allTouches())! {
            let point = touch.locationInView(self.view)
            row = self.view.indexPathForRowAtPoint(point)!.row
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
    private let trader: Trader
    private let view: UITableView
    private let btcJpyPrice: Double
    private var tappedRow: Int
}