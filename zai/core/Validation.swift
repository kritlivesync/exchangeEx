//
//  Validation.swift
//  zai
//
//  Created by 渡部郷太 on 1/22/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation


func allowBtcAmountInput(existingInput: String, addedString: String) -> Bool {
    if addedString.isEmpty {
        return true
    } else {
        if validateExistingInput(string: existingInput) &&
           validateInput(string: addedString) &&
           validateCombinationInput(existingInput: existingInput, addedString: addedString) {
            return true
        }
    }
    return false
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

fileprivate func validateExistingInput(string: String) -> Bool {
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

fileprivate func validateInput(string: String) -> Bool {
    return Double(string) != nil || string == "."
}

fileprivate func validateCombinationInput(existingInput: String, addedString: String) -> Bool {
    if addedString == "." && existingInput.contains(".") {
        return false
    }
    return true
}
