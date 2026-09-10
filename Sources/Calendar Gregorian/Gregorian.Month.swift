extension Gregorian {

    public struct Month {

        public let rawValue: Int

        public init(_ value: Int) throws(Gregorian.Month.Error) {
            guard (1...12).contains(value) else {
                throw Error.invalidMonth(value)
            }
            self.rawValue = value
        }
    }
}

extension Gregorian.Month {

    internal init(unchecked value: Int) {
        self.rawValue = value
    }
}

extension Gregorian.Month {

    public static func < (lhs: Gregorian.Month, rhs: Gregorian.Month) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

extension Gregorian.Month {

    public static func == (lhs: Gregorian.Month, rhs: Int) -> Bool {
        lhs.rawValue == rhs
    }

    public static func == (lhs: Int, rhs: Gregorian.Month) -> Bool {
        lhs == rhs.rawValue
    }
}

extension Gregorian.Month {

    public func days(in year: Gregorian.Year) -> Int {
        Self.days(in: year, month: self)
    }

    public static func days(in year: Gregorian.Year, month: Gregorian.Month) -> Int {
        Gregorian.daysInMonth(year, month)
    }
}

extension Gregorian.Month {

    public static let january = Self(unchecked: 1)

    public static let february = Self(unchecked: 2)

    public static let march = Self(unchecked: 3)

    public static let april = Self(unchecked: 4)

    public static let may = Self(unchecked: 5)

    public static let june = Self(unchecked: 6)

    public static let july = Self(unchecked: 7)

    public static let august = Self(unchecked: 8)

    public static let september = Self(unchecked: 9)

    public static let october = Self(unchecked: 10)

    public static let november = Self(unchecked: 11)

    public static let december = Self(unchecked: 12)
}

extension Gregorian.Month: RawRepresentable {}
extension Gregorian.Month: Sendable {}
extension Gregorian.Month: Equatable {}
extension Gregorian.Month: Hashable {}
extension Gregorian.Month: Comparable {}

extension Gregorian.Month {
    public init?(rawValue: Int) {
        do { try self.init(rawValue) }
        catch { return nil }
    }
}
