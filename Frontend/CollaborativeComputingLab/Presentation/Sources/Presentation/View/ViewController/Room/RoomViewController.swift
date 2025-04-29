//
//  RoomViewController.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.26.
//

import UIKit
import Combine
import PDFKit

public class RoomViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pdfView: PDFView!
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatButton: UIButton!
    
    private var chatTableViewDelegate: TableViewDelegate?
    private var chatTableViewDataSource: TableViewDataSource?
    
    private var id: String!
    private var chatViewModel: ChatViewModel!
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public func inject(id: String!, chatViewModel: ChatViewModel) {
        self.id = id
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
        titleLabel.text = "\(id ?? "") 님의 회의실"
    }
    
    private func configureChatTableView() {
        chatTableViewDelegate = TableViewDelegate()
        chatTableViewDataSource = TableViewDataSource(numberOfRowsInSection: chatTableViewNumberOfRowsInSection(_:numberOfRowsInSection:), cellForRowAt: chatTableView(_:cellForRowAt:))
        
        chatTableView.delegate = chatTableViewDelegate
        chatTableView.dataSource = chatTableViewDataSource
        
        chatTableView.register(UINib(nibName: String(describing: ChatTableViewCell.self), bundle: Bundle.presentation), forCellReuseIdentifier: String(describing: ChatTableViewCell.self))
    }
    
    private func chatTableViewNumberOfRowsInSection(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatViewModel.chats.value.count
    }
    
    private func chatTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatTableViewCell = ChatTableViewCell.create(tableView: tableView, indexPath: indexPath)
        cell.senderLabel.text = chatViewModel.chats.value[indexPath.row].sender
        cell.messageLabel.text = chatViewModel.chats.value[indexPath.row].message
        return cell
    }
    @IBAction func onClickFile(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
    @IBAction func onClickChatSend(_ sender: Any) {
        chatViewModel.sendChat(sender: id, message: chatTextField.text ?? "")
        chatTextField.text = ""
    }
}

extension RoomViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        print(urls)
        pdfView.document = PDFDocument(url: urls.first!)
    }
}
