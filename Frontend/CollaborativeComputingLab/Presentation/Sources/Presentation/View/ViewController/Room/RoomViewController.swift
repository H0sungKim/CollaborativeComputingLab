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

public class RoomViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var pdfOpenButton: UIButton!
    @IBOutlet weak var pdfView: PDFView!
    @IBOutlet weak var pdfDrawButton: UIButton!
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var chatTextField: UITextField!
    @IBOutlet weak var chatButton: UIButton!
    
    @IBOutlet weak var streamView: UIView!
    @IBOutlet weak var cameraView: UIView!
    
    // MARK: - ChatTableView
    private var chatTableViewDelegate: TableViewDelegate?
    private var chatTableViewDataSource: TableViewDataSource?
    
    // MARK: - PDF
    private let canvasProvider: CanvasProvider = CanvasProvider()
    
    // MARK: - Dependency
    private var id: String!
    private var role: RoomRole!
    private var streamViewModel: StreamViewModel!
    
    // MARK: - Combine
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    // MARK: - Inject
    public func inject(id: String!, role: RoomRole, streamViewModel: StreamViewModel) {
        self.id = id
        self.role = role
//        self.chatViewModel = chatViewModel
        self.streamViewModel = streamViewModel
    }
    
    // MARK: - Bind
    
    
    // MARK: - Basic
    public override func viewDidLoad() {
        super.viewDidLoad()
        configureChatTableView()
        configurePDFView()
        titleLabel.text = "\(id ?? "") 님의 회의실"
        
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
//        Task {
//            await streamViewModel.configure(roomRole: role, outputView: outputView)
//        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        switch role {
        case .instructor:
            streamViewModel.offer()
        case .student:
            streamViewModel.answer()
        case .none:
            break
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        switch role {
//        case .instructor:
//            Task {
//                await streamViewModel.stopPublish()
//            }
//        case .student:
//            Task {
//                await streamViewModel.stopPlay()
//            }
//        case .none:
//            break
//        }
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
        return 0
    }
    
    private func chatTableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ChatTableViewCell = ChatTableViewCell.create(tableView: tableView, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - IBAction
    @IBAction func onClickFile(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        documentPicker.delegate = self
        present(documentPicker, animated: true)
    }
    
    @IBAction func onClickChatSend(_ sender: Any) {
        
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
