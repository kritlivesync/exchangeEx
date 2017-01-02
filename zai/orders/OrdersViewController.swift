//
//  OrdersViewController.swift
//  zai
//
//  Created by 渡部郷太 on 12/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class OrdersViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let account = getAccount()
        
        self.orderListView = OrderListView(view: self.orderTableView, trader: account!.activeExchange.trader)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        self.orderListView.startWatch()
        self.orderListView.reloadData()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        self.orderListView.stopWatch()
    }
    
    var account: Account?
    var orderListView: OrderListView!
    @IBOutlet weak var orderTableView: UITableView!
}
