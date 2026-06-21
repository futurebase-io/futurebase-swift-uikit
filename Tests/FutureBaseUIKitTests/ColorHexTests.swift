import Testing
@testable import FutureBaseUIKit

@Suite struct ColorHexTests {
    @Test func parsesSixDigitHexWithHash() throws {
        let c = try #require(rgba(fromHex: "#FF8000"))
        #expect(abs(c.r - 1.0) < 0.001)
        #expect(abs(c.g - 0.502) < 0.01)
        #expect(abs(c.b - 0.0) < 0.001)
        #expect(abs(c.a - 1.0) < 0.001)
    }

    @Test func parsesSixDigitHexWithoutHash() throws {
        let c = try #require(rgba(fromHex: "0000FF"))
        #expect(abs(c.b - 1.0) < 0.001)
        #expect(abs(c.r - 0.0) < 0.001)
    }

    @Test func parsesEightDigitHexWithAlpha() throws {
        let c = try #require(rgba(fromHex: "#00000080"))
        #expect(abs(c.a - 0.502) < 0.01)
    }

    @Test func parsesThreeDigitShorthand() throws {
        let c = try #require(rgba(fromHex: "#0F0"))
        #expect(abs(c.g - 1.0) < 0.001)
        #expect(abs(c.r - 0.0) < 0.001)
    }

    @Test func returnsNilForInvalidInput() {
        #expect(rgba(fromHex: "nope") == nil)
        #expect(rgba(fromHex: "#12") == nil)
        #expect(rgba(fromHex: "") == nil)
    }
}
