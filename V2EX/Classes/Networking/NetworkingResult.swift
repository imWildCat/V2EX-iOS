//
//  NetworkingResult.swift
//  V2EX
//
//  Created by WildCat on 10/5/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

/**
Used to represent whether a request was successful or encountered an error.

- Success: The request and all post processing operations were successful resulting in the serialization of the
provided associated value.
- Failure: The request encountered an error resulting in a failure. The associated values are the original data
provided by the server as well as the error that caused the failure.
*/
public enum NetworkingResult<Value> {
    case Success(Value)
    case Failure(NSHTTPURLResponse?, ErrorType?)
    
    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }
    
    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }
    
    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }
    
    /// Returns the associated data value if the result is a failure, `nil` otherwise.
//    public var data: NSData? {
//        switch self {
//        case .Success:
//            return nil
//        case .Failure(let data, _):
//            return data
//        }
//    }
    
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(_, let error):
            return error
        }
    }
}

// MARK: - CustomStringConvertible

extension NetworkingResult: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Success:
            return "SUCCESS"
        case .Failure:
            return "FAILURE"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension NetworkingResult: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .Success(let value):
            return "SUCCESS: \(value)"
        case .Failure(_, let error):
//            if let
//                data = data,
//                utf8Data = NSString(data: data, encoding: NSUTF8StringEncoding)
//            {
//                return "FAILURE: \(error) \(utf8Data)"
//            } else {
                return "FAILURE with Error: \(error)"
//            }
        }
    }
}