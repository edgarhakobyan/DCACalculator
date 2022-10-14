//
//  UIAnimable.swift
//  DCACalculator
//
//  Created by Edgar on 15.10.22.
//

import Foundation
import MBProgressHUD

protocol UIAnimateble where Self: UIViewController {
    func showLoadingAnimation()
    func hideLoadingAnimation()
}

extension UIAnimateble {
    func showLoadingAnimation() {
        DispatchQueue.main.async {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
    }
    func hideLoadingAnimation() {
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
}
