import Foundation


public final class WriteResult {

    private let result: BinaryenModuleAllocateAndWriteResult

    public var data: Data {
        return Data(
            bytes: result.binary,
            count: result.binaryBytes
        )
    }

    internal init(result: BinaryenModuleAllocateAndWriteResult) {
        self.result = result
    }

    deinit {
        free(result.binary)
    }
}
