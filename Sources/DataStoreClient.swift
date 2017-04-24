//
//  DataStoreClient.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public enum DataStoreClientError: Error {
    case badRequestContent
    case badResponse
    case emptyResponseContent
}

public protocol DataStoreClientTransport: class {
    typealias RequestBlock = (_ request: inout URLRequest) -> Error?
    typealias DataResponseBlock = (_ response: HTTPURLResponse, _ responseContent: Data?) -> Error?
    typealias URLResponseBlock = (_ response: HTTPURLResponse, _ responseContent: URL?) -> Error?
    typealias ErrorBlock = (_ error: Error?) -> Void

    func execute(_ path: String, _ requestBlock: RequestBlock, _ responseBlock: @escaping DataResponseBlock, _ completion: @escaping ErrorBlock)
    func execute(_ path: String, _ requestBlock: RequestBlock, _ responseBlock: @escaping URLResponseBlock, _ completion: @escaping ErrorBlock)
    func execute(_ path: String, _ requestContent: Data, _ requestBlock: RequestBlock, _ responseBlock: @escaping DataResponseBlock, _ completion: @escaping ErrorBlock)
    func execute(_ path: String, _ requestContent: URL, _ requestBlock: RequestBlock, _ responseBlock: @escaping DataResponseBlock, _ completion: @escaping ErrorBlock)
}

public class DataStoreClient {
    public typealias CompletionBlock = (_ error: Error?) -> Void
    public typealias MetadataCompletionBlock = (_ metadata: [AnyHashable:Any], _ error: Error?) -> Void

    public static let MetadataKey_ItemId = "ItemId"
    public static let MetadataKey_ItemLastModified = "ItemLastModified"

    public var authToken: String?

    private var transport: DataStoreClientTransport
    private var basePath: String
    private var dateFormatter = DateFormatter()

    private func queryString(from dict: [String:String]?) -> String? {
        guard dict != nil else { return nil }
        let queryItems = dict!.flatMap({ $0+"="+$1 })
        let queryString = queryItems.reduce("", { ($0.isEmpty ? "" : $0+"&") + $1 })
        return queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    private func rangeString(from range: Range<Int>?) -> String? {
        guard range != nil else { return nil }
        return "\(range!.lowerBound)-\(range!.upperBound)"
    }

    private func stripBasePath(from string: String) -> String {
        guard string.hasPrefix(basePath) else { return string }
        var result = string
        result.removeSubrange(result.startIndex ..< basePath.endIndex)
        if result.hasPrefix("/") { result.remove(at: result.startIndex) }
        return result
    }

    private func createTempURL(_ fileName: String) -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("datastore-"+fileName)
    }

