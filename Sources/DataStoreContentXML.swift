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
        #if os(Linux)
            xml = try XMLDocument(data: data, options: XMLNode.Options.documentValidate)
        #else
            xml = try XMLDocument(data: data, options: Int(XMLNode.Options.documentValidate.rawValue))
        #endif
            return nil
        }
        catch let error {
            return error
        }
    }

    public func toData() -> Data? {
    #if os(Linux)
        return xml.xmlData(withOptions: XMLNode.Options.documentIncludeContentTypeDeclaration)
    #else
        return xml.xmlData(withOptions: Int(XMLNode.Options.documentIncludeContentTypeDeclaration.rawValue))
    #endif
    }

    public func fromURL(_ url: URL) -> Error? {
        do {
        #if os(Linux)
            xml = try XMLDocument(contentsOf: url, options: XMLNode.Options.documentValidate)
        #else
            xml = try XMLDocument(contentsOf: url, options: Int(XMLNode.Options.documentValidate.rawValue))
        #endif
            return nil
        }
        catch let error {
            return error
        }
    }
    
    public func toURL(_ url: URL) -> Error? {
        do {
            #if os(Linux)
                try xml.xmlData(withOptions: XMLNode.Options.documentIncludeContentTypeDeclaration).write(to: url)
            #else
                try xml.xmlData(withOptions: Int(XMLNode.Options.documentIncludeContentTypeDeclaration.rawValue)).write(to: url)
            #endif
            return nil
        }
        catch let error {
            return error
        }
    }
}
