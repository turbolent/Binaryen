@_exported import CBinaryen
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

    private init(moduleRef: BinaryenModuleRef!) {
        self.moduleRef = moduleRef
    }

    public convenience init() {
        self.init(moduleRef: BinaryenModuleCreate())
    }

    // Deserialize a module from binary form.
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
    /// Note: name can be NULL, in which case we auto-generate a name
    public func addFunctionType(name: String? = nil, result: BinaryenType, parameterTypes: [BinaryenType]) -> FunctionType? {
        var parameterTypes = parameterTypes
        guard let functionTypeRef =
            BinaryenAddFunctionType(
                moduleRef,
                name?.cString(using: .utf8),
                result,
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

    deinit {
        BinaryenModuleDispose(moduleRef)
    }
}


public struct FunctionType {

    public let functionTypeRef: BinaryenFunctionTypeRef

    fileprivate init(functionTypeRef: BinaryenFunctionTypeRef) {
        self.functionTypeRef = functionTypeRef
    }

    /// Gets the name.
    public var name: String {
        return String(cString:
            BinaryenFunctionTypeGetName(functionTypeRef)
        )
    }

    /// Gets the result type.
    public var resultType: BinaryenType {
        return BinaryenFunctionTypeGetResult(functionTypeRef)
    }

    /// Gets the type of the parameter at the specified index.
    public func parameterType(at index: Int) -> BinaryenType? {
        return BinaryenFunctionTypeGetParam(functionTypeRef, BinaryenIndex(index))
    }

    /// Gets the number of parameters.
    public var parameterCount: Int {
        return Int(BinaryenFunctionTypeGetNumParams(functionTypeRef))
    }
}


public final class WriteResult {

    private let result: BinaryenModuleAllocateAndWriteResult

    public var data: Data {
        return Data(
            bytes: result.binary,
            count: result.binaryBytes
        )
    }

    fileprivate init(result: BinaryenModuleAllocateAndWriteResult) {
        self.result = result
    }

    deinit {
        free(result.binary)
    }
}

public struct Binaryen {

    private init() {}

    /// The currently set optimize level. Applies to all modules, globally.
    /// 0, 1, 2 correspond to -O0, -O1, -O2 (default), etc.
    public static var optimizeLevel: Int {
        get {
            return Int(BinaryenGetOptimizeLevel())
        }
        set {
            BinaryenSetOptimizeLevel(Int32(newValue))
        }
    }

    /// The currently set shrink level. Applies to all modules, globally.
    /// 0, 1, 2 correspond to -O0, -Os (default), -Oz.
    public static var shrinkLevel: Int {
        get {
            return Int(BinaryenGetShrinkLevel())
        }
        set {
            BinaryenSetShrinkLevel(Int32(newValue))
        }
    }

    /// Enables or disables debug information in emitted binaries.
    /// Applies to all modules, globally.
    public static var isDebugInfoEnabled: Bool {
        get {
            return BinaryenGetDebugInfo() == 1
        }
        set {
            BinaryenSetDebugInfo(newValue ? 1 : 0)
        }
    }
}
