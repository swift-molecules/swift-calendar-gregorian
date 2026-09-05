

extension Gregorian.Weekday {

    public init(
        year: Gregorian.Year,
        month: Gregorian.Month,
        day: Gregorian.Month.Day
    ) {
        self = Self.calculate(year: year, month: month, day: day)
    }

    public static func calculate(
        year: Gregorian.Year,
        month: Gregorian.Month,
        day: Gregorian.Month.Day
    ) -> Gregorian.Weekday {
        let days = Gregorian.fixedDay(year: year, month: month, day: day)
        let remainder = days % 7
        let gregorianDay = remainder < 0 ? remainder + 7 : remainder

        switch gregorianDay {
        case 0: return .sunday
        case 1: return .monday
        case 2: return .tuesday
        case 3: return .wednesday
        case 4: return .thursday
        case 5: return .friday
        default: return .saturday
        }
    }

    public init(year: Int, month: Int, day: Int) throws(Gregorian.Week.Day.Error) {
        let y = Gregorian.Year(year)

        let m: Gregorian.Month
        do throws(Gregorian.Month.Error) {
            m = try Gregorian.Month(month)
        } catch {
            throw Error.invalidMonth(month)
        }

        let d: Gregorian.Month.Day
        do throws(Gregorian.Month.Day.Error) {
            d = try Gregorian.Month.Day(day, in: m, year: y)
        } catch {
            throw Error.invalidDay(day, month: month, year: year)
        }

        self.init(year: y, month: m, day: d)
    }
}
