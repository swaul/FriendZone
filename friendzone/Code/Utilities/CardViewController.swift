import DataSource
import Foundation
import Toolbox
import UIKit

protocol InteractiveAnimationDelegate: AnyObject {
    func updateAnimation(to progress: CGFloat)
    func animationDidFinish()
    func animationCanceled()
}

protocol InteractiveAnimationProvider: AnyObject {
    var shouldExecuteAnimationInteractive: Bool { get }
    var interactionDelegate: InteractiveAnimationDelegate? { get set }
}

class CardViewController: UIViewController {
    var onDismiss: (() -> Void)!
    var onBack: (() -> Void)!

    static func create() -> CardViewController {
        return CardViewController()
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        modalPresentationStyle = .overFullScreen
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        container.layer.cornerRadius = 20
    }

    var panGesture: UIPanGestureRecognizer!

    var currentHeightConstraint: NSLayoutConstraint!
    // to extend background to cover
    var extendedBackground: UIView!
    var extendedBackgroundHeight: NSLayoutConstraint!
    private let headerHeight: CGFloat = 0
    private let dragIndicatorHeight: CGFloat = 0
    var headerView: UIView!

    var container: UIView!
    
    lazy var backButton = UIButton().with {
        $0.setImage(.chevronLeft, for: .normal)
        $0.setTitle("Zurück", for: .normal)
        $0.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        $0.tintColor = .white
    }

    func setupViews() {
        view.backgroundColor = .clear
        container = UIView()
        view.addSubview(backButton)
        view.addSubview(container)
        currentHeightConstraint = container.heightAnchor.constraint(equalToConstant: headerHeight)

        // background
        extendedBackground = UIView()
        extendedBackground.backgroundColor = .clear
        view.addSubview(extendedBackground)
        view.sendSubviewToBack(extendedBackground)
        extendedBackgroundHeight = extendedBackground.heightAnchor.constraint(equalToConstant: 1)
        extendedBackgroundHeight.priority = .init(rawValue: 900)
        extendedBackground.backgroundColor = .clear
        extendedBackground.withConstraints {
            [
                $0.alignLeading(),
                $0.alignTrailing(),
                $0.alignBottom(),
                $0.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor),
                extendedBackgroundHeight
            ]
        }
        
        setUpHeader()
    }

    private func setUpHeader() {
        // header container
        headerView = UIView()
        container.addSubview(headerView)
        headerView.backgroundColor = .red
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerView.layer.cornerRadius = Style.CornerRadius.normal
        
        // drag indicator

        let dragIndicator = UIView()
        headerView.addSubview(dragIndicator)
        dragIndicator.backgroundColor = Asset.backgroundColor.color
        dragIndicator.layer.cornerRadius = dragIndicatorHeight / 2.0

        dragIndicator.withConstraints { view in
            view.alignCenter()
                + [
                    view.constraintHeight(dragIndicatorHeight),
                    view.constraintWidth(32)
                ]
        }
    }
    
    func updateBackButton(title: String) {
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.backButton.setTitle(title, for: .normal)
        }, completion: nil)
    }

    func setupConstraints() {
        
        backButton.withConstraints { button in
            [
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                button.bottomAnchor.constraint(equalTo: container.topAnchor, constant: -16)
            ]
        }
        
        headerView.withConstraints { view in
            [
                view.alignLeading(),
                view.alignTrailing(),
                view.alignTop(),
                view.constraintHeight(headerHeight)
            ]
        }

        container.withConstraints { view in
            [
                currentHeightConstraint,
                view.alignLeading(),
                view.alignTrailing(),
                view.alignBottom(),
                view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 48)
            ]
        }
    }

    @objc func backgroundTapped() {
        onDismiss()
    }
    
    @objc func backButtonTapped() {
        onBack()
    }

    // MARK: - Setting content

    func setBottomCard(contentViewController: UIViewController) {
        // removing old view controller(s)
        loadViewIfNeeded()
        children.forEach {
            $0.willMove(toParent: nil)
            $0.view.removeFromSuperview()
            $0.removeFromParent()
        }

        // adding new view controller
        if let interactionProvider = contentViewController as? InteractiveAnimationProvider {
            interactionProvider.interactionDelegate = self
        }
        addChild(contentViewController)
        container.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)
        contentViewController.view.withConstraints {
            [
                $0.alignLeading(),
                $0.alignTrailing(),
                $0.alignBottom(),
                $0.topAnchor.constraint(equalTo: headerView.bottomAnchor)
            ]
        }
        currentHeightConstraint.constant = cappedHeight(for: contentViewController.preferredContentSize.height)
    }

    // MARK: - Height changes

    private let maxHeight = UIScreen.main.bounds.size.height * 0.9
    private func cappedHeight(for preferredHeight: CGFloat) -> CGFloat {
        return min(preferredHeight + headerHeight, maxHeight)
    }

    private var currentDiffToAnimate: CGFloat?

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        let cappedHeight = cappedHeight(for: container.preferredContentSize.height)
        let difference = currentHeightConstraint!.constant - cappedHeight
        view.layoutIfNeeded()
        extendedBackgroundHeight.constant = max(abs(difference), 0)
        currentHeightConstraint?.constant = cappedHeight
        
        if let provider = children.first as? InteractiveAnimationProvider,
           provider.shouldExecuteAnimationInteractive {
            currentDiffToAnimate = difference
        } else {
            UIView.animate(withDuration: 0.3, animations: { [self] in
                view.layoutIfNeeded()
            }, completion: { _ in
                self.extendedBackgroundHeight.constant = 0
            })
        }
    }

    private var originalContainerY: CGFloat?
}

// Interactive content size changes

extension CardViewController: InteractiveAnimationDelegate {
    func animationDidFinish() {
        currentDiffToAnimate = nil
        container.transform = .identity
    }

    func updateAnimation(to progress: CGFloat) {
        guard let difference = currentDiffToAnimate else { return }
        container.transform = .init(translationX: 0, y: -(difference * (1 - progress)))
    }

    func animationCanceled() {
        currentDiffToAnimate = nil

        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut, animations: {
            if let container = self.children.first {
                self.currentHeightConstraint.constant = self.cappedHeight(for: container.preferredContentSize.height)
            }
            self.container.transform = .identity
        })
    }
}
