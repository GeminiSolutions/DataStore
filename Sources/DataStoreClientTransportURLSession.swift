//
//  DataStoreClientTransportURLSession.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public class DataStoreClientTransportURLSession : DataStoreClientTransport {
    let session = URLSession(configuration: URLSessionConfiguration.default)

    public var serverAddr = ""
    public var pathPrefix = ""
    public var secureTransport = true

    private func url(for path: String) -> URL {
        return URL(string: "http" + (secureTransport ? "s" : "") + "://" + serverAddr + pathPrefix + path)!
    }

    public init() {
        //
    }

    public func execute(_ path: String, _ requestBlock: DataStoreClientTransport.RequestBlock, _ responseBlock: @escaping DataStoreClientTransport.DataResponseBlock, _ completion: @escaping DataStoreClientTransport.ErrorBlock) {
        var request = URLRequest(url: url(for: path))

        if let error = requestBlock(&request) {
            completion(error)
            return
        }

        session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(error == nil ? responseBlock(httpResponse, data) : error)
            }
            else {
                completion(DataStoreClientError.badResponse)
            }
        }).resume()
    }

    public func execute(_ path: String, _ requestBlock: DataStoreClientTransport.RequestBlock, _ responseBlock: @escaping DataStoreClientTransport.URLResponseBlock, _ completion: @escaping DataStoreClientTransport.ErrorBlock) {
        var request = URLRequest(url: url(for: path))

        if let error = requestBlock(&request) {
            completion(error)
            return
        }

        session.downloadTask(with: request, completionHandler: { (url, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(error == nil ? responseBlock(httpResponse, url) : error)
            }
            else {
                completion(DataStoreClientError.badResponse)
            }
        }).resume()
    }

    public func execute(_ path: String, _ requestContent: Data, _ requestBlock: DataStoreClientTransport.RequestBlock, _ responseBlock: @escaping DataStoreClientTransport.DataResponseBlock, _ completion: @escaping DataStoreClientTransport.ErrorBlock) {
        var request = URLRequest(url: url(for: path))
        
        if let error = requestBlock(&request) {
            completion(error)
            return
        }

        request.httpBody = requestContent
        session.dataTask(with: request, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(error == nil ? responseBlock(httpResponse, data) : error)
            }
            else {
                completion(DataStoreClientError.badResponse)
            }
        }).resume()
    }

    public func execute(_ path: String, _ requestContent: URL, _ requestBlock: DataStoreClientTransport.RequestBlock, _ responseBlock: @escaping DataStoreClientTransport.DataResponseBlock, _ completion: @escaping DataStoreClientTransport.ErrorBlock) {
        var request = URLRequest(url: url(for: path))

        if let error = requestBlock(&request) {
            completion(error)
            return
        }

        session.uploadTask(with: request, fromFile: requestContent, completionHandler: { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse {
                completion(error == nil ? responseBlock(httpResponse, data) : error)
            }
            else {
                completion(DataStoreClientError.badResponse)
            }
        }).resume()
    }
}
