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
}
