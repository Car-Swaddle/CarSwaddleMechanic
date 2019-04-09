import UIKit


/// These Nib protocols are broken up to allow more explicit access to the functionality.
public protocol NibNamed: class {
    /**
     The default implementation returns (`Self.self`). The class in string format. Which assumes the class name is the
     same as the '.xib' name. If they are different you can override it to provide the correct '.xib' name.
     */
    static var nibName: String { get }
}
extension NibNamed {
    public static var nibName: String { return String(describing: Self.self) }
}




/// Allows access to a nib instance of the conforming class
public protocol Nibbed: NibNamed {
    /// Creates a UINib of the class if one exists.
    /// Will use default `nibName` if one is not provided.
    static var nib: UINib { get }
}

extension Nibbed {
    public static var nib: UINib {
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: nibName, bundle: bundle)
    }
}





/**
 Your UIView subclass should conform to this when you want to instantiate a view from a nib.
 By default it will use the name of the class to find the nib. You can implement this yourself
 if the class name is different than the .xib name.
 
 Your type cannot be subclassable. If a class conforms to this, it must be `final`.
 */
public protocol NibInstantiating: Nibbed {
    /// See extension that provides `viewFromNib`.
}

public extension NibInstantiating where Self: UIView {
    
    /**
     Creates a UIView (or subclass) using `nibName` to generate it.
     
     - returns: `Self` This should be a subclass of `UIView`.
     
     - seealso: `nibName` This is used to determine which '.xib' file to use
     
     */
    static func viewFromNib(owner: Any? = nil) -> Self {
        return viewFromGenericNib(owner: owner) as Self
    }
    
    static func viewFromGenericNib<T: UIView>(owner: Any? = nil) -> T {
        var view: T!
        let objects = Bundle(for: self).loadNibNamed(nibName, owner: owner, options: nil)
        for object in objects ?? [] {
            guard let foundView = object as? T else { continue }
            view = foundView
            break
        }
        assert(view != nil, "Could not find object of type: \(T.self) \(#function)")
        return view
    }
    
    /* 0
     /Users/kylekendall/Projects/carswaddleui/CarSwaddleUITests/CarSwaddleUITests.swift:23: error: -[CarSwaddleUITests.CarSwaddleUITests testCreateView] : failed: caught "NSInternalInconsistencyException", "Could not load NIB in bundle: 'NSBundle </Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents> (loaded)' with name 'CustomAlertContentView'"
     */
    /* 1
     /Users/kylekendall/Projects/carswaddleui/CarSwaddleUITests/CarSwaddleUITests.swift:23: error: -[CarSwaddleUITests.CarSwaddleUITests testCreateView] : failed: caught "NSInternalInconsistencyException", "Could not load NIB in bundle: 'NSBundle </Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents> (loaded)' with name 'CustomAlertContentView'"
     */
    
    /* 2
     /Users/kylekendall/Projects/carswaddleui/CarSwaddleUITests/CarSwaddleUITests.swift:23: error: -[CarSwaddleUITests.CarSwaddleUITests testCreateView] : failed: caught "NSInternalInconsistencyException", "Could not load NIB in bundle: 'NSBundle </Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Library/Xcode/Agents> (loaded)' with name 'CustomAlertContentView'"
     */
    
}


public protocol StoryboardInstantiating: class {

    /**
     The name of the view controller to be created. The default implementation returns (`Self.self`). The class in string format.
     */
    static var viewControllerName: String { get }
    
    /**
     You must provide the name of the storyboard on which the UIViewController subclass exists.
     */
    static var storyboardName: String { get }
    
    static var bundle: Bundle { get }
    
}

public extension StoryboardInstantiating where Self: UIViewController {

    /**
     Creates a `Self` (UIViewController subclass) from the given parameters.
     
     - returns: `Self` This will be a `UIViewController` subclass generated from a `UIStoryboard`
     */
    static func viewControllerFromStoryboard() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: bundle)
        if let viewController = storyboard.instantiateInitialViewController() as? Self {
            return viewController
        } else if let viewController = storyboard.instantiateViewController(withIdentifier: viewControllerName) as? Self {
            return viewController
        }
        fatalError("A viewcontroller with the identifier '\(viewControllerName)' does not exist on the storyboard with the name '\(storyboardName)'. Or it does exist and it does NOT match up with the type '\(type(of: self))'. AND… there is no initial view controller of the current type.")
    }
    
    static var viewControllerName: String { return String(describing: Self.self) }
    static var storyboardName: String { return String(describing: Self.self) }
    static var bundle: Bundle { return Bundle(for: Self.self) }
}
