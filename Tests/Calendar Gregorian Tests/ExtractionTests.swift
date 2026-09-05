import Foundation
import Testing
import Time
import Calendar
import Calendar_Gregorian

@Suite struct ExtractionTests {
    @Test func aDayCannotCarryValidityFromAnotherMonth() throws {
        let day = try Gregorian.Month.Day(31, in: .january, year: 2024)
        #expect(throws: Gregorian.Month.Day.Error.self) {
            try Gregorian.Date(year: 2024, month: .february, day: day)
        }
        #expect(throws: Gregorian.Month.Day.Error.self) {
            try GregorianDateTime(year: 2024, month: .february, day: day)
        }
        let leapDay = try Gregorian.Month.Day(29, in: .february, year: 2024)
        #expect(throws: Gregorian.Month.Day.Error.self) {
            try Gregorian.Date(year: 2023, month: .february, day: leapDay)
        }
    }

    @Test func everyNamedEpochAndCustomReferenceSurvives() throws {
        let origins: [(Gregorian.Epoch, Int, Int, Int)] = [
            (.unix, 1970, 1, 1), (.ntp, 1900, 1, 1), (.gps, 1980, 1, 6),
            (.tai, 1958, 1, 1), (.windowsFileTime, 1601, 1, 1), (.appleAbsolute, 2001, 1, 1)
        ]
        for (epoch, year, month, day) in origins {
            #expect(epoch.referenceDate.year.rawValue == year)
            #expect(epoch.referenceDate.month.rawValue == month)
            #expect(epoch.referenceDate.day.rawValue == day)
            #expect(epoch == Time.Epoch(referenceDate: epoch.referenceDate))
        }
        let reference = try GregorianDateTime(
            year: 2024, month: 2, day: 29, hour: 12, minute: 30, second: 15,
            millisecond: 123, microsecond: 456, nanosecond: 789
        )
        let epoch = Time.Epoch(referenceDate: reference)
        #expect(epoch.referenceDate == reference)
    }

    @Test(arguments: [Int64(-1), 0, 1, 1_704_067_200])
    func fractionalInstantAndEncodingRoundTrip(seconds: Int64) throws {
        let instant = try Instant(secondsSinceUnixEpoch: seconds, nanosecondFraction: 123_456_789)
        let civil = GregorianDateTime(instant)
        #expect(Instant(civil) == instant)
        #expect(civil.millisecond.value == 123)
        #expect(civil.microsecond.value == 456)
        #expect(civil.nanosecond.value == 789)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        #expect(try encoder.encode(civil) == encoder.encode(instant))
        #expect(try JSONDecoder().decode(GregorianDateTime.self, from: encoder.encode(civil)) == civil)
    }

    @Test func weekdayUsesTheGregorianDayCoordinateAcrossNegativeYears() throws {
        let last = try GregorianDateTime(year: -497, month: 12, day: 31, hour: 0, minute: 0, second: 0)
        let next = GregorianDateTime(secondsSinceEpoch: last.secondsSinceEpoch + Time.Conversion.secondsPerDay)
        let week: [Gregorian.Weekday] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
        let index = try #require(week.firstIndex(of: last.weekday))
        #expect(next.weekday == week[(index + 1) % 7])
        #expect(GregorianDateTime(secondsSinceEpoch: last.secondsSinceEpoch + 7 * Time.Conversion.secondsPerDay).weekday == last.weekday)
    }
}
