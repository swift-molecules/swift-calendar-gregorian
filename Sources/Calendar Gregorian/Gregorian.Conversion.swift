public import Calendar
internal import Time

extension Gregorian {

    public enum Conversion {}
}

extension Gregorian.Conversion {
    static let unixEpochDay: Int128 = 719_163

    public static func secondsSinceEpoch(from components: Gregorian.DateTime) -> Int {
        secondsSinceEpoch(
            year: components.year, month: components.month, day: components.day,
            hour: components.hour, minute: components.minute, second: components.second
        )
    }

    static func secondsSinceEpoch(
        year: Gregorian.Year, month: Gregorian.Month, day: Gregorian.Month.Day,
        hour: Time.Day.Hour, minute: Time.Hour.Minute, second: Time.Minute.Second
    ) -> Int {
        let days = Gregorian.fixedDay(year: year, month: month, day: day) - unixEpochDay
        let seconds = days * Int128(Time.Conversion.secondsPerDay)
            + Int128(Time.Conversion.seconds(hour: hour, minute: minute, second: second))
        guard let result = Int(exactly: seconds) else {
            preconditionFailure("Gregorian date does not fit the Unix seconds coordinate")
        }
        return result
    }

    static func componentsRaw(
        fromSecondsSinceEpoch secondsSinceEpoch: Int
    ) -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) {
        let clock = Time.Conversion.components(fromSeconds: secondsSinceEpoch)

        let day = DayNumber(rawValue: Int64(clock.days) + Int64(unixEpochDay))
        do throws(Calendar::Calendar<Gregorian.Date>.Decode.Error) {
            let date = try Gregorian.date(on: day)
            return (
                date.year.rawValue, date.month.rawValue, date.day.rawValue,
                clock.hour.value, clock.minute.value, clock.second.value
            )
        } catch {
            preconditionFailure("Unix coordinate has no representable Gregorian date")
        }
    }

    static func daysSinceEpoch(
        year: Gregorian.Year, month: Gregorian.Month, day: Gregorian.Month.Day
    ) -> Int {
        let days = Gregorian.fixedDay(year: year, month: month, day: day) - unixEpochDay
        guard let result = Int(exactly: days) else {
            preconditionFailure("Gregorian date does not fit the Unix day coordinate")
        }
        return result
    }
}
