import Foundation
import UIKit

class CustomPushAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    init(operation: UINavigationController.Operation) {
        self.operation = operation
    }

    private let operation: UINavigationController.Operation

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let rawFromView = transitionContext.view(forKey: .from) else { return }
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let fromView = rawFromView.snapshotView(afterScreenUpdates: false) ?? rawFromView
        rawFromView.isHidden = true
        let container = transitionContext.containerView
        container.addSubview(fromView)
        container.clipsToBounds = false
        fromView.clipsToBounds = false

        switch operation {
        case .push:
            container.addSubview(toView)
            fromView.transform = CGAffineTransform.identity
            toView.transform = CGAffineTransform(translationX: fromView.bounds.width, y: 0)
        case .pop:
            container.insertSubview(toView, belowSubview: fromView)
            fromView.transform = CGAffineTransform.identity
            toView.transform = CGAffineTransform(translationX: -toView.bounds.width, y: 0.0)
        default:
            break
        }

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            switch self.operation {
            case .push:
                fromView.transform = CGAffineTransform(translationX: -fromView.bounds.width, y: 0.0)
                toView.transform = CGAffineTransform.identity
            case .pop:
                fromView.transform = CGAffineTransform(translationX: fromView.bounds.width, y: 0.0)
                toView.transform = .identity
            default:
                break
            }

        }, completion: { _ in
            let success = !transitionContext.transitionWasCancelled

            if !success {
                toView.transform = .identity
                toView.removeFromSuperview()
            }
            rawFromView.isHidden = false
            fromView.removeFromSuperview()
            fromView.transform = .identity
            transitionContext.completeTransition(success)
        })
    }
}

