//
//  FilePickerViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 12/27/18.
//  Copyright © 2018 CarSwaddle. All rights reserved.
//

import UIKit
import CarSwaddleUI
import MobileCoreServices
import CarSwaddleData

final class FilePickerViewController: UIViewController, StoryboardInstantiating {
    
    private enum FilePickerError: Error {
        case unableToUpload
    }

    @IBOutlet private weak var documentDescriptionLabel: UILabel!
    @IBOutlet private weak var documentImageView: UIImageView!
    @IBOutlet private weak var actionButton: ActionButton!
    @IBOutlet private weak var selectFileButton: UIButton!
    
    private var mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    
    private lazy var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: actionButton)
    
    private var selectedFileURL: URL? {
        didSet {
//            fileNameLabel.text = selectedFileURL?.lastPathComponent
            if let fileURL = selectedFileURL {
                documentImageView.image = UIImage(contentsOfFile: fileURL.path)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentImageView.layer.cornerRadius = 8
        
        insetAdjuster.positionActionButton()
        
        documentDescriptionLabel.font = UIFont.appFont(type: .regular, size: 17)
        selectFileButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 17)
        
        // Passport, government-issued ID, or driver's license*
        documentDescriptionLabel.text = NSLocalizedString("To correctly identify you for security and for tax reasons an identity document may be required.\n\nPlease provide one of the following documents:\n- Passport\n- Goverment issued id\n- Driver's license", comment: "Explanation of identity document")
    }
    
    @IBAction private func didTapSave() {
        uploadFileIfExists { [weak self] error in
            if error == nil {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction private func didTapSelectFile() {
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeJPEG), String(kUTTypePNG)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        importMenu.allowsMultipleSelection = false
        self.present(importMenu, animated: true, completion: nil)
    }
    
    private func uploadFileIfExists(completion: @escaping (_ error: Error?) -> Void) {
//        let previousButton = navigationItem.rightBarButtonItem
//        let spinButton = UIBarButtonItem.activityBarButtonItem(with: .gray)
//        navigationItem.rightBarButtonItem = spinButton
        
        guard let fileURL = selectedFileURL else { return }
        store.privateContext { [weak self] privateContext in
            self?.mechanicNetwork.uploadIdentityDocument(fileURL: fileURL, in: privateContext) { mechanicID, error in
                DispatchQueue.main.async {
//                    self?.navigationItem.rightBarButtonItem = previousButton
                    var completionError: Error? = error
                    if error == nil && mechanicID == nil {
                        completionError = FilePickerError.unableToUpload
                    }
                    completion(completionError)
                }
            }
        }
    }
    
}

extension FilePickerViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // multiple selection is false, should be able to get the first url if exists
        selectedFileURL = urls.first
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}
