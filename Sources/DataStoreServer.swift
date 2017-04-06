//
//  DataStoreServer.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public protocol DataStoreServerTransport: class {
    typealias ProcessBlock = (_ request: URLRequest, _ response: HTTPURLResponse) -> Void

    var processBlock: ProcessBlock { get set }
}

public protocol DataStoreServerDelegate: class {
    func getItems(_ query: [String:String]?, _ range: Range<Int>?) -> DataStoreContent?
    func createItem(_ content: DataStoreContent) -> DataStoreContent?
    func getItemsMetadata() -> DataStoreContent?
    func getItemsCount() -> DataStoreContent?
    func getItemsIdentifiers( _ range: Range<Int>?) -> DataStoreContent?
    func getItem(_ itemId: String) -> DataStoreContent?
    func updateItem(_ itemId: String, _ content: DataStoreContent) -> DataStoreContent?
    func deleteItem(_ itemId: String) -> DataStoreContent?
    func getEmptyItem() -> DataStoreContent?
}

public class DataStoreServer {
    private var transport: DataStoreServerTransport
    private var delegate: DataStoreServerDelegate

    public init(transport: DataStoreServerTransport, delegate: DataStoreServerDelegate) {
        self.transport = transport
        self.delegate = delegate
        self.transport.processBlock = process
    }

    private func process(_ request: URLRequest, _ response: HTTPURLResponse) {
        guard let url = request.url, let method = request.httpMethod else {
            processBadRequest(response)
            return
        }

        if url.path == "/items" {
            switch method {
            case "GET":     let query = queryFrom(url.query ?? "")
                            let range = rangeFrom(request.allHTTPHeaderFields?["Range"] ?? "")
                            processGet(response, delegate.getItems(query, range))
            case "POST":    if let requestContent = dataStoreContent(from: request) {
                                processPost(response, delegate.createItem(requestContent))
                            }
                            else {
                                processBadRequestContent(response)
                            }
            default:        break
            }
        }
        else if url.path == "/items/metadata" {
            switch method {
            case "GET":     processGet(response, delegate.getItemsMetadata())
            default:        break
            }
        }
        else if url.path == "/items/count" {
            switch method {
            case "GET":     processGet(response, delegate.getItemsCount())
            default:        break
            }
        }
        else if url.path == "/items/identifiers" {
            switch method {
            case "GET":     let range = rangeFrom(request.allHTTPHeaderFields?["Range"] ?? "")
                            processGet(response, delegate.getItemsIdentifiers(range))
            default:        break
            }
        }
        else if url.path.hasPrefix("/items/") {
            let itemId = url.path.substring(from: url.path.index(url.path.startIndex, offsetBy: 7))
            switch method {
            case "GET":     processGet(response, delegate.getItem(itemId))
            case "PUT":     if let requestContent = dataStoreContent(from: request) {
                                processPut(response, delegate.updateItem(itemId, requestContent))
                            }
                            else {
                                processBadRequestContent(response)
                            }
            case "DELETE":  processDelete(response, delegate.deleteItem(itemId))
            default:        break
            }
        }
    }

    private func queryFrom(_ string: String) -> [String:String]? {
        var query = [String:String]()
        string.components(separatedBy: "&").forEach({ (queryItem) in
            let queryItemComponents = queryItem.components(separatedBy: "=")
            if queryItemComponents.count == 2 {
                query[queryItemComponents.first!] = queryItemComponents.last!
            }
        })
        return query.isEmpty ? nil : query
    }

    private func rangeFrom(_ string: String) -> Range<Int>? {
        guard string.hasPrefix("items=") else { return nil }
        let bounds = string.substring(from: string.index(string.startIndex, offsetBy: 6)).components(separatedBy: "-")
        guard bounds.count == 2 else { return nil }
        guard let lowerBound = Int(bounds.first!), let upperBound = Int(bounds.last!) else { return nil }
        guard lowerBound <= upperBound else { return nil }
        return Range<Int>(uncheckedBounds: (lower: lowerBound, upper: upperBound))
    }

    private func dataStoreContent(from request: URLRequest) -> DataStoreContent? {
        guard let requestContent = delegate.getEmptyItem() else { return nil }
        guard let data = request.httpBody else { return nil }
        guard requestContent.fromData(data) == nil else { return nil }
        return requestContent
    }

    private func processBadRequest(_ response: HTTPURLResponse) {
        //TODO
    }

    private func processBadRequestContent(_ response: HTTPURLResponse) {
        //TODO
    }

    private func processGet(_ reponse: HTTPURLResponse, _ responseContent: DataStoreContent?) {
        //TODO
    }

    private func processPost(_ reponse: HTTPURLResponse, _ responseContent: DataStoreContent?) {
        //TODO
    }

    private func processPut(_ reponse: HTTPURLResponse, _ responseContent: DataStoreContent?) {
        //TODO
    }

    private func processDelete(_ reponse: HTTPURLResponse, _ responseContent: DataStoreContent?) {
        //TODO
    }
}
