extension Gregorian.Week.Day {

    public enum Error {

        case invalidMonth(Int)

        case invalidDay(Int, month: Int, year: Int)
    }
}

extension Gregorian.Week.Day.Error: Swift.Error {}
extension Gregorian.Week.Day.Error: Equatable {}
