# FutureBase UIKit

Pre-built UIKit components for collecting feedback with
[FutureBase](https://futurebase.io). Built on
[`futurebase-swift`](https://github.com/futurebase-io/futurebase-swift) (core).

## Requirements

- iOS 15+
- Swift 5.9+

## Installation (Swift Package Manager)

```swift
.package(url: "https://github.com/futurebase-io/futurebase-swift-uikit", from: "0.1.0")
```

Add `"FutureBaseUIKit"` to your target's dependencies.

## Usage

Present a feedback form modally:

```swift
import FutureBaseUIKit

FeedbackPresenter.present(from: self, slug: "your-board-slug")
```

Or push/embed the view controller yourself:

```swift
let vc = FeedbackViewController(slug: "your-board-slug", fields: [.stars, .text]) { result in
    // optional: handle success/failure
}
navigationController?.pushViewController(vc, animated: true)
```

### Customization

- `fields:` — which fields to collect (`[.stars, .text]` by default).
- `theme:` — a `FeedbackTheme` (e.g. `FeedbackTheme(primaryColor: "#FF8000")`) to tint the form. Falls back to the board's color, then system styling.
- `baseURL:` — override the API endpoint for local testing.
- `sendDeviceContext:` — set `false` to stop attaching app/device info.

The form reads the board's categories, accent color, and email requirement automatically.

## License

MIT
