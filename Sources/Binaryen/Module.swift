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

    public let moduleRef: BinaryenModuleRef!

    public let expressions: ExpressionFactory

    internal init(moduleRef: BinaryenModuleRef!) {
        self.moduleRef = moduleRef
        self.expressions = ExpressionFactory(moduleRef: moduleRef)
    }

    public convenience init() {
        self.init(moduleRef: BinaryenModuleCreate())
    }

    /// Deserialize a module from binary form.
    public convenience init(data: Data) {
        var data = data
        let count = data.count
        self.init(moduleRef: data.withUnsafeMutableBytes { pointer in
            BinaryenModuleRead(pointer, count)
        })
    }

    /// Validate a module, showing errors on problems.
    public var isValid: Bool {
        return BinaryenModuleValidate(moduleRef) == 1
    }

    /// Auto-generate drop() operations where needed. This lets you generate code without
    /// worrying about where they are needed. (It is more efficient to do it yourself,
    /// but simpler to use autodrop).
    public func autoDrop() {
        BinaryenModuleAutoDrop(moduleRef)
    }

    /// Runs the standard optimization passes on the module. Uses the currently set
    /// global optimize and shrink level.
    public func optimize() {
        BinaryenModuleOptimize(moduleRef)
    }

    /// Print a module to stdout in s-expression text format. Useful for debugging.
    public func print() {
        BinaryenModulePrint(moduleRef)
    }

    /// Serializes a module into binary form, optionally including its source map if
    /// sourceMapUrl has been specified. Uses the currently set global debugInfo option.
    public func write(sourceMapURL: String? = nil) -> WriteResult {
        return WriteResult(result:
            BinaryenModuleAllocateAndWrite(moduleRef, sourceMapURL?.cString(using: .utf8))
        )
    }

    /// Add a new function type. This is thread-safe.
    /// Note: name can be nil, in which case we auto-generate a name
    public func addFunctionType(name: String? = nil, result: Type, parameterTypes: [Type]) -> FunctionType? {
        var parameterTypes = parameterTypes.map { $0.type }
        guard let functionTypeRef =
            BinaryenAddFunctionType(
                moduleRef,
                name?.cString(using: .utf8),
                result.type,
                UnsafeMutablePointer(&parameterTypes),
                BinaryenIndex(parameterTypes.count)
            )
        else {
            return nil
        }
        return FunctionType(functionTypeRef: functionTypeRef)
    }

    /// Removes a function type.
    public func removeFunctionType(name: String) {
        BinaryenRemoveFunctionType(moduleRef, name.cString(using: .utf8))
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
    public func addFunction(name: String, type: FunctionType, variableTypes: [Type], body: Expression) -> Function? {
        var variableTypes = variableTypes.map { $0.type }
        guard let functionRef =
            BinaryenAddFunction(
                moduleRef,
                name.cString(using: .utf8),
                type.functionTypeRef,
                UnsafeMutablePointer(&variableTypes),
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
            BinaryenGetFunction(moduleRef, name.cString(using: .utf8))
        else {
            return nil
        }

        return Function(functionRef: functionRef)
    }

    /// Removes a function by name.
    public func removeFunction(name: String) {
        BinaryenRemoveFunction(moduleRef, name.cString(using: .utf8))
    }

    /// Set the start function. One per module.
    public func setStart(_ function: Function) {
        BinaryenSetStart(moduleRef, function.functionRef)
    }

    public func addFunctionImport(
        internalName: String,
        externalModuleName: String,
        externalBaseName: String,
        functionType: FunctionType
    ) {
        BinaryenAddFunctionImport(
            moduleRef,
            internalName.cString(using: .utf8),
            externalModuleName.cString(using: .utf8),
            externalBaseName.cString(using: .utf8),
            functionType.functionTypeRef
        )
    }

    public func addTableImport(
        internalName: String,
        externalModuleName: String,
        externalBaseName: String
    ) {
        BinaryenAddTableImport(
            moduleRef,
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
            moduleRef,
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
        globalType: Type
    ) {
        BinaryenAddGlobalImport(
            moduleRef,
            internalName.cString(using: .utf8),
            externalModuleName.cString(using: .utf8),
            externalBaseName.cString(using: .utf8),
            globalType.type
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
                moduleRef,
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
                moduleRef,
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
                moduleRef,
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
                moduleRef,
                internalName.cString(using: .utf8),
                externalName.cString(using: .utf8)
            )
        )
    }

    public func removeExport(
        externalName: String
    ) {
        BinaryenRemoveExport(
            moduleRef,
            externalName.cString(using: .utf8)
        )
    }

    public func addGlobal(name: String, type: Type, mutable: Bool, initial: Expression) -> Global {
        return Global(globalRef:
            BinaryenAddGlobal(
                moduleRef,
                name.cString(using: .utf8),
                type.type,
                mutable ? 1 : 0,
                initial.expressionRef
            )
        )
    }

    public func removeGlobal(name: String) {
        BinaryenRemoveGlobal(moduleRef, name.cString(using: .utf8))
    }

    deinit {
        BinaryenModuleDispose(moduleRef)
    }
}
