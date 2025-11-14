//
//  UITableViewCell+Ext.swift
//  Presentation
//
//  Created by 김호성 on 2025.03.31.
//

import Foundation
import UIKit

extension UITableViewCell: Identifiable {
    class func create<T: UITableViewCell>(tableView: UITableView, indexPath: IndexPath) -> T {
        let cell: T
        if let reusableCell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T {
            cell = reusableCell
        } else {
            let objectArray = Bundle.presentation.loadNibNamed(identifier, owner: nil, options: nil)
            cell = objectArray!.first! as! T
        }
        return cell
    }
}
