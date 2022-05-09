import Foundation
import UIKit
import AVFoundation
import CoreImage
import Toolbox

class ImageCropperViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard, viewModel: ImagePicker, image: UIImage) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        viewController.viewModel = viewModel
        viewController.image = image
        return viewController
    }
        
    var imageView: UIImageView?
    var image: UIImage!
    var center: CGPoint!
    
    var viewModel: ImagePicker!
    
    var blurEffectStyle: UIBlurEffect.Style {
        if self.traitCollection.userInterfaceStyle == .dark {
            return UIBlurEffect.Style.dark
        } else {
            return UIBlurEffect.Style.light
        }
    }
    
    @IBOutlet var titleBackground: UIView!
    @IBOutlet var bottomBackground: UIView!
    @IBOutlet var indicatorView: UIView!
    @IBOutlet var spaceView: UIView!
    @IBOutlet var doneButton: FriendZoneButton!
    @IBOutlet var cancelButton: FriendZoneButton!
    @IBOutlet var titleLabel: UILabel!
    
    // Set these to the desired width and height of your output image.
    lazy var desiredWidth: CGFloat = view.frame.width - 32
    lazy var desiredHeight: CGFloat = view.frame.width - 32
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up UI and gesture recognisers.
        indicatorView.layer.borderColor = Asset.primaryColor.color.cgColor
        indicatorView.layer.borderWidth = 8
        indicatorView.layer.cornerRadius = 20
        indicatorView.backgroundColor = .clear
        
        let topBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let topBlurEffectView = UIVisualEffectView(effect: topBlurEffect)
        topBlurEffectView.frame = titleBackground.bounds
        topBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        titleBackground.addSubview(topBlurEffectView)
        
        let botBlutEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let botBlurEffectView = UIVisualEffectView(effect: botBlutEffect)
        botBlurEffectView.frame = bottomBackground.bounds
        botBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bottomBackground.addSubview(botBlurEffectView)
        
        doneButton.setStyle(.primary)
        doneButton.setTitle("Fertig", for: .normal)
        
        cancelButton.setStyle(.tertiary)
        cancelButton.setTitle("Abbrechen", for: .normal)
        
        titleLabel.text = "Zuschneiden"
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(recognizer:)))
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(recognizer:)))
        indicatorView.addGestureRecognizer(pan)
        indicatorView.addGestureRecognizer(pinch)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set up the image view in relation to the storyboard views.
        imageView = UIImageView()
        imageView?.image = image
        imageView!.frame = AVMakeRect(aspectRatio: image.size, insideRect: indicatorView.frame)
        center = imageView!.center
        spaceView.insertSubview(imageView!, belowSubview: indicatorView)
    }
    
    // Invoked when the user pans accross the screen. The logic happening here basically just checks if the pan would move the image outside the cropping square and if so, don't allow the pan to happen.
    @objc func didPan(recognizer: UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: spaceView)
        
        if (imageView!.frame.minX + translation.x >= indicatorView.frame.minX && imageView!.frame.maxX + translation.x <= indicatorView.frame.maxX) || ((imageView!.frame.size.width >= indicatorView.frame.size.width) && (imageView!.frame.minX + translation.x <= indicatorView.frame.minX && imageView!.frame.maxX + translation.x >= indicatorView.frame.maxX)) {
            imageView!.center.x += translation.x
        }
        
        if (imageView!.frame.minY + translation.y >= indicatorView.frame.minY && imageView!.frame.maxY + translation.y <= indicatorView.frame.maxY) || ((imageView!.frame.size.height >= indicatorView.frame.size.height) && (imageView!.frame.minY + translation.y <= indicatorView.frame.minY && imageView!.frame.maxY + translation.y >= indicatorView.frame.maxY)) {
            imageView!.center.y += translation.y
        }
        
        recognizer.setTranslation(.zero, in: spaceView)
    }
    
    // Invoked when the user pinches the screen. Again the logic here just ensures that zooming the image would not make it exceed the bounds of the cropping square and cancels the zoom if it does.
    @objc func didPinch(recognizer: UIPinchGestureRecognizer) {
        
        let view = UIView(frame: imageView!.frame)
        
        view.transform = imageView!.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
        
        if view.frame.size.width >= indicatorView.frame.size.width && view.frame.size.height >= indicatorView.frame.size.height {
            
            imageView!.transform = imageView!.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
        
        if recognizer.state == UIGestureRecognizer.State.ended {
            
            if imageView!.frame.minX > indicatorView.frame.minX || imageView!.frame.maxX < indicatorView.frame.maxX {
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.imageView!.center = self.indicatorView.center
                })
            }
            
            if imageView!.frame.size.height < indicatorView.frame.size.height && imageView!.frame.size.width < indicatorView.frame.size.width {
                
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.imageView!.frame = AVMakeRect(aspectRatio: self.image.size, insideRect: self.indicatorView.frame)
                })
            }
        }
    }
    
    // Outlet for the cancel button.
    @IBAction func cancelButtonPressed(sender: AnyObject) {
       dismiss(animated: true)
    }
    
    // Outlet for the save button. The logic here scales the outputed image down to the desired size.
    @IBAction func saveButtonPressed(sender: AnyObject) {
        
        let croppedImage = grabIndicatedImage()
        UIGraphicsBeginImageContext(CGSize(width: desiredWidth, height: desiredHeight))
        UIGraphicsGetCurrentContext()!.setFillColor(UIColor.black.cgColor)
        
        if desiredWidth / desiredHeight == croppedImage.size.width / croppedImage.size.height {
            croppedImage.draw(in: CGRect(x: 0, y: 0, width: desiredWidth, height: desiredHeight))
        } else {
            let croppedImageSize: CGRect = AVMakeRect(aspectRatio: croppedImage.size, insideRect: CGRect(x: 0, y: 0, width: desiredWidth, height: desiredHeight))
            croppedImage.draw(in: croppedImageSize)
        }
        
        let resizedCroppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let data = resizedCroppedImage!.pngData()

        viewModel.profilePicture = UIImage(data: data!)
        dismiss(animated: true)
    }
    
    // When you call this method it basically takes a screenshot of the crop area and gets the UIImage object from it.
    func grabIndicatedImage() -> UIImage {
        
        UIGraphicsBeginImageContext(self.view.layer.frame.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        self.view.layer.render(in: context)
        let screenshot: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        let rectToCrop = CGRect(x: indicatorView.frame.minX + 8, y: indicatorView.frame.minY + 72, width: indicatorView.frame.width - 16, height: indicatorView.frame.height - 16)
        
        let imageRef: CGImage = screenshot.cgImage!.cropping(to: rectToCrop)!
        let croppedImage = UIImage(cgImage: imageRef)
        
        UIGraphicsEndImageContext()
        return croppedImage
    }
}
