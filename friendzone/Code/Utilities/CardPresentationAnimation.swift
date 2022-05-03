import UIKit

class CardPresentationAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    init(direction: Direction) {
        self.direction = direction
    }

    private let direction: Direction
    
    enum Direction {
        case dismiss
        case present
        var sourceAlpha: CGFloat {
            switch self {
            case .present:
                return 0
            case .dismiss:
                return 1.0
            }
        }
        
        var targetAlpha: CGFloat {
            switch self {
            case .present:
                return 1.0
            case .dismiss:
                return 0.0
            }
        }
        
        func sourceTransformation(for view: UIView) -> CGAffineTransform {
            switch self {
            case .present:
                return CGAffineTransform(translationX: 0, y: view.frame.height)
            case .dismiss:
                return .identity
            }
        }
        
        func targetTransformation(for view: UIView) -> CGAffineTransform {
            switch self {
            case .present:
                return .identity
            case .dismiss:
                return CGAffineTransform(translationX: 0, y: view.frame.height)
            }
        }
    }

    private let duration = 0.3
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let cardViewController: CardViewController
        let container = transitionContext.containerView
        let viewToAnimate: UIView
        
        switch direction {
        case .dismiss:
            cardViewController = transitionContext.viewController(forKey: .from) as! CardViewController
        case .present:
            cardViewController = transitionContext.viewController(forKey: .to) as! CardViewController
        }
        container.addSubview(cardViewController.view)
        viewToAnimate = cardViewController.container
        
        viewToAnimate.safeAreaInsetsDidChange()
        viewToAnimate.setNeedsLayout()
        viewToAnimate.layoutIfNeeded()
        
        // set up snapshot
        let snapshot = viewToAnimate.snapshotView(afterScreenUpdates: true)!
        container.addSubview(snapshot)
        snapshot.frame = viewToAnimate.frame
        
        // prepare for animations
        cardViewController.extendedBackground.isHidden = true
        viewToAnimate.isHidden = true
        cardViewController.view.alpha = direction.sourceAlpha
        snapshot.transform = direction.sourceTransformation(for: snapshot)
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0, options: [.curveEaseInOut], animations: {
            cardViewController.view.alpha = self.direction.targetAlpha
            snapshot.transform = self.direction.targetTransformation(for: snapshot)
            
        }, completion: { _ in
            let success = !transitionContext.transitionWasCancelled
            cardViewController.extendedBackground.isHidden = false
            transitionContext.completeTransition(success)
            snapshot.removeFromSuperview()
            viewToAnimate.isHidden = false
        })
    }
}
