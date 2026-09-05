public import Calendar

extension Calendar::DateTime where Date == Gregorian.Date {

    public enum Error {

        case monthOutOfRange(Int)

        case dayOutOfRange(Int, month: Int, year: Int)

        case hourOutOfRange(Int)

        case minuteOutOfRange(Int)

        case secondOutOfRange(Int)

        case millisecondOutOfRange(Int)

        case microsecondOutOfRange(Int)

        case nanosecondOutOfRange(Int)
    }
}

extension Calendar::DateTime.Error: Swift.Error {}
extension Calendar::DateTime.Error: Equatable {}
