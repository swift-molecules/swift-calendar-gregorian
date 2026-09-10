extension Gregorian.Conversion {

    public enum Error: Swift.Error, Hashable, Sendable {

        case unsupportedLeapSecond

        case overflow
    }
}
