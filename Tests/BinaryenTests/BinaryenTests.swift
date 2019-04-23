import XCTest
import Binaryen


final class BinaryenTests: XCTestCase {
    func testTypeNone() {
        _ = BinaryenTypeNone()
    }

    func testModule() throws {
        let module = Module()
        module.addFunctionType(name: "x", result: BinaryenTypeInt32(), parameterTypes: [])
        _ = module.write().data
    }
}
