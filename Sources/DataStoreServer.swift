//
//  DataStoreServer.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public enum DataStoreServerError: Error {
    case notImplemented
    case badRequestMethod
    case badRequestContent
    case badResponseContent
    case emptyRequestContent
}

public protocol DataStoreServerTransport: class {
    typealias ProcessBlock = (_ path: String, _ request: URLRequest, _ response: HTTPURLResponse) -> Error?

    var processBlock: ProcessBlock { get set }
}

public class DataStoreServer {
    public typealias ResponseBlock = (_ response: HTTPURLResponse ) -> Error?
    public typealias ItemResponseBlock = (_ itemId: String, _ response: HTTPURLResponse) -> Error?

    private var transport: DataStoreServerTransport

    public var getItemsBlock: ResponseBlock = { _ in return DataStoreServerError.notImplemented }
    public var getItemsCountBlock: ResponseBlock = { _ in return DataStoreServerError.notImplemented }
    public var getItemsIdentifiersBlock: ResponseBlock = { _ in return DataStoreServerError.notImplemented }
    public var getItemBlock: ItemResponseBlock = { _,_ in return DataStoreServerError.notImplemented }
    public var putItemBlock: ItemResponseBlock = { _,_ in return DataStoreServerError.notImplemented }
    public var deleteItemBlock: ItemResponseBlock = { _,_ in return DataStoreServerError.notImplemented }

    public init(transport: DataStoreServerTransport) {
        self.transport = transport
        self.transport.processBlock = process
    }

    func process(_ path: String, _ request: URLRequest, _ response: HTTPURLResponse) -> Error? {
        guard let method = request.httpMethod else { return DataStoreServerError.badRequestMethod }

        if path == "/items" {
            guard ["GET", "POST"].contains(method) else { return DataStoreServerError.notImplemented }
            return getItemsBlock(response)
        }
        else if path == "/items/count" {
            guard ["GET"].contains(method) else { return DataStoreServerError.notImplemented }
            return getItemsCountBlock(response)
        }
        else if path == "/items/identifiers" {
            guard ["GET"].contains(method) else { return DataStoreServerError.notImplemented }
            return getItemsIdentifiersBlock(response)
        }
        else if path.hasPrefix("/items/") {
            let itemId = path.substring(from: path.index(path.startIndex, offsetBy: 7))
            switch method {
            case "GET":     return getItemBlock(itemId, response)
            case "PUT":     return putItemBlock(itemId, response)
            case "DELETE":  return deleteItemBlock(itemId, response)
            default:        break
            }
        }

        return DataStoreServerError.notImplemented
    }
}
