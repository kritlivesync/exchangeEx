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
    func didSelectActivate(_ trader: Trader)
    func didSelectDeactivate(_ trader: Trader)
    func didSelectShowPositions(_ trader: Trader)
    func didSelectDelete(_ trader: Trader)
}


class TraderMenuViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func pushActivateButton(_ sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.didSelectActivate(self.trader!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pushDeactivateButton(_ sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.didSelectDeactivate(self.trader!)
        }
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func pushShowPositionsButton(_ sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.didSelectShowPositions(self.trader!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pushDeleteButton(_ sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.didSelectDelete(self.trader!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
 
    internal var trader: Trader? = nil
    internal var delegate: TraderMenuViewDelegate?
}
