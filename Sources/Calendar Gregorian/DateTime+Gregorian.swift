@_spi(Internal) public import Calendar
@_spi(Internal) public import Time

extension Calendar::DateTime where Date == Gregorian.Date {

    @_spi(Internal)
    public init(
        _unchecked: Void,
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        millisecond: Int = 0,
        microsecond: Int = 0,
        nanosecond: Int = 0
    ) {
        self = Self(
            date: .init(
                unchecked: Gregorian.Year(year),
                month: Gregorian.Month(unchecked: month),
                day: Gregorian.Month.Day(unchecked: day)
            ),
            hour: Time.Day.Hour(unchecked: hour),
            minute: Time.Hour.Minute(unchecked: minute),
            second: Time.Minute.Second(unchecked: second),
            millisecond: Time.Second.Millisecond(unchecked: millisecond),
            microsecond: Time.Millisecond.Microsecond(unchecked: microsecond),
            nanosecond: Time.Microsecond.Nanosecond(unchecked: nanosecond)
        )
    }
}

extension Calendar::DateTime where Date == Gregorian.Date {

    public init(
        year: Int,
        month: Int,
        day: Int,
        hour: Int,
        minute: Int,
        second: Int,
        millisecond: Int = 0,
        microsecond: Int = 0,
        nanosecond: Int = 0
    ) throws(Gregorian.DateTime.Error) {
        let m: Gregorian.Month
        do throws(Gregorian.Month.Error) {
            m = try Gregorian.Month(month)
        } catch {
            throw Error.monthOutOfRange(month)
        }
        try self.init(
            year: year, month: m, day: day, hour: hour, minute: minute, second: second,
            millisecond: millisecond, microsecond: microsecond, nanosecond: nanosecond
        )
    }

    public init(
        year: Int,
        month: Gregorian.Month,
        day: Int,
        hour: Int = 0,
        minute: Int = 0,
        second: Int = 0,
        millisecond: Int = 0,
        microsecond: Int = 0,
        nanosecond: Int = 0
    ) throws(Gregorian.DateTime.Error) {
        let y = Gregorian.Year(year)
        let m = month

        let date: Gregorian.Date
        do throws(Gregorian.Month.Day.Error) {
            date = try Gregorian.Date(year: y, month: m, day: day)
        } catch {
            throw Error.dayOutOfRange(day, month: month.rawValue, year: year)
        }

        let h: Time.Day.Hour
        do throws(Time.Day.Hour.Error) {
            h = try Time.Day.Hour(hour)
        } catch {
            throw Error.hourOutOfRange(hour)
        }

        let min: Time.Hour.Minute
        do throws(Time.Hour.Minute.Error) {
            min = try Time.Hour.Minute(minute)
        } catch {
            throw Error.minuteOutOfRange(minute)
        }

        let s: Time.Minute.Second
        do throws(Time.Minute.Second.Error) {
            s = try Time.Minute.Second(second)
        } catch {
            throw Error.secondOutOfRange(second)
        }

        let ms: Time.Second.Millisecond
        do throws(Time.Second.Millisecond.Error) {
            ms = try Time.Second.Millisecond(millisecond)
        } catch {
            throw Error.millisecondOutOfRange(millisecond)
        }

        let us: Time.Millisecond.Microsecond
        do throws(Time.Millisecond.Microsecond.Error) {
            us = try Time.Millisecond.Microsecond(microsecond)
        } catch {
            throw Error.microsecondOutOfRange(microsecond)
        }

        let ns: Time.Microsecond.Nanosecond
        do throws(Time.Microsecond.Nanosecond.Error) {
            ns = try Time.Microsecond.Nanosecond(nanosecond)
        } catch {
            throw Error.nanosecondOutOfRange(nanosecond)
        }

        self.init(
            date: date,
            hour: h,
            minute: min,
            second: s,
            millisecond: ms,
            microsecond: us,
            nanosecond: ns
        )
    }
}

extension Calendar::DateTime where Date == Gregorian.Date {

    public init(
        secondsSinceEpoch: Int
    ) {
        let (year, month, day, hour, minute, second) = Gregorian.Conversion
            .componentsRaw(fromSecondsSinceEpoch: secondsSinceEpoch)

        self = .init(
            _unchecked: (),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: 0,
            microsecond: 0,
            nanosecond: 0
        )
    }

