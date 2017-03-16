//
//  DataStoreContentJSONArray.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

open class DataStoreContentJSONArray<ElementType>: DataStoreContentJSON {
    var json: [ElementType]

    public var content: [ElementType] {
        return json
    }

    public init() {
        json = []
    }

    public init(json: [ElementType]) {
        self.json = json
    }

    public func append(_ element: ElementType) {
        json.append(element)
    }

    public func remove(at index: Int) {
        json.remove(at: index)
    }
}
