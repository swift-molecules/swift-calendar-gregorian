@_spi(Internal) public import Calendar
@_spi(Internal) public import Time

extension Time.Epoch where Reference == Gregorian.DateTime {

    public static var unix: Self {
        Self(referenceDate: .init(
            _unchecked: (), year: 1970, month: 1, day: 1, hour: 0, minute: 0, second: 0
        ))
    }

    public static var ntp: Self {
        Self(referenceDate: .init(
            _unchecked: (), year: 1900, month: 1, day: 1, hour: 0, minute: 0, second: 0
        ))
    }

    public static var gps: Self {
        Self(referenceDate: .init(
            _unchecked: (), year: 1980, month: 1, day: 6, hour: 0, minute: 0, second: 0
        ))
    }

    public static var tai: Self {
        Self(referenceDate: .init(
            _unchecked: (), year: 1958, month: 1, day: 1, hour: 0, minute: 0, second: 0
        ))
    }

    public static var windowsFileTime: Self {
        Self(referenceDate: .init(
            _unchecked: (), year: 1601, month: 1, day: 1, hour: 0, minute: 0, second: 0
        ))
    }

    public static var appleAbsolute: Self {
        Self(referenceDate: .init(
            _unchecked: (), year: 2001, month: 1, day: 1, hour: 0, minute: 0, second: 0
        ))
    }

    public typealias Conversion = Gregorian.Conversion
}
