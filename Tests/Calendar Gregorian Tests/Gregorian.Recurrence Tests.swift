import Calendar_Gregorian
import Foundation
import Testing

@Suite
struct `Gregorian.Recurrence describes a repeating schedule` {

    @Test
    func `the interval defaults to one`() {
        #expect(Gregorian.Recurrence(frequency: .weekly).interval == 1)
    }

    @Test(arguments: [Gregorian.Recurrence.Frequency.daily, .weekly, .monthly, .yearly])
    func `a recurrence round trips through JSON`(_ frequency: Gregorian.Recurrence.Frequency) throws {
        let recurrence = Gregorian.Recurrence(frequency: frequency, interval: 3)
        let data = try JSONEncoder().encode(recurrence)
        #expect(try JSONDecoder().decode(Gregorian.Recurrence.self, from: data) == recurrence)
    }

    @Test
    func `recurrences hash by frequency and interval`() {
        let set: Set = [
            Gregorian.Recurrence(frequency: .monthly),
            Gregorian.Recurrence(frequency: .monthly, interval: 1),
            Gregorian.Recurrence(frequency: .monthly, interval: 2),
            Gregorian.Recurrence(frequency: .yearly),
        ]
        #expect(set.count == 3)
    }
}
