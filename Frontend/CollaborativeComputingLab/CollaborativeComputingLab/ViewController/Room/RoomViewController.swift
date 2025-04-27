//
//  RoomViewController.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.26.
//

import UIKit
import Combine

public class RoomViewController: UIViewController {
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatButton: UIButton!
    
    private var chatTableViewDelegate: TableViewDelegate?
    private var chatTableViewDataSource: TableViewDataSource?
    
    private var chatViewModel: ChatViewModel!
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public func inject(chatViewModel: ChatViewModel) {
        self.chatViewModel = chatViewModel
    }
    
    private func bind(chatViewModel: ChatViewModel) {
        chatViewModel.chats.sink(receiveValue: { [weak self] chats in
            Task { @MainActor in
                self?.chatTableView.reloadData()
            }
            
        })
        .store(in: &cancellable)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        bind(chatViewModel: chatViewModel)
        configureChatTableView()
    }
    
    private func configureChatTableView() {
        chatTableViewDelegate = TableViewDelegate()
        chatTableViewDataSource = TableViewDataSource(numberOfRowsInSection: chatTableViewNumberOfRowsInSection(_:numberOfRowsInSection:), cellForRowAt: chatTableView(_:cellForRowAt:))
        
        chatTableView.delegate = chatTableViewDelegate
        chatTableView.dataSource = chatTableViewDataSource
        
        chatTableView.register(UINib(nibName: String(describing: ChatTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: ChatTableViewCell.self))
    }
    
    private func chatTableViewNumberOfRowsInSection(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel.chats.value.count
    }
    
    private func chatTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatTableViewCell = ChatTableViewCell.create(tableView: tableView, indexPath: indexPath)
        cell.messageLabel.text = chatViewModel.chats.value[indexPath.row]
        return cell
    }
    @IBAction func onClickChatSend(_ sender: Any) {
        chatViewModel.sendMessage(message: chatTextField.text ?? "")
    }
}
