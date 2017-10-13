//
//  DSContentData.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

open class DSContentData: DSContent {
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

extension DSContentData {
    public func fromData(_ data: Data) -> Error? {
        self.data = data
        return nil
    }

    public func toData() -> Data? {
        return self.data
    }

    public func fromURL(_ url: URL) -> Error? {
        do {
            try self.data = Data(contentsOf: url)
            return nil
        }
        catch let error {
            return error
        }
    }

    public func toURL(_ url: URL) -> Error? {
        do {
            try data.write(to: url)
            return nil
        }
        catch let error {
            return error
        }
    }
}
