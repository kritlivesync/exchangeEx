//
//  File.swift
//  zai
//
//  Created by 渡部郷太 on 8/27/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

class SelectTraderViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        switch segue.identifier! {
        case self.newTraderSegue:
            let destController = segue.destinationViewController as! NewTraderViewController
            destController.account = account!
        default: break
        }
    }
    
    
    internal var account: Account!
    
    private let newTraderSegue = "newTraderSegue"

    @IBOutlet weak var tableView: UITableView!

}

