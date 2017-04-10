//
//  DataStoreItemsCountJSON.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public class DataStoreItemsCountJSON: DataStoreContentJSONDictionary<String,UInt64> {
    public var value: UInt64 {
        get {
            return content["count"] ?? 0
        }
        set {
            set(newValue, for: "count")
        }
    }
    
    public override init() {
        super.init(json: ["count":0])
    }
    
    public init(count: UInt64) {
        super.init(json: ["count":count])
    }
}
