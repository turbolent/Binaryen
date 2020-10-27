import Foundation


/// Modules contain lists of functions, imports, exports, function types. The
/// add* methods create them on a module. The module owns them and will free their
/// memory when the module is disposed of.
///
/// Expressions are also allocated inside modules, and freed with the module. They
/// are not created by Add* methods, since they are not added directly on the
/// module, instead, they are arguments to other expressions (and then they are
/// the children of that AST node), or to a function (and then they are the body
/// of that function).
///
/// A module can also contain a function table for indirect calls, a memory,
/// and a start method.
///
public final class Module {
    let ref: BinaryenModuleRef!

    public let expressions: ExpressionFactory

    init(ref: BinaryenModuleRef!) {
        self.ref = ref
        self.expressions = ExpressionFactory(ref: ref)
    }

    public convenience init() {
        self.init(ref: BinaryenModuleCreate())
    }

    /// Deserialize a module from binary form.
    public convenience init?(binary: [UInt8]) {
        var binary = binary
        let count = binary.count
        guard let ref = binary.withUnsafeMutableBufferPointer({
            $0.withMemoryRebound(to: Int8.self) {
                BinaryenModuleRead($0.baseAddress, count)
            }
        }) else { return nil }

        self.init(ref: ref)
    }

    /// Validate a module, showing errors on problems.
    public var isValid: Bool {
        return BinaryenModuleValidate(ref) == 1
    }

    /// Auto-generate drop() operations where needed. This lets you generate code without
    /// worrying about where they are needed. (It is more efficient to do it yourself,
    /// but simpler to use autodrop).
    public func autoDrop() {
        BinaryenModuleAutoDrop(ref)
    }

    /// Runs the standard optimization passes on the module. Uses the currently set
    /// global optimize and shrink level.
    public func optimize() {
        BinaryenModuleOptimize(ref)
    }

    /// Print a module to stdout in s-expression text format. Useful for debugging.
    public func print() {
        BinaryenModulePrint(ref)
    }

    /// Serializes a module into binary form, optionally including its source map if
    /// sourceMapUrl has been specified. Uses the currently set global debugInfo option.
    public func write(sourceMapURL: String? = nil) -> WriteResult {
        return WriteResult(result:
            BinaryenModuleAllocateAndWrite(ref, sourceMapURL?.cString(using: .utf8))
        )
    }

    /// Serialize a module in s-expression form.
    public func writeText() -> String? {
        guard let result = BinaryenModuleAllocateAndWriteText(ref) else { return nil }

        defer {
            free(result)
        }

        return String(cString: result)
    }

    /// Adds a function to the module. This is thread-safe.
    ///
    /// - Parameter variableTypes:
    ///    the types of variables. In WebAssembly, vars share
    ///    an index space with params. In other words, params come from
    ///    the function type, and vars are provided in this call, and
    ///    together they are all the locals. The order is first params
    ///    and then vars, so if you have one param it will be at index
    ///    0 (and written $0), and if you also have 2 vars they will be
    ///    at indexes 1 and 2, etc., that is, they share an index space.
    ///
    @discardableResult public func addFunction(
        name: String,
        parameters: Type,
        results: Type,
        variableTypes: [Type] = [],
        body: Expression
    ) -> Function? {
        var variableTypes = variableTypes.map { $0.rawValue }
        guard let functionRef =
            BinaryenAddFunction(
                ref,
                name.cString(using: .utf8),
                parameters.rawValue,
                results.rawValue,
                &variableTypes,
                BinaryenIndex(variableTypes.count),
                body.expressionRef
            )
        else {
            return nil
        }

        return Function(functionRef: functionRef)
    }

    /// Gets a function reference by name.
    public func getFunction(name: String) -> Function? {
        guard let functionRef =
            BinaryenGetFunction(ref, name.cString(using: .utf8))
        else {
            return nil
        }

        return Function(functionRef: functionRef)
    }

    /// Removes a function by name.
    public func removeFunction(name: String) {
        BinaryenRemoveFunction(ref, name.cString(using: .utf8))
    }

    /// Set the start function. One per module.
    public func setStart(_ function: Function) {
        BinaryenSetStart(ref, function.functionRef)
    }

    public func addFunctionImport(
        internalName: String,
        externalModuleName: String,
        externalBaseName: String,
        parameters: Type,
        results: Type
    ) {
        BinaryenAddFunctionImport(
            ref,
            internalName.cString(using: .utf8),
            externalModuleName.cString(using: .utf8),
            externalBaseName.cString(using: .utf8),
            parameters.rawValue,
            results.rawValue
        )
    }

    public func addTableImport(
        internalName: String,
        externalModuleName: String,
        externalBaseName: String
    ) {
        BinaryenAddTableImport(
            ref,
            internalName.cString(using: .utf8),
            externalModuleName.cString(using: .utf8),
            externalBaseName.cString(using: .utf8)
        )
    }

    public func addMemoryImport(
        internalName: String,
        externalModuleName: String,
        externalBaseName: String,
        shared: Bool
    ) {
        BinaryenAddMemoryImport(
            ref,
            internalName.cString(using: .utf8),
            externalModuleName.cString(using: .utf8),
            externalBaseName.cString(using: .utf8),
            shared ? 1 : 0
        )
    }

    public func addGlobalImport(
        internalName: String,
        externalModuleName: String,
        externalBaseName: String,
        globalType: Type,
        isMutable: Bool
    ) {
        BinaryenAddGlobalImport(
            ref,
            internalName.cString(using: .utf8),
            externalModuleName.cString(using: .utf8),
            externalBaseName.cString(using: .utf8),
            globalType.rawValue,
            isMutable ? 1 : 0
        )
    }

    public func addFunctionExport(
        internalName: String,
        externalName: String
    )
        -> Export
    {
        return Export(
            exportRef: BinaryenAddFunctionExport(
                ref,
                internalName.cString(using: .utf8),
                externalName.cString(using: .utf8)
            )
        )
    }

    public func addTableExport(
        internalName: String,
        externalName: String
    )
        -> Export
    {
        return Export(
            exportRef: BinaryenAddTableExport(
                ref,
                internalName.cString(using: .utf8),
                externalName.cString(using: .utf8)
            )
        )
    }

    public func addMemoryExport(
        internalName: String,
        externalName: String
    )
        -> Export
    {
        return Export(
            exportRef: BinaryenAddMemoryExport(
                ref,
                internalName.cString(using: .utf8),
                externalName.cString(using: .utf8)
            )
        )
    }

    public func addGlobalExport(
        internalName: String,
        externalName: String
    )
        -> Export
    {
        return Export(
            exportRef: BinaryenAddGlobalExport(
                ref,
                internalName.cString(using: .utf8),
                externalName.cString(using: .utf8)
            )
        )
    }

    public func removeExport(
        externalName: String
    ) {
        BinaryenRemoveExport(
            ref,
            externalName.cString(using: .utf8)
        )
    }

    public func addGlobal(name: String, type: Type, mutable: Bool, initial: Expression) -> Global {
        return Global(globalRef:
            BinaryenAddGlobal(
                ref,
                name.cString(using: .utf8),
                type.rawValue,
                mutable ? 1 : 0,
                initial.expressionRef
            )
        )
    }

    public func removeGlobal(name: String) {
        BinaryenRemoveGlobal(ref, name.cString(using: .utf8))
    }

    deinit {
        BinaryenModuleDispose(ref)
    }
}
