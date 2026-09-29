extension Gregorian.Recurrence {

    public enum Frequency {
        case daily
        case weekly
        case monthly
        case yearly
    }
}

extension Gregorian.Recurrence.Frequency: Sendable {}
extension Gregorian.Recurrence.Frequency: Equatable {}
extension Gregorian.Recurrence.Frequency: Hashable {}

#if !hasFeature(Embedded)
extension Gregorian.Recurrence.Frequency: Codable {}
#endif
