//
//  RoomTableViewCell.swift
//  Presentation
//
//  Created by 김호성 on 2025.07.02.
//

import UIKit

import Domain

final class RoomTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func configure(roomEntity: RoomEntity) {
        titleLabel.text = "\(roomEntity.participants.first ?? "알수없음")님의 강의실"
        subtitleLabel.text = "\(roomEntity.participants.count)명"
    }
}
