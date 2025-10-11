//
//  UIViewController+Ext.swift
//  Presentation
//
//  Created by 김호성 on 2021/11/22.
//

import UIKit

extension UIViewController {
    public class func create<T: UIViewController>() -> T {
        let identifier: String = String(describing: T.self)
        let sb = UIStoryboard(name: identifier, bundle: Bundle.presentation)
        let vc = sb.instantiateViewController(withIdentifier: identifier) as! T
        return vc
    }
}
