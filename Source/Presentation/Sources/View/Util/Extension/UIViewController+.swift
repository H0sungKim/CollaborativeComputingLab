//
//  UIViewController+Ext.swift
//  Presentation
//
//  Created by 김호성 on 2021/11/22.
//

import Core

import UIKit

extension UIViewController: TypeIdentifiable {
    public class func instantiate() -> Self {
        let storyboard = UIStoryboard(name: typeIdentifier, bundle: .module)
        let viewController = storyboard.instantiateViewController(withIdentifier: typeIdentifier)
        return viewController as! Self
    }
    
    public var diNavigationController: DINavigationController? {
        return navigationController as? DINavigationController
    }
}
