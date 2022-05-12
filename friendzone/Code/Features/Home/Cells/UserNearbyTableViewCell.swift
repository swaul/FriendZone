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
    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        if selected {
//            cellViewWrapper.backgroundColor = Asset.secondaryColor.color.darker()
//        } else {
//            cellViewWrapper.backgroundColor = Asset.secondaryColor.color
//        }
//    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if highlighted {
            cellViewWrapper.backgroundColor = Asset.secondaryColor.color.darker()
        } else {
            cellViewWrapper.backgroundColor = Asset.secondaryColor.color
        }
    }
    
    var user: UserViewModel!
    
    func configure(user: UserViewModel) {
        self.user = user
        setupBindings()
        
        userImageView.layer.cornerRadius = 20
        userImageView.layer.borderColor = Asset.accentColor.color.cgColor
        userImageView.layer.borderWidth = 2
        cellViewWrapper.layer.cornerRadius = 10
        cellViewWrapper.backgroundColor = Asset.secondaryColor.color
        backgroundColor = .clear
        userNameLabel.setStyle(TextStyle.boldText)
        userScoreLabel.setStyle(TextStyle.blueSmall)
        userNameBioLabel.setStyle(TextStyle.fadedText)
        
        userNameLabel.text = user.name
        userScoreLabel.text = String(user.score)
        userNameBioLabel.text = user.bio
        
        guard let image = user.profilePicture else { return }
        userImageView.image = image
    }
    
    var cancellabels = Set<AnyCancellable>()
    
    func setupBindings() {
        user.$profilePicture.sink { image in
            if let image = image {
                self.userImageView.image = image
            }
        }.store(in: &cancellabels)
    }
}
