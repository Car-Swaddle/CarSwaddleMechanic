//
//  Tweak.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 1/27/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import Foundation

public class Tweak: CustomDebugStringConvertible {
    
    public init(label: String, options: Options, userDefaultsKey: String, valueDidChange: @escaping (_ tweak: Tweak) -> Void = { _ in}, defaultValue: Any? = nil, requiresAppReset: Bool = false) {
        self.label = label
        self.options = options
        self.userDefaultsKey = userDefaultsKey
        if self.value == nil {
            self.value = defaultValue
        }
        self.valueDidChange = valueDidChange
        self.requiresAppReset = requiresAppReset
    }
    
    public let label: String
    public var value: Any? {
        get {
            return UserDefaults.standard.value(forKey: userDefaultsKey)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: userDefaultsKey)
            valueDidChange(self)
        }
    }
    public var valueDidChange: (_ tweak: Tweak) -> Void = { _ in }
    public var userDefaultsKey: String
    public var requiresAppReset: Bool = false
    
    public var options: Options
    
    public enum Options: CustomDebugStringConvertible {
        case bool
        case openString
        case openInt
        case string(values: [String])
        case integer(values: [Int])
        
        public var debugDescription: String {
            switch self {
            case .bool: return "bool"
            case .openString: return "open String"
            case .openInt: return "openInt"
            case .string(let values):
                return "string with values: " + values.joined(separator: ", ")
            case .integer(let values):
                return "integer with values: " + values.map{ String($0) }.joined(separator: ", ")
            }
        }
        
    }
    
    public var debugDescription: String {
        return "label: \(label), value: \(String(describing: value)), options: \(label)"
    }
    
}
