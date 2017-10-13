//
//  DSContentLargeObject.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

open class DSContentLargeObject: DSContent {
    enum ContentType {
        case data
        case file
    }

    var dataContent: DSContentData?
    var fileContent: DSContentFile?
    var contentType: ContentType

    public var content: DSContent {
        switch contentType {
        case .data: return dataContent!
        case .file: return fileContent!
        }
    }

    public var usesURL: Bool {
        switch contentType {
        case .data: return false
        case .file: return true
        }
    }

    public init() {
        contentType = .data
        dataContent = DSContentData()
    }

    public init(data: Data) {
        contentType = .data
        dataContent = DSContentData(data: data)
    }
    
    public init?(fileURL: URL) {
        contentType = .file
        fileContent = DSContentFile(fileURL: fileURL)
        guard fileContent != nil else { return nil }
    }
}

extension DSContentLargeObject {
    public func fromData(_ data: Data) -> Error? {
        return content.fromData(data);
    }
    
    public func toData() -> Data? {
        return content.toData()
    }
    
    public func fromURL(_ url: URL) -> Error? {
        return content.fromURL(url)
    }
    
    public func toURL(_ url: URL) -> Error? {
        return content.toURL(url)
    }
}
