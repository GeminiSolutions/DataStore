//
//  DataStoreContentJSON.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public enum DataStoreContentJSONError: Error {
    case jsonObjectTypeNotValid
}

protocol DataStoreContentJSON: DataStoreContent {
    associatedtype jsonObjectType
    var json: jsonObjectType { get set }
}

extension DataStoreContentJSON {
    public func fromData(_ data: Data) -> Error? {
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? jsonObjectType else { return DataStoreContentJSONError.jsonObjectTypeNotValid }
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
        catch let error {
            print(error)
            return nil
        }
    }
}