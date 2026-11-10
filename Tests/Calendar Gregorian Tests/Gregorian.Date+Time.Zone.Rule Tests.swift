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

enum `Gregorian.Date+Time.Zone.Rule Tests` {}

extension `Gregorian.Date+Time.Zone.Rule Tests` {
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
}

extension `Gregorian.Date+Time.Zone.Rule Tests` {
    @Suite
    struct `Gregorian.DateTime converts through a zone rule` {

        @Test
        func `a local time in summer takes the summer offset`() throws {
            let transition = try midnight(2026, .march, 29) + 3_600
            let europe = rule(at: transition, from: 3_600, to: 7_200)
            let local = try Gregorian.DateTime(year: 2026, month: .july, day: 1, hour: 12)
            #expect(try local.instant(in: europe).secondsSinceUnixEpoch == midnight(2026, .july, 1) + 36_000)
        }

        @Test
        func `an ambiguous local time resolves to the earlier instant`() throws {
            let transition = try midnight(2026, .october, 25) + 3_600
            let europe = rule(at: transition, from: 7_200, to: 3_600)
            let local = try Gregorian.DateTime(year: 2026, month: .october, day: 25, hour: 2, minute: 30)
            #expect(try local.instant(in: europe).secondsSinceUnixEpoch == transition - 1_800)
        }

        @Test
        func `a skipped local time resolves to the later instant`() throws {
            let transition = try midnight(2026, .march, 29) + 3_600
            let europe = rule(at: transition, from: 3_600, to: 7_200)
            let local = try Gregorian.DateTime(year: 2026, month: .march, day: 29, hour: 2, minute: 30)
            #expect(try local.instant(in: europe).secondsSinceUnixEpoch == transition + 1_800)
        }

        @Test
        func `an instant reads back as the local time of its offset`() throws {
            let transition = try midnight(2026, .march, 29) + 3_600
            let europe = rule(at: transition, from: 3_600, to: 7_200)
            let before = Time.Instant(secondsSinceUnixEpoch: transition - 1)
            let after = Time.Instant(secondsSinceUnixEpoch: transition)
            #expect(try before.gregorian(in: europe).hour.value == 1)
            #expect(try after.gregorian(in: europe).hour.value == 3)
            #expect(try Gregorian.DateTime(instant: after, in: europe) == after.gregorian(in: europe))
            #expect(try after.gregorian(in: europe).instant(in: europe) == after)
        }

        @Test
        func `today is the local date at the instant`() throws {
            let east = Time.Zone.Rule { _ in .seconds(7_200) }
            let west = Time.Zone.Rule { _ in .seconds(-18_000) }
            let instant = Time.Instant(secondsSinceUnixEpoch: try midnight(2026, .november, 10) - 3_600)
            #expect(try Gregorian.Date.today(in: east, at: instant) == Gregorian.Date(year: 2026, month: .november, day: 10))
            #expect(try Gregorian.Date.today(in: west, at: instant) == Gregorian.Date(year: 2026, month: .november, day: 9))
        }
    }
}
