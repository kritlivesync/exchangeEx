//
//  PositionCreateViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 12/30/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


class PositionEditor : NSObject {
    init(title: String, message: String) {
        self.controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    let controller: UIAlertController
    var priceTextField: UITextField?
    var amountextField: UITextField?
}


class ValidatablePositionEditor : PositionEditor, UITextFieldDelegate {
    override init(title: String, message: String) {
        super.init(title: title, message: message)
    }
    
    // UITextFieldDelegate
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let nsstring = textField.text! as NSString
        let newInput = nsstring.replacingCharacters(in: range, with: string)
        
        if textField.tag == 0 {
            if !BtcPriceValidator.allowBtcPriceInput(existingInput: textField.text!, addedString: string, replaceRange: range) {
                return false
            }
        } else if textField.tag == 1 {
            if !BtcAmountValidator.allowBtcAmountInput(existingInput: textField.text!, addedString: string, replaceRange: range) {
                return false
            }
        } else {
            return false
        }

        // all field are filled by valid value? if no, disable ok button.
        self.controller.actions.last?.isEnabled = true
        
        var newValue = 0.0
        if let val = Double(newInput as String) {
            newValue = val
        }
        
        if textField.tag == 0 {
            if !BtcPriceValidator.validateRange(price: Int(newValue)) {
                self.controller.actions.last?.isEnabled = false
            }
        } else {
            if !BtcAmountValidator.validateRange(amount: newValue) {
                self.controller.actions.last?.isEnabled = false
            }
        }
        
        let textFields = self.controller.textFields
        for field in textFields! {
            if textField.tag != field.tag {
                if field.text?.characters.count == 0 {
                    self.controller.actions.last?.isEnabled = false
                }
                if let value = Double(field.text!) {
                    if field.tag == 0 {
                        if !BtcPriceValidator.validateRange(price: Int(value)) {
                            self.controller.actions.last?.isEnabled = false
                        }
                    } else {
                        if !BtcAmountValidator.validateRange(amount: value) {
                            self.controller.actions.last?.isEnabled = false
                        }
                    }
                }
            }
        }
        return true
    }
}

protocol PositionCreateDelegate {
    func createOk(position: Position)
    func createCancel()
}

class PositionCreateViewController : ValidatablePositionEditor {
    
    init(trader: Trader) {
        self.trader = trader
        super.init(title: LabelResource.positionAddViewTitle, message: Resource.positionAddMessage)
        
        self.addPriceField()
        self.addAmountField()
        self.addCancelAction()
        self.addOkAction()
    }
    
    fileprivate func addPriceField() {
        self.controller.addTextField { (textField) -> Void in
            self.priceTextField = textField
            textField.tag = 0
            textField.placeholder = LabelResource.price + "(" + BtcPriceValidator.lowerLimit.description + " - " + BtcPriceValidator.upperLimit.description + ")"
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
    }
    
    fileprivate func addAmountField() {
        self.controller.addTextField { (textField) -> Void in
            self.amountextField = textField
            textField.tag = 1
            textField.placeholder = LabelResource.amount + "(" + self.trader.exchange.api.orderUnit(currencyPair: ApiCurrencyPair(rawValue: self.trader.exchange.currencyPair)!).description + " - " + BtcAmountValidator.upperLimit.description + ")"
            textField.keyboardType = .decimalPad
            textField.delegate = self
        }
    }
    
    fileprivate func addCancelAction() {
        let action = UIAlertAction(title: LabelResource.cancel, style: .cancel) { action in
            self.delegate?.createCancel()
        }
        self.controller.addAction(action)
    }
    
    fileprivate func addOkAction() {
        let action = UIAlertAction(title: LabelResource.add, style: .default, handler: { action in
            let position = PositionRepository.getInstance().createLongPosition(trader: self.trader)
            let log = TradeLogRepository.getInstance().create(userId: self.trader.exchange.account.userId, action: .OPEN_LONG_POSITION, traderName: self.trader.name, orderAction: "bid", orderId: nil, currencyPair: "btc_jpy", price: Double(self.priceTextField!.text!)!, amount: Double(self.amountextField!.text!)!, positionId: position.id)
            position.addLog(log)
            position.open()
            self.delegate?.createOk(position: position)
        })
        action.isEnabled = false
        self.controller.addAction(action)
    }
    
    let trader: Trader
    var delegate: PositionCreateDelegate?
}


protocol PositionEditDelegate {
    func editOk(position: Position)
    func editCancel()
}

class PositionEditViewController : ValidatablePositionEditor {
    
    init(trader: Trader, position: Position) {
        self.trader = trader
        self.position = position
        super.init(title: LabelResource.positionEditViewTitle, message: "")
        
        self.addPriceField()
        self.addAmountField()
        self.addCancelAction()
        self.addOkAction()
    }
    
    fileprivate func addPriceField() {
        self.controller.addTextField { (textField) -> Void in
            self.priceTextField = textField
            textField.tag = 0
            textField.placeholder = LabelResource.price
            textField.text? = Int(self.position.price).description
            textField.keyboardType = .numberPad
            textField.delegate = self
        }
    }
    
    fileprivate func addAmountField() {
        self.controller.addTextField { (textField) -> Void in
            self.amountextField = textField
            textField.tag = 1
            textField.placeholder = LabelResource.amount
            textField.text? = self.position.amount.description
            textField.keyboardType = .decimalPad
            textField.delegate = self
        }
    }
    
    fileprivate func addCancelAction() {
        let action = UIAlertAction(title: LabelResource.cancel, style: .cancel) { action in
            self.delegate?.editCancel()
        }
        self.controller.addAction(action)
    }
    
    fileprivate func addOkAction() {
        let action = UIAlertAction(title: LabelResource.save, style: .default, handler: { action in
            self.position.price = Double(self.priceTextField!.text!)!
            self.position.amount = Double(self.amountextField!.text!)!
            self.delegate?.editOk(position: self.position)
        })
        action.isEnabled = false
        self.controller.addAction(action)
    }
    
    let trader: Trader
    let position: Position
    var delegate: PositionEditDelegate?
}
