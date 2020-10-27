public struct ExpressionFactory {

    private let ref: BinaryenModuleRef!

    init(ref: BinaryenModuleRef!) {
        self.ref = ref
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
                ref,
                name?.cString(using: .utf8),
                &children,
                BinaryenIndex(children.count),
                type.rawValue
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
                ref,
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
                ref,
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
                ref,
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
        let mutableNames = names.map { strdup($0) }
        var immutableNames = mutableNames.map { UnsafePointer($0) }
        return SwitchExpression(
            expressionRef: BinaryenSwitch(
                ref,
                &immutableNames,
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
        returnTypes: Type
    )
        -> CallExpression
    {
        var operands = operands.map { $0.expressionRef }
        return CallExpression(
            expressionRef: BinaryenCall(
                ref,
                target.cString(using: .utf8),
                &operands,
                BinaryenIndex(operands.count),
                returnTypes.rawValue
            )
        )
    }

    public func callIndirect(
        target: Expression,
        operands: [Expression],
        params: Type,
        results: Type
    )
        -> CallIndirectExpression
    {
        var operands = operands.map { $0.expressionRef }
        return CallIndirectExpression(
            expressionRef: BinaryenCallIndirect(
                ref,
                target.expressionRef,
                &operands,
                BinaryenIndex(operands.count),
                params.rawValue,
                results.rawValue
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
    public func localGet(index: UInt32, type: Type) -> GetLocalExpression {
        return GetLocalExpression(
            expressionRef: BinaryenLocalGet(
                ref,
                index,
                type.rawValue
            )
        )
    }

    public func localSet(index: UInt32, value: Expression) -> SetLocalExpression {
        return SetLocalExpression(
            expressionRef: BinaryenLocalSet(
                ref,
                index,
                value.expressionRef
            )
        )
    }

    public func localTee(index: UInt32, value: Expression, type: Type) -> SetLocalExpression {
        return SetLocalExpression(
            expressionRef: BinaryenLocalTee(
                ref,
                index,
                value.expressionRef,
                type.rawValue
            )
        )
    }

    public func globalGet(name: String, type: Type) -> GetGlobalExpression {
        return GetGlobalExpression(
            expressionRef: BinaryenGlobalGet(
                ref,
                name.cString(using: .utf8),
                type.rawValue
            )
        )
    }

    public func globalSet(name: String, value: Expression) -> SetGlobalExpression {
        return SetGlobalExpression(
            expressionRef: BinaryenGlobalSet(
                ref,
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
                ref,
                bytes,
                signed ? 1 : 0,
                offset,
                align,
                type.rawValue,
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
                ref,
                bytes,
                offset,
                align,
                pointer.expressionRef,
                value.expressionRef,
                type.rawValue
            )
        )
    }

    public func const(value: Literal) -> LiteralExpression {
        return LiteralExpression(expressionRef: BinaryenConst(ref, value))
    }

    public func unary(instruction: Instruction, _ value: Expression) -> UnaryExpression {
        return UnaryExpression(expressionRef: BinaryenUnary(ref, instruction.rawValue, value.expressionRef))
    }

    public func binary(instruction: Instruction, _ left: Expression, _ right: Expression) -> BinaryExpression {
        return BinaryExpression(
            expressionRef: BinaryenBinary(
                ref,
                instruction.rawValue,
                left.expressionRef,
                right.expressionRef
            )
        )
    }

    public func select(condition: Expression, ifTrue: Expression, ifFalse: Expression, type: Type) -> SelectExpression {
        return SelectExpression(
            expressionRef: BinaryenSelect(
                ref,
                condition.expressionRef,
                ifTrue.expressionRef,
                ifFalse.expressionRef,
                type.rawValue
            )
        )
    }

    public func drop(value: Expression) -> DropExpression {
        return DropExpression(expressionRef: BinaryenDrop(ref, value.expressionRef))
    }

    /// Return: value can be nil.
    public func `return`(value: Expression? = nil) -> ReturnExpression {
        return ReturnExpression(expressionRef: BinaryenReturn(ref, value?.expressionRef))
    }

    public func nop() -> Expression {
        return Expression(expressionRef: BinaryenNop(ref))
    }

    public func unreachable() -> Expression {
        return Expression(expressionRef: BinaryenUnreachable(ref))
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
                ref,
                segment,
                destination.expressionRef,
                offset.expressionRef,
                size.expressionRef
            )
        )
    }

    public func dataDrop(segment: UInt32) -> DataDropExpression {
        return DataDropExpression(expressionRef: BinaryenDataDrop(ref, segment))
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
                ref,
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
                ref,
                destination.expressionRef,
                value.expressionRef,
                size.expressionRef
            )
        )
    }
}
