import Foundation
import UIKit

class CardNavigationController: UINavigationController {
    static func create() -> CardNavigationController {
        return CardNavigationController()
    }

    var panGesture: UIScreenEdgePanGestureRecognizer!

    weak var interactionDelegate: InteractiveAnimationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        interactivePopGestureRecognizer?.isEnabled = false
    }

    override func didMove(toParent parent: UIViewController?) {
        panGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        panGesture!.edges = .left
        view.superview!.addGestureRecognizer(panGesture!)
    }
    var lastChildContentSize: CGSize = .zero

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.view.layoutIfNeeded()
        preferredContentSize = viewController.preferredContentSize
        lastChildContentSize = viewController.preferredContentSize
        
        super.pushViewController(viewController, animated: true)
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let lastViewController = super.popViewController(animated: animated)

        if let topViewController = topViewController {
            preferredContentSize = topViewController.preferredContentSize
            lastChildContentSize = topViewController.preferredContentSize
        }
        return lastViewController
    }
    
//    override var preferredContentSize: CGSize {
//        get {
//            if let internalContentSize = internalContentSize {
//                return internalContentSize
//            }
//            print("returning", internalContentSize)
//            return super.preferredContentSize
//        }
//        set {
//            print("setting", newValue)
//            internalContentSize = newValue
//        }
//    }
    
    private var internalContentSize: CGSize?
        
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        guard container === topViewController else { return }
//        if container.preferredContentSize != lastChildContentSize {
//            internalContentSize = container.preferredContentSize
//        }
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container.preferredContentSize != lastChildContentSize {
            preferredContentSize = container.preferredContentSize
            lastChildContentSize = container.preferredContentSize
        }
    }
}

extension CardNavigationController {
    @objc func handleSwipe(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        guard gestureRecognizer.state == .began else { return }
        _ = popViewController(animated: true)
    }
}

extension CardNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPushAnimation(operation: operation)
    }
}
