//
//  UserNearbyTableViewCell.swift
//  friendzone
//
//  Created by Paul Kühnel on 28.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import friendzoneKit
import UIKit
import Combine

class UserNearbyTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBOutlet var cellViewWrapper: UIView!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userScoreLabel: UILabel!
    @IBOutlet var userNameBioLabel: UILabel!
    @IBOutlet var ignoreUserButton: UIButton!

    var user: UserViewModel!
    
    func configure(user: UserViewModel, buttonType: ButtonType) {
        self.user = user
        setupBindings()
        
        userImageView.layer.cornerRadius = 32
        userImageView.layer.borderColor = Asset.accentColor.color.cgColor
        userImageView.layer.borderWidth = 2
        userImageView.activityIndicator.hidesWhenStopped = true
        cellViewWrapper.layer.cornerRadius = 10
        backgroundColor = .clear
        userNameLabel.setStyle(TextStyle.boldText)
        userScoreLabel.setStyle(TextStyle.blueSmall)
        userNameBioLabel.setStyle(TextStyle.fadedText)
        
        userNameLabel.text = user.name
        userScoreLabel.text = String(user.score)
        userNameBioLabel.text = user.bio
        
        switch buttonType {
        case .delete:
            ignoreUserButton.setImage(UIImage(systemSymbol: .xCircle), for: .normal)
        case .revert:
            ignoreUserButton.setImage(UIImage(systemSymbol: .arrowClockwiseHeart), for: .normal)
        case .none:
            ignoreUserButton.isHidden = true
        }
        
        if user.ignored {
            cellViewWrapper.backgroundColor = .systemRed.withAlphaComponent(0.4)
        } else {
            cellViewWrapper.backgroundColor = Asset.secondaryColor.color
        }
        
        guard let image = user.profilePicture else {
            if user.profilePictureId == nil {
                print("########## end animation")
                userImageView.stopAnimating()
                userImageView.image = Asset.image.image
            }
            return
        }
        userImageView.image = image
        print("########## end animation")
        userImageView.stopAnimating()
    }
    
    var cancellabels = Set<AnyCancellable>()
    
    func setupBindings() {
        user.$profilePicture.sink { [weak self] image in
            if let image = image {
                self?.userImageView.stopAnimating()
                self?.userImageView.image = image
            }
        }.store(in: &cancellabels)
        
        user.$viewModelState.sink { [weak self] state in
            switch state {
            case .loading:
                self?.userImageView.startAnimating()
            case .loaded:
                self?.userImageView.stopAnimating()
            case .error:
                self?.userImageView.stopAnimating()
            default:
                self?.userImageView.stopAnimating()
            }
        }.store(in: &cancellabels)
    }
}

enum ButtonType {
    case delete
    case revert
    case none
}

extension UIImageView {

    //// Returns activity indicator view centrally aligned inside the UIImageView
    var activityIndicator: UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        self.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        let centerX = NSLayoutConstraint(item: self,
                                         attribute: .centerX,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerX,
                                         multiplier: 1,
                                         constant: 0)
        let centerY = NSLayoutConstraint(item: self,
                                         attribute: .centerY,
                                         relatedBy: .equal,
                                         toItem: activityIndicator,
                                         attribute: .centerY,
                                         multiplier: 1,
                                         constant: 0)
        self.addConstraints([centerX, centerY])
        return activityIndicator
    }
    
    func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
