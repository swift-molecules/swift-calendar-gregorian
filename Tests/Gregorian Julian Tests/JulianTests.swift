#if Julian
import Calendar_Gregorian
import Tagged
import Testing
import Time


extension Gregorian.Julian {

    @Suite
    struct Test {

        @Test
        func `unix Epoch Constant`() {
            let jd = Gregorian.Julian.Day.unixEpoch
            #expect(jd.underlying == 2_440_587.5)
        }

        @Test
        func `j2000 Constant`() {
            let jd = Gregorian.Julian.Day.j2000
            #expect(jd.underlying == 2_451_545.0)
        }

        @Test
        func `modified Offset Constant`() {
            let offset = Gregorian.Julian.Offset.modified
            #expect(offset.underlying == 2_400_000.5)
        }

        @Test
        func `time To Julian Day J2000`() throws {

            let time = try Gregorian.DateTime(year: 2000, month: 1, day: 1, hour: 12, minute: 0, second: 0)
            let jd = try Gregorian.Julian.Day(time)
            #expect(abs(jd.underlying - 2_451_545.0) < 0.0001)
        }

        @Test
        func `time To Julian Day Unix Epoch`() throws {

            let time = try Gregorian.DateTime(year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0)
            let jd = try Gregorian.Julian.Day(time)
            #expect(abs(jd.underlying - 2_440_587.5) < 0.0001)
        }

        @Test
        func `time To Julian Day Midnight`() throws {

            let time = try Gregorian.DateTime(year: 2024, month: 6, day: 15, hour: 0, minute: 0, second: 0)
            let jd = try Gregorian.Julian.Day(time)
            let fractionalPart = jd.underlying - Double(Int(jd.underlying))
            #expect(abs(fractionalPart - 0.5) < 0.0001)
        }

        @Test
        func `time To Julian Day Noon`() throws {

            let time = try Gregorian.DateTime(year: 2024, month: 6, day: 15, hour: 12, minute: 0, second: 0)
            let jd = try Gregorian.Julian.Day(time)
            let fractionalPart = jd.underlying - Double(Int(jd.underlying))
            #expect(fractionalPart < 0.0001 || fractionalPart > 0.9999)
        }

        @Test
        func `julian Day To Time J2000`() throws {
            let jd = Gregorian.Julian.Day.j2000
            let time = try Gregorian.DateTime(jd)
            #expect(time.year.rawValue == 2000)
            #expect(time.month.rawValue == 1)
            #expect(time.day.rawValue == 1)
            #expect(time.hour.value == 12)
        }

        @Test
        func `julian Day To Time Unix Epoch`() throws {
            let jd = Gregorian.Julian.Day.unixEpoch
            let time = try Gregorian.DateTime(jd)
            #expect(time.year.rawValue == 1970)
            #expect(time.month.rawValue == 1)
            #expect(time.day.rawValue == 1)
            #expect(time.hour.value == 0)
        }

        @Test
        func `round Trip Time To Julian Day`() throws {
            let original = try Gregorian.DateTime(
                year: 2024,
                month: 7,
                day: 20,
                hour: 15,
                minute: 30,
                second: 45
            )
            let jd = try Gregorian.Julian.Day(original)
            let restored = try Gregorian.DateTime(jd)

            #expect(restored.year.rawValue == original.year.rawValue)
            #expect(restored.month.rawValue == original.month.rawValue)
            #expect(restored.day.rawValue == original.day.rawValue)
            #expect(restored.hour.value == original.hour.value)
            #expect(restored.minute.value == original.minute.value)
            // Tagged Double Julian days retain submillisecond, not exact second-boundary, precision.
            let restoredSeconds = Double(restored.second.value) + Double(restored.totalNanoseconds) / 1_000_000_000
            let originalSeconds = Double(original.second.value) + Double(original.totalNanoseconds) / 1_000_000_000
            #expect(abs(restoredSeconds - originalSeconds) < 0.0001)
        }

        @Test
        func `day Minus Day Equals Offset`() {
            let jd1 = Gregorian.Julian.Day.j2000
            let jd2 = Gregorian.Julian.Day(2_451_546.0)
            let offset = jd2 - jd1
            #expect(abs(offset.underlying - 1.0) < 0.0001)
        }

        @Test
        func `day Plus Offset Equals Day`() {
            let jd = Gregorian.Julian.Day.j2000
            let offset = Gregorian.Julian.Offset(10.0)
            let result = jd + offset
            #expect(abs(result.underlying - 2_451_555.0) < 0.0001)
        }

        @Test
        func `day Minus Offset Equals Day`() {
            let jd = Gregorian.Julian.Day.j2000
            let offset = Gregorian.Julian.Offset(10.0)
            let result = jd - offset
            #expect(abs(result.underlying - 2_451_535.0) < 0.0001)
        }

        @Test
        func `modified Julian Day J2000`() {
            let jd = Gregorian.Julian.Day.j2000
            let mjd = jd.modified
            #expect(abs(mjd - 51544.5) < 0.0001)
        }

        @Test
        func `modified Julian Day From Offset`() {
            let jd = Gregorian.Julian.Day.j2000
            let mjd = jd - .modified
            #expect(abs(mjd.underlying - 51544.5) < 0.0001)
        }

        @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
        @Test
        func `instant To Julian Day`() throws {
            let instant = try Time.Instant(secondsSinceUnixEpoch: 0)
            let jd = Gregorian.Julian.Day(instant)
            #expect(abs(jd.underlying - 2_440_587.5) < 0.0001)
        }

        @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
        @Test
        func `julian Day To Instant`() throws {
            let jd = Gregorian.Julian.Day.unixEpoch
            let instant = try Time.Instant(jd)
            #expect(instant.secondsSinceUnixEpoch == 0)
        }

        @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
        @Test
        func `instant Round Trip`() throws {
            let original = try Time.Instant(
                secondsSinceUnixEpoch: 1_000_000_000,
                nanosecondFraction: 500_000_000
            )
            let jd = try Gregorian.Julian.Day(original)
            let restored = try Time.Instant(jd)

            #expect(restored.secondsSinceUnixEpoch == original.secondsSinceUnixEpoch)

            #expect(abs(restored.nanosecondFraction - original.nanosecondFraction) < 100_000)
        }
    }
}

#endif
