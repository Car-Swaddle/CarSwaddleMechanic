//
//  TransactionViewController.swift
//  CarSwaddleMechanic
//
//  Created by Kyle Kendall on 2/1/19.
//  Copyright © 2019 CarSwaddle. All rights reserved.
//

import CarSwaddleUI
import Store
import CarSwaddleData
import CoreData
import CoreLocation

let costFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.minimumIntegerDigits = 1
    numberFormatter.maximumFractionDigits = 2
    
    numberFormatter.numberStyle = .currency
    
    return numberFormatter
}()

final class TransactionViewController: UIViewController, StoryboardInstantiating {
    
    private enum Section: CaseIterable {
        case transactionDetails
        case receipts
    }
    
    private enum TransactionDetailsRow: CaseIterable {
        case transaction
        case cost
        case distance
        case autoService
    }
    
    @IBOutlet private weak var actionButton: ActionButton!
    
    private var sections: [Section] = Section.allCases
    private var detailsRows: [TransactionDetailsRow] = TransactionDetailsRow.allCases
    
    static func create(transaction: Transaction) -> TransactionViewController {
        let viewController = TransactionViewController.viewControllerFromStoryboard()
        viewController.transaction = transaction
        return viewController
    }
    
    private var transaction: Transaction! {
        didSet {
            resetData()
        }
    }
    
    @IBOutlet private weak var tableView: UITableView!
    private let stripeNetwork: StripeNetwork = StripeNetwork(serviceRequest: serviceRequest)
    
