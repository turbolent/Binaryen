public struct ExpressionId {

    public let expressionId: BinaryenExpressionId

    internal init(expressionId: BinaryenExpressionId) {
        self.expressionId = expressionId
    }

    public static let invalid = ExpressionId(expressionId: BinaryenInvalidId())
    public static let block = ExpressionId(expressionId: BinaryenBlockId())
    public static let `if` = ExpressionId(expressionId: BinaryenIfId())
    public static let loop = ExpressionId(expressionId: BinaryenLoopId())
    public static let `break` = ExpressionId(expressionId: BinaryenBreakId())
    public static let `switch` = ExpressionId(expressionId: BinaryenSwitchId())
    public static let call = ExpressionId(expressionId: BinaryenCallId())
    public static let callIndirect = ExpressionId(expressionId: BinaryenCallIndirectId())
    public static let getLocal = ExpressionId(expressionId: BinaryenGetLocalId())
    public static let setLocal = ExpressionId(expressionId: BinaryenSetLocalId())
    public static let getGlobal = ExpressionId(expressionId: BinaryenGetGlobalId())
    public static let setGlobal = ExpressionId(expressionId: BinaryenSetGlobalId())
    public static let load = ExpressionId(expressionId: BinaryenLoadId())
    public static let store = ExpressionId(expressionId: BinaryenStoreId())
    public static let const = ExpressionId(expressionId: BinaryenConstId())
    public static let unary = ExpressionId(expressionId: BinaryenUnaryId())
    public static let binary = ExpressionId(expressionId: BinaryenBinaryId())
    public static let select = ExpressionId(expressionId: BinaryenSelectId())
    public static let drop = ExpressionId(expressionId: BinaryenDropId())
    public static let `return` = ExpressionId(expressionId: BinaryenReturnId())
    public static let host = ExpressionId(expressionId: BinaryenHostId())
    public static let nop = ExpressionId(expressionId: BinaryenNopId())
    public static let unreachable = ExpressionId(expressionId: BinaryenUnreachableId())
    public static let atomicCmpxchg = ExpressionId(expressionId: BinaryenAtomicCmpxchgId())
    public static let atomicRMW = ExpressionId(expressionId: BinaryenAtomicRMWId())
    public static let atomicWait = ExpressionId(expressionId: BinaryenAtomicWaitId())
    public static let atomicNotify = ExpressionId(expressionId: BinaryenAtomicNotifyId())
    public static let sIMDExtract = ExpressionId(expressionId: BinaryenSIMDExtractId())
    public static let sIMDReplace = ExpressionId(expressionId: BinaryenSIMDReplaceId())
    public static let sIMDShuffle = ExpressionId(expressionId: BinaryenSIMDShuffleId())
    public static let sIMDBitselect = ExpressionId(expressionId: BinaryenSIMDBitselectId())
    public static let sIMDShift = ExpressionId(expressionId: BinaryenSIMDShiftId())
    public static let memoryInit = ExpressionId(expressionId: BinaryenMemoryInitId())
    public static let dataDrop = ExpressionId(expressionId: BinaryenDataDropId())
    public static let memoryCopy = ExpressionId(expressionId: BinaryenMemoryCopyId())
    public static let memoryFill = ExpressionId(expressionId: BinaryenMemoryFillId())
}
