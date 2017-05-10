//
//  DataStore.swift
//  DataStore
//
//  Copyright © 2017 Gemini Solutions. All rights reserved.
//

import Foundation

class DataStore {
    private static let dateFormatter = HTTPDateFormatter()

    class func queryString(from dict: [String:String]?) -> String? {
        guard dict != nil else { return nil }
        let queryItems = dict!.flatMap({ $0+"="+$1 })
        let queryString = queryItems.reduce("", { ($0.isEmpty ? "" : $0+"&") + $1 })
        return queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }

    class func query(from string: String) -> [String:String]? {
        var query = [String:String]()
        string.components(separatedBy: "&").forEach({ (queryItem) in
            let queryItemComponents = queryItem.components(separatedBy: "=")
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
        let bounds = string.substring(from: string.index(string.startIndex, offsetBy: 6)).components(separatedBy: "-")
        guard bounds.count == 2 else { return nil }
        guard let lowerBound = Int(bounds.first!), let upperBound = Int(bounds.last!) else { return nil }
        guard lowerBound <= upperBound else { return nil }
        return Range<Int>(uncheckedBounds: (lower: lowerBound, upper: upperBound))
    }

    class func dateString(from date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    class func date(from string: String) -> Date? {
        return dateFormatter.date(from: string)
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
