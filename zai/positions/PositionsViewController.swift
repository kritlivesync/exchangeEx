//
//  PositionsViewController.swift
//  zai
//
//  Created by 渡部郷太 on 9/4/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit



class PositionsViewController : UIViewController, UITextFieldDelegate {
    
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
    
    @IBAction func pushAddPositionButton(_ sender: Any) {
        let addPositionController = UIAlertController(title: "ポシション追加", message: "新しいロングポジションを追加します。注文は執行されません。", preferredStyle: .alert)
        var priceTextField: UITextField?
        addPositionController.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            priceTextField = textField
            textField.tag = 0
            textField.placeholder = "価格"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
        var amountextField: UITextField?
        addPositionController.addTextField { (textField) -> Void in
            // Enter the textfiled customization code here.
            amountextField = textField
            textField.tag = 1
            textField.placeholder = "数量"
            textField.keyboardType = .decimalPad
            textField.delegate = self
        }

        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { action in
            print("Cancel Button Pressed")
        }
        addPositionController.addAction(cancel)
        
        let add = UIAlertAction(title: "追加", style: .default, handler: { action in
            let order = BuyOrder(currencyPair: .BTC_JPY, price: Double((priceTextField?.text)!), amount: Double((amountextField?.text)!)!, api: self.trader.account.privateApi)
            let position = PositionRepository.getInstance().createLongPosition(order!, trader: self.trader)
            self.trader.addPosition(position)
            self.positionListView.reloadData()
            
        })
        add.isEnabled = false
        addPositionController.addAction(add)
        
        self.addPositionController = addPositionController
        self.present(addPositionController, animated: true, completion: nil)
    }
    
    // UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.isEmpty {
            // delete
            if textField.text?.characters.count == range.length {
                self.addPositionController?.actions.last?.isEnabled = false
            }
            return true
        } else {
            if self.validate(string: textField.text!) {
                self.addPositionController?.actions.last?.isEnabled = true
                let textFields = self.addPositionController?.textFields
                for field in textFields! {
                    if textField.tag != field.tag {
                        if field.text?.characters.count == 0 {
                            self.addPositionController?.actions.last?.isEnabled = false
                        }
                    }
                }
                return true
            } else {
                return false
            }
        }
    }
    
    func validate(string: String) -> Bool {
        var pattern = "^[0-9]+\\."
        var reg = try! NSRegularExpression(pattern: pattern)
        var matches = reg.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count))
        if matches.count == 0 {
            return true
        }
        
        // for amount
        pattern = "^[0-9]+\\.[0-9]{4}$"
        reg = try! NSRegularExpression(pattern: pattern)
        matches = reg.matches(in: string, options: [], range: NSMakeRange(0, string.characters.count))
        return matches.count == 0
    }
    
    var account: Account! = nil
    var trader: Trader! = nil
    
    var positionListView: PositionListView! = nil
    var addPositionController: UIAlertController?
    
    @IBOutlet weak var tableView: UITableView!

}
