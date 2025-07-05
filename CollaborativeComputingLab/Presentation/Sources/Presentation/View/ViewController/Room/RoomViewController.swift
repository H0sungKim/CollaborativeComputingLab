//
//  RoomViewController.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.26.
//

import Domain

import UIKit
import Combine
import PDFKit
import AVFoundation

import HaishinKit

public class RoomViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pdfOpenButton: UIButton!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfDrawButton: UIButton!
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var streamView: MTHKView!
    @IBOutlet weak var cameraView: MTHKView!
    
    // MARK: - ChatTableView
    private var chatTableViewDelegate: TableViewDelegate?
    private var chatTableViewDataSource: TableViewDataSource?
    
    // MARK: - PDF
    private let canvasProvider: CanvasProvider = CanvasProvider()
    
    // MARK: - Dependency
    private var id: String!
    private var role: RoomRole!
    private var roomViewModel: RoomViewModel!
    private var chatViewModel: ChatViewModel!
    private var streamViewModel: StreamViewModel!
    
    // MARK: - Combine
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // MARK: - Inject
    public func inject(
        id: String,
        role: RoomRole,
        roomViewModel: RoomViewModel,
        chatViewModel: ChatViewModel,
        streamViewModel: StreamViewModel
    ) {
        self.id = id
        self.role = role
        self.roomViewModel = roomViewModel
        self.chatViewModel = chatViewModel
        self.streamViewModel = streamViewModel
    }
    
    // MARK: - Bind
    private func bind() {
        chatViewModel.chats.sink(receiveValue: { [weak self] chats in
            self?.chatTableView.reloadData()
        })
        .store(in: &cancellable)
        
        roomViewModel.participants.sink(receiveValue: { [weak self] participants in
            Logger.log("Participants updated: \(participants)")
            self?.titleLabel.text = "\(self?.roomViewModel.participants.value.first?.name ?? "") 님의 강의실"
        })
        .store(in: &cancellable)
        
        roomViewModel.roomClosed.sink(receiveValue: {
            Logger.log("Room closed.")
        })
        .store(in: &cancellable)
    }
    
    // MARK: - Basic
    public override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureChatTableView()
        configurePDFView()
        titleLabel.text = "\(roomViewModel.participants.value.first?.name ?? "") 님의 강의실"
        
        let outputView: UIView = {
            switch role {
            case .instructor:
                return cameraView
            case .student:
                return streamView
            case .none:
                return UIView()
            }
        }()
        Task {
            await streamViewModel.configure(roomRole: role, outputView: outputView)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chatViewModel.connectWebSocket()
        roomViewModel.connectWebSocket()
        
        switch role {
        case .instructor:
            Task {
                await streamViewModel.publish(streamName: id, video: AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front), audio: AVCaptureDevice.default(for: .audio))
            }
        case .student:
            Task {
                await streamViewModel.play(streamName: id)
            }
        case .none:
            break
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        roomViewModel.exitRoom(id: id)
        
        switch role {
        case .instructor:
            Task {
                await streamViewModel.stopPublish()
            }
        case .student:
            Task {
                await streamViewModel.stopPlay()
            }
        case .none:
            break
        }
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        Task {
            await streamViewModel.setScreenSize()
        }
    }
    
    // MARK: - PDFView
    private func configurePDFView() {
        pdfView.displayMode = .singlePageContinuous
        pdfView.pageOverlayViewProvider = canvasProvider
        pdfView.isInMarkupMode = true
        pdfView.isScrollEnabled = true
        
        pdfView.isHidden = role.isPDFHidden
        pdfDrawButton.isHidden = role.isPDFHidden
        pdfOpenButton.isHidden = role.isPDFHidden
    }
    
    // MARK: - ChatTableView
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
        cell.senderLabel.text = chatViewModel.chats.value[indexPath.row].name
        cell.messageLabel.text = chatViewModel.chats.value[indexPath.row].message
        return cell
    }
    
    // MARK: - IBAction
    @IBAction func onClickFile(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
    
    @IBAction func onClickChatSend(_ sender: Any) {
        chatViewModel.sendChat(message: chatTextField.text ?? "")
        chatTextField.text = ""
    }
    
    @IBAction func onClickCanvas(_ sender: UIButton) {
        pdfView.isScrollEnabled?.toggle()
        sender.setImage(UIImage(systemName: pdfView.isScrollEnabled ?? true ? "pencil.tip.crop.circle" : "pencil.tip.crop.circle.fill"), for: .normal)
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIDocumentPickerDelegate
extension RoomViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        pdfView.document = PDFDocument(url: urls.first!)
    }
}
