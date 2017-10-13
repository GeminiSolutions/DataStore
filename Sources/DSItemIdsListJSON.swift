//
//  DSItemIdsListJSON.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public class DSItemIdsListJSON<ItemIdType>: DSContentJSONArray<ItemIdType> {
    public var itemIds: [ItemIdType] {
        return content
    }
    
    public override init() {
        super.init()
    }
    
    public init(ids: [ItemIdType]) {
        super.init(json: ids)
    }
}
