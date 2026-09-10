# swift-calendar-gregorian

Proleptic Gregorian dates and conversion to the shared DayNumber coordinate.
Dependencies remain Calendar -> Time, with Gregorian depending on both. All manifests use URLs; the workspace resolves local checkouts.

```swift
import Calendar
import Calendar_Gregorian
import Time

let calendar = Gregorian.calendar()
let date = try Gregorian.Date(year: 2024, month: .february, day: 29)
let tomorrow = try date + Gregorian.Day(1)
let elapsedDays = try tomorrow - date
let coordinate = try calendar.dayNumber(of: date)
let restored = try calendar.date(on: coordinate)

let civil = try Gregorian.DateTime(
    date: date, hour: 12, minute: 30,
    millisecond: 123, microsecond: 456, nanosecond: 789
)
let instant = Instant(civil)
assert(Gregorian.DateTime(instant) == civil)
let origin = Gregorian.Epoch.unix
let custom = Time.Epoch(referenceDate: civil)
```

`Gregorian.calendar()` and `Calendar<Gregorian.Date>.gregorian()` return fresh
`sending Calendar<Gregorian.Date>` values. The calendar value supplies coordinate
conversion, not a second collection of Gregorian rules. Leap-year, month-length,
weekday and Easter operations belong directly to Gregorian and its component types.

Gregorian.Date owns and jointly validates Gregorian.Year, Gregorian.Month and
Gregorian.Month.Day. Reusing a day component with a different month or year revalidates
its context. Gregorian.DateTime aliases Calendar's generic DateTime<Gregorian.Date>;
its component constructors, property conveniences and Instant integration
are extensions in this package. The date structure is not imposed on other calendars.

## Migration

| Earlier API | Current owner/API |
| --- | --- |
| Root Time civil aggregate, then Calendar.Gregorian.DateTime | Gregorian.DateTime |
| Time.Year, then Calendar.Year | Gregorian.Year |
| Time.Month and Time.Month.Day | Gregorian.Month and Gregorian.Month.Day |
| Time.Week.Day / Time.Weekday | Gregorian.Week.Day / Gregorian.Weekday |
| Calendar.Date<System> with year/month/day fields | Gregorian.Date |
| Calendar.DateTime<System> | DateTime<Date>; Gregorian.DateTime is its Gregorian specialization |
| Calendar.Rules, Calendar.System and makeRules | Removed; Gregorian.calendar() supplies Calendar<Gregorian.Date> |
| Calendar.Gregorian leap-year/month-length/Easter operations | Same operations on Gregorian |
| Civil Epoch and its six named reference definitions | Gregorian.Epoch = Time.Epoch<Gregorian.DateTime> |
| Time.Epoch.Conversion | Gregorian.Conversion; also Gregorian.Epoch.Conversion |
| Civil/Instant conversion and civil Codable | Gregorian conversion; explicitly encode Instant(civil) and decode Instant before constructing Gregorian.DateTime |
| Bounded Time.Hour, Time.Minute, Time.Second | Time.Day.Hour, Time.Hour.Minute, Time.Minute.Second |
| Fractional clock components | Time.Second.Millisecond through Time.Zeptosecond.Yoctosecond |
| Time.Minute.quantity(90) | Time.Minute(90); analogous for every elapsed unit |

Year coordinates remain Int. Gregorian.dayNumber(of:) throws Calendar<Gregorian.Date>.Encode.Error.unsupported if the
coordinate cannot fit Int64; date(on:) checks the resulting year representation.
The 400-year cycle arithmetic uses Int128 intermediates, including for negative years.
Day advancement and cross-calendar conversion use Calendar's generic composition.

The existing nonthrowing Unix conversion APIs retain their representability precondition:
the resulting Unix seconds must fit Int. They now compose the same fixed-day calculation
with Time's mixed-radix clock arithmetic. No second Gregorian conversion algorithm is kept.
The existing second=60 acceptance and uniform-day normalization remain unchanged; this
experiment does not add leap-second or time-zone interpretation.

All six named epoch references (Unix, NTP, GPS, TAI, Windows FILETIME, Apple absolute) and
custom references remain. Named reference dates do not implement those time scales or
wire formats. Typed errors retain evaluated month length and year without capturing a
calendar-dependent reference value. Downstream RFC migration remains separate.


## Exact fixed-offset interpretation

```swift
let zone = try Time.Zone(hours: -5, minutes: 30)
let instant = try civil.instant(in: zone)
let restored = try instant.gregorian(in: zone)
assert(restored == civil)
```

These checked operations compose the same Gregorian day calculation with the
Time Instant checked duration arithmetic. UTC-to-local adds the offset;
local-to-UTC subtracts it. Nanoseconds are preserved and coordinate overflow is
reported through `Gregorian.Conversion.Error`.

A second component of 60 remains valid as a civil label. The exact uniform-day
correspondence rejects that label because representing a leap second requires a
separate time-scale interpretation. The older Unix convenience conversion retains
its documented uniform-day normalization.

Calendar distance now returns `DayNumber.Offset`, preserving the day domain and
representing the entire Int64 minimum-to-maximum separation. `adding(days:to:)`
accepts that typed offset; its integer overload remains a convenience boundary.

`Gregorian.Day(1)` is a signed calendar-day step. Date addition, subtraction, and
difference use checked Calendar coordinate operations. `Time.Day(1)` is a separate
elapsed quantity of exactly 86,400 seconds. Date differences require `try` because
a valid Gregorian date can lie outside the supported fixed-day coordinate range.

Gregorian.DateTime does not conform to Codable: Unix seconds are an interpretation
of a civil label, not Calendar.DateTime's generic representation. For the existing
Unix wire format, encode `Instant(civil)` and decode `Instant` before constructing
`Gregorian.DateTime(instant)`. This retains Instant's validation and wire keys
without assigning Gregorian semantics to every Calendar.DateTime specialization.
The nonthrowing conversion keeps its documented representability precondition;
use the checked fixed-offset conversion when that boundary must be reported.
