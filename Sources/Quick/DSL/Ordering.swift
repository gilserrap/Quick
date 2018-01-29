import Foundation

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
@objc public enum TestOrder: Int {
    case random
    case defined
}
#else
public enum TestTestOrder: Int {
    case random
    case defined
}
#endif
