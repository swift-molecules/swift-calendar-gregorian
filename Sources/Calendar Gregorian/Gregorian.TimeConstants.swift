internal import Time

extension Gregorian {

    public enum TimeConstants {}
}

extension Gregorian.TimeConstants {

    public static let secondsPerMinute = Time.Conversion.secondsPerMinute

    public static let secondsPerHour = Time.Conversion.secondsPerHour

    public static let secondsPerDay = Time.Conversion.secondsPerDay

    public static let daysPerCommonYear = 365

    public static let daysPerLeapYear = 366

    public static let daysPer4Years = 1461

    public static let daysPer100Years = 36524

    public static let daysPer400Years = 146_097
}
