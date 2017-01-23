//
//  Validation.swift
//  zai
//
//  Created by 渡部郷太 on 1/22/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation


class BtcAmountValidator {
    static let lowerLimit = BitCoin.Satoshi
    static let upperLimit = 100000000.0
    
    static func allowBtcAmountInput(existingInput: String, addedString: String, replaceRange: NSRange) -> Bool {
        if addedString.isEmpty {
            return true
        } else {
            let nsstring = existingInput as NSString
            let newInput = nsstring.replacingCharacters(in: replaceRange, with: addedString)
            if BtcAmountValidator.validateExistingInput(string: existingInput) &&
               BtcAmountValidator.validateInput(string: addedString) &&
               BtcAmountValidator.validateCombinationInput(existingInput: existingInput, addedString: addedString) &&
               BtcAmountValidator.validateString(amount: newInput) {
                return true
            }
            return false
        }
    }
    
    static func validateExistingInput(string: String) -> Bool {
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
    
    static func validateInput(string: String) -> Bool {
        return Double(string) != nil || string == "."
    }
    
    static func validateCombinationInput(existingInput: String, addedString: String) -> Bool {
        if addedString == "." && existingInput.contains(".") {
            return false
        }
        return true
    }
    
    static func validateString(amount: String) -> Bool {
        guard let double = Double(amount) else {
            return false
        }
        return double <= Double(INT_MAX)
    }
    
    static func validateRange(amount: Double) -> Bool {
        return BtcAmountValidator.lowerLimit <= amount && amount <= BtcAmountValidator.upperLimit
    }
}


class BtcPriceValidator {
    static let lowerLimit = 1
    static let upperLimit = 100000000
    
    static func allowBtcPriceInput(existingInput: String, addedString: String, replaceRange: NSRange) -> Bool {
        if addedString.isEmpty {
            return true
        } else {
            let nsstring = existingInput as NSString
            let newInput = nsstring.replacingCharacters(in: replaceRange, with: addedString)
            guard let value = Int64(newInput) else {
                return false
            }
            return value <= Int64(INT_MAX)
        }
    }
    
    static func validateRange(price: Int) -> Bool {
        return BtcPriceValidator.lowerLimit <= price && price <= BtcPriceValidator.upperLimit
    }
}


func validateBtcAmount(amount: Double) -> Bool {
    let amount10000 = amount * 10000
    let rest = amount10000 - Double(Int(amount10000))
    if rest != 0 || amount <= 0 {
        return false
    }
    return true
}


func validateUserId(existingInput: String, addedString: String) -> Bool {
    return existingInput.characters.count + addedString.characters.count <= 24
}

func validatePassword(existingInput: String, addedString: String) -> Bool {
    return existingInput.characters.count + addedString.characters.count <= 18
}


