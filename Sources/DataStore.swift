//
//  DataStore.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

public class DataStore {
    private static let dateFormatter = HTTPDateFormatter()

    public static let HTTPCustomHeader1 = "X-DataStoreCustomHeader1"

    class func randomUInt32() -> UInt32 {
#if os(Linux)
        return UInt32(random() % (Int(UInt32.max)+1))
#else
        return arc4random_uniform(UInt32.max)
#endif
    }

    class func queryString(from dict: [String:String]?) -> String? {
        guard dict != nil else { return nil }
        let queryItems = dict!.flatMap({ $0+"="+$1 })
        let queryString = DataStore.string(from: queryItems, separator: "&")
        return queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    class func query(from string: String) -> [String:String]? {
        var query = [String:String]()
        let queryItems = DataStore.array(from: string, separator: "&")
        queryItems.forEach({ (queryItem) in
            let queryItemComponents = DataStore.array(from: queryItem, separator: "=")
            if queryItemComponents.count == 2 {
                query[queryItemComponents.first!] = queryItemComponents.last!
            }
        })
        return query.isEmpty ? nil : query
    }

    class func rangeString(from range: Range<Int>?) -> String? {
        guard range != nil else { return nil }
        return "\(range!.lowerBound)-\(range!.upperBound)"
    }

    class func range(from string: String) -> Range<Int>? {
        guard string.hasPrefix("items=") else { return nil }
        let bounds = DataStore.array(from: string.substring(from: string.index(string.startIndex, offsetBy: 6)), separator: "-")
        guard bounds.count == 2 else { return nil }
        guard let lowerBound = Int(bounds.first!), let upperBound = Int(bounds.last!) else { return nil }
        guard lowerBound <= upperBound else { return nil }
        return Range<Int>(uncheckedBounds: (lower: lowerBound, upper: upperBound))
    }

    class func string(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    class func date(from string: String) -> Date? {
        return dateFormatter.date(from: string)
    }

    public class func string(from array: [String], separator: String) -> String {
        return array.reduce("", { ($0.isEmpty ? "" : $0+separator) + $1 })
    }

    public class func array(from string: String, separator: String) -> [String] {
        return string.components(separatedBy: separator)
    }
}

private class HTTPDateFormatter: DateFormatter {
    override init() {
        super.init()
        self.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"
    }
}
