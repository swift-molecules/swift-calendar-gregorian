extension Gregorian {

    public struct Recurrence {
        public var frequency: Frequency
        public var interval: Int = 1

        public init(frequency: Frequency, interval: Int = 1) {
            self.frequency = frequency
            self.interval = interval
        }
    }
}

extension Gregorian.Recurrence: Sendable {}
extension Gregorian.Recurrence: Equatable {}
extension Gregorian.Recurrence: Hashable {}

#if !hasFeature(Embedded)
extension Gregorian.Recurrence: Codable {}
#endif
