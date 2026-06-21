#if canImport(UIKit)
import UIKit

/// A horizontal row of tappable stars. Reads/writes `rating` (0...maximum) and
/// fires `.valueChanged` on user taps. Tapping the current rating clears it.
public final class StarRatingControl: UIControl {
    private let maximum: Int
    private let stack = UIStackView()
    private var buttons: [UIButton] = []

    public var rating: Int = 0 {
        didSet { updateImages() }
    }

    public init(maximum: Int = 5) {
        self.maximum = maximum
        super.init(frame: .zero)
        setUp()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    private func setUp() {
        stack.axis = .horizontal
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
        ])

        for index in 1...maximum {
            let button = UIButton(type: .system)
            button.tag = index
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            button.accessibilityLabel = "\(index) star\(index == 1 ? "" : "s")"
            buttons.append(button)
            stack.addArrangedSubview(button)
        }
        updateImages()
    }

    @objc private func starTapped(_ sender: UIButton) {
        rating = (rating == sender.tag) ? 0 : sender.tag
        sendActions(for: .valueChanged)
    }

    private func updateImages() {
        let config = UIImage.SymbolConfiguration(textStyle: .title2)
        for button in buttons {
            let filled = button.tag <= rating
            let image = UIImage(systemName: filled ? "star.fill" : "star", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = filled ? .systemYellow : .secondaryLabel
        }
    }
}
#endif
