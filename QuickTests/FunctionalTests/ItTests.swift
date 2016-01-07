import XCTest
import Quick
import Nimble

class FunctionalTests_ItSpec: QuickSpec {
    override func spec() {
        var exampleMetadata: ExampleMetadata?
        beforeEach { metadata in exampleMetadata = metadata }
        
        it("") {
            expect(exampleMetadata!.example.name).to(equal(""))
        }
        
        it("has a description with セレクター名に使えない文字が入っている 👊💥") {
            let name = "has a description with セレクター名に使えない文字が入っている 👊💥"
            expect(exampleMetadata!.example.name).to(equal(name))
        }
        
        describe("error handling when misusing ordering") {
            it("wraps another it that will...") {
                expect {
                    it("...throw an error") { }
                    }.to(raiseException { (exception: NSException) in
                        expect(exception.name).to(equal("Invalid DSL Exception"))
                        expect(exception.reason).to(equal("'it' cannot be used inside 'it', 'it' may only be used inside 'context' or 'describe'. "))
                        })
            }
        }
    }
}

class ItTests: XCTestCase {
    func testAllExamplesAreExecuted() {
        let result = qck_runSpec(FunctionalTests_ItSpec.classForCoder())
        XCTAssertEqual(result.executionCount, 3 as UInt)
    }
}
