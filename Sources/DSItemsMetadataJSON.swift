//
//  DSItemsMetadataJSON.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

open class DSItemsMetadataJSON: DSContentJSONDictionary<String,Any> {
    public typealias JSONObjectType = [String:Any]

    public var tags: [String]? {
        get {
            return content["tags"] as? [String]
        }
        set {
            set(newValue, for: "tags")
        }
    }

    override public required init() {
        super.init()
    }

    public required init?(content: JSONObjectType) {
        super.init(json: content)
    }
}
