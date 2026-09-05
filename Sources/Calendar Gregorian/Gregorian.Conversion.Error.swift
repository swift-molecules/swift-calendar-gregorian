extension Gregorian.Conversion {
    /// Failures interpreting a Gregorian clock label at a fixed numeric offset.
    public enum Error: Swift.Error, Hashable, Sendable {
        /// A uniform Unix coordinate cannot distinguish a leap-second label.
        case unsupportedLeapSecond

        /// A local or UTC coordinate lies outside the Int64 seconds domain.
        case overflow
    }
}
