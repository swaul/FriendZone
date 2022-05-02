//
//  DesignableTextField.swift
//  friendzone
//
//  Created by Paul Kühnel on 30.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import UIKit
import Toolbox
import Combine

@IBDesignable
class DesignableTextField: UITextField {
    var placeholderStyle: Style = TextStyle.lightBody
    var textStyle: Style = TextStyle.lightBody
    var image: UIImage? = nil {
        didSet {
            (leftView as? UIImageView)?.image = image
        }
    }
    
    var rightImage: UIImage? = nil {
        didSet {
            (rightView as? UIButton)?.setImage(rightImage, for: .normal)
        }
    }
    
    var rightButtonTapped: (() -> Void)? = nil
    
    var imagePadding: CGFloat = Style.Padding.single
    
    // MARK: - Line
    var linePadding: CGFloat = 14.0
    var lineWidth: CGFloat = 1
    @IBInspectable var activeLineColor: UIColor?
    @IBInspectable var lineColor: UIColor? = .gray

    @IBInspectable var labelColor: UIColor? {
        didSet {
            titleLabel?.textColor = labelColor
        }
    }
    
    private var bottomLine: CALayer?
    
    // MARK: - Title
    
    private var titleLabel: UILabel?
    
    var shouldShowTitle: Bool {
        return !(text?.isEmpty ?? true)
    }
    
