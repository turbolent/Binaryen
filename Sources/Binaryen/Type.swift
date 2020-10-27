public struct Type: RawRepresentable {
  public let rawValue: BinaryenType

  init(value: BinaryenType) { rawValue = value }
  public init?(rawValue: BinaryenType) { self.rawValue = rawValue }

  public static var none: Self { .init(value: BinaryenTypeNone()) }
  public static var int32: Self { .init(value: BinaryenTypeInt32()) }
  public static var int64: Self { .init(value: BinaryenTypeInt64()) }
  public static var float32: Self { .init(value: BinaryenTypeFloat32()) }
  public static var float64: Self { .init(value: BinaryenTypeFloat64()) }
  public static var vec128: Self { .init(value: BinaryenTypeVec128()) }
  public static var funcRef: Self { .init(value: BinaryenTypeFuncref()) }
  public static var externRef: Self { .init(value: BinaryenTypeExternref()) }
  public static var exnRef: Self { .init(value: BinaryenTypeExnref()) }
  public static var anyRef: Self { .init(value: BinaryenTypeAnyref()) }
  public static var auto: Self { .init(value: BinaryenTypeAuto()) }

  var arity: UInt32 { BinaryenTypeArity(rawValue) }
}

extension Type: ExpressibleByArrayLiteral {
  public init(arrayLiteral elements: Self...) {
    var elements = elements.map(\.rawValue)
    self = .init(value: BinaryenTypeCreate(&elements, UInt32(elements.count)))
  }
}
