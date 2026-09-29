import Calendar
import Calendar_Gregorian
import Testing

private func date(_ year: Int, _ month: Gregorian.Month, _ day: Int) throws -> Gregorian.Date {
    try Gregorian.Date(year: Gregorian.Year(year), month: month, day: day)
}

@Suite
struct `Gregorian.Date month, year and weekday arithmetic` {

    @Test
    func `adding months clamps the day to the target month`() throws {
        #expect(try date(2024, .january, 31).adding(months: 1) == date(2024, .february, 29))
        #expect(try date(2023, .january, 31).adding(months: 1) == date(2023, .february, 28))
        #expect(try date(2024, .march, 31).adding(months: -1) == date(2024, .february, 29))
        #expect(try date(2024, .may, 31).adding(months: 1) == date(2024, .june, 30))
    }

    @Test
    func `adding months crosses year boundaries in both directions`() throws {
        #expect(try date(2024, .january, 15).adding(months: -1) == date(2023, .december, 15))
        #expect(try date(2024, .november, 15).adding(months: 14) == date(2026, .january, 15))
        #expect(try date(2024, .january, 15).adding(months: -13) == date(2022, .december, 15))
        #expect(try date(1, .january, 1).adding(months: -1) == date(0, .december, 1))
        #expect(try date(2024, .june, 15).adding(months: 0) == date(2024, .june, 15))
    }

    @Test
    func `adding years clamps a leap day`() throws {
        #expect(try date(2024, .february, 29).adding(years: 1) == date(2025, .february, 28))
        #expect(try date(2024, .february, 29).adding(years: 4) == date(2028, .february, 29))
        #expect(try date(2000, .february, 29).adding(years: 100) == date(2100, .february, 28))
        #expect(try date(2024, .february, 29).adding(years: -100) == date(1924, .february, 29))
    }

    @Test
    func `adding beyond the representable years throws overflow`() throws {
        let last = try date(Int.max, .december, 1)
        #expect(throws: Calendar<Gregorian.Date>.Error.arithmetic(.overflow)) { try last.adding(months: 1) }
        #expect(throws: Calendar<Gregorian.Date>.Error.arithmetic(.overflow)) { try last.adding(years: 1) }
        #expect(throws: Calendar<Gregorian.Date>.Error.arithmetic(.overflow)) {
            try date(-1, .january, 1).adding(years: Int.min)
        }
    }

    @Test
    func `the first of the month keeps year and month`() throws {
        #expect(try date(2024, .february, 29).firstOfMonth == date(2024, .february, 1))
        #expect(try date(2024, .february, 1).firstOfMonth == date(2024, .february, 1))
    }

    @Test
    func `next weekday is strictly later`() throws {
        let tuesday = try date(2026, .september, 29)
        #expect(tuesday.weekday == .tuesday)
        #expect(try tuesday.next(.tuesday) == date(2026, .october, 6))
        #expect(try tuesday.next(.wednesday) == date(2026, .september, 30))
        #expect(try tuesday.next(.monday) == date(2026, .october, 5))
    }

    @Test(arguments: Gregorian.Weekday.allCases)
    func `next weekday lands within a week on that weekday`(_ weekday: Gregorian.Weekday) throws {
        for day in 1...7 {
            let start = try date(2026, .september, day)
            let next = try start.next(weekday)
            let distance = try next - start
            #expect(next.weekday == weekday)
            #expect((1...7).contains { Gregorian.Day($0) == distance })
        }
    }
}
