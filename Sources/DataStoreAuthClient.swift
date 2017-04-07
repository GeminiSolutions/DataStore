//
//  DataStoreAuthClient.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public class DataStoreAuthClient {
    public typealias CompletionBlock = (_ error: Error?) -> Void

    private var transport: DataStoreClientTransport
    private var basePath: String

    public init(transport: DataStoreClientTransport, basePath: String) {
        self.transport = transport
        self.basePath = basePath
    }
    
    //POST /auth/token
    public func createItem(_ requestContent: DataStoreContent, _ responseContent: DataStoreContent, _ completion: @escaping CompletionBlock) {
        transport.execute(basePath+"/token", { (request) in
            request.httpMethod = "POST"
            request.httpBody = requestContent.toData()
            return request.httpBody == nil ? DataStoreClientError.badRequestContent : nil
        }, { (response, responseData) in
            guard responseData != nil else { return DataStoreClientError.emptyResponseContent }
            return responseContent.fromData(responseData!)
        }, { (error) in
            completion(error)
        })
    }
}
