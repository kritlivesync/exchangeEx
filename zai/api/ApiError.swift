//
//  ApiError.swift
//  zai
//
//  Created by Kyota Watanabe on 1/1/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation


public enum ApiErrorType : Error {
    case NO_PERMISSION
    case NONCE_NOT_INCREMENTED
    case INVALID_API_KEY
    case CONNECTION_ERROR
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
