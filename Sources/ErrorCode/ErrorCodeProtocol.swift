
/// Defines an interface for converting a type to and from some opaque `String` representation.
///
/// Use the `@ErrorCode` macro for a default implementation.
public protocol ErrorCode {
    
    // MARK: - Properties
    
    /// A `String` representation of this instance, that is opaque to the user and does not expose any implementation details.
    var opaqueCode: String { get }
    
    // MARK: - Initializers
    
    /// Creates an instance of the conforming type from it's corresponding `opaqueCode`.
    /// - Parameter opaqueCode: The opaque code `String`.
    /// - Throws: Errors that occur due to unrecognized or malformed `opaqueCode` values.
    init(opaqueCode: String) throws
}
