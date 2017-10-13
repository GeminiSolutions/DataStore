//
//  DSContent.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public protocol DSContent: class {
    func fromData(_ data: Data) -> Error?
    func toData() -> Data?
    func fromURL(_ url: URL) -> Error?
    func toURL(_ url: URL) -> Error?
}
