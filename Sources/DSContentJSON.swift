//
//  DSContentJSON.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public enum DSContentJSONError: Error {
    case jsonObjectTypeNotValid
}

protocol DSContentJSON: DSContent {
    associatedtype jsonObjectType
    var json: jsonObjectType { get set }
}

extension DSContentJSON {
    public func fromData(_ data: Data) -> Error? {
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? jsonObjectType else { return DSContentJSONError.jsonObjectTypeNotValid }
            json = jsonObject
            return nil
        }
        catch let error {
            return error
        }
    }

    public func toData() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json)
        }
        catch {
            return nil
        }
    }

    public func fromURL(_ url: URL) -> Error? {
        do {
            let data = try Data(contentsOf: url)
            return fromData(data)
        }
        catch let error {
            return error
        }
    }

    public func toURL(_ url: URL) -> Error? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json)
            try data.write(to: url)
            return nil
        }
        catch let error {
            return error
        }
    }
}
