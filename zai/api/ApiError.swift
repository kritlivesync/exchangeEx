//
//  ApiError.swift
//  zai
//
//  Created by 渡部郷太 on 1/1/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation


public enum ApiErrorType : Error {
    case NO_PERMISSION
    case NONCE_NOT_INCREMENTED
    case UNKNOWN_ERROR
}


public struct ApiError {
    public init(errorType: ApiErrorType, message: String="") {
        self.errorType = errorType
        self.message = message
    }
    
    public let errorType: ApiErrorType
    public let message: String
}
