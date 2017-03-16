//
//  DataStoreClient.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public enum DataStoreClientError: Error {
    case badRequestContent
    case badResponseContent
    case emptyResponseContent
}

public protocol DataStoreClientTransport: class {
    typealias RequestBlock = (_ request: inout URLRequest) -> Error?
    typealias ResponseBlock = (_ response: HTTPURLResponse, _ responseData: Data?) -> Error?
    typealias ErrorBlock = (_ error: Error?) -> Void

    func execute(_ path: String, _ requestBlock: RequestBlock, _ responseBlock: @escaping ResponseBlock, _ completion: @escaping ErrorBlock)
}

public class DataStoreClient {
    public typealias CompletionBlock = (_ error: Error?) -> Void
    public typealias MetadataCompletionBlock = (_ metadata: [AnyHashable:Any], _ error: Error?) -> Void

    private var transport: DataStoreClientTransport

    private func queryString(from dict: [String:Any]?) -> String {
        guard dict != nil else { return "" }
        let str = dict!.flatMap({ return "\($0)=\($1)" }).reduce("", { return ($0.isEmpty ? "" : $0+"&") + $1 })
        return str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    public init(transport: DataStoreClientTransport) {
        self.transport = transport
    }

    //GET /items
    public func getItems(_ query: [String:Any]?, _ range: Range<Int>?, _ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        let queryString = self.queryString(from: query)
        transport.execute("/items"+(queryString.isEmpty ? "" : "?" + queryString), { (request) in
            request.httpMethod = "GET"
            if range != nil {
                request.addValue("items=\(range!.lowerBound)-\(range!.upperBound)", forHTTPHeaderField: "Range")
            }
            return nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }

    //POST /items
    public func createItem(_ requestContent: DataStoreContent, _ responseContent: DataStoreContent, _ completion: @escaping MetadataCompletionBlock) {
        var metadata: [String:Any] = [:]
        transport.execute("/items", { (request) in
            request.httpMethod = "POST"
            request.httpBody = requestContent.toData()
            return request.httpBody == nil ? DataStoreClientError.badRequestContent : nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            if let value = response.allHeaderFields["Location"] {
                metadata["Location"] = value
            }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(metadata, error)
        })
    }

    //GET /items/count
    public func getItemsCount(_ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute("/items/count", { (request) in
            request.httpMethod = "GET"
            return nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }

    //GET /items/identifiers
    public func getItemsIdentifiers(_ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute("/items/identifiers", { (request) in
            request.httpMethod = "GET"
            return nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }

    //GET /items/item_id
    public func getItem(id: String, _ responseContent: DataStoreContent, _ completion: @escaping MetadataCompletionBlock) {
        var metadata: [String:Any] = [:]
        transport.execute("/items/"+id, { (request) in
            request.httpMethod = "GET"
            return nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            if let value = response.allHeaderFields["Last-Modified"] {
                metadata["Last-Modified"] = value
            }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(metadata, error)
        })
    }

    //PUT /items/item_id
    public func updateItem(id: String, _ requestContent: DataStoreContent, _ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute("/items/"+id, { (request) in
            request.httpMethod = "PUT"
            request.httpBody = requestContent.toData()
            return request.httpBody == nil ? DataStoreClientError.badRequestContent : nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }

    //DELETE /items/item_id
    public func removeItem(id: String, _ completion: @escaping CompletionBlock) {
        transport.execute("/items/"+id, { (request) in
            request.httpMethod = "DELETE"
            return nil
        }, { (response, responseData) in
            return nil
        }, { (error) in
            completion(error)
        })
    }
}