    private var isTitleLabelVisible: Bool = false
    var titleStyle: Style = TextStyle.blueNormal
    var titlePadding: CGFloat = Style.Padding.half
    var error: Bool = false {
        didSet {
            if error {
                changeToErrorColor()
            } else {
                changeToLineColor()
            }
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        super.placeholder = nil
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        super.placeholder = nil
        setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    func setup() {
        borderStyle = UITextField.BorderStyle.none
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        leftViewMode = .always
        imageView.tintColor = Asset.loginBlue.color
        leftView = imageView
        
        let button = UIButton(type: .system)
        button.setTitle(nil, for: .normal)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(toggleSecureText), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: Style.Padding.single, bottom: 0, right: Style.Padding.single)
        button.imageView?.contentMode = .scaleAspectFit
        rightViewMode = .always
        rightView = button
        
        if bottomLine == nil {
            bottomLine = CALayer()
            layer.addSublayer(bottomLine!)
        }
        bottomLine?.backgroundColor = lineColor?.cgColor

        if titleLabel == nil {
            
            titleLabel = UILabel()
            setNeedsLayout()
            layoutIfNeeded()
            titleLabel?.frame = placeholderRect
            titleLabel?.layer.anchorPoint = CGPoint(x: 0, y: 0)
            titleLabel?.font = font
            titleLabel?.text = placeholder
            addSubview(titleLabel!)
        }
        updateLabelVisibility()
        layoutSubviews()
        titleLabel?.textColor = labelColor
        
        addTarget(self, action: #selector(DesignableTextField.updateLabelVisbility), for: .editingChanged)

        addTarget(self, action: #selector(DesignableTextField.changeToActiveLineColor), for: .editingDidBegin)

        addTarget(self, action: #selector(DesignableTextField.changeToLineColor), for: .editingDidEnd)
        
    }
    
    @objc func updateLabelVisbility() {
        updateLabelVisibility()
    }
    
    @objc func changeToErrorColor() {
        bottomLine?.backgroundColor = Asset.errorColor.color.cgColor
        labelColor = Asset.errorColor.color
    }
    
    @objc func changeToActiveLineColor() {
        bottomLine?.backgroundColor = activeLineColor?.cgColor
        labelColor = placeholderStyle.color
    }
    
    @objc func changeToLineColor() {
        if error == false {
            bottomLine?.backgroundColor = lineColor?.cgColor
            labelColor = placeholderStyle.color
        }
    }
    
    func configure(style: TextFieldStyle) {
        titleStyle = style.titleStyle
        placeholderStyle = style.placeHolderStyle
        textStyle = style.textStyle
        
        tintColor = style.textStyle.color
        
        titleLabel?.font = placeholderStyle.font
        let relevantTitleStyle = isTitleLabelVisible ? titleStyle : placeholderStyle
        titleLabel?.textColor = relevantTitleStyle.color
        
        font = textStyle.font
        textColor = textStyle.color
        
        activeLineColor = style.activeLineColor
        lineColor = style.lineColor
    }
    
    @objc func toggleSecureText() {
        rightButtonTapped?()
    }
    
    override var text: String? {
        didSet {
            updateLabelVisibility()
        }
    }
    
    override var placeholder: String? {
        get {
            return titleLabel?.text
        }
        set {
            titleLabel?.text = newValue
        }
    }
    
    var titleSize: CGFloat {
        return "M".height(withConstrainedWidth: bounds.width, font: titleStyle.font)
    }
    
    var placeholderSize: CGFloat {
        return "M".height(withConstrainedWidth: bounds.width, font: placeholderStyle.font)
    }
    
    var imageRatio: CGFloat? {
        1.0
//        if let image = image {
//            return image.size.width / image.size.height
//        } else if let image = rightImage {
//            return image.size.width / image.size.height
//        } else {
//            return nil
//        }
    }
    var imageWidth: CGFloat {
        return textHeight(for: bounds) * (imageRatio ?? 0)
    }
    
    var rightWidth: CGFloat {
        return imageWidth + (Style.Padding.double * 2)
    }
    
    var leftInset: CGFloat {
        guard image != nil else { return 0 }
        return imageWidth + imagePadding
    }
    
    var rightInset: CGFloat {
        guard rightImage != nil else { return 0 }
        return rightWidth
    }
    
    var rightOrigin: CGFloat {
        guard rightImage != nil else { return 0 }
        return bounds.width - rightWidth
    }
    
    func textHeight(for bounds: CGRect) -> CGFloat {
        return bounds.height - headerSize - footerSize
    }
    
    var headerSize: CGFloat {
        return titleSize + titlePadding
    }
    
    var footerSize: CGFloat {
        return lineWidth + linePadding
    }
    
    var titleFrame: CGRect {
        return CGRect(x: leftInset, y: 0, width: frame.width - leftInset, height: titleSize)
    }
    
    var placeholderRect: CGRect {
        return  CGRect(
            x: leftInset,
            y: headerSize,
            width: bounds.width - leftInset,
            height: placeholderSize)
    }
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: 0,
            y: headerSize,
            width: imageWidth,
            height: textHeight(for: bounds))
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(
            x: rightOrigin,
            y: 0,
            width: rightWidth,
            height: bounds.height)
    }
    
    var totalInset: CGFloat {
        leftInset + rightInset
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: leftInset, y: headerSize, width: bounds.width - totalInset, height: textHeight(for: bounds))
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: leftInset, y: headerSize, width: bounds.width - totalInset, height: textHeight(for: bounds))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        bottomLine?.frame = CGRect(x: 0, y: frame.height - lineWidth, width: frame.width, height: lineWidth)
        if !shouldShowTitle {
            titleLabel?.frame = placeholderRect
            titleLabel?.transform = .identity
        } else {
            titleLabel?.transform = .identity
            titleLabel?.frame = placeholderRect
            titleLabel?.transform = calculateTransformation()
        }
    }
    
    private func updateLabelVisibility() {
        if !shouldShowTitle {
            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .curveEaseOut, animations: { [weak self] in
                guard let self = self else { return }
                self.titleLabel?.transform = .identity
                self.titleLabel?.textColor = self.placeholderStyle.color
                }, completion: nil)
            isTitleLabelVisible = false
        } else {
            if isTitleLabelVisible == false {
                isTitleLabelVisible = true
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 5, options: .curveEaseOut, animations: { [weak self] in
                    guard let self = self else { return }
                    self.titleLabel?.textColor = self.titleStyle.color
                    self.titleLabel?.transform = self.calculateTransformation()
                    }, completion: nil)
            }
        }
    }
    
    func calculateTransformation() -> CGAffineTransform {
        let originRect = placeholderRect
        let scale = titleSize / originRect.height
        
        let diffX = titleFrame.origin.x - originRect.origin.x
        let diffY = titleFrame.origin.y - originRect.origin.y

        return CGAffineTransform(translationX: diffX, y: diffY).scaledBy(x: scale, y: scale)
    }
}

extension String {
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}
