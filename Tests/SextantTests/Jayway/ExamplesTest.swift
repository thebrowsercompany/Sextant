import XCTest
import Hitch
import class Foundation.Bundle

@testable import Sextant

class ExamplesTest: TestsBase {
    
    /// Each call to Sextant's query(values: ) will return an array on success and nil on failure
    func testSimple0() {
        let json = #"["Hello","World"]"#
        guard let results = json.query(values: "$[0]") else { return XCTFail() }
        XCTAssertEqualAny(results[0], "Hello")
    }
    
    /// You can avoid the provided extensions and call query on the Sextant singleton directly
    func testSimple1() {
        let json = #"["Hello","World"]"#
        guard let jsonData = json.data(using: .utf8) else { return }
        guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) else { return }
        guard let results = Sextant.shared.query(jsonObject, values: "$[0]") else { return XCTFail() }
        XCTAssertEqualAny(results[0], "Hello")
    }
    
    /// Works with any existing JSON-like structure
    func testSimple2() {
        let data = [ "Hello", "World" ]
        guard let results = data.query(values: "$[0]") else { return XCTFail() }
        XCTAssertEqualAny(results[0], "Hello")
    }
    
    /// Automatically covert to simple tuples
    func testSimple3() {
        let json = #"{"name":"Rocco","age":42}"#
        
        guard let person: (name: String, age: Int) = json.query("$.['name','age']") else { return XCTFail() }
        XCTAssertEqual(person.name, "Rocco")
        XCTAssertEqual(person.age, 42)
        
        guard let person2: (name: String, age: Int?) = json.query("$.['name','age2']") else { return XCTFail() }
        XCTAssertEqual(person2.name, "Rocco")
        XCTAssertEqual(person2.age, nil)
        
        if let _: (name: String, age: Int) = json.query("$.['name','age2']") {
            return XCTFail()
        }
    }
    
    /// Supports Decodable structs
    func testSimple4() {
        let json = #"{"data":{"people":[{"name":"Rocco","age":42},{"name":"John","age":12},{"name":"Elizabeth","age":35},{"name":"Victoria","age":85}]}}"#
        
        class Person: Decodable {
            let name: String
            let age: Int
        }
        
        guard let persons: [Person] = json.query("$..[?(@.name)]") else { return XCTFail() }
        XCTAssertEqual(persons[0].name, "Rocco")
        XCTAssertEqual(persons[0].age, 42)
        XCTAssertEqual(persons[2].name, "Elizabeth")
        XCTAssertEqual(persons[2].age, 35)
    }
    
    /// Easily combine results from multiple queries
    func testSimple5() {
        let json1 = #"{"error": "invalid_request", "error_description": "Mismatching redirect URI."}"#
        let json2 = #"{"errors":[{"title":"Error!","detail":"Error format 2"}]}"#
                
        let queries: [String] = [
            "$.['error','error_description']",
            "$.errors[0].['title','detail']"
        ]
        
        XCTAssertEqualAny(json1.query(values: queries), ["Mismatching redirect URI.", "invalid_request"])
        XCTAssertEqualAny(json2.query(values: queries), ["Error format 2", "Error!"])
    }
    
    func testSimple6() {
        let json1 = #"{"access_token":"aex-0u-7Yq09sBls123456789","expires_in":2678400,"token_type":"Bearer","scope":"identity","refresh_token":"CayptzsmZ_MejrKgNtAF8ka36123456789","version":"0.0.1"}"#
        
        if let _: (title: String, detail: String) = json1.query([
            "$.['error','error_description']",
            "$.errors[0].['title','detail']"
        ]) {
            XCTFail()
        }
    }
}

extension ExamplesTest {
    static var allTests : [(String, (ExamplesTest) -> () throws -> Void)] {
        return [
            ("testSimple0", testSimple0),
            ("testSimple1", testSimple1),
            ("testSimple2", testSimple2),
        ]
    }
}

