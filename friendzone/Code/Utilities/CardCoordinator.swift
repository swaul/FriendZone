import Foundation
import Toolbox
import UIKit

class CardCoordinator: Coordinator {
    var onDismiss: (() -> Void)!

    let cardViewController: CardViewController
    let navigationController: CardNavigationController
    
    init() {
        cardViewController = CardViewController.create()

        navigationController = CardNavigationController.create()
        cardViewController.setBottomCard(contentViewController: navigationController)

        super.init(rootViewController: cardViewController)

        cardViewController.onDismiss = { [weak self] in
            self?.dismissedTriggered()
        }
        rootViewController.transitioningDelegate = self
    }
    
    func dismissedTriggered() {
        onDismiss()
    }
}

extension CardCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardPresentationAnimation(direction: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardPresentationAnimation(direction: .dismiss)
    }
}