    private func discardTempURL(_ url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        }
        catch let error {
            print(error)
        }
    }

    public init(transport: DataStoreClientTransport, basePath: String) {
        self.transport = transport
        self.basePath = basePath
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    }

    //GET /items
    public func getItems(_ query: [String:String]?, _ range: Range<Int>?, _ itemsContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        let requestBlock: DataStoreClientTransport.RequestBlock = { (request) in
            request.httpMethod = "GET"
            request.setValue(self.authToken, forHTTPHeaderField: "Authorization")
            request.setValue(self.rangeString(from: range), forHTTPHeaderField: "Range")
            return nil
        }

        if itemsContent.largeSize {
            transport.execute(basePath+"?"+(queryString(from: query) ?? ""), requestBlock, { (response, responseContent: URL?) in
                guard responseContent != nil else { return DataStoreClientError.emptyResponseContent }
                return itemsContent.fromURL(responseContent!)
            }, { (error) in
                completion(error)
            })
        }
        else {
            transport.execute(basePath+"?"+(queryString(from: query) ?? ""), requestBlock, { (response, responseContent: Data?) in
                guard responseContent != nil else { return DataStoreClientError.emptyResponseContent }
                return itemsContent.fromData(responseContent!)
            }, { (error) in
                completion(error)
            })
        }
    }

    //POST /items
    public func createItem(_ itemContent: DataStoreContent, _ completion: @escaping MetadataCompletionBlock) {
        var metadata: [String:Any] = [:]
        let requestBlock: DataStoreClientTransport.RequestBlock = { (request) in
            request.httpMethod = "POST"
            request.setValue(self.authToken, forHTTPHeaderField: "Authorization")
            return nil
        }
        let responseBlock: DataStoreClientTransport.DataResponseBlock = { (response, responseData) in
            guard let value = response.allHeaderFields["Location"] as? String else { return DataStoreClientError.badResponse }
            metadata[DataStoreClient.MetadataKey_ItemId] = self.stripBasePath(from: value)
            return nil
        }

        if itemContent.largeSize {
            let url = createTempURL("newItem")//TODO
            if let error = itemContent.toURL(url) {
                completion(metadata, error)
            }
            else {
                transport.execute(basePath, url, requestBlock, responseBlock, { (error) in
                    completion(metadata, error)
                    self.discardTempURL(url)
                })
            }
        }
        else {
            if let data = itemContent.toData() {
                transport.execute(basePath, data, requestBlock, responseBlock, { (error) in
                    completion(metadata, error)
                })
            }
            else {
                completion(metadata, DataStoreClientError.badRequestContent)
            }
        }
    }

    //GET /items/item_id
    public func getItem(id: String, _ itemContent: DataStoreContent, _ completion: @escaping MetadataCompletionBlock) {
        var metadata: [String:Any] = [:]
        let requestBlock: DataStoreClientTransport.RequestBlock = { (request) in
            request.httpMethod = "GET"
            request.setValue(self.authToken, forHTTPHeaderField: "Authorization")
            return nil
        }

        if itemContent.largeSize {
            transport.execute(basePath+"/"+id, requestBlock, { (response, responseContent: URL?) in
                guard responseContent != nil else { return DataStoreClientError.emptyResponseContent }
                if let value = response.allHeaderFields["Last-Modified"] as? String {
                    metadata[DataStoreClient.MetadataKey_ItemLastModified] = self.dateFormatter.date(from: value)
                }
                return itemContent.fromURL(responseContent!)
            }, { (error) in
                completion(metadata, error)
            })
        }
        else {
            transport.execute(basePath+"/"+id, requestBlock, { (response, responseContent: Data?) in
                guard responseContent != nil else { return DataStoreClientError.emptyResponseContent }
                if let value = response.allHeaderFields["Last-Modified"] as? String {
                    metadata[DataStoreClient.MetadataKey_ItemLastModified] = self.dateFormatter.date(from: value)
                }
                return itemContent.fromData(responseContent!)
            }, { (error) in
                completion(metadata, error)
            })
        }
    }

    //PUT /items/item_id
    public func updateItem(id: String, _ itemContent: DataStoreContent, _ completion: @escaping MetadataCompletionBlock) {
        var metadata: [String:Any] = [:]
        let requestBlock: DataStoreClientTransport.RequestBlock = { (request) in
            request.httpMethod = "PUT"
            request.setValue(self.authToken, forHTTPHeaderField: "Authorization")
            return nil
        }
        let responseBlock: DataStoreClientTransport.DataResponseBlock = { (response, responseData) in
            guard let value = response.allHeaderFields["Location"] as? String else { return DataStoreClientError.badResponse }
            metadata[DataStoreClient.MetadataKey_ItemId] = self.stripBasePath(from: value)
            return nil
        }

        if itemContent.largeSize {
            let url = createTempURL(id)
            if let error = itemContent.toURL(url) {
                completion(metadata, error)
            }
            else {
                transport.execute(basePath+"/"+id, url, requestBlock, responseBlock, { (error) in
                    completion(metadata, error)
                    self.discardTempURL(url)
                })
            }
        }
        else {
            if let data = itemContent.toData() {
                transport.execute(basePath+"/"+id, data, requestBlock, responseBlock, { (error) in
                    completion(metadata, error)
                })
            }
            else {
                completion(metadata, DataStoreClientError.badRequestContent)
            }
        }
    }

    //DELETE /items/item_id
    public func removeItem(id: String, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"/"+id, { (request) in
            request.httpMethod = "DELETE"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            return nil
        }, { (response, responseData: Data?) in
            return nil
        }, { (error) in
            completion(error)
        })
    }

    //GET /items/count
    public func getItemsCount(_ itemsCount: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"/count", { (request) in
            request.httpMethod = "GET"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            return nil
        }, { (response, responseData: Data?) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return itemsCount.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }
    
    //GET /items/identifiers
    public func getItemsIdentifiers( _ range: Range<Int>?, _ itemsIdentifiers: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"/identifiers", { (request) in
            request.httpMethod = "GET"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            request.setValue(rangeString(from: range), forHTTPHeaderField: "Range")
            return nil
        }, { (response, responseData: Data?) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return itemsIdentifiers.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }

    //GET /items/metadata
    public func getItemsMetadata(_ itemsMetadata: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"/metadata", { (request) in
            request.httpMethod = "GET"
            request.setValue(authToken, forHTTPHeaderField: "Authorization")
            return nil
        }, { (response, responseData: Data?) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return itemsMetadata.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }
}
