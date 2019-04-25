public struct ExternalKind {

    public let externalKind: BinaryenExternalKind

    internal init(externalKind: BinaryenExternalKind) {
        self.externalKind = externalKind
    }

    public static let function = ExternalKind(externalKind: BinaryenExternalFunction())
    public static let table = ExternalKind(externalKind: BinaryenExternalTable())
    public static let memory = ExternalKind(externalKind: BinaryenExternalMemory())
    public static let global = ExternalKind(externalKind: BinaryenExternalGlobal())
}
