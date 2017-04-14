//
//  DataStoreContentXML.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

open class DataStoreContentXML: DataStoreContent {
    var xml: XMLDocument

    public var content: XMLDocument {
        return xml
    }

    public init() {
        xml = XMLDocument()
    }

    public init(xml: XMLDocument) {
        self.xml = xml
    }
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
