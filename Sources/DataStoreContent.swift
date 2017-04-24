//
//  DataStoreContent.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public protocol DataStoreContent: class {
    var largeSize: Bool { get }

    func fromData(_ data: Data) -> Error?
    func toData() -> Data?
    func fromURL(_ url: URL) -> Error?
    func toURL(_ url: URL) -> Error?
}
