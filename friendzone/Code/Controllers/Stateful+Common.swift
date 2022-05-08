//
//  Stateful+Common.swift
//  friendzone
//
//  Created by Paul Kühnel on 07.05.22.
//

import Foundation
import StatefulViewController
import UIKit
import friendzoneKit

protocol CommonStatefulViews {
    func refetchData()
}

extension CommonStatefulViews where Self: UIViewController, Self: StatefulViewController {
    
    func setupStatefulViews(backgroundVisible: Bool) {
        loadingView = LoadingView.viewFromNib().configure(backgroundVisible: backgroundVisible)
    }

    var loadingPlaceholderView: LoadingView? {
        return loadingView as? LoadingView
    }

    var emptyPlaceholderView: EmptyView? {
        return emptyView as? EmptyView
    }

    var errorPlaceholderView: ErrorView? {
        return errorView as? ErrorView
    }

}

class PassthroughView: UIView {
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for view in subviews {
            if !view.isHidden && view.alpha > 0 && view.isUserInteractionEnabled && view.point(inside: convert(point, to: view), with: event) {
                return true
            }
        }
        return false
    }
}
