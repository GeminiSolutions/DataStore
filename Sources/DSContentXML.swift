//
//  DSContentXML.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

#if os(Linux) || os(macOS)
open class DSContentXML: DSContent {
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

extension DSContentXML {
    public func fromData(_ data: Data) -> Error? {
        do {
            xml = try XMLDocument(data: data, options: XMLNode.Options.documentValidate)
            return nil
        }
        catch let error {
            return error
        }
    }

    public func toData() -> Data? {
        return xml.xmlData(options: XMLNode.Options.documentIncludeContentTypeDeclaration)
    }

    public func fromURL(_ url: URL) -> Error? {
        do {
            xml = try XMLDocument(contentsOf: url, options: XMLNode.Options.documentValidate)
            return nil
        }
        catch let error {
            return error
        }
    }

    public func toURL(_ url: URL) -> Error? {
        do {
            try xml.xmlData(options: XMLNode.Options.documentIncludeContentTypeDeclaration).write(to: url)
            return nil
        }
        catch let error {
            return error
        }
    }
}
#endif
