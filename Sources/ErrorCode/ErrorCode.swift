
/**
 Adds a pseudo-random, alphanumeric ``ErrorCode/ErrorCode/opaqueCode`` `String` property to each member of an `enum` declaration that is safe to present to a user without unintentionally exposing implementation details. This `opaqueCode` can be used to re-construct the ``ErrorCode/ErrorCode`` that produced it by calling the synthesized ``ErrorCode/ErrorCode/init(opaqueCode:)`` initializer.
 
 Exposing error names or detailed descriptions to the user can be confusing to a non-technical person, and a potential security risk if it describes implementation details. This macro, which provides a default implementation of ``ErrorCode/ErrorCode``, allows the developer to create a large list of error codes as Swift `enum` types that contain detailed descriptions of what went wrong, as well as where. These types can then be exposed to the user safely using their ``ErrorCode/ErrorCode/opaqueCode`` property. This code can then be reported via analytics, or manually by the user, then used with the ``ErrorCode/ErrorCode/init(opaqueCode:)`` initializer to see exactly which error code was triggered, and potentially even where it was triggered in code.
 
 ### Basic usage
 To use this macro, simply apply it to an `enum` declaration:
 
 ```swift
 @ErrorCode
 enum AppErrorCode {
    case error1
    ...
 }
 ```
 
 This will synthesize the ``ErrorCode/ErrorCode/opaqueCode`` and ``ErrorCode/ErrorCode/init(opaqueCode:)`` declarations for you, as well as a couple of private types:
 
 The `OpaqueCode` type contains a list of static properties containing the `String` literal opaque code values for each case.
 
 The `OpaqueCodeError` type contains a few errors that may be thrown when initializing an ``ErrorCode/ErrorCode`` from the throwing ``ErrorCode/ErrorCode/init(opaqueCode:)`` initializer.
 
 ### Nested error codes
 Error codes can be nested into each other using associated values on `enum` cases:
 
 ```swift
 @ErrorCode
 enum AppErrorCode {
    case error1(NestedErrorCode)
    case error2(child: NestedErrorCode)
    case error3
    ...
 }
 
 @ErrorCode
 enum NestedErrorCode {
    case nested1
    ...
 }
 ```
 
 Associated values can have names, but they aren't required, and not all cases on a type need to have associated values.. The only requirement is that all of the error codes conform to the ``ErrorCode/ErrorCode`` protocol. ``ErrorCode/ErrorCode/opaqueCode`` values from nested error codes combine each level in to one `String` delimeted by a hyphen (`-`) between each level, starting from the top most error code at the start of the string and going down through the nesting. For example, the above `AppErrorCode` of `AppErrorCode.error1(.nested1)`, if `error1` had an  opaque code of `"AAAA"` and `nested1` had an opaque code of `"BBBB"`, the combined, nested code would be `"AAAA-BBBB"`.
 
 ### Custom opaque code lengths
 The `codeLength` optional parameter can be used to override the generated code length. By default, this value is `4`, but it can be any length. You may wish to have shorter codes for ease of reporting and debugging, but the shorter the code, the more likely that the generated codes will collide. If this happens, an error is reported with possible fixits, one of which is to increase the `codeLength` parameter by `1`.
 
 ### Custom child code delimiter
 The `delimiter` optional parameter can be used to override the default `"-"` delimiter placed between parent and child codes. This must not be an empty string.

 ### Custom opaque code characters
 The `codeCharacters` optional parameter can be used to override which characters are used when generating opaque codes. By default the `[a-zA-Z0-9]` characters are used. The provided `String` must contain at least five unique characters, and duplicate characters are ignored.
 
 ### Additional generated code
 If you apply this macro to a nested `enum` and expand the generated source code, you will see two further private functions are generated. `childOpaqueCode(for:)` is used as a type safe way of getting the ``ErrorCode/ErrorCode/opaqueCode`` from a nested error code, and the static `childErrorCode(for:)` function does the reverse to create a nested error code from an opaque code `String`. The default implementations are very simple, but they provide a way of customising how child opaque codes are handled by a parent, without having to manually declare the ``ErrorCode/ErrorCode/init(opaqueCode:)`` initializer, which is largely boilerplate code. More on overriding generated code is exxplained below.
 
 ### Overriding generated code
 As stated above, the ``ErrorCode(codeLength:)`` macro simply generates a conformance to the ``ErrorCode/ErrorCode`` protocol. Most of this generated code is basic boilerplate, and the generated code will work as is. However, should you want to customise the generated implementation, each generated function and type can be manually declared, and the macro will intelligently verify that that declaration is valid, and then use it instead of generating it. There are a few requirements for this:
 
 1. The `opaqueCode` property must have the correct access modifier for it's containing type to satisfy the ``ErrorCode/ErrorCode`` protocol, and must not have a getter that is `async` or `throws`. Declaring this property manually prevents the `childOpaqueCode(for:)` function from being generated by the macro as it will no longer be used.
 2. The `init(opaqueCode:)` initializer must also have the correct access modifier for it's containing type to satisfy the ``ErrorCode/ErrorCode`` protocol, and must not be failable or `async`, though it does not have to be a throwing initializer. Declaring this initializer manually prevents the `childErrorCode(for:)` function and `OpaqueCodeError` `enum` from being generated by the macro as they will no longer be used.
 3. The `OpaqueCode` can be declared as an `enum`, `struct`, `class` or `actor`, and MUST contain one `static` property declared as `let` with a `String` literal initializer for each case in it's containing type. An error will be generated if any cases are omitted. Other functionality can be declared in this type without effecting the macro.
 4. The `childOpaqueCode(for:)` and `childErrorCode(for:)` functions can by individually overriden, or both overridden at the same time. The only requirement is that they are not `async`, and that `childErrorCode(for:)` does not `throw`. It should be noted however, that any modifications to child opaque codes made in `childOpaqueCode(for:)` **MUST** be reversed in `childErrorCode(for:)` for the generated ``ErrorCode/ErrorCode/init(opaqueCode:)`` initializer to pattern match and work correctly.
 5. The `OpaqueCodeError` `enum` can be manually declared to add other cases, and can be declared as an `enum`, `struct`, `class` or `actor`. If the ``ErrorCode/ErrorCode/init(opaqueCode:)`` initializer is being generated then this manual declaration must conform to the ``OpaqueCodeInitializerError`` protocol, as there are members on this type that are used by the generated code. *Note* that the protocol requirements can be satisfied by `enum` cases in place of `static` properties or functions. If both the ``ErrorCode/ErrorCode/init(opaqueCode:)`` and `OpaqueCodeError` types are declared manually, then no conformance to ``OpaqueCodeInitializerError`` is required.
 
 All of these requirements should be enforced by compiler warnings and errors. If anything doesn't work as expected, please submit an issue.
 */
@attached(extension, conformances: ErrorCode, names: named(OpaqueCode), named(opaqueCode), named(childOpaqueCode), named(init(opaqueCode: )), named(childErrorCode(for: )), named(OpaqueCodeError))
public macro ErrorCode(codeLength: Int? = nil, delimiter: String? = nil, codeCharacters: String? = nil) = #externalMacro(module: "ErrorCodeMacros", type: "ErrorCodeMacro")
