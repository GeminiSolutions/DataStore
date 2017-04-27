//
//  DataStoreContentFile.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public enum DataStoreContentFileError: Error {
    case invalidFileURL
}

open class DataStoreContentFile: DataStoreContent {
    var fileURL: URL
    
    public init?(fileURL: URL) {
        guard fileURL.isFileURL else { return nil }
        self.fileURL = fileURL
    }

    public var content: URL {
        return self.fileURL
    }
}

extension DataStoreContentFile {
    public func fromData(_ data: Data) -> Error? {
        do {
            try data.write(to: fileURL)
            return nil
        }
        catch let error {
            return error
        }
    }
    
    public func toData() -> Data? {
        do {
            return try Data(contentsOf: fileURL)
        }
        catch {
            return nil
        }
    }
    
    public func fromURL(_ url: URL) -> Error? {
        guard url.isFileURL else { return DataStoreContentFileError.invalidFileURL }
        do {
            try FileManager.default.copyItem(at: url, to: fileURL)
            return nil
        }
        catch let error {
            return error
        }
    }
    
    public func toURL(_ url: URL) -> Error? {
        guard url.isFileURL else { return DataStoreContentFileError.invalidFileURL }
        do {
            try FileManager.default.copyItem(at: fileURL, to: url)
            return nil
        }
        catch let error {
            return error
        }
    }
}
