@_exported import CBinaryen
import Foundation


public struct Binaryen {
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

    /// Enable or disable coloring for the Wasm printer
    public static var isPrinterColoringEnabled: Bool {
        get { BinaryenAreColorsEnabled() == 1 }
        set { BinaryenSetColorsEnabled(newValue ? 1 : 0) }
    }
}
