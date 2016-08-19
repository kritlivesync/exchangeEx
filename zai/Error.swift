//
//  Error.swift
//  zai
//
//  Created by 渡部郷太 on 8/19/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation


public enum ZaiErrorType : ErrorType {
    case ZAIF_API_ERROR
    case INVALID_ORDER
    case UNKNOWN_ERROR
}

public struct ZaiError {
    public init(errorType: ZaiErrorType=ZaiErrorType.UNKNOWN_ERROR, message: String="") {
        self.errorType = errorType
        self.message = message
    }
    
    public let errorType: ZaiErrorType
    public let message: String
}