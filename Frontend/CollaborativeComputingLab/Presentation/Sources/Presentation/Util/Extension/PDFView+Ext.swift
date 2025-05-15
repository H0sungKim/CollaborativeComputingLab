//
//  PDFView+Ext.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.03.
//

import Foundation
import PDFKit

extension PDFView {
    private var scrollView: UIScrollView? {
        return subviews.first as? UIScrollView
    }
    
    var isScrollEnabled: Bool? {
        set {
            if let newValue {
                scrollView?.isScrollEnabled = newValue
            }
        }
        
        get {
            scrollView?.isScrollEnabled
        }
    }
}
