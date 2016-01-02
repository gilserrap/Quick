/**
    Descriptors intended to identify DSL function context.
*/
public enum ExampleContextDescriptor: String {
    case None = "none"
    case Top = "spec"
    case Describe = "describe"
    case Context = "context"
    case It = "it"
    case ItBehavesLike = "itBehavesLike"
    case BeforeEach = "beforeEach"
    case AfterEach = "afterEach"
}

public func validateDSLItemWithContext(currentContext: ExampleContextDescriptor, withinContext containingContext: ExampleContextDescriptor) {
    switch currentContext {
    case .It:
        if containingContext == .It || containingContext == .BeforeEach || containingContext == .AfterEach {
            fatalError("'\(currentContext.rawValue)' cannot be used inside '\(containingContext.rawValue)', '\(currentContext.rawValue)' may only be used inside 'context' or 'describe'.")
        }
    case .Context, .Describe, .ItBehavesLike, .AfterEach, .BeforeEach:
        if containingContext == .It {
            fatalError("'\(currentContext.rawValue)' cannot be used inside '\(containingContext.rawValue)', '\(currentContext.rawValue)' may only be used inside 'context' or 'describe'.")
        }
    default:
        break
    }
}
