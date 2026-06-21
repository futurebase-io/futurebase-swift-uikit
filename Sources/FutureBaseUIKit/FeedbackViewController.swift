#if canImport(UIKit)
import UIKit
import FutureBase

/// A ready-to-use feedback form screen. Construct with a board `slug`; it
/// fetches board config on appear, renders the requested `fields`, and submits
/// via the core client. Present it yourself or use `FeedbackPresenter`.
public final class FeedbackViewController: UIViewController {
    private let client: FutureBaseClient
    private let fields: [FeedbackField]
    private let theme: FeedbackTheme
    private let onResult: ((Result<FeedbackResult, Error>) -> Void)?

    private var board: BoardInfo?
    private var selectedCategory: String?

    // Views
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private let starControl = StarRatingControl()
    private let textView = UITextView()
    private let nameField = UITextField()
    private let emailField = UITextField()
    private let categoryButton = UIButton(type: .system)
    private let submitButton = UIButton(type: .system)
    private let statusLabel = UILabel()
    private lazy var starRow = labeledRow(title: "Rating", view: starControl)
    private lazy var textRow = labeledRow(title: "Your feedback", view: textView)
    private lazy var categoryRow = labeledRow(title: "Category", view: categoryButton)

    public init(
        slug: String,
        fields: [FeedbackField] = [.stars, .text],
        theme: FeedbackTheme = FeedbackTheme(),
        baseURL: URL? = nil,
        sendDeviceContext: Bool = true,
        onResult: ((Result<FeedbackResult, Error>) -> Void)? = nil
    ) {
        self.client = FutureBaseClient(
            slug: slug,
            baseURL: baseURL ?? FutureBaseClient.productionBaseURL,
            sendDeviceContext: sendDeviceContext
        )
        self.fields = fields
        self.theme = theme
        self.onResult = onResult
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        buildLayout()
        applyAccentColor()
        loadBoard()
    }

    // MARK: layout

    private func buildLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        stack.axis = .vertical
        stack.spacing = 20
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        if fields.contains(.stars) { stack.addArrangedSubview(starRow) }
        if fields.contains(.text) {
            textView.font = .preferredFont(forTextStyle: .body)
            textView.layer.borderColor = UIColor.separator.cgColor
            textView.layer.borderWidth = 1
            textView.layer.cornerRadius = 8
            textView.heightAnchor.constraint(equalToConstant: 120).isActive = true
            stack.addArrangedSubview(textRow)
        }

        nameField.placeholder = "Name (optional)"
        nameField.borderStyle = .roundedRect
        emailField.placeholder = "Email (optional)"
        emailField.borderStyle = .roundedRect
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        stack.addArrangedSubview(labeledRow(title: "Contact", view: nameField))
        stack.addArrangedSubview(emailField)

        categoryButton.contentHorizontalAlignment = .leading
        categoryButton.setTitle("Select a category", for: .normal)
        categoryButton.showsMenuAsPrimaryAction = true
        categoryRow.isHidden = true
        stack.addArrangedSubview(categoryRow)

        var config = UIButton.Configuration.filled()
        config.title = "Send feedback"
        submitButton.configuration = config
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        stack.addArrangedSubview(submitButton)

        statusLabel.numberOfLines = 0
        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.isHidden = true
        stack.addArrangedSubview(statusLabel)
    }

    private func labeledRow(title: String, view: UIView) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .headline)
        let row = UIStackView(arrangedSubviews: [label, view])
        row.axis = .vertical
        row.spacing = 8
        return row
    }

    private func applyAccentColor() {
        let hex = theme.primaryColor ?? board?.primaryColor
        guard let hex, let color = UIColor(hex: hex) else { return }
        submitButton.configuration?.baseBackgroundColor = color
        starControl.tintColor = color
    }

    // MARK: board config

    private func loadBoard() {
        client.feedback.boardInfo { [weak self] result in
            DispatchQueue.main.async {
                guard let self, case let .success(info) = result else { return }
                self.board = info
                self.applyBoardConfig(info)
            }
        }
    }

    private func applyBoardConfig(_ info: BoardInfo) {
        applyAccentColor()

        if !info.feedbackEnabled {
            submitButton.isEnabled = false
            showStatus("Feedback is currently disabled for this board.", isError: false)
        }

        if info.requireEmailForFeedback {
            emailField.placeholder = "Email"
        }

        if let categories = info.categories, !categories.isEmpty {
            selectedCategory = categories.first
            categoryButton.setTitle(selectedCategory, for: .normal)
            categoryButton.menu = makeCategoryMenu(categories)
            categoryRow.isHidden = false
        }
    }

    private func makeCategoryMenu(_ categories: [String]) -> UIMenu {
        let actions = categories.map { category in
            UIAction(title: category, state: category == selectedCategory ? .on : .off) { [weak self] _ in
                guard let self else { return }
                self.selectedCategory = category
                self.categoryButton.setTitle(category, for: .normal)
                self.categoryButton.menu = self.makeCategoryMenu(categories)
            }
        }
        return UIMenu(children: actions)
    }

    // MARK: submission

    @objc private func submitTapped() {
        let emailRequired = board?.requireEmailForFeedback ?? false
        let email = emailField.text ?? ""
        if emailRequired && email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            showStatus("Email is required.", isError: true)
            return
        }

        submitButton.isEnabled = false
        showStatus("Sending…", isError: false)

        let rating = starControl.rating
        let input = FeedbackInput(
            content: resolveFeedbackContent(text: textView.text ?? "", rating: rating),
            rating: fields.contains(.stars) && rating > 0 ? rating : nil,
            email: email.isEmpty ? nil : email,
            name: nameField.text?.isEmpty == false ? nameField.text : nil,
            category: selectedCategory
        )

        client.feedback.submit(input) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success:
                    self.showStatus("Thanks for your feedback!", isError: false)
                    self.onResult?(result)
                case .failure(let error):
                    self.submitButton.isEnabled = true
                    self.showStatus(self.message(for: error), isError: true)
                    self.onResult?(result)
                }
            }
        }
    }

    private func showStatus(_ text: String, isError: Bool) {
        statusLabel.text = text
        statusLabel.textColor = isError ? .systemRed : .secondaryLabel
        statusLabel.isHidden = false
    }

    private func message(for error: Error) -> String {
        guard let error = error as? FutureBaseError else { return "Something went wrong." }
        switch error {
        case .network: return "Network error. Please try again."
        case .validation(let fields): return "Please check: \(fields.joined(separator: ", "))."
        case .server(_, let message): return message
        case .decoding, .invalidResponse: return "Unexpected server response."
        }
    }
}
#endif
