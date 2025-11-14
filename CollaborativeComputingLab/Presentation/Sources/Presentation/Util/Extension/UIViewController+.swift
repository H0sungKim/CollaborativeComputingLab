//
//  UIViewController+Ext.swift
//  Presentation
//
//  Created by 김호성 on 2021/11/22.
//

import UIKit

extension UIViewController: Identifiable {
    public class func create<T: UIViewController>() -> T {
        let storyboard = UIStoryboard(name: identifier, bundle: Bundle.presentation)
        let viewController = storyboard.instantiateViewController(withIdentifier: identifier) as! T
        return viewController
    }
}
