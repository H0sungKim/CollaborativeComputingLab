//
//  File.swift
//  PresentationLayer
//
//  Created by 김호성 on 2025.03.28.
//

import Foundation
import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource {
    
    init(numberOfSections: ( (_ tableView: UITableView) -> Int)? = nil, numberOfRowsInSection: ( (_: UITableView, _: Int) -> Int)? = nil, cellForRowAt: ( (_: UITableView, _: IndexPath) -> UITableViewCell)? = nil) {
        self.numberOfSections = numberOfSections
        self.numberOfRowsInSection = numberOfRowsInSection
        self.cellForRowAt = cellForRowAt
    }
    
    var numberOfSections: ((_ tableView: UITableView) -> Int)?
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections?(tableView) ?? 1
    }
    
    var numberOfRowsInSection: ((_ tableView: UITableView, _ section: Int) -> Int)?
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowsInSection?(tableView, section) ?? 0
    }
    
    var cellForRowAt: ((_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell)?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellForRowAt?(tableView, indexPath) ?? UITableViewCell()
    }
}
