//
//  UIViewController+Ext.swift
//  Presentation
//
//  Created by 김호성 on 2021/11/22.
//

import UIKit

extension UIViewController: TypeIdentifiable {
    public class func instantiate() -> Self {
        let storyboard = UIStoryboard(name: typeIdentifier, bundle: .presentation)
        let viewController = storyboard.instantiateViewController(withIdentifier: typeIdentifier) as! Self
        return viewController
    }
}
