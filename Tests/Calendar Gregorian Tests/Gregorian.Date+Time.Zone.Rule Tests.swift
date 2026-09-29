import Calendar
import Calendar_Gregorian
import Testing
import Time

private func midnight(_ year: Int, _ month: Gregorian.Month, _ day: Int) throws -> Int64 {
    try Gregorian.DateTime(year: year, month: month, day: day).instant().secondsSinceUnixEpoch
}

private func rule(at transition: Int64, from before: Int, to after: Int) -> Time.Zone.Rule {
    Time.Zone.Rule { instant in .seconds(instant.secondsSinceUnixEpoch < transition ? before : after) }
}

private func hours(_ range: Range<Time.Instant>) -> Int64 {
    (range.upperBound.secondsSinceUnixEpoch - range.lowerBound.secondsSinceUnixEpoch) / 3_600
}

@Suite
struct `Gregorian.Date bounds a day in a zone rule` {

    @Test
    func `a day in a fixed zone starts at local midnight and lasts a day`() throws {
        let day = try Gregorian.Date(year: 2026, month: .september, day: 29)
        let utc = Time.Zone.Rule { _ in .utc }
        let east = Time.Zone.Rule { _ in .seconds(7_200) }
        #expect(try day.start(in: utc).secondsSinceUnixEpoch == midnight(2026, .september, 29))
        #expect(try day.start(in: east).secondsSinceUnixEpoch == midnight(2026, .september, 29) - 7_200)
        #expect(try hours(day.instants(in: east)) == 24)
    }

    @Test
    func `a spring forward day lasts twenty three hours`() throws {
        let europe = rule(at: try midnight(2026, .march, 29) + 3_600, from: 3_600, to: 7_200)
        let day = try Gregorian.Date(year: 2026, month: .march, day: 29)
        #expect(try hours(day.instants(in: europe)) == 23)
        #expect(try day.start(in: europe).secondsSinceUnixEpoch == midnight(2026, .march, 29) - 3_600)
    }

    @Test
    func `a fall back day lasts twenty five hours`() throws {
        let europe = rule(at: try midnight(2026, .october, 25) + 3_600, from: 7_200, to: 3_600)
        let day = try Gregorian.Date(year: 2026, month: .october, day: 25)
        #expect(try hours(day.instants(in: europe)) == 25)
    }

    @Test
    func `a day whose midnight is skipped starts at the transition`() throws {
        let transition = try midnight(2018, .november, 4) + 10_800
        let brazil = rule(at: transition, from: -10_800, to: -7_200)
        let day = try Gregorian.Date(year: 2018, month: .november, day: 4)
        #expect(try day.start(in: brazil).secondsSinceUnixEpoch == transition)
        #expect(try hours(day.instants(in: brazil)) == 23)
    }

    @Test
    func `a skipped day has no instants`() throws {
        let transition = try midnight(2011, .december, 30) + 36_000
        let samoa = rule(at: transition, from: -36_000, to: 50_400)
        let skipped = try Gregorian.Date(year: 2011, month: .december, day: 30)
        let before = try Gregorian.Date(year: 2011, month: .december, day: 29)
        #expect(try skipped.instants(in: samoa).isEmpty)
        #expect(try skipped.start(in: samoa).secondsSinceUnixEpoch == transition)
        #expect(try before.instants(in: samoa).upperBound.secondsSinceUnixEpoch == transition)
    }

    @Test
    func `a day beyond the instant range throws overflow`() throws {
        let day = try Gregorian.Date(year: Gregorian.Year(Int.max), month: .january, day: 1)
        #expect(throws: Gregorian.Conversion.Error.overflow) { try day.start(in: Time.Zone.Rule { _ in .utc }) }
    }
}
