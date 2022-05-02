//
//  FriendZoneButton.swift
//  friendzone
//
//  Created by Paul Kühnel on 30.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import SimpleButton
import AlamofireImage
import Toolbox

class FriendZoneButton: SimpleButton {
    
    // MARK: - Style
    
    enum Style {
        case primary
        case secondary
        case tertiary
    }
    
    // MARK: - Properties
    
    // used for title only buttons
    internal var regularInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    
    // used for title + image buttons
    internal var compactInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    internal var imageTitleSpacing: CGFloat = 10
    internal var imageSize = CGSize(width: 24, height: 24)
    
    // color for text + images
    internal var foregroundColorNormal: UIColor = Asset.textColor.color
    internal var foregroundColorHighlighted: UIColor = Asset.textColor.color
    internal var foregroundColorDisabled: UIColor = Asset.placeHolderTextColor.color
    
    private var style: Style! {
        didSet {
            configureButtonStyles()
        }
    }
    
    // MARK: - Lifecycle
    
    override func configureButtonStyles() {
        super.configureButtonStyles()
        
        switch style {
        case .primary:
            setupPrimaryStyle()
        case .secondary:
            setupSecondaryStyle()
        case .tertiary:
            setupTertiaryStyle()
        case .none:
            break
        }
        
        setTitleColor(foregroundColorNormal, for: .normal)
        setTitleColor(foregroundColorHighlighted, for: .highlighted)
        setTitleColor(foregroundColorDisabled, for: .disabled)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.adjustsFontSizeToFitWidth = true
        
        tintColor = foregroundColorNormal
        imageView?.tintColor = foregroundColorNormal
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch style {
        case .primary, .secondary, .tertiary:
            setCornerRadius(frame.height / 2)
        case .none:
            setCornerRadius(0)
        }
    }
    
    // MARK: - UI
    
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                tintColor = foregroundColorNormal
                imageView?.tintColor = foregroundColorNormal
            } else {
                tintColor = foregroundColorDisabled
                imageView?.tintColor = foregroundColorDisabled
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                tintColor = foregroundColorHighlighted
                imageView?.tintColor = foregroundColorHighlighted
            } else {
                tintColor = foregroundColorNormal
                imageView?.tintColor = foregroundColorNormal
            }
        }
    }
    
    // MARK: - Helpers
    
    func setStyle(_ style: Style) {
        self.style = style
    }
    
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        contentEdgeInsets = regularInsets
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        let reframedImage = image?.af.imageAspectScaled(toFit: imageSize).withRenderingMode(.alwaysTemplate)
        super.setImage(reframedImage, for: state)
        
        if let image = image, image.size.width > 0 {
            let additionalWidth = (imageSize.width / 2) + (imageTitleSpacing / 2)
            
            contentEdgeInsets = UIEdgeInsets(top: compactInsets.top, left: compactInsets.left + additionalWidth, bottom: compactInsets.bottom, right: compactInsets.right + additionalWidth)
            
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -imageTitleSpacing, bottom: 0, right: 16)
        }
    }
    
    // MARK: - Set UI
    
    private func setupPrimaryStyle() {
        regularInsets = UIEdgeInsets(top: 10, left: 32, bottom: 10, right: 32)
        
        compactInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        imageTitleSpacing = 10
        imageSize = CGSize(width: 24, height: 24)
        
        foregroundColorNormal = Asset.lightTextColor.color
        foregroundColorHighlighted = .systemGray6
        foregroundColorDisabled = Asset.lightTextColor.color
        
        setBackgroundColor(Asset.loginBlue.color, for: .normal, animated: false)
        setBackgroundColor(Asset.loginBlue.color.lighter(), for: .highlighted, animated: false)
        setBackgroundColor(.systemGray, for: .disabled, animated: false)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 16)
    }
    
    private func setupSecondaryStyle() {
        regularInsets = UIEdgeInsets(top: 10, left: 32, bottom: 10, right: 32)
        
        compactInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        imageTitleSpacing = 10
        imageSize = CGSize(width: 24, height: 24)
        
        foregroundColorNormal = Asset.loginBlue.color
        foregroundColorHighlighted = Asset.textColor.color
        foregroundColorDisabled = .systemGray
        
        setBackgroundColor(.white, for: .normal, animated: false)
        setBackgroundColor(.black, for: .highlighted, animated: false)
        setBackgroundColor(.clear, for: .disabled, animated: false)
        
        setBorderWidth(2)
        setBorderColor(Asset.loginBlue.color, for: .normal)
        setBorderColor(.black, for: .highlighted)
        setBorderColor(.systemGray, for: .disabled)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 16)
    }
    
    private func setupTertiaryStyle() {
        regularInsets = UIEdgeInsets(top: 10, left: 32, bottom: 10, right: 32)
        
        compactInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        imageTitleSpacing = 10
        imageSize = CGSize(width: 20, height: 20)
        
        foregroundColorNormal = Asset.loginBlue.color
        foregroundColorHighlighted = Asset.loginBlue.color
        foregroundColorDisabled = Asset.loginBlue.color
        
        setBackgroundColor(.clear, for: .normal, animated: false)
        setBackgroundColor(.clear, for: .highlighted, animated: false)
        setBackgroundColor(.clear, for: .disabled, animated: false)
        
        titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
    }
}
