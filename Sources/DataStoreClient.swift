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
    private var basePath: String
    public var authToken: String?

    private func queryString(from dict: [String:String]?) -> String? {
        guard dict != nil else { return nil }
        let queryItems = dict!.flatMap({ return $0+"="+$1 })
        let queryString = queryItems.reduce("", { return ($0.isEmpty ? "" : $0+"&") + $1 })
        return queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    private func rangeString(from range: Range<Int>?) -> String? {
        guard range != nil else { return nil }
        return "\(range!.lowerBound)-\(range!.upperBound)"
    }

    public init(transport: DataStoreClientTransport, basePath: String) {
        self.transport = transport
        self.basePath = basePath
    }

    //GET /items
    public func getItems(_ query: [String:String]?, _ range: Range<Int>?, _ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"?"+(queryString(from: query) ?? ""), { (request) in
            request.httpMethod = "GET"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            request.setValue(rangeString(from: range), forHTTPHeaderField: "Range")
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
        transport.execute(basePath, { (request) in
            request.httpMethod = "POST"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
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

    //GET /items/metadata
    public func getItemsMetadata(_ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"/metadata", { (request) in
            request.httpMethod = "GET"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            return nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }

    //GET /items/count
    public func getItemsCount(_ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"/count", { (request) in
            request.httpMethod = "GET"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            return nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }

    //GET /items/identifiers
    public func getItemsIdentifiers( _ range: Range<Int>?, _ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"/identifiers", { (request) in
            request.httpMethod = "GET"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            request.setValue(rangeString(from: range), forHTTPHeaderField: "Range")
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
        transport.execute(basePath+"/"+id, { (request) in
            request.httpMethod = "GET"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
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
        transport.execute(basePath+"/"+id, { (request) in
            request.httpMethod = "PUT"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
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
        transport.execute(basePath+"/"+id, { (request) in
            request.httpMethod = "DELETE"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            return nil
        }, { (response, responseData) in
            return nil
        }, { (error) in
            completion(error)
        })
    }
}
