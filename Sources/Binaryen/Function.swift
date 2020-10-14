public struct Function {

    public let functionRef: BinaryenFunctionRef!

    internal init(functionRef: BinaryenFunctionRef!) {
        self.functionRef = functionRef
    }

    /// Gets the name.
    public var name: String {
        return String(cString: BinaryenFunctionGetName(functionRef))
    }

    public var parametersType: Type {
        Type(value: BinaryenFunctionGetParams(functionRef))
    }

    /// Gets the result type.
    public var resultsType: Type {
        return Type(value: BinaryenFunctionGetResults(functionRef))
    }

    /// Gets the number of additional locals.
    public var variableCount: Int {
        return Int(BinaryenFunctionGetNumVars(functionRef))
    }

    /// Gets the type of the additional local at the specified index.
    public func variableType(at index: UInt32) -> Type {
        return Type(value: BinaryenFunctionGetVar(functionRef, index))
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
