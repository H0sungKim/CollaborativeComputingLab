//
//  UITableView+.swift
//  Presentation
//
//  Created by 김호성 on 2025.11.22.
//

import UIKit

extension UITableView {
    func register(_ cellClass: UITableViewCell.Type) {
        register(UINib(nibName: cellClass.typeIdentifier, bundle: .presentation), forCellReuseIdentifier: cellClass.typeIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, indexPath: IndexPath) -> T {
        let cell: T = dequeueReusableCell(withIdentifier: cellClass.typeIdentifier, for: indexPath) as! T
        return cell
    }
}
