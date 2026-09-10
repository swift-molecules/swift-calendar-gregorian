extension Gregorian {

    public struct Year {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

extension Gregorian.Year {

    public static func < (lhs: Gregorian.Year, rhs: Gregorian.Year) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Gregorian.Year: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: Int) {
        self.init(value)
    }
}

extension Gregorian.Year: RawRepresentable {}
extension Gregorian.Year: Sendable {}
extension Gregorian.Year: Equatable {}
extension Gregorian.Year: Hashable {}
extension Gregorian.Year: Comparable {}

extension Gregorian.Year {
    public init(_ value: Int) { self.init(rawValue: value) }
}
