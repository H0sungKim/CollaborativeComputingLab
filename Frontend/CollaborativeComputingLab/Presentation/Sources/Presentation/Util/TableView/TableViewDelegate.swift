//
//  TableViewDelegate.swift
//  PresentationLayer
//
//  Created by 김호성 on 2025.03.28.
//

import Foundation
import UIKit

class TableViewDelegate: NSObject, UITableViewDelegate {
    
    init(didSelectRowAt: ( (_ tableView: UITableView, _ indexPath: IndexPath) -> Void)? = nil, scrollViewDidScroll: ( (_ scrollView: UIScrollView) -> Void)? = nil) {
        self.didSelectRowAt = didSelectRowAt
        self.scrollViewDidScroll = scrollViewDidScroll
    }
    
    var didSelectRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> Void)?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRowAt?(tableView, indexPath)
    }
    
    var scrollViewDidScroll: ((_ scrollView: UIScrollView) -> Void)?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewDidScroll?(scrollView)
    }
}
