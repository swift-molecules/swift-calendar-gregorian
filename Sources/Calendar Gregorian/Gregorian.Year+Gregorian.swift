extension Gregorian.Year {

    public var isLeapYear: Bool {
        Self.isLeapYear(self)
    }

    public static func isLeapYear(_ year: Gregorian.Year) -> Bool {
        Gregorian.isLeapYear(year)
    }
}
