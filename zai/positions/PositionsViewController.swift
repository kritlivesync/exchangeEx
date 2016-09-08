//
//  PositionsViewController.swift
//  zai
//
//  Created by 渡部郷太 on 9/4/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit



class PositionsViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BitCoin.getPriceFor(.JPY) { (err, price) in
            if let _ = err {
                
            } else {
                self.positionListView = PositionListView(view: self.tableView, trader: self.trader, btcJpyPrice: price)
                self.positionListView.reloadData()
            }
        }
    }
    
    var positionListView: PositionListView! = nil
    var trader: Trader! = nil
    
    @IBOutlet weak var tableView: UITableView!
}