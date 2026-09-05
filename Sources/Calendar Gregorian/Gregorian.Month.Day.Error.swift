extension Gregorian.Month.Day {
    public enum Error {
        // Report the evaluated bound and year of the attempted date.
        case invalidDay(Int, daysInMonth: Int, year: Gregorian.Year)
    }
}

extension Gregorian.Month.Day.Error: Swift.Error {}
extension Gregorian.Month.Day.Error: Equatable {}
