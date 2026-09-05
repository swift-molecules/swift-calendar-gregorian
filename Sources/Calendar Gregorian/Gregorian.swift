public import Calendar
public import Time

/// Proleptic Gregorian dates and their interpretation on the fixed-day coordinate.
public enum Gregorian {}

extension Gregorian {

    public static func isLeapYear(_ year: Gregorian.Year) -> Bool {
        let y = year.rawValue
        return (y % 4 == 0 && y % 100 != 0) || (y % 400 == 0)
    }

    public static func isLeapYear(_ year: Int) -> Bool {
        isLeapYear(Gregorian.Year(year))
    }
}

extension Gregorian {

    internal static let daysInCommonYearMonths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    internal static let daysInLeapYearMonths = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    public static func daysInMonth(_ year: Gregorian.Year, _ month: Gregorian.Month) -> Int {
        let monthArray = isLeapYear(year) ? daysInLeapYearMonths : daysInCommonYearMonths

        return monthArray[month.rawValue - 1]
    }

    public static func daysInMonths(year: Int) -> [Int] {
        isLeapYear(year) ? daysInLeapYearMonths : daysInCommonYearMonths
    }

    internal static func daysInMonth(year: Int, month: Int) -> Int {
        let months = daysInMonths(year: year)

        return months[month - 1]
    }
}

extension Gregorian {
    public typealias DateTime = Calendar::DateTime<Gregorian.Date>
    public typealias Epoch = Time.Epoch<DateTime>

    public static func calendar() -> sending Calendar::Calendar<Date> {
        Calendar::Calendar(dayNumber: dayNumber, date: date)
    }
}
