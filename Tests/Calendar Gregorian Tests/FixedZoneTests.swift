import Calendar
import Affine
import Tagged
import Calendar_Gregorian
import Difference
import Testing
import Time

private func fixedZone(_ seconds: Int) -> Time.Zone {
    Time.Zone(offset: .init(seconds))
}

@Suite struct FixedZoneTests {
    @Test func fixedOffsetsHaveTheExpectedDirectionAcrossMidnightAndYearBoundaries() throws {
        let epoch = Instant(secondsSinceUnixEpoch: 0)
        let west = try epoch.gregorian(in: fixedZone(-30))
        #expect(west.year.rawValue == 1969)
        #expect(west.month == .december)
        #expect(west.day.rawValue == 31)
        #expect(west.hour.value == 23)
        #expect(west.minute.value == 59)
        #expect(west.second.value == 30)
        #expect(try west.instant(in: fixedZone(-30)) == epoch)

        let east = try epoch.gregorian(in: fixedZone(1_800))
        #expect(east.year.rawValue == 1970)
        #expect(east.month == .january)
        #expect(east.day.rawValue == 1)
        #expect(east.hour.value == 0)
        #expect(east.minute.value == 30)
        #expect(try east.instant(in: fixedZone(1_800)) == epoch)

        let localNewYear = try Gregorian.DateTime(year: 2000, month: .january, day: 1)
        let utc = try localNewYear.instant(in: fixedZone(20_700)).gregorian()
        #expect(utc.year.rawValue == 1999)
        #expect(utc.month == .december)
        #expect(utc.day.rawValue == 31)
        #expect(utc.hour.value == 18)
        #expect(utc.minute.value == 15)
    }

    @Test func exactRoundTripsPreserveFractionsAndSignedOffsets() throws {
        let offsets = [-86_401, -20_700, -1_800, -30, -1, 0, 1, 30, 1_800, 20_700, 86_401]
        let seconds: [Int64] = [-2_208_988_800, -86_401, -1, 0, 1, 86_399, 951_782_400]
        for offset in offsets {
            let zone = fixedZone(offset)
            for value in seconds {
                for fraction in [Int32(0), 1, 123_456_789, 999_999_999] {
                    let instant = try Instant(secondsSinceUnixEpoch: value, nanosecondFraction: fraction)
                    let local = try instant.gregorian(in: zone)
                    #expect(try local.instant(in: zone) == instant)
                    #expect(try Gregorian.DateTime(instant: instant, in: zone) == local)
                    #expect(local.totalNanoseconds == Int(fraction))
                    #expect(local.secondsSinceEpoch == Int(value) + offset)
                }
            }
        }
    }

    @Test func exactUniformCoordinateRejectsLeapSecondLabels() throws {
        let leapSecond = try Gregorian.DateTime(
            year: 2016, month: .december, day: 31, hour: 23, minute: 59, second: 60
        )
        #expect(leapSecond.second.value == 60)
        for offset in [-3_600, 0, 3_600] {
            #expect(throws: Gregorian.Conversion.Error.unsupportedLeapSecond) {
                try leapSecond.instant(in: fixedZone(offset))
            }
        }
    }

    @Test func fullUnixCoordinateEndpointsRoundTripExactlyInUTC() throws {
        for seconds in [Int64.min, .min + 1, .max - 1, .max] {
            for fraction in [Int32(0), 1, 999_999_999] {
                let instant = try Instant(secondsSinceUnixEpoch: seconds, nanosecondFraction: fraction)
                #expect(try instant.gregorian().instant() == instant)
            }
        }
    }

    @Test func overflowingFixedTranslationsReportErrorsInEitherDirection() throws {
        let maximum = Instant(secondsSinceUnixEpoch: .max)
        let minimum = Instant(secondsSinceUnixEpoch: .min)
        #expect(throws: Gregorian.Conversion.Error.overflow) {
            try maximum.gregorian(in: fixedZone(1))
        }
        #expect(throws: Gregorian.Conversion.Error.overflow) {
            try minimum.gregorian(in: fixedZone(-1))
        }
        let latest = try maximum.gregorian()
        let earliest = try minimum.gregorian()
        #expect(throws: Gregorian.Conversion.Error.overflow) {
            try latest.instant(in: fixedZone(-1))
        }
        #expect(throws: Gregorian.Conversion.Error.overflow) {
            try earliest.instant(in: fixedZone(1))
        }
        #expect(try maximum.gregorian(in: fixedZone(-1)).instant(in: fixedZone(-1)) == maximum)
        #expect(try minimum.gregorian(in: fixedZone(1)).instant(in: fixedZone(1)) == minimum)
    }

    @Test func GregorianYearsOutsideUnixCoordinateRangeReportErrors() throws {
        for year in [Int.min, Int.max] {
            let local = try Gregorian.DateTime(year: year, month: .january, day: 1)
            #expect(throws: Gregorian.Conversion.Error.overflow) { try local.instant() }
        }
    }
}
