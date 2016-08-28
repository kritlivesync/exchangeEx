//
//  TraderMenuViewController.swift
//  zai
//
//  Created by 渡部郷太 on 8/28/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


@objc protocol TraderMenuViewDelegate {
    func didSelectActivate(trader: Trader)
    func didSelectDeactivate(trader: Trader)
    func didSelectShowPositions(trader: Trader)
    func didSelectDelete(trader: Trader)
}


class TraderMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pushActivateButton(sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.didSelectActivate(self.trader!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pushDeactivateButton(sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.didSelectDeactivate(self.trader!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func pushShowPositionsButton(sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.didSelectShowPositions(self.trader!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pushDeleteButton(sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.didSelectDelete(self.trader!)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
 
    internal var trader: Trader? = nil
    internal var delegate: TraderMenuViewDelegate?
}