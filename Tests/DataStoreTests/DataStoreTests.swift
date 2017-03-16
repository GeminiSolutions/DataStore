import XCTest
@testable import DataStore

class DataStoreTests: XCTestCase {
    func testJSONContent() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let jsonString = "{\"name\":\"value\"}"
        let data = jsonString.data(using: .utf8)
        let jsonContent = DataStoreContentJSONDictionary<String,String>()
        let result = jsonContent.fromData(data!)
        print(result ?? "success")
        //XCTAssertEqual(result, nil)
    }


    static var allTests : [(String, (DataStoreTests) -> () throws -> Void)] {
        return [
            ("testJSONContent", testJSONContent),
        ]
    }
}
