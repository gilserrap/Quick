import XCTest
import Nimble
import Quick

class DescribeTests: XCTestCase {
    
    func testDescribeThrowsIfUsedOutsideOfQuickSpec() {
        expect { describe("this should throw an exception", {}) }.to(raiseException())
    }
}

class QuickDescribeTests: QuickSpec {
    override func spec() {
        describe("Describe") {
            it("should throw an exception if used in an it block") {
                expect {
                    describe("A nested describe that should throw") { }
                }.to(raiseException { (exception: NSException) in
                    expect(exception.name).to(equal("Invalid DSL Exception"))
                    expect(exception.reason).to(equal("'describe' cannot be used inside 'it', 'describe' may only be used inside 'context' or 'describe'. "))
                })
            }
        }
    }
}
