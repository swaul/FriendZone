import UIKit
import StatefulViewController

public class ErrorView: UIView, StatefulPlaceholderView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var retryButton: UIButton!

    private var retryClosure: (() -> Void)?
    
    var edgeInsets = UIEdgeInsets.zero
    
    class func viewFromNib() -> ErrorView {
        let view = Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)!.first as! ErrorView
        return view
    }
    
    @discardableResult public func configure(image: UIImage?, title: String?, subtitle: String?, retryTitle: String?, insets: UIEdgeInsets = UIEdgeInsets.zero, retryClosure: (() -> Void)?) -> ErrorView {
        imageView.image = image
        imageView.isHidden = image == nil
        titleLabel.text = title
        subtitleLabel.text = subtitle
        retryButton.setTitle(retryTitle, for: .normal)
        self.retryClosure = retryClosure
        self.retryButton.isHidden = retryClosure == nil
        edgeInsets = insets
        return self
    }
    
    public func placeholderViewInsets() -> UIEdgeInsets {
        return edgeInsets
    }
    
    @IBAction private func retry() {
        retryClosure?()
    }
    
}
