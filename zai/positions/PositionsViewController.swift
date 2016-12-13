//
//  PositionsViewController.swift
//  zai
//
//  Created by 渡部郷太 on 9/4/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit



class PositionsViewController : UIViewController, BitCoinDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bitcoin = BitCoin()
        self.bitcoin.delegate = self
    }
    
    // BitCoinDelegate
    func recievedJpyPrice(price: Int) {
        self.positionListView = PositionListView(view: self.tableView, trader: self.trader, btcPrice: price)
        self.positionListView.reloadData()
    }
    
    var account: Account! = nil
    var trader: Trader! = nil
    
    var bitcoin: BitCoin! = nil
    
    var positionListView: PositionListView! = nil
    
    @IBOutlet weak var tableView: UITableView!

}
