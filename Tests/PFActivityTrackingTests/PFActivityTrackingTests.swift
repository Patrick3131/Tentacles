import XCTest
@testable import PFActivityTracking

final class PFActivityTrackingTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
    
    func testAttributesOfActivity() throws {
        let initialAttributes = AttributesStub(values: [
            "User" : "Patrick",
            "Age" : 29,
            "Job": "Software Developer",
            "Human": true])
        let lazyAttributes = AttributesStub(
            values: ["Attributes Selected": true])
        let activityType = PFActivityTypeStub(
            name: "Wave Peak Selected",
            attributes: initialAttributes)
        var activity = PFActivity(type: activityType, status: .opened)
        activity.addAttributes(lazyAttributes)
        XCTAssertEqual(activity.status.rawValue, "opened")
        XCTAssertNotEqual(activity.attributesValue, initialAttributes.value)
    }
}
