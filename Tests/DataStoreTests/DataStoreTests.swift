import XCTest
@testable import DataStore

class DataStoreTests: XCTestCase {
    func testJSONContentEncode() {
        let jsonContent = DataStoreContentJSONDictionary<String,String>()
        jsonContent.set("value", for: "name")
        let result = jsonContent.toData()
        XCTAssertNotNil(result)
    }

    func testJSONContentDecode() {
        let jsonContent = DataStoreContentJSONDictionary<String,String>()
        let data = "{\"name\":\"value\"}".data(using: .utf8)!
        XCTAssertNil(jsonContent.fromData(data))
    }

    static var allTests = [
        ("testJSONContentEncode", testJSONContentEncode),
        ("testJSONContentDecode", testJSONContentDecode)
    ]
}
