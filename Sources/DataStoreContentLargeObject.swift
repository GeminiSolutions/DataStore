//
//  DataStoreContentLargeObject.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

open class DataStoreContentLargeObject: DataStoreContent {
    enum ContentType {
        case data
        case file
    }

    var dataContent: DataStoreContentData?
    var fileContent: DataStoreContentFile?
    var contentType: ContentType

    public var content: DataStoreContent {
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
        dataContent = DataStoreContentData()
    }

    public init(data: Data) {
        contentType = .data
        dataContent = DataStoreContentData(data: data)
    }
    
    public init?(fileURL: URL) {
        contentType = .file
        fileContent = DataStoreContentFile(fileURL: fileURL)
        guard fileContent != nil else { return nil }
    }
}

extension DataStoreContentLargeObject {
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
