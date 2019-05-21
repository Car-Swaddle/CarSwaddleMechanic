
import UIKit

public extension CustomAlertAction {
    
    static var cancelTitle = NSLocalizedString("CANCEL", comment: "Action to cancel on an alert")
    
    /// CustomAlertAction configured for `cancel`.
    ///
    /// - Parameter handler: Closure called on button tap.
    /// - Returns: CustomAlertAction configured for `cancel`.
    static func cancelAction(_ handler: ((CustomAlertAction) -> Void)? = nil) -> CustomAlertAction {
        let action = CustomAlertAction(title: cancelTitle, handler: handler)
        return action
    }
    
    static var okayTitle = NSLocalizedString("OKAY", comment: "Action to cancel on an alert")
    
    /// CustomAlertAction configured for `okay`.
    ///
    /// - Parameter handler: Closure called on button tap.
    /// - Returns: CustomAlertAction configured for `okay`.
    static func okayAction(_ handler: ((CustomAlertAction) -> Void)? = nil) -> CustomAlertAction {
        let action = CustomAlertAction(title: okayTitle, handler: handler)
        return action
    }
    
}

public extension CustomAlertContentView {
    
    /// Adds an action to the content view that is configured for `cancel`.
    ///
    /// - Parameter handler: Closure called on button tap.
    @discardableResult
    func addCancelAction(_ handler: ((CustomAlertAction) -> Void)? = nil) -> CustomAlertAction {
        let action = CustomAlertAction.cancelAction(handler)
        addAction(action)
        return action
    }
    
    /// Adds an action to the content view that is configured for `okay`.
    ///
    /// - Parameter handler: Closure called on button tap.
    @discardableResult
    func addOkayAction(_ handler: ((CustomAlertAction) -> Void)? = nil) -> CustomAlertAction {
        let action = CustomAlertAction.okayAction(handler)
        addAction(action)
        return action
    }
    
}
