public class Expression {

    public let expressionRef: BinaryenExpressionRef!

    internal init(expressionRef: BinaryenExpressionRef!) {
        self.expressionRef = expressionRef
    }

    public var expressionId: ExpressionId {
        return ExpressionId(expressionId: BinaryenExpressionGetId(expressionRef))
    }

    public var type: Type {
        return Type(value: BinaryenExpressionGetType(expressionRef))
    }

    public func print() {
        BinaryenExpressionPrint(expressionRef)
    }
}

public final class BlockExpression: Expression {

    public var name: String {
        return String(cString: BinaryenBlockGetName(expressionRef))
    }

    public var childCount: Int {
        return Int(BinaryenBlockGetNumChildren(expressionRef))
    }

    public func child(at index: UInt32) -> Expression? {
        return BinaryenBlockGetChildAt(expressionRef, index)
            .map { Expression(expressionRef: $0) }
    }
}


public final class IfExpression: Expression {

    public var condition: Expression {
        return Expression(expressionRef: BinaryenIfGetCondition(expressionRef))
    }

    public var ifTrue: Expression {
        return Expression(expressionRef: BinaryenIfGetIfTrue(expressionRef))
    }

    public var ifFalse: Expression? {
        return BinaryenIfGetIfFalse(expressionRef)
            .map { Expression(expressionRef: $0) }
    }
}


public final class LoopExpression: Expression {

    public var name: String {
        return String(cString: BinaryenLoopGetName(expressionRef))
    }

    public var body: Expression {
        return Expression(expressionRef: BinaryenLoopGetBody(expressionRef))
    }
}


public final class BreakExpression: Expression {

    public var name: String {
        return String(cString: BinaryenBreakGetName(expressionRef))
    }

    public var condition: Expression? {
        return BinaryenBreakGetCondition(expressionRef)
            .map { Expression(expressionRef: $0) }
    }

    public var value: Expression? {
        return BinaryenBreakGetValue(expressionRef)
            .map { Expression(expressionRef: $0) }
    }
}


public final class SwitchExpression: Expression {

    public var nameCount: Int {
        return Int(BinaryenSwitchGetNumNames(expressionRef))
    }

    public func name(at index: UInt32) -> String? {
        return BinaryenSwitchGetNameAt(expressionRef, index)
            .map { String(cString: $0) }
    }

    public var defaultName: String {
        return String(cString: BinaryenSwitchGetDefaultName(expressionRef))
    }

    public var condition: Expression {
        return Expression(expressionRef: BinaryenSwitchGetCondition(expressionRef))
    }

    public var value: Expression? {
        return BinaryenSwitchGetValue(expressionRef)
            .map { Expression(expressionRef: $0) }
    }
}


public final class CallExpression: Expression {

    public var target: String {
        return String(cString: BinaryenCallGetTarget(expressionRef))
    }

    public var operandCount: Int {
        return Int(BinaryenCallGetNumOperands(expressionRef))
    }

    public func operand(at index: UInt32) -> Expression? {
        return BinaryenCallGetOperandAt(expressionRef, index)
            .map { Expression(expressionRef: $0) }
    }
}


public final class CallIndirectExpression: Expression {

    public var target: Expression {
        return Expression(expressionRef: BinaryenCallIndirectGetTarget(expressionRef))
    }

    public var operandCount: Int {
        return Int(BinaryenCallIndirectGetNumOperands(expressionRef))
    }

    public func operand(at index: UInt32) -> Expression? {
        return BinaryenCallIndirectGetOperandAt(expressionRef, index)
            .map { Expression(expressionRef: $0) }
    }
}


public final class GetLocalExpression: Expression {

    public var index: Int {
        return Int(BinaryenLocalGetGetIndex(expressionRef))
    }
}


public final class SetLocalExpression: Expression {

    public var index: Int {
        return Int(BinaryenLocalSetGetIndex(expressionRef))
    }

    public var value: Expression {
        return Expression(expressionRef: BinaryenLocalSetGetValue(expressionRef))
    }
}


public final class SetGlobalExpression: Expression {

    public var name: String {
        return String(cString: BinaryenGlobalSetGetName(expressionRef))
    }


    public var value: Expression {
        return Expression(expressionRef: BinaryenGlobalSetGetValue(expressionRef))
    }
}


public final class GetGlobalExpression: Expression {

    public var name: String {
        return String(cString: BinaryenGlobalGetName(expressionRef))
    }
}


public final class LoadExpression: Expression {

    public var isSigned: Bool {
        return BinaryenLoadIsSigned(expressionRef) == 1
    }

