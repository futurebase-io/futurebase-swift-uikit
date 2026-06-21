import Testing
@testable import FutureBaseUIKit

@Suite struct FeedbackContentTests {
    @Test func usesTrimmedTextWhenPresent() {
        #expect(resolveFeedbackContent(text: "  Great app  ", rating: 0) == "Great app")
        #expect(resolveFeedbackContent(text: "Great app", rating: 4) == "Great app")
    }

    @Test func synthesizesFromRatingWhenTextEmpty() {
        #expect(resolveFeedbackContent(text: "   ", rating: 5) == "User rated 5/5 stars")
        #expect(resolveFeedbackContent(text: "", rating: 1) == "User rated 1/5 stars")
    }

    @Test func returnsEmptyWhenNothingProvided() {
        #expect(resolveFeedbackContent(text: "  ", rating: 0) == "")
    }
}
