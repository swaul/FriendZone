import Toolbox
import UIKit

/// Defines the global appearance for the application.
struct Appearance {
    /// Sets the global appearance for the application.
    /// Call this method early in the application's setup, i.e. in `applicationDidFinishLaunching:`
    static func setup() {
        UINavigationBar.appearance().barTintColor = .systemBackground
        UINavigationBar.appearance().tintColor = Asset.primaryColor.color
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.primaryColor.color]
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: Asset.primaryColor.color]
        UITabBar.appearance().tintColor = Asset.primaryColor.color
    }
}

extension UIFont {
    struct FZ {
        static let lightTextFont = UIFont.systemFont(ofSize: 16.0, weight: .light)
        static let regularTextFont = UIFont.systemFont(ofSize: 25.0)
        static let boldTextFont = UIFont.boldSystemFont(ofSize: 25.0)
    }
}

// MARK: - TextStyle
public struct TextStyle {
    
    static let header = Style(font: UIFont.FZ.boldTextFont.withSize(24.0), color: Asset.lightTextColor.color)
    static let secondaryHeader = Style(font: UIFont.FZ.regularTextFont.withSize(16.0), color: Asset.lightTextColor.color)
    
    static let darkHeader = Style(font: UIFont.FZ.boldTextFont.withSize(28.0), color: Asset.textColor.color)
    static let darkSecondaryHeader = Style(font: UIFont.FZ.regularTextFont.withSize(20.0), color: Asset.textColor.color)
    
    static let cellTitle = Style(font: UIFont.FZ.regularTextFont.withSize(12.0), color: UIColor.lightGray)
    static let cellContent = Style(font: UIFont.FZ.regularTextFont.withSize(16.0), color: Asset.textColor.color)
    
    static let lightBody = Style(font: UIFont.FZ.boldTextFont.withSize(14.0), color: Asset.placeHolderTextColor.color)
    static let primaryCaption1 = Style(font: UIFont.FZ.boldTextFont.withSize(20.0), color: Asset.textColor.color)
    static let normal = Style(font: UIFont.FZ.regularTextFont.withSize(16.0), color: Asset.textColor.color)
    static let normalSmall = Style(font: UIFont.FZ.regularTextFont.withSize(12.0), color: Asset.textColor.color)
    static let grayNormal = Style(font: UIFont.FZ.regularTextFont.withSize(16.0), color: Asset.placeHolderTextColor.color)
    static let whiteNormal = Style(font: UIFont.FZ.regularTextFont.withSize(16.0), color: Asset.lightTextColor.color)
    static let whiteNormalSmall = Style(font: UIFont.FZ.regularTextFont.withSize(12.0), color: Asset.lightTextColor.color)
    static let normalTiny = Style(font: UIFont.FZ.regularTextFont.withSize(14.0), color: Asset.textColor.color)
    
    static let primaryButton = Style(font: UIFont.FZ.boldTextFont.withSize(18.0), color: Asset.accentColor.color)
    static let secondaryButton = Style(font: UIFont.FZ.boldTextFont.withSize(18.0), color: Asset.accentColor.color)
    
    static let blueSmall = Style(font: UIFont.FZ.lightTextFont.withSize(14.0), color: Asset.primaryColor.color)
    static let blueNormal = Style(font: UIFont.FZ.regularTextFont.withSize(16.0), color: Asset.primaryColor.color)
    static let blueBig = Style(font: UIFont.FZ.regularTextFont.withSize(24.0), color: Asset.primaryColor.color)
    static let errorText = Style(font: UIFont.FZ.regularTextFont.withSize(16.0), color: Asset.errorColor.color)
    static let versionLabel = Style(font: UIFont.FZ.regularTextFont.withSize(36.0), color: Asset.errorColor.color)
    
    static let fadedText = Style(font: UIFont.FZ.regularTextFont.withSize(16.0), color: Asset.fadedTextColor.color)
    static let boldText = Style(font: UIFont.FZ.boldTextFont.withSize(16.0), color: Asset.textColor.color)
    static let grayBold = Style(font: UIFont.FZ.boldTextFont.withSize(18.0), color: Asset.textColor.color)
}

public struct TextFieldStyle {
    public let titleStyle: Style
    public let placeHolderStyle: Style
    public let textStyle: Style
    public let activeLineColor: UIColor
    public let lineColor: UIColor
    
    public static let primary = TextFieldStyle(titleStyle: TextStyle.blueSmall,
                                               placeHolderStyle: TextStyle.lightBody,
                                               textStyle: TextStyle.blueNormal,
                                               activeLineColor: Asset.primaryColor.color,
                                               lineColor: .gray)
    
    public static let comment = TextFieldStyle(titleStyle: TextStyle.lightBody,
                                               placeHolderStyle: TextStyle.lightBody,
                                               textStyle: TextStyle.normal,
                                               activeLineColor: Asset.primaryColor.color,
                                               lineColor: Asset.inactiveCommentInputColor.color)
}

// MARK: - Padding

extension Style {
    struct Padding {
        /// 4
        static let half: CGFloat = 4.0
        /// 8
        static let single: CGFloat = 8.0
        /// 16
        static let double: CGFloat = 16.0
        /// 24
        static let triple: CGFloat = 24.0
    }
}

// MARK: - CornerRadius

extension Style {
    struct CornerRadius {
        /// 3
        static let small: CGFloat = 3.0
        /// 5
        static let normal: CGFloat = 5.0
        /// 10
        static let double: CGFloat = 10.0
    }
}
