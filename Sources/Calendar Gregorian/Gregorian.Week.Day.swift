extension Gregorian.Week {

    public enum Day {
        case sunday
        case monday
        case tuesday
        case wednesday
        case thursday
        case friday
        case saturday
    }
}

extension Gregorian.Week.Day: Sendable {}
extension Gregorian.Week.Day: Equatable {}
extension Gregorian.Week.Day: Hashable {}
extension Gregorian.Week.Day: CaseIterable {}
