#if canImport(UIKit)
import UIKit
import FutureBase

/// Convenience for presenting a feedback form modally. Wraps
/// `FeedbackViewController` in a navigation controller with a Close button and
/// dismisses automatically on a successful submission.
public enum FeedbackPresenter {
    public static func present(
        from presenter: UIViewController,
        slug: String,
        fields: [FeedbackField] = [.stars, .text],
        theme: FeedbackTheme = FeedbackTheme(),
        baseURL: URL? = nil,
        sendDeviceContext: Bool = true,
        title: String = "Feedback",
        animated: Bool = true,
        onResult: ((Result<FeedbackResult, Error>) -> Void)? = nil
    ) {
        let controller = FeedbackViewController(
            slug: slug,
            fields: fields,
            theme: theme,
            baseURL: baseURL,
            sendDeviceContext: sendDeviceContext,
            onResult: { result in
                onResult?(result)
                if case .success = result {
                    presenter.presentedViewController?.dismiss(animated: animated)
                }
            }
        )
        controller.title = title

        let navigation = UINavigationController(rootViewController: controller)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            systemItem: .close,
            primaryAction: UIAction { _ in navigation.dismiss(animated: animated) }
        )

        presenter.present(navigation, animated: animated)
    }
}
#endif