    lazy private var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(TransactionViewController.didRefresh), for: .valueChanged)
        return refresh
    }()
    
    @objc private func didRefresh() {
        requestData { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
    
    private lazy var insetAdjuster: ContentInsetAdjuster = ContentInsetAdjuster(tableView: nil, actionButton: actionButton)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestData { [weak self] in
            self?.tableView.reloadData()
        }
        setupTableView()
        insetAdjuster.positionActionButton()
    }
    
    private func setupTableView() {
        tableView.register(TransactionCell.self)
        tableView.register(TransactionReceiptCell.self)
        tableView.register(AddReceiptCell.self)
        tableView.register(TextCell.self)
        tableView.register(LabelValueCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = refreshControl
    }
    
    private func requestData(completion: @escaping () -> Void = {}) {
        let transactionID = transaction.identifier
        store.privateContext { [weak self] privateContext in
            self?.stripeNetwork.requestTransactionDetails(transactionID: transactionID, in: privateContext) { transactionObjectID, error in
                DispatchQueue.main.async {
                    if let transactionObjectID = transactionObjectID,
                        let transaction = store.mainContext.object(with: transactionObjectID) as? Transaction {
                        self?.transaction = transaction
                    }
                    completion()
                }
            }
        }
    }
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TransactionReceipt> = createFetchedResultsController()
    
    private func createFetchedResultsController() -> NSFetchedResultsController<TransactionReceipt> {
        let fetchRequest: NSFetchRequest<TransactionReceipt> = TransactionReceipt.fetchRequest()
        fetchRequest.sortDescriptors = [TransactionReceipt.createdAtSortDescriptor]
        fetchRequest.predicate = TransactionReceipt.predicate(forTransactionMetadataID: transaction.transactionMetadata?.identifier ?? "")
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: store.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        try! fetchedResultsController.performFetch()
        return fetchedResultsController
    }
    
    private func resetData() {
        fetchedResultsController = createFetchedResultsController()
    }
    
    private var cameraAction: UIAlertAction {
        let title = NSLocalizedString("Camera", comment: "Title of button when selected presents a camera")
        return UIAlertAction(title: title, style: .default) { [weak self] action in
            guard let imagePicker = self?.imagePicker(source: .camera) else { return }
            self?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private var cameraRollAction: UIAlertAction {
        let title = NSLocalizedString("Camera Roll", comment: "Title of button when selected presents a camera")
        return UIAlertAction(title: title, style: .default) { [weak self] action in
            guard let imagePicker = self?.imagePicker(source: .photoLibrary) else { return }
            self?.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func cameraAlertController() -> UIAlertController {
        let title = NSLocalizedString("Add a receipt for your tax records", comment: "Title of alert")
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(cameraAction)
        alert.addAction(cameraRollAction)
        alert.addCancelAction()
        
        return alert
    }
    
    private func imagePicker(source: UIImagePickerController.SourceType) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = false
        return imagePicker
    }
    
    @IBAction private func didTapAddReceipt() {
        let alert = self.cameraAlertController()
        present(alert, animated: true, completion: nil)
    }
    
}


extension TransactionViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.section(fromSectionIndex: section) {
        case .transactionDetails:
            return detailsRows.count
        case .receipts:
            return (fetchedResultsController.sections?[0].numberOfObjects ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch self.section(fromSectionIndex: indexPath.section) {
        case .transactionDetails:
            switch detailsRows[indexPath.row] {
            case .transaction:
                let cell: TransactionCell = tableView.dequeueCell()
                cell.allowDisclosure = false
                cell.configure(with: transaction)
                return cell
            case .autoService:
                let cell: TextCell = tableView.dequeueCell()
                cell.textLabel?.text = NSLocalizedString("Auto service", comment: "Tap to get to auto service from a transaction")
                cell.textLabel?.font = UIFont.appFont(type: .regular, size: 17)
                cell.accessoryType = .disclosureIndicator
                return cell
            case .cost:
                let cell: LabelValueCell = tableView.dequeueCell()
                cell.labelText = NSLocalizedString("Cost to write off for taxes (estimate)", comment: "Label")
                if let cost = transaction.transactionMetadata?.mechanicCostDollars {
                    cell.value = costFormatter.string(from: NSNumber(value: cost))
                } else {
                    cell.value = "--"
                }
                return cell
            case .distance:
                let cell: LabelValueCell = tableView.dequeueCell()
                cell.labelText = NSLocalizedString("Miles to write off for taxes (estimate)", comment: "Label")
                if let distance = transaction.transactionMetadata?.drivingDistanceMiles {
                    let formatString = NSLocalizedString("%@ miles driven", comment: "How many miles driven to point")
                    cell.value = String(format: formatString, String(distance))
                } else {
                    cell.value = "--"
                }
                return cell
            }
        case .receipts:
//            if isAddReceiptRow(indexPath: indexPath) {
//                return tableView.dequeueCell() as AddReceiptCell
//            } else {
                let cell: TransactionReceiptCell = tableView.dequeueCell()
                let formatString = NSLocalizedString("Receipt %i", comment: "The order of the receipt. Just how many there are")
                cell.receiptLabel?.text = String(format: formatString, indexPath.row+1)
                let adjustedIndexPath = receiptIndexPath(from: indexPath)
                let receipt = fetchedResultsController.object(at: adjustedIndexPath)
                cell.configure(with: receipt)
                return cell
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch self.section(fromSectionIndex: section) {
        case .receipts:
            if fetchedResultsController.sections?[0].numberOfObjects == 0 {
                return 0
            } else {
                return 74
            }
        case .transactionDetails: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labeledHeaderView = HeaderView()
        labeledHeaderView.labelText = NSLocalizedString("Receipts", comment: "Header list of photos of receipts listed below")
        return labeledHeaderView
    }
    
    private func isAddReceiptRow(indexPath: IndexPath) -> Bool {
        let numberOfObjects = fetchedResultsController.sections?[0].numberOfObjects ?? 0
        return indexPath.row == numberOfObjects && indexPath.section == 1
    }
    
    private func section(fromSectionIndex sectionIndex: Int) -> Section {
        return sections[sectionIndex]
    }
    
}

extension TransactionViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch self.section(fromSectionIndex: indexPath.section) {
        case .transactionDetails:
            if detailsRows[indexPath.row] == .autoService {
                guard let autoServiceID = transaction.transactionMetadata?.autoServiceID else { return }
                let autoServiceViewController = AutoServiceDetailsViewController.create(autoServiceID: autoServiceID)
                show(autoServiceViewController, sender: self)
            }
        case .receipts:
//            if isAddReceiptRow(indexPath: indexPath) {
//                let alert = self.cameraAlertController()
//                present(alert, animated: true, completion: nil)
//            } else {
                let receipt = fetchedResultsController.object(at: receiptIndexPath(from: indexPath))
                guard let fileURL = (try? profileImageStore.getFilePath(name: receipt.receiptPhotoID)) else { return }
                let viewController = UIDocumentInteractionController(url: fileURL)
                viewController.delegate = self
                viewController.presentPreview(animated: true)
//            }
        }
    }
    
    private func receiptIndexPath(from indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: 0)
    }
    
}

extension TransactionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let section = IndexSet(arrayLiteral: 1)
        tableView.reloadSections(section, with: .none)
    }
    
}


extension TransactionViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//        return navigationController ?? self
        return self
    }
    
}


extension TransactionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            picker.dismiss(animated: true, completion: nil)
        }
        guard let image = info[.originalImage] as? UIImage else { return }
        let orientedImage = UIImage.imageWithCorrectedOrientation(image)
        guard let imageData = orientedImage.resized(toWidth: 300 * UIScreen.main.scale)?.jpegData(compressionQuality: 1.0) else {
            return
        }
        guard let url = try? profileImageStore.storeFile(data: imageData, fileName: "receipt") else {
            return
        }
        let transactionID = self.transaction.identifier
        store.privateContext { [weak self] privateContext in
            self?.stripeNetwork.uploadTransactionReceipt(transactionID: transactionID, fileURL: url, in: privateContext) { receiptObjectID, error in
                store.mainContext { mainContext in
                    print("got back")
                    if let error = error {
                        print("error: \(error)")
                    } else if let id = receiptObjectID {
                        print("id: \(id)")
                    }
                }
            }
        }
    }
    
}

private let milesToMetersConstant: Float = 1609.344
private let metersToMilesConstant: CGFloat = 0.00062137

extension TransactionMetadata {
    
    var drivingDistanceMiles: Int {
        return Int(CGFloat(drivingDistance) * metersToMilesConstant)
    }
    
    var mechanicCostDollars: Float {
        return Float(mechanicCost) / 100.0
    }
    
}
