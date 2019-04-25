public struct Global {
    public let globalRef: BinaryenGlobalRef!

    internal init(globalRef: BinaryenGlobalRef!) {
        self.globalRef = globalRef
    }

    // TODO: https://github.com/WebAssembly/binaryen/pull/2047
//    /// Gets the external module name.
//    public var externalModuleName: String? {
//        return BinaryenGlobalImportGetModule(globalRef)
//            .map { String(cString: $0) }
//    }

    /// Gets the external base name.
    public var externalBaseName: String? {
        return BinaryenGlobalImportGetBase(globalRef)
            .map { String(cString: $0) }
    }
}
