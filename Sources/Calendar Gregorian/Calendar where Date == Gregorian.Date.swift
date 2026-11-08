public import Calendar

extension Calendar::Calendar where Date == Gregorian.Date {
    public static func gregorian() -> sending Self { Gregorian.calendar() }
}
