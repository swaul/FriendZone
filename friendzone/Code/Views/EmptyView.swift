import UIKit
import StatefulViewController

public class EmptyView: UIView, StatefulPlaceholderView {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    
    private var retryClosure: (() -> Void)?
    
    var edgeInsets = UIEdgeInsets.zero
    var isAnimating = false
    
    class func viewFromNib() -> EmptyView {
        let view = Bundle.main.loadNibNamed("EmptyView", owner: self, options: nil)!.first as! EmptyView
        return view
    }
    
    @discardableResult public func configure(image: UIImage?, title: String?, subtitle: String?, insets: UIEdgeInsets = UIEdgeInsets.zero, showArrow: Bool) -> EmptyView {
                
        imageView.image = image
        imageView.isHidden = image == nil
        titleLabel.text = title
        subtitleLabel.text = subtitle
        edgeInsets = insets
        
        return self
    }

    @IBAction private func retry() {
        retryClosure?()
    }
    
}