    public init(
        secondsSinceEpoch: Int,
        nanoseconds: Int
    ) throws(Gregorian.DateTime.Error) {
        guard nanoseconds >= 0 && nanoseconds < 1_000_000_000 else {
            throw Error.nanosecondOutOfRange(nanoseconds)
        }

        let (year, month, day, hour, minute, second) = Gregorian.Conversion
            .componentsRaw(fromSecondsSinceEpoch: secondsSinceEpoch)

        let millisecond = nanoseconds / 1_000_000
        let microsecond = (nanoseconds % 1_000_000) / 1_000
        let nanosecond = nanoseconds % 1_000

        self = .init(
            _unchecked: (),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: millisecond,
            microsecond: microsecond,
            nanosecond: nanosecond
        )
    }

    @_spi(Internal)
    public init(
        _unchecked: (),
        secondsSinceEpoch: Int,
        nanoseconds: Int
    ) {
        let (year, month, day, hour, minute, second) = Gregorian.Conversion
            .componentsRaw(fromSecondsSinceEpoch: secondsSinceEpoch)

        let millisecond = nanoseconds / 1_000_000
        let microsecond = (nanoseconds % 1_000_000) / 1_000
        let nanosecond = nanoseconds % 1_000

        self = .init(
            _unchecked: (),
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute,
            second: second,
            millisecond: millisecond,
            microsecond: microsecond,
            nanosecond: nanosecond
        )
    }
}

extension Calendar::DateTime where Date == Gregorian.Date {

    public static func totalNanoseconds(
        millisecond: Time.Second.Millisecond, microsecond: Time.Millisecond.Microsecond, nanosecond: Time.Microsecond.Nanosecond
    ) -> Int {
        Time.totalNanoseconds(millisecond: millisecond, microsecond: microsecond, nanosecond: nanosecond)
    }

    public var weekday: Gregorian.Weekday {
        Self.weekday(year: year, month: month, day: day)
    }

    public static func weekday(
        year: Gregorian.Year,
        month: Gregorian.Month,
        day: Gregorian.Month.Day
    ) -> Gregorian.Weekday {
        Gregorian.Weekday(year: year, month: month, day: day)
    }

    public var secondsSinceEpoch: Int {
        Self.secondsSinceEpoch(from: self)
    }

    public static func secondsSinceEpoch(from time: Self) -> Int {
        Gregorian.Conversion.secondsSinceEpoch(from: time)
    }
}

@available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
extension Calendar::DateTime where Date == Gregorian.Date {

    public init(_ instant: Instant) {

        self = .init(
            _unchecked: (),
            secondsSinceEpoch: Int(instant.secondsSinceUnixEpoch),
            nanoseconds: Int(instant.nanosecondFraction)
        )
    }
}



extension Calendar::DateTime where Date == Gregorian.Date {
    public var year: Gregorian.Year { date.year }
    public var month: Gregorian.Month { date.month }
    public var day: Gregorian.Month.Day { date.day }

    public init(
        year: Gregorian.Year,
        month: Gregorian.Month,
        day: Gregorian.Month.Day,
        hour: Time.Day.Hour = .zero,
        minute: Time.Hour.Minute = .zero,
        second: Time.Minute.Second = .zero,
        millisecond: Time.Second.Millisecond = .zero,
        microsecond: Time.Millisecond.Microsecond = .zero,
        nanosecond: Time.Microsecond.Nanosecond = .zero
    ) throws(Gregorian.Month.Day.Error) {
        self.init(
            date: try Gregorian.Date(year: year, month: month, day: day),
            hour: hour, minute: minute, second: second,
            millisecond: millisecond, microsecond: microsecond, nanosecond: nanosecond
        )
    }
}

extension Calendar::DateTime where Date == Gregorian.Date {
    public init(
        date: Gregorian.Date,
        hour: Int,
        minute: Int = 0,
        second: Int = 0,
        millisecond: Int = 0,
        microsecond: Int = 0,
        nanosecond: Int = 0
    ) throws(Gregorian.DateTime.Error) {
        try self.init(
            year: date.year.rawValue, month: date.month, day: date.day.rawValue,
            hour: hour, minute: minute, second: second,
            millisecond: millisecond, microsecond: microsecond, nanosecond: nanosecond
        )
    }
}
