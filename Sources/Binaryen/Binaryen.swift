@_exported import CBinaryen
import Foundation


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

    /// Sets whether API tracing is on or off. It is off by default. When on, each call
    /// to an API method will print out C code equivalent to it, which is useful for
    /// auto-generating standalone testcases from projects using the API.
    /// When calling this to turn on tracing, the prelude of the full program is printed,
    /// and when calling it to turn it off, the ending of the program is printed, giving
    /// you the full compilable testcase.
    /// TODO: compile-time option to enable/disable this feature entirely at build time?
    public static func setAPITracing(enabled: Bool) {
        BinaryenSetAPITracing(enabled ? 1 : 0)
    }

}
