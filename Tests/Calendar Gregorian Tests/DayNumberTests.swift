import Testing
import Calendar
import Calendar_Gregorian
import Difference
import Cardinal
import Magnitude
import Tagged
import Time

@Suite struct DayNumberTests {
    @Test func knownFixedDayAnchors() throws {
        let calendar = Gregorian.calendar()
        let anchors: [(Int, Gregorian.Month, Int, Int64)] = [
            (0, .january, 1, -365), (0, .december, 31, 0), (1, .january, 1, 1),
            (1969, .december, 31, 719_162), (1970, .january, 1, 719_163),
            (2000, .january, 1, 730_120)
        ]
        for (year, month, day, ordinal) in anchors {
            let date = try Gregorian.Date(year: .init(year), month: month, day: day)
            #expect(try calendar.dayNumber(of: date).rawValue == ordinal)
            #expect(try calendar.date(on: DayNumber(rawValue: ordinal)) == date)
        }
    }

    @Test func inverseAcrossACompleteFourHundredYearCycle() throws {
        let calendar = Gregorian.calendar()
        for value in Int64(-146_097)...0 {
            let day = DayNumber(rawValue: value)
            let date = try calendar.date(on: day)
            #expect(try calendar.dayNumber(of: date) == day)
        }
    }

    @Test(arguments: [Int64.min, -1, 0, 1, Int64.max])
    func coordinateEndpointsRoundTrip(value: Int64) throws {
        let calendar = Calendar<Gregorian.Date>.gregorian()
        let day = DayNumber(rawValue: value)
        #expect(try calendar.dayNumber(of: calendar.date(on: day)) == day)
    }

    @Test func datesOutsideCoordinateRangeReportFailure() throws {
        let calendar = Gregorian.calendar()
        for year in [Int.min, Int.max] {
            let date = try Gregorian.Date(year: .init(year), month: .january, day: 1)
            #expect(throws: Calendar<Gregorian.Date>.Encode.Error.unsupported) { try calendar.dayNumber(of: date) }
        }
    }

    @Test func dayArithmeticCrossesMonthAndLeapBoundaries() throws {
        let calendar = Gregorian.calendar()
        let february = try Gregorian.Date(year: 2024, month: .february, day: 28)
        let march = try Gregorian.Date(year: 2024, month: .march, day: 1)
        #expect(try calendar.adding(days: 2, to: february) == march)
        #expect(try calendar.distance(from: february, to: march).underlying == Difference(2))
        let identity = Calendar<DayNumber>(dayNumber: { $0 }, date: { $0 })
        #expect(try identity.convert(calendar.convert(march, to: identity), to: calendar) == march)
    }

    @Test(arguments: [Int64.min, Int64.max])
    func unixEndpointRoundTripsAfterCoordinateComposition(seconds: Int64) throws {
        let instant = try Instant(secondsSinceUnixEpoch: seconds, nanosecondFraction: 123_456_789)
        #expect(Instant(Gregorian.DateTime(instant)) == instant)
    }

    @Test func fullCoordinateDistanceRemainsARepresentableTypedDisplacement() throws {
        let minimum = DayNumber(rawValue: .min)
        let maximum = DayNumber(rawValue: .max)
        let distance = minimum.distance(to: maximum)
        #expect(distance.underlying.magnitude.value.rawValue == UInt.max)
        #expect(try minimum.advanced(by: distance) == maximum)
        #expect(try maximum.advanced(by: .init(_unchecked: -distance.underlying)) == minimum)

        let calendar = Gregorian.calendar()
        let first = try calendar.date(on: minimum)
        let last = try calendar.date(on: maximum)
        #expect(try calendar.distance(from: first, to: last) == distance)
        #expect(try calendar.adding(days: distance, to: first) == last)
    }
}
