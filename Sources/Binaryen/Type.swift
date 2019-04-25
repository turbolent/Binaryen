public struct Type {

    public let type: BinaryenType

    internal init(type: BinaryenType) {
        self.type = type
    }

    public static let none = Type(type: BinaryenTypeNone())
    public static let int32 = Type(type: BinaryenTypeInt32())
    public static let int64 = Type(type: BinaryenTypeInt64())
    public static let float32 = Type(type: BinaryenTypeFloat32())
    public static let float64 = Type(type: BinaryenTypeFloat64())
    public static let vec128 = Type(type: BinaryenTypeVec128())
    public static let unreachable = Type(type: BinaryenTypeUnreachable())
    /// Not a real type. Used as the last parameter to BinaryenBlock to let
    /// the API figure out the type instead of providing one.
    public static let auto = Type(type: BinaryenTypeAuto())
}
