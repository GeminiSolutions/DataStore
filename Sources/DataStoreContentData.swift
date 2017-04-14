//
//  DataStoreContentData.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

open class DataStoreContentData: DataStoreContent {
    var data: Data

    public var content: Data {
        return data
    }

    public init() {
        data = Data()
    }

    public init(data: Data) {
        self.data = data
    }
}

extension DataStoreContentData {
    public func fromData(_ data: Data) -> Error? {
        self.data = data
        return nil
    }

    public func toData() -> Data? {
        return data
    }
}
