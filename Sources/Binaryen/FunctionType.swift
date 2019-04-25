public struct FunctionType {

    public let functionTypeRef: BinaryenFunctionTypeRef!

    internal init(functionTypeRef: BinaryenFunctionTypeRef!) {
        self.functionTypeRef = functionTypeRef
    }

    /// Gets the name.
    public var name: String {
        return String(cString:
            BinaryenFunctionTypeGetName(functionTypeRef)
        )
    }

    /// Gets the result type.
    public var resultType: Type {
        return Type(type: BinaryenFunctionTypeGetResult(functionTypeRef))
    }

    /// Gets the type of the parameter at the specified index.
    public func parameterType(at index: UInt32) -> Type? {
        return Type(type: BinaryenFunctionTypeGetParam(functionTypeRef, index))
    }

    /// Gets the number of parameters.
    public var parameterCount: Int {
        return Int(BinaryenFunctionTypeGetNumParams(functionTypeRef))
    }
}
