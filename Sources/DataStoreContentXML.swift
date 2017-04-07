//
//  DataStoreContentXML.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

protocol DataStoreContentXML: DataStoreContent {
    var xml: XMLDocument { get set }
}

extension DataStoreContentXML {
    public func fromData(_ data: Data) -> Error? {
        do {
            xml = try XMLDocument(data: data, options: Int(XMLNode.Options.documentValidate.rawValue))
            return nil
        }
        catch let error {
            return error
        }
    }

    public func toData() -> Data? {
        return xml.xmlData(withOptions: Int(XMLNode.Options.documentIncludeContentTypeDeclaration.rawValue))
    }
}
