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
import CarSwaddleStore
import CarSwaddleNetworkRequest

final class FilePickerViewController: UIViewController, StoryboardInstantiating {
    
    private enum FilePickerError: Error {
        case unableToUpload
    }

    @IBOutlet private weak var documentDescriptionLabel: UILabel!
    @IBOutlet private weak var frontImageView: UIImageView!
//    @IBOutlet private weak var selectFileButton: UIButton!
    @IBOutlet private weak var backImageView: UIImageView!
    @IBOutlet private weak var selectFrontButton: LoadingButton!
    @IBOutlet private weak var selectBackButton: LoadingButton!
    @IBOutlet private weak var actionButton: ActionButton!
    
    private var mechanicNetwork = MechanicNetwork(serviceRequest: serviceRequest)
    private var fileService: FileService = FileService(serviceRequest: serviceRequest)
    
    private lazy var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: actionButton)
    
    private var selectedFrontFileURL: URL? {
        didSet {
            if let fileURL = selectedFrontFileURL {
                frontImageView.image = UIImage(contentsOfFile: fileURL.path)
            }
            frontImageLabel?.isHidden = selectedFrontFileURL != nil
        }
    }
    
    private var selectedBackFileURL: URL? {
        didSet {
            if let fileURL = selectedBackFileURL {
                backImageView.image = UIImage(contentsOfFile: fileURL.path)
            }
            backImageLabel?.isHidden = selectedBackFileURL != nil
        }
    }
    
    private var frontImageLabel: UILabel?
    private var backImageLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        frontImageView.layer.cornerRadius = defaultCornerRadius
        backImageView.layer.cornerRadius = defaultCornerRadius
        
        let frontImageLabel = self.imageLabel()
        frontImageLabel.text = NSLocalizedString("front of document", comment: "front of document")
        frontImageView.addSubview(frontImageLabel)
        frontImageLabel.constrainToCenter()
        frontImageLabel.textColor = .text
        frontImageLabel.constrainWithinEdges(insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        self.frontImageLabel = frontImageLabel
        
        let backImageLabel = self.imageLabel()
        backImageLabel.text = NSLocalizedString("back of document (only for driver's license)", comment: "front of document")
        backImageView.addSubview(backImageLabel)
        backImageLabel.constrainToCenter()
        backImageLabel.constrainWithinEdges(insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        backImageLabel.textColor = .text
        self.backImageLabel = backImageLabel
        
        insetAdjuster.positionActionButton()
        
        documentDescriptionLabel.font = UIFont.appFont(type: .regular, size: 17)
        selectFrontButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 17)
        selectBackButton.titleLabel?.font = UIFont.appFont(type: .semiBold, size: 17)
        
        // Passport, government-issued ID, or driver's license*
        documentDescriptionLabel.text = NSLocalizedString("To correctly identify you for security and for tax reasons an identity document may be required.\n\nPlease provide one of the following documents:\n- Passport\n- Goverment issued id\n- Driver's license (front and back)", comment: "Explanation of identity document")
        
        
    }
    
    private func imageLabel() -> UILabel {
        let imageLabel = UILabel()
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageLabel.font = UIFont.appFont(type: .regular, size: 15)
        imageLabel.textColor = .gray5
        imageLabel.textAlignment = .center
        imageLabel.numberOfLines = 0
        return imageLabel
    }
    
    @IBAction private func didTapSave() {
//        uploadFileIfExists { [weak self] error in
//            if error == nil {
//                self?.navigationController?.popViewController(animated: true)
//            }
//        }
    }
    
    private var frontDocumentPicker: UIDocumentPickerViewController?
    private var backDocumentPicker: UIDocumentPickerViewController?
    
    @IBAction private func didTapSelectFront() {
        let importMenu = self.createDocumentPicker()
        frontDocumentPicker = importMenu
        self.present(importMenu, animated: true, completion: nil)
    }
    
    @IBAction private func didTapSelectBack() {
        let importMenu = self.createDocumentPicker()
        backDocumentPicker = importMenu
        self.present(importMenu, animated: true, completion: nil)
    }
    
    private func createDocumentPicker() -> UIDocumentPickerViewController {
        let importMenu = UIDocumentPickerViewController(documentTypes: [String(kUTTypeJPEG), String(kUTTypePNG)], in: .import)
        importMenu.delegate = self
        importMenu.modalPresentationStyle = .formSheet
        importMenu.allowsMultipleSelection = false
        return importMenu
    }
    
    private func uploadFile(fileURL: URL, side: MechanicNetwork.DocumentSide, completion: @escaping (_ error: Error?) -> Void) {
        store.privateContext { [weak self] privateContext in
            self?.mechanicNetwork.uploadIdentityDocument(fileURL: fileURL, side: side, in: privateContext) { mechanicID, error in
                DispatchQueue.main.async {
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
        if controller == frontDocumentPicker {
            selectedFrontFileURL = urls.first
            if let fileURL = selectedFrontFileURL {
//                let previousTitle = selectFrontButton.title(for: .normal)
                selectFrontButton.isLoading = true
                uploadFile(fileURL: fileURL, side: .front) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.selectFrontButton.isLoading = false
                    }
                }
            }
        } else if controller == backDocumentPicker {
            selectedBackFileURL = urls.first
            if let fileURL = selectedBackFileURL {
//                let previousTitle = selectBackButton.title(for: .normal)
                selectBackButton.isLoading = true
                uploadFile(fileURL: fileURL, side: .back) { [weak self] error in
                    DispatchQueue.main.async {
                        self?.selectBackButton.isLoading = false
                    }
                }
            }
        }
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        dismiss(animated: true, completion: nil)
    }
    
}


open class LoadingButton: UIButton {
    
    var isLoading: Bool = false {
        didSet {
            guard oldValue != isLoading else { return }
            if isLoading {
                updateForIsLoading()
            } else {
                updateForIsNotLoading()
            }
            isEnabled = !isLoading
        }
    }
    
    var indicatorViewStyle: UIActivityIndicatorView.Style = .gray {
        didSet {
            spinner.style = indicatorViewStyle
        }
    }
    
    private lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: indicatorViewStyle)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.isHidden = true
        return spinner
    }()
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.isHidden = isLoading
    }
    
    private func updateForIsLoading() {
        addSubview(spinner)
        spinner.constrainToCenter()
        spinner.startAnimating()
        spinner.isHidden = false
        spinner.alpha = 0.0
        
        UIView.animate(withDuration: 0.25) {
            self.spinner.alpha = 1.0
            self.titleLabel?.alpha = 0
        }
    }
    
    private func updateForIsNotLoading() {
        spinner.stopAnimating()
//        spinner.isHidden = true
//        titleLabel?.isHidden = false
//        titleLabel?.alpha = 0.0
//        spinner.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: {
            self.spinner.alpha = 0.0
            self.titleLabel?.alpha = 1.0
        }) { isFinished in
            self.spinner.isHidden = true
        }
//        UIView.animate(withDuration: 0.25) {
//            self.spinner.alpha = 1.0
//            self.titleLabel?.alpha = 0
//        } { isFinished in
//            self.spinner.isHidden = true
//        }
    }
    
}
