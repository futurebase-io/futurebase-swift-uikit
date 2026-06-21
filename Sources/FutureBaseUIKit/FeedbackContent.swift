import Foundation

/// Resolves the `content` string sent to the server. Prefers the user's typed
/// text; falls back to a rating summary so a stars-only submission still has
/// non-empty content (mirrors the web widget). Returns "" when nothing was
/// provided, so the core's validation surfaces the empty-content error.
func resolveFeedbackContent(text: String, rating: Int) -> String {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
    if !trimmed.isEmpty { return trimmed }
    if rating > 0 { return "User rated \(rating)/5 stars" }
    return ""
}
