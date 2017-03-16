//
//  DataStoreContentJSONDictionary.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

open class DataStoreContentJSONDictionary<KeyType: Hashable, ValueType>: DataStoreContentJSON {
    var json: [KeyType:ValueType]

    public var content: [KeyType:ValueType] {
        return json
    }

    public init() {
        json = [:]
    }

    public init(json: [KeyType:ValueType]) {
        self.json = json
    }
    
    public func set(_ value: ValueType?, for key: KeyType) {
        if value == nil {
            json.removeValue(forKey: key)
        }
        else {
            json[key] = value!
        }
    }
}
