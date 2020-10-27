public extension BinaryenLiteral {

    static func int32(_ value: Int32) -> BinaryenLiteral {
        return BinaryenLiteralInt32(value)
    }

    static func int64(_ value: Int64) -> BinaryenLiteral {
        return BinaryenLiteralInt64(value)
    }

    static func float32(_ value: Float) -> BinaryenLiteral {
        return BinaryenLiteralFloat32(value)
    }

    static func float64(_ value: Double) -> BinaryenLiteral {
        return BinaryenLiteralFloat64(value)
    }

    static func vec128(_ value: [UInt8]) -> BinaryenLiteral {
        return BinaryenLiteralVec128(value)
    }

    static func float32Bits(_ value: Int32) -> BinaryenLiteral {
        return BinaryenLiteralFloat32Bits(value)
    }

    static func float64Bits(_ value: Int64) -> BinaryenLiteral {
        return BinaryenLiteralFloat64Bits(value)
    }
}


public typealias Literal = BinaryenLiteral
