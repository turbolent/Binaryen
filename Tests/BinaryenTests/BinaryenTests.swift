import XCTest
import Binaryen

final class BinaryenTests: XCTestCase {
    func testModule() throws {
        let module = Module()

        let expressions = module.expressions

        let first = expressions.localGet(index: 0, type: .int32)
        let second = expressions.localGet(index: 1, type: .int32)

        let add = expressions.binary(instruction: .addInt32, first, second)

        module.addFunction(name: "adder", parameters: [.int32, .int32], results: .int32, body: add)

        Binaryen.isPrinterColoringEnabled = false
        XCTAssertEqual(
            module.writeText(),
            """
            (module
             (type $i32_i32_=>_i32 (func (param i32 i32) (result i32)))
             (func $adder (param $0 i32) (param $1 i32) (result i32)
              (i32.add
               (local.get $0)
               (local.get $1)
              )
             )
            )
            
            """
        )
    }
}
