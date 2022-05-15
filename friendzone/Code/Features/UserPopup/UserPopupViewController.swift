//
//  UserPopupViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 13.05.22.
//

import Foundation
import UIKit

class UserPopupViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: UserViewModel) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        return viewController
    }
    var viewModel: UserViewModel!
    
    var onDismiss: (() -> Void)?
    
    var presentationManager = PopupPresentationManager()

    @IBOutlet var popupView: UIView!
    @IBOutlet var popupBackgroundView: UIView!
    @IBOutlet var selectedUserImageView: UIImageView!
    @IBOutlet var selectedUserNameLabel: UILabel!
    @IBOutlet var selectedUserBioLabel: UILabel!
    @IBOutlet var selectedUserScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting size of the popup relative to screen
        preferredContentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        setupView()
    }
    
    func setupView() {
        view.layer.cornerRadius = 6
        view.layer.shadowRadius = 3
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)

        popupView.layer.cornerRadius = 20
        
        popupBackgroundView.backgroundColor = .clear
        popupView.isUserInteractionEnabled = true
        
        selectedUserImageView.layer.cornerRadius = 60
        selectedUserImageView.layer.borderWidth = 4
        selectedUserImageView.layer.borderColor = Asset.accentColor.color.cgColor
        
        selectedUserNameLabel.setStyle(TextStyle.boldText)
        selectedUserScoreLabel.setStyle(TextStyle.blueSmall)
        
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(xTapped(_:)))
        popupBackgroundView.addGestureRecognizer(dismissTap)
        popupBackgroundView.isUserInteractionEnabled = true
        
        selectedUserImageView.image = viewModel.profilePicture
        selectedUserNameLabel.text = viewModel.name
        selectedUserBioLabel.text = viewModel.bio
        selectedUserScoreLabel.text = String(viewModel.score)
        selectedUserScoreLabel.text! += "🔥"
    }
    
    @IBAction func xTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        onDismiss?()
    }
}

extension UserPopupViewController: DimmingViewTappedProtocol {}

extension UIView {
    func setConstraintsEqual(secondView: UIView, offset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        secondView.translatesAutoresizingMaskIntoConstraints = false
        
        let firstView: UIView = self
        let targetView = secondView
        
        targetView.leadingAnchor.constraint(equalTo: firstView.leadingAnchor, constant: offset.left).isActive = true
        targetView.trailingAnchor.constraint(equalTo: firstView.trailingAnchor, constant: offset.right).isActive = true
        targetView.topAnchor.constraint(equalTo: firstView.topAnchor, constant: offset.top).isActive = true
        targetView.bottomAnchor.constraint(equalTo: firstView.bottomAnchor, constant: offset.bottom).isActive = true
    }
}

protocol DimmingViewTappedProtocol: class {
    func dimmingViewTapped()
}
extension DimmingViewTappedProtocol where Self: UIViewController {
    func dimmingViewTapped() {
        dismiss(animated: true, completion: nil)
    }
}

final class DimmedPopupPresentationController: UIPresentationController {
    fileprivate var dimmingView: UIView!
    
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        
        guard let containerView = self.containerView else {return frame}
        
        frame.size = size(forChildContentContainer: presentedViewController,
                          withParentContainerSize: containerView.bounds.size)
        
        frame.origin.x = (containerView.frame.width - frame.size.width)*0.5
        frame.origin.y = UIScreen.main.bounds.maxY - frame.size.height
        return frame
    }
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setupDimmingView()
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(dimmingView, at: 0)
        containerView?.setConstraintsEqual(secondView: dimmingView)

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override func dismissalTransitionWillBegin() {
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return presentedViewController.preferredContentSize
    }
    
}

// MARK: - dimming view
private extension DimmedPopupPresentationController {
    func setupDimmingView() {
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        dimmingView.alpha = 0.0
        
        //add dismiss on tap recognizer
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dimmingViewTapped(_:))))
        dimmingView.isUserInteractionEnabled = true
    }
    
    @objc func dimmingViewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        //if vc conforms to DimmingViewTappedProtocol, it can receive tap events
        if let vc = presentedViewController as? DimmingViewTappedProtocol {
            vc.dimmingViewTapped()
        }
    }
    
}
