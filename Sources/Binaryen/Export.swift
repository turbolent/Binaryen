public struct Export {
    public let exportRef: BinaryenExportRef!

    internal init(exportRef: BinaryenExportRef!) {
        self.exportRef = exportRef
    }

    /// Gets the external kind.
    public var externalKind: ExternalKind {
        return ExternalKind(externalKind: BinaryenExportGetKind(exportRef))
    }

    /// Gets the external name.
    public var externalName: String {
        return String(cString: BinaryenExportGetName(exportRef))
    }

    /// Gets the internal name.
    public var internalName: String {
        return String(cString: BinaryenExportGetValue(exportRef))
    }
}
