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
    
    init(view: UITableView, trader: Trader, btcPrice: Int) {
        self.positions = trader.getActivePositions()
        self.view = view
        self.tappedRow = -1
        self.btcPrice = btcPrice
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let c = self.positions.count
        return c
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "positionListViewCell", for: indexPath) as! PositionListViewCell
        cell.setPosition(self.positions[(indexPath as NSIndexPath).row] as? Position, btcPrice: self.btcPrice)
        cell.closeButton.addTarget(self, action: #selector(PositionListView.pushCloseButton(_:event:)), for: .touchUpInside)
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tappedRow = (indexPath as NSIndexPath).row
        if self.delegate != nil {
            self.delegate!.didSelectPosition(self.positions[(indexPath as NSIndexPath).row] as! Position)
        }
    }
    
    func pushCloseButton(_ sender: AnyObject, event: UIEvent?) {
        var row = -1
        for touch in (event?.allTouches)! {
            let point = touch.location(in: self.view)
            row = (self.view.indexPathForRow(at: point)! as NSIndexPath).row
        }
        if 0 <= row && row < self.positions.count {
            let position = self.positions[row] as? Position
            position?.unwind(nil, price: nil) { err in
                if let e = err {
                    return
                } else {
                    self.positions.remove(at: row)
                    DispatchQueue.main.async {
                        self.reloadData()
                    }
                    
                }
            }
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    internal var delegate: PositionListViewDelegate? = nil
    fileprivate var positions: [Position]
    fileprivate let view: UITableView
    fileprivate var tappedRow: Int
    fileprivate let btcPrice: Int
}
