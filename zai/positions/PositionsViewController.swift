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
        
        self.positionListView = PositionListView(view: self.tableView, trader: self.trader)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        self.positionListView.startWatch()
        self.positionListView.reloadData()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        self.positionListView.stopWatch()
    }
    
    var account: Account! = nil
    var trader: Trader! = nil
    
    var positionListView: PositionListView! = nil
    
    @IBOutlet weak var tableView: UITableView!

}
