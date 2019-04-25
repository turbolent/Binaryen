public struct Function {

    public let functionRef: BinaryenFunctionRef!

    internal init(functionRef: BinaryenFunctionRef!) {
        self.functionRef = functionRef
    }

    /// Gets the name.
    public var name: String {
        return String(cString: BinaryenFunctionGetName(functionRef))
    }

    /// Gets the name of the `FunctionType`.
    /// May be nil if the signature is implicit.
    public var typeName: String? {
        return BinaryenFunctionGetType(functionRef)
            .map { String(cString: $0) }
    }

    /// Gets the number of parameters.
    public var parameterCount: Int {
        return Int(BinaryenFunctionGetNumParams(functionRef))
    }

    /// Gets the type of the parameter at the specified index.
    public func paramerterType(at index: UInt32) -> Type? {
        return Type(type: BinaryenFunctionGetParam(functionRef, index))
    }

    /// Gets the result type.
    public var resultType: Type {
        return Type(type: BinaryenFunctionGetResult(functionRef))
    }

    /// Gets the number of additional locals.
    public var variableCount: Int {
        return Int(BinaryenFunctionGetNumVars(functionRef))
    }

    /// Gets the type of the additional local at the specified index.
    public func variableType(at index: UInt32) -> Type? {
        return Type(type: BinaryenFunctionGetVar(functionRef, index))
    }

    /// Gets the body of the specified `Function`.
    public var body: Expression {
        return Expression(expressionRef: BinaryenFunctionGetBody(functionRef))
    }

    /// Gets the external module name.
    public var externalModuleName: String? {
        return BinaryenFunctionImportGetModule(functionRef)
            .map { String(cString: $0) }
    }

    /// Gets the external base name.
    public var externalBaseName: String? {
        return BinaryenFunctionImportGetBase(functionRef)
            .map { String(cString: $0) }
    }
}
