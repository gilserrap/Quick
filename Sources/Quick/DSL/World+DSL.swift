import Foundation

/**
    Adds methods to World to support top-level DSL functions (Swift) and
    macros (Objective-C). These functions map directly to the DSL that test
    writers use in their specs.
*/
extension World {
    internal func beforeSuite(closure: BeforeSuiteClosure) {
        suiteHooks.appendBefore(closure)
    }

    internal func afterSuite(closure: AfterSuiteClosure) {
        suiteHooks.appendAfter(closure)
    }

    internal func sharedExamples(name: String, closure: SharedExampleClosure) {
        registerSharedExample(name, closure: closure)
    }

    internal func describe(description: String, flags: FilterFlags, closure: () -> ()) {
        guard currentExampleMetadata == nil else {
            NSException(name: "Invalid DSL Exception", reason: "'describe' cannot be used inside 'it', 'describe' may only be used inside 'context' or 'describe'. ", userInfo: nil).raise()
            return
        }
        guard currentExampleGroup != nil else {
            NSException(name: NSInternalInconsistencyException, reason:"Error: example group was not created by its parent QuickSpec spec. Check that describe() or context() was used in QuickSpec.spec() and not a more general context (i.e. an XCTestCase test)", userInfo: nil).raise()
            return
        }
        let group = ExampleGroup(description: description, flags: flags)
        currentExampleGroup.appendExampleGroup(group)
        currentExampleGroup = group
        closure()
        currentExampleGroup = group.parent
    }

    internal func context(description: String, flags: FilterFlags, closure: () -> ()) {
        guard currentExampleMetadata == nil else {
            NSException(name: "Invalid DSL Exception", reason: "'context' cannot be used inside 'it', 'context' may only be used inside 'context' or 'describe'. ", userInfo: nil).raise()
            return
        }
        self.describe(description, flags: flags, closure: closure)
    }

    internal func fdescribe(description: String, flags: FilterFlags, closure: () -> ()) {
        var focusedFlags = flags
        focusedFlags[Filter.focused] = true
        self.describe(description, flags: focusedFlags, closure: closure)
    }

    internal func xdescribe(description: String, flags: FilterFlags, closure: () -> ()) {
        var pendingFlags = flags
        pendingFlags[Filter.pending] = true
        self.describe(description, flags: pendingFlags, closure: closure)
    }

    internal func beforeEach(closure: BeforeExampleClosure) {
        guard currentExampleMetadata == nil else {
            NSException(name: "Invalid DSL Exception", reason: "'beforeEach' cannot be used inside 'it', 'beforeEach' may only be used inside 'context' or 'describe'. ", userInfo: nil).raise()
            return
        }
        currentExampleGroup.hooks.appendBefore(closure)
    }

    @objc(beforeEachWithMetadata:)
    internal func beforeEach(closure closure: BeforeExampleWithMetadataClosure) {
        currentExampleGroup.hooks.appendBefore(closure)
    }

    internal func afterEach(closure: AfterExampleClosure) {
        guard currentExampleMetadata == nil else {
            NSException(name: "Invalid DSL Exception", reason: "'afterEach' cannot be used inside 'it', 'afterEach' may only be used inside 'context' or 'describe'. ", userInfo: nil).raise()
            return
        }
        currentExampleGroup.hooks.appendAfter(closure)
    }

    @objc(afterEachWithMetadata:)
    internal func afterEach(closure closure: AfterExampleWithMetadataClosure) {
        currentExampleGroup.hooks.appendAfter(closure)
    }

    @objc(itWithDescription:flags:file:line:closure:)
    internal func it(description: String, flags: FilterFlags, file: String, line: UInt, closure: () -> ()) {
        if beforesCurrentlyExecuting() {
            NSException(name: "Invalid DSL Exception", reason: "'it' cannot be used inside 'beforeEach', 'it' may only be used inside 'context' or 'describe'. ", userInfo: nil).raise()
            return
        }
        guard currentExampleMetadata == nil else {
            NSException(name: "Invalid DSL Exception", reason: "'it' cannot be used inside 'it', 'it' may only be used inside 'context' or 'describe'. ", userInfo: nil).raise()
            return
        }
        let callsite = Callsite(file: file, line: line)
        let example = Example(description: description, callsite: callsite, flags: flags, closure: closure)
        currentExampleGroup.appendExample(example)
    }

    @objc(fitWithDescription:flags:file:line:closure:)
    internal func fit(description: String, flags: FilterFlags, file: String, line: UInt, closure: () -> ()) {
        var focusedFlags = flags
        focusedFlags[Filter.focused] = true
        self.it(description, flags: focusedFlags, file: file, line: line, closure: closure)
    }

    @objc(xitWithDescription:flags:file:line:closure:)
    internal func xit(description: String, flags: FilterFlags, file: String, line: UInt, closure: () -> ()) {
        var pendingFlags = flags
        pendingFlags[Filter.pending] = true
        self.it(description, flags: pendingFlags, file: file, line: line, closure: closure)
    }

    @objc(itBehavesLikeSharedExampleNamed:sharedExampleContext:flags:file:line:)
    internal func itBehavesLike(name: String, sharedExampleContext: SharedExampleContext, flags: FilterFlags, file: String, line: UInt) {
        guard currentExampleMetadata == nil else {
            NSException(name: "Invalid DSL Exception", reason: "'itBehavesLike' cannot be used inside 'it', 'itBehavesLike' may only be used inside 'context' or 'describe'. ", userInfo: nil).raise()
            return
        }
        let callsite = Callsite(file: file, line: line)
        let closure = World.sharedWorld.sharedExample(name)

        let group = ExampleGroup(description: name, flags: flags)
        currentExampleGroup.appendExampleGroup(group)
        currentExampleGroup = group
        closure(sharedExampleContext)
        currentExampleGroup.walkDownExamples { (example: Example) in
            example.isSharedExample = true
            example.callsite = callsite
        }

        currentExampleGroup = group.parent
    }

    internal func pending(description: String, closure: () -> ()) {
        print("Pending: \(description)")
    }
}
