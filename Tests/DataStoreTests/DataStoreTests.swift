import XCTest
@testable import DataStore

class DataStoreTests: XCTestCase {
    func testJSONContentEncode() {
        let jsonContent = DataStoreContentJSONDictionary<String,String>()
        jsonContent.set("value", for: "name")
        let result = jsonContent.toData()
        XCTAssertEqual(result, nil)
    }

    func testJSONContentDecode() {
        let jsonContent = DataStoreContentJSONDictionary<String,String>()
        let data = "{\"name\":\"value\"}".data(using: .utf8)!
        let result = jsonContent.fromData(data)
        XCTAssertEqual(result, nil)
    }

    static var allTests : [(String, (DataStoreTests) -> () throws -> Void)] {
        return [
            ("testJSONContentEncode", testJSONContentEncode),
            ("testJSONContentDecode", testJSONContentDecode)
        ]
    }
}
