import UIKit


// Use `NibRegisterable` to register a nib instance (you must be using a .xib). Use `ReuseIdentifying` if you do not use a .xib file with your cell.

/// Conform to this to get an identifier for free. Normally used with UITableViewCell or UICollectionViewCell.
/// You CANNOT have a reuseIdentifer in the Nib if you conform to this protocol.
public protocol ReuseIdentifying: class {
    // See extension
}

public extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: Self.self) + "Identifier"
    }
}


/// To use this, have your Cell conform, and call `tableView.register(MyCell.self)` or `collectionView.register(MyCell.self)`
/// and when you want to use the cell call `let cell: MyCell = tableView.dequeue()`
/// or `let cell: MyCell = tableView.dequeue(for: indexPath)` or `let cell: MyCell = collectionView.dequeue(for: indexPath)`
public protocol NibRegisterable: ReuseIdentifying, Nibbed { }


public extension UITableView {
    
    /// Register a NIB with this method.
    ///
    /// - Parameter nibRegisterable: A UITableViewCell that conforms to NibRegisterable
    func register(_ nibRegisterable: (NibRegisterable & UITableViewCell).Type) {
        register(nibRegisterable.nib, forCellReuseIdentifier: nibRegisterable.reuseIdentifier)
    }
    
    /// Register a class with this method.
    ///
    /// - Parameter reuseIdentifying: A UITableViewCell that conforms to ReuseIdentifying
    func register(_ reuseIdentifying: (ReuseIdentifying & UITableViewCell).Type) {
        register(reuseIdentifying, forCellReuseIdentifier: reuseIdentifying.reuseIdentifier)
    }
    
    /// Dequeue a cell that was registered with ReuseIdentifying.
    ///
    /// - Returns: A UITableViewCell that conforms to ReuseIdentifying.
    func dequeueCell<T: UITableViewCell & ReuseIdentifying>() -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.self.reuseIdentifier) as? T else {
            fatalError("You must register your cell with `tableView.register(_ nibRegisterable: NibRegisterable.Type)` or other `register` methods on `UITableView`. The type you are wanting is: \(T.self) and the identifier for that type is: \(T.self.reuseIdentifier)")
        }
        return cell
    }
    
    /// Dequeue a cell that was registered with ReuseIdentifying.
    ///
    /// - Parameter indexPath: The indexPath for the cell to be used.
    /// - Returns: A UITableViewCell that conforms to ReuseIdentifying.
    func dequeueCell<T: UITableViewCell & ReuseIdentifying>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.self.reuseIdentifier, for: indexPath) as? T else {
            fatalError("You must register your cell with `tableView.register(_ nibRegisterable: NibRegisterable.Type)` or other `register` methods on `UITableView`. The type you are wanting is: \(T.self) and the identifier for that type is: \(T.self.reuseIdentifier)")
        }
        return cell
    }
    
}


public extension UICollectionView {
    
    /// Register a NIB with this method.
    ///
    /// - Parameter nibRegisterable: A UITableViewCell that conforms to NibRegisterable
    func register(_ nibRegisterable: (NibRegisterable & UICollectionViewCell).Type) {
        register(nibRegisterable.nib, forCellWithReuseIdentifier: nibRegisterable.reuseIdentifier)
    }
    
    /// Register a class with this method.
    ///
    /// - Parameter reuseIdentifying: A UITableViewCell that conforms to ReuseIdentifying
    func register(_ reuseIdentifying: (ReuseIdentifying & UICollectionViewCell).Type) {
        register(reuseIdentifying, forCellWithReuseIdentifier: reuseIdentifying.reuseIdentifier)
    }
    
    /// Dequeue a cell that was registered with ReuseIdentifying.
    ///
    /// - Parameter indexPath: The indexPath for the cell to be used.
    /// - Returns: A UICollectionViewCell that conforms to ReuseIdentifying.
    func dequeueCell<T: UICollectionViewCell & ReuseIdentifying>(for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.self.reuseIdentifier, for: indexPath) as? T else {
            fatalError("You must register your cell with `tableView.register(_ nibRegisterable: NibRegisterable.Type)` or other `register` methods on `UITableView`. The type you are wanting is: \(T.self) and the identifier for that type is: \(T.self.reuseIdentifier)")
        }
        return cell
    }
    
}
