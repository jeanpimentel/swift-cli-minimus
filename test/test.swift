import XCTest
import Minimus

class MinimusTest: XCTestCase {
    
    func testTrue() {
        XCTAssert(returnTrue())
    }

    func testFalse() {
        XCTAssertFalse(returnFalse())
    }

}

