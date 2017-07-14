//
//  DataStoreContent.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public protocol DataStoreContent: class {
    func fromData(_ data: Data) -> Error?
    func toData() -> Data?
    func fromURL(_ url: URL) -> Error?
    func toURL(_ url: URL) -> Error?
}

extension DataStoreContent {
    public static func dateString(from date: Date) -> String {
        return DataStore.string(from: date)
    }

    public static func date(from string: String) -> Date? {
        return DataStore.date(from: string)
    }
}