    public var offset: UInt32 {
        return BinaryenLoadGetOffset(expressionRef)
    }

    public var bytes: UInt32 {
        return BinaryenLoadGetBytes(expressionRef)
    }

    public var align: UInt32 {
        return BinaryenLoadGetAlign(expressionRef)
    }

    public var pointer: Expression {
        return Expression(expressionRef: BinaryenLoadGetPtr(expressionRef))
    }
}


public final class StoreExpression: Expression {

    public var offset: UInt32 {
        return BinaryenStoreGetBytes(expressionRef)
    }

    public var bytes: UInt32 {
        return BinaryenStoreGetOffset(expressionRef)
    }

    public var align: UInt32 {
        return BinaryenStoreGetAlign(expressionRef)
    }

    public var pointer: Expression {
        return Expression(expressionRef: BinaryenStoreGetPtr(expressionRef))
    }

    public var value: Expression {
        return Expression(expressionRef: BinaryenStoreGetValue(expressionRef))
    }
}


public final class LiteralExpression: Expression {

    public var valueI32: Int32 {
        return BinaryenConstGetValueI32(expressionRef)
    }

    public var valueI64: Int64 {
        return BinaryenConstGetValueI64(expressionRef)
    }

    public var valueI64Low: Int32 {
        return BinaryenConstGetValueI64Low(expressionRef)
    }

    public var valueI64High: Int32 {
        return BinaryenConstGetValueI64High(expressionRef)
    }

    public var valueF32: Float {
        return BinaryenConstGetValueF32(expressionRef)
    }

    public var valueF64: Float {
        return BinaryenConstGetValueF32(expressionRef)
    }
}


public final class UnaryExpression: Expression {
    public var instruction: Instruction {
        return .init(value: BinaryenUnaryGetOp(expressionRef))
    }

    public var value: Expression {
        return Expression(expressionRef: BinaryenUnaryGetValue(expressionRef))
    }
}


public final class BinaryExpression: Expression {
    public var instruction: Instruction {
        return .init(value: BinaryenBinaryGetOp(expressionRef))
    }

    public var left: Expression {
        return Expression(expressionRef: BinaryenBinaryGetLeft(expressionRef))
    }

    public var right: Expression {
        return Expression(expressionRef: BinaryenBinaryGetRight(expressionRef))
    }

}


public final class SelectExpression: Expression {

    public var condition: Expression {
        return Expression(expressionRef: BinaryenSelectGetCondition(expressionRef))
    }

    public var ifTrue: Expression {
        return Expression(expressionRef: BinaryenSelectGetIfTrue(expressionRef))
    }

    public var ifFalse: Expression {
        return Expression(expressionRef: BinaryenSelectGetIfFalse(expressionRef))
    }
}


public final class DropExpression: Expression {

    public var value: Expression {
        return Expression(expressionRef: BinaryenDropGetValue(expressionRef))
    }
}


public final class ReturnExpression: Expression {

    public var value: Expression? {
        return BinaryenReturnGetValue(expressionRef)
            .map { Expression(expressionRef: $0) }
    }
}

public final class MemoryInitExpression: Expression {

    public var segment: UInt32 {
        return BinaryenMemoryInitGetSegment(expressionRef)
    }

    public var destination: Expression {
        return Expression(expressionRef: BinaryenMemoryInitGetDest(expressionRef))
    }

    public var offset: Expression {
        return Expression(expressionRef: BinaryenMemoryInitGetOffset(expressionRef))
    }

    public var size: Expression {
        return Expression(expressionRef: BinaryenMemoryInitGetSize(expressionRef))
    }
}


public final class DataDropExpression: Expression {

    public var segment: UInt32 {
        return BinaryenDataDropGetSegment(expressionRef)
    }
}


public final class MemoryCopyExpression: Expression {

    public var destination: Expression {
        return Expression(expressionRef: BinaryenMemoryCopyGetDest(expressionRef))
    }

    public var source: Expression {
        return Expression(expressionRef: BinaryenMemoryCopyGetSource(expressionRef))
    }

    public var size: Expression {
        return Expression(expressionRef: BinaryenMemoryCopyGetSize(expressionRef))
    }
}


public final class MemoryFillExpression: Expression {

    public var destination: Expression {
        return Expression(expressionRef: BinaryenMemoryFillGetDest(expressionRef))
    }

    public var value: Expression {
        return Expression(expressionRef: BinaryenMemoryFillGetValue(expressionRef))
    }

    public var size: Expression {
        return Expression(expressionRef: BinaryenMemoryFillGetSize(expressionRef))
    }

}
