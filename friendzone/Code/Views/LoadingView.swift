import UIKit
import StatefulViewController
import NVActivityIndicatorView

public class LoadingView: UIView, StatefulPlaceholderView {
        
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressView: UIView!
    @IBOutlet var loadingViewWrapper: UIView!
    
    var isAnimating = false
    
    class func viewFromNib() -> LoadingView {
        return Bundle.main.loadNibNamed("LoadingView", owner: self, options: nil)!.first as! LoadingView
    }
    
    @discardableResult public func configure(backgroundVisible: Bool) -> LoadingView {
        progressView.layer.cornerRadius = 16
        progressView.layer.shadowColor = UIColor.black.cgColor
        progressView.layer.shadowOffset = CGSize(width: 0, height: 2)
        progressView.layer.shadowRadius = 2
        progressView.layer.shadowOpacity = 0.25
        
        progressLabel.setStyle(TextStyle.normal)
        progressLabel.text = "Lädt..."
        
        backgroundColor = backgroundVisible ? .black.withAlphaComponent(0.2) : .clear

        let activityIndicatorView = NVActivityIndicatorView(frame: progressView.frame, type: .ballScaleRippleMultiple, color: Asset.primaryColor.color, padding: 16)
        loadingViewWrapper.addSubview(activityIndicatorView)
        
        if !isAnimating {
            activityIndicatorView.startAnimating()
        }
        
        return self
    }

}
