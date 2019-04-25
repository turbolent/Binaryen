public struct ExpressionFactory {

    private let moduleRef: BinaryenModuleRef!

    internal init(moduleRef: BinaryenModuleRef!) {
        self.moduleRef = moduleRef
    }

    /// Block: `name` can be nil. Specifying `Type.auto` as the 'type'
    ///        parameter indicates that the block's type shall be figured out
    ///        automatically instead of explicitly providing it. This conforms
    ///        to the behavior before the 'type' parameter has been introduced.
    public func block(
        name: String? = nil,
        children: [Expression],
        type: Type
    )
        -> BlockExpression
    {
        var children = children.map { $0.expressionRef }
        return BlockExpression(
            expressionRef: BinaryenBlock(
                moduleRef,
                name?.cString(using: .utf8),
                UnsafeMutablePointer(&children),
                BinaryenIndex(children.count),
                type.type
            )
        )
    }

    /// If: ifFalse can be nil
    public func `if`(
        condition: Expression,
        ifTrue: Expression,
        ifFalse: Expression?
    )
        -> IfExpression
    {
        return IfExpression(
            expressionRef: BinaryenIf(
                moduleRef,
                condition.expressionRef,
                ifTrue.expressionRef,
                ifFalse?.expressionRef
            )
        )
    }

    public func loop(
        name: String,
        body: Expression
    )
        -> LoopExpression
    {
        return LoopExpression(
            expressionRef: BinaryenLoop(
                moduleRef,
                name.cString(using: .utf8),
                body.expressionRef
            )
        )
    }

    /// Break: value and condition can be nil
    public func `break`(
        name: String,
        condition: Expression? = nil,
        value: Expression? = nil
    )
        -> BreakExpression
    {
        return BreakExpression(
            expressionRef: BinaryenBreak(
                moduleRef,
                name.cString(using: .utf8),
                condition?.expressionRef,
                value?.expressionRef
            )
        )
    }

    /// Switch: value can be nil
    public func `switch`(
        names: [String],
        defaultName: String,
        condition: Expression,
        value: Expression? = nil
    )
        -> SwitchExpression
    {
        var names = names.map { UnsafePointer($0.cString(using: .utf8)) }
        return SwitchExpression(
            expressionRef: BinaryenSwitch(
                moduleRef,
                UnsafeMutablePointer(&names),
                BinaryenIndex(names.count),
                defaultName.cString(using: .utf8),
                condition.expressionRef,
                value?.expressionRef
            )
        )
    }

    /// Call: Note the 'returnType' parameter. You must declare the
    ///       type returned by the function being called, as that
    ///       function might not have been created yet, so we don't
    ///       know what it is.
    public func call(
        target: String,
        operands: [Expression],
        returnType: Type
    )
        -> CallExpression
    {
        var operands = operands.map { $0.expressionRef }
        return CallExpression(
            expressionRef: BinaryenCall(
                moduleRef,
                target.cString(using: .utf8),
                UnsafeMutablePointer(&operands),
                BinaryenIndex(operands.count),
                returnType.type
            )
        )
    }

    public func callIndirect(
        target: Expression,
        operands: [Expression],
        type: String
    )
        -> CallIndirectExpression
    {
        var operands = operands.map { $0.expressionRef }
        return CallIndirectExpression(
            expressionRef: BinaryenCallIndirect(
                moduleRef,
                target.expressionRef,
                UnsafeMutablePointer(&operands),
                BinaryenIndex(operands.count),
                type.cString(using: .utf8)
            )
        )
    }

    /// GetLocal: Note the 'type' parameter. It might seem redundant, since the
    ///           local at that index must have a type. However, this API lets you
    ///           build code "top-down": create a node, then its parents, and so
    ///           on, and finally create the function at the end. (Note that in fact
    ///           you do not mention a function when creating ExpressionRefs, only
    ///           a module.) And since GetLocal is a leaf node, we need to be told
    ///           its type. (Other nodes detect their type either from their
    ///           type or their opcode, or failing that, their children. But
    ///           GetLocal has no children, it is where a "stream" of type info
    ///           begins.)
    ///           Note also that the index of a local can refer to a param or
    ///           a var, that is, either a parameter to the function or a variable
    ///           declared when you call BinaryenAddFunction. See BinaryenAddFunction
    ///           for more details.
    public func getLocal(index: UInt32, type: Type) -> GetLocalExpression? {
        return GetLocalExpression(
            expressionRef: BinaryenGetLocal(
                moduleRef,
                index,
                type.type
            )
        )
    }

    public func setLocal(index: UInt32, value: Expression) -> SetLocalExpression? {
        return SetLocalExpression(
            expressionRef: BinaryenSetLocal(
                moduleRef,
                index,
                value.expressionRef
            )
        )
    }

    public func teeLocal(index: UInt32, value: Expression) -> SetLocalExpression? {
        return SetLocalExpression(
            expressionRef: BinaryenTeeLocal(
                moduleRef,
                index,
                value.expressionRef
            )
        )
    }

    public func getGlobal(name: String, type: Type) -> GetGlobalExpression {
        return GetGlobalExpression(
            expressionRef: BinaryenGetGlobal(
                moduleRef,
                name.cString(using: .utf8),
                type.type
            )
        )
    }

    public func setGlobal(name: String, value: Expression) -> SetGlobalExpression {
        return SetGlobalExpression(
            expressionRef: BinaryenSetGlobal(
                moduleRef,
                name.cString(using: .utf8),
                value.expressionRef
            )
        )
    }

    /// Load: align can be 0, in which case it will be the natural alignment (equal to bytes)
    public func load(
        bytes: UInt32,
        signed: Bool,
        offset: UInt32,
        align: UInt32,
        type: Type,
        pointer: Expression
    )
        -> LoadExpression
    {
        return LoadExpression(
            expressionRef: BinaryenLoad(
                moduleRef,
                bytes,
                signed ? 1 : 0,
                offset,
                align,
                type.type,
                pointer.expressionRef
            )
        )
    }

    /// Store: align can be 0, in which case it will be the natural alignment (equal to bytes)
    public func store(
        bytes: UInt32,
        signed: Bool,
        offset: UInt32,
        align: UInt32,
        pointer: Expression,
        value: Expression,
        type: Type
    )
        -> StoreExpression
    {
        return StoreExpression(
            expressionRef: BinaryenStore(
                moduleRef,
                bytes,
                offset,
                align,
                pointer.expressionRef,
                value.expressionRef,
                type.type
            )
        )
    }

    public func const(value: Literal) -> LiteralExpression {
        return LiteralExpression(expressionRef: BinaryenConst(moduleRef, value))
    }

    public func unary(op: Op, value: Expression) -> UnaryExpression {
        return UnaryExpression(expressionRef: BinaryenUnary(moduleRef, op.op, value.expressionRef))
    }

    public func binary(op: Op, left: Expression, right: Expression) -> BinaryExpression {
        return BinaryExpression(
            expressionRef: BinaryenBinary(
                moduleRef,
                op.op,
                left.expressionRef,
                right.expressionRef
            )
        )
    }

    public func select(condition: Expression, ifTrue: Expression, ifFalse: Expression) -> SelectExpression {
        return SelectExpression(
            expressionRef: BinaryenSelect(
                moduleRef,
                condition.expressionRef,
                ifTrue.expressionRef,
                ifFalse.expressionRef
            )
        )
    }

    public func drop(value: Expression) -> DropExpression {
        return DropExpression(expressionRef: BinaryenDrop(moduleRef, value.expressionRef))
    }

    /// Return: value can be nil.
    public func `return`(value: Expression? = nil) -> ReturnExpression {
        return ReturnExpression(expressionRef: BinaryenReturn(moduleRef, value?.expressionRef))
    }

    // Host: name may be nil.
    public func host(op: Op, name: String, operands: [Expression]) -> HostExpression {
        var operands = operands.map { $0.expressionRef }
        return HostExpression(
            expressionRef: BinaryenHost(
                moduleRef,
                op.op,
                name.cString(using: .utf8),
                UnsafeMutablePointer(&operands),
                BinaryenIndex(operands.count)
            )
        )
    }

    public func nop() -> Expression {
        return Expression(expressionRef: BinaryenNop(moduleRef))
    }

    public func unreachable() -> Expression {
        return Expression(expressionRef: BinaryenUnreachable(moduleRef))
    }

    public func memoryInit(
        segment: UInt32,
        destination: Expression,
        offset: Expression,
        size: Expression
    )
        -> MemoryInitExpression
    {
        return MemoryInitExpression(
            expressionRef: BinaryenMemoryInit(
                moduleRef,
                segment,
                destination.expressionRef,
                offset.expressionRef,
                size.expressionRef
            )
        )
    }

    public func dataDrop(segment: UInt32) -> DataDropExpression {
        return DataDropExpression(expressionRef: BinaryenDataDrop(moduleRef, segment))
    }

    public func memoryCopy(
        segment: UInt32,
        destination: Expression,
        source: Expression,
        size: Expression
    )
        -> MemoryCopyExpression
    {
        return MemoryCopyExpression(
            expressionRef: BinaryenMemoryCopy(
                moduleRef,
                destination.expressionRef,
                source.expressionRef,
                size.expressionRef
            )
        )
    }

    public func memoryFill(
        segment: UInt32,
        destination: Expression,
        value: Expression,
        size: Expression
    )
        -> MemoryFillExpression
    {
        return MemoryFillExpression(
            expressionRef: BinaryenMemoryFill(
                moduleRef,
                destination.expressionRef,
                value.expressionRef,
                size.expressionRef
            )
        )
    }
}
