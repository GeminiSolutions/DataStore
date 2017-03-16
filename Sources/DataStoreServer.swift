//
//  DataStoreServer.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public enum DataStoreServerError: Error {
    case badRequestContent
    case badResponseContent
    case emptyRequestContent
}

public protocol DataStoreServerTransport: class {
}

public class DataStoreServer {
    private var transport: DataStoreServerTransport

    public init(transport: DataStoreServerTransport) {
        self.transport = transport
    }
}
