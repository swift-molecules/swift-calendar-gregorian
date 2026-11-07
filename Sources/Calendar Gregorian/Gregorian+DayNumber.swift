public import Calendar

extension Gregorian {

    public static func dayNumber(of date: Date) throws(Calendar::Calendar<Gregorian.Date>.Encode.Error) -> DayNumber {
        let day = fixedDay(year: date.year, month: date.month, day: date.day)
        guard let rawValue = Int64(exactly: day) else { throw .unsupported }
        return DayNumber(rawValue: rawValue)
    }

    public static func date(on day: DayNumber) throws(Calendar::Calendar<Gregorian.Date>.Decode.Error) -> Date {

        let shifted = Int128(day.rawValue) + 305
        let era = floorDivide(shifted, by: 146_097)
        let dayOfEra = shifted - era * 146_097
        let yearOfEra = (dayOfEra - dayOfEra / 1460 + dayOfEra / 36_524 - dayOfEra / 146_096) / 365
        let year = yearOfEra + era * 400
        let dayOfYear = dayOfEra - (365 * yearOfEra + yearOfEra / 4 - yearOfEra / 100)
        let shiftedMonth = (5 * dayOfYear + 2) / 153
        let dateDay = dayOfYear - (153 * shiftedMonth + 2) / 5 + 1
        let month = shiftedMonth + (shiftedMonth < 10 ? 3 : -9)
        guard let dateYear = Int(exactly: year + (month <= 2 ? 1 : 0)) else {
            throw .unsupported(day)
        }

        let dateMonth = Month(unchecked: Int(month))
        do throws(Gregorian.Month.Day.Error) {
            return try Date(year: Year(dateYear), month: dateMonth, day: Int(dateDay))
        } catch {
            throw .unsupported(day)
        }
    }

    static func fixedDay(year: Year, month: Month, day: Month.Day) -> Int128 {
        let year = Int128(year.rawValue) - (month.rawValue <= 2 ? 1 : 0)
        let era = floorDivide(year, by: 400)
        let yearOfEra = year - era * 400
        let month = Int128(month.rawValue) + (month.rawValue > 2 ? -3 : 9)
        let dayOfYear = (153 * month + 2) / 5 + Int128(day.rawValue) - 1
        let dayOfEra = yearOfEra * 365 + yearOfEra / 4 - yearOfEra / 100 + dayOfYear
        return era * 146_097 + dayOfEra - 305
    }

    private static func floorDivide(_ value: Int128, by divisor: Int128) -> Int128 {
        let quotient = value / divisor
        return value % divisor < 0 ? quotient - 1 : quotient
    }
}
