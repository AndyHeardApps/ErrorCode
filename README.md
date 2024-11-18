# ErrorCode

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAndyHeardApps%2FErrorCode%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/AndyHeardApps/ErrorCode)
![GitHub License](https://img.shields.io/github/license/andyheardapps/ErrorCode)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/andyheardapps/errorcode/build.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FAndyHeardApps%2FErrorCode%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/AndyHeardApps/ErrorCode)

The package contains tools for the automatic generation of opaque error codes. Surfacing low level errors can be problematic because, as developers, we want to know where and why an error occurred, and we want a user or analytics to be able to report this to us, however we don't want to risk exposing implementation details of our code to potenital malicious actors. For instance a networking error may unintentionally expose details that open us up to person-in-the-middle attacks, or may expose how the back end is being hosted, which could provide information for possible attacks on infrastructure.

Consider an error called `MyError.usernameCorrectPasswordIncorrect`. If this raw text were exposed to the user, it would show that the provided username exists, which is a potential leak of critical information.

One simple solution is to instead present a localized error message to the user, however to avoid convoluted and overly technical alerts, that message may end up being something such as "Server error" or "Network error" for multiple different errors, and do not provide much information on where the error was thrown or why.

Ideally each error will have a stable, uniquely identifiable representation that is safe to expose to the user, and can be used to indicate which line of code threw the error. This is very cumbersome, and is almost all boilerplate code, with the addition that a developer typing in random gibberish to represent this identifier might result in duplicates. Using a hash value could work, but Swift hashing uses a random seed for each app launch and is therefore not stable. Hashing is lossy in general, so simply exposing some custom, stable hash value would not be able to preserve all of the error data.

To this end, this package contains tools to automatically generate an opaque `String` representation of an `enum` case for use in or as Swift `Error` types. This is accomplished by using the type and case names of the value (e.g. `MyErrorCode.networkingError`) and lossily hashing it at compile time into some `String` representation. This allows us to store this lossy representation in generated source code, and it doesn't matter that the code itself is lossy, as we can use pattern matching to know which code corresponds to which error. Swift macros also allow us to completely remove the boilerplate required store and pattern match each error to the corresponding code.

It was decided to constrain this macro to only be applicable to `enum` declarations to allow for exhaustive pattern matching when creating an opaque code, and to force developers to be explicit in their grouping of error codes. It is also common for developers to have a user facing, localized description of an error code. Ideally, these localized strings would be declared in the UI layer of an app, but the error code itself may be declared in some low level code. Forcing `enum` declarations and using`switch` statements means that the Swift compiler will enforce that every case for an error code is handled when declaring this localized value, preventing missing cases, and also informing the developer when cases have changed.

## Documentation
Full documentation is available [here](https://andyheardapps.github.io/ErrorCode/documentation/errorcode).

## Basic usage

The main point of interaction with this package is the `@ErrorCode` macro. This must be applied to an `enum` declaration, and will generate an extension on that type with conformance and a default implementation for the `ErrorCode` protocol. 

This protocol has two requirements, an `opaqueCode` property of type `String`, and an `init(opaqueCode: String)` initializer. These two functions are used to convert the adopting type into an opaque code `String`, and back again. The initializer can `throw` if no match can be found for the provided `opaqueCode`.

There is also the `@ErrorCodeExtension` macro that can be applied to existing `enum` declarations on an extension, however this requires a little more work, and does not support nesting.

The macro can be applied to an enum as simply as:

```swift
@ErrorCode
enum MyErrorCode {
    case error1
    case error2
}
```

This will generate the following extension:

```swift
extension MyErrorCode: ErrorCode {

    private enum OpaqueCode {
        static let error1 = "kDn6"
        static let error2 = "lEo5"
    }

    var opaqueCode: String {
        switch self {
        case .error1:
            OpaqueCode.error1
        case .error2:
            OpaqueCode.error2
        }
    }

    init(opaqueCode: String) throws {

        guard opaqueCode.isEmpty == false else {
            throw OpaqueCodeError.opaqueCodeIsEmpty
        }

        switch opaqueCode {
        case OpaqueCode.error1:
            self = .error1

        case OpaqueCode.error2:
            self = .error2

        default:
            throw OpaqueCodeError.unrecognizedOpaqueCode(opaqueCode)

        }
    }

    private enum OpaqueCodeError: OpaqueCodeInitializerError {
        case opaqueCodeIsEmpty
        case unrecognizedOpaqueCode(String)
        case unusedOpaqueCodeComponents([String])
    }
}
```

As you can see, the macro generates more than the minimum two implementations required by the `ErrorCode` protocol. By default, everything generated by the macro that isn't a protocol requirement is declared as `private`.

The `OpaqueCode` type is a store of `static` `String` properties for each `enum` `case`. These values are generated using a deterministic, lossy hashing function.

The `OpaqueCodeError` contains a few `Error` types that can be thrown by the `init(opaqueCode:)` initializer when pattern matching fails.

By default, the `opaqueCode` property and `init(opaqueCode:)` initializer will have the lowest access level possible while still satisfying the protocol requirements. e.g for a `public enum`, they will be declared as `public`, and for a `private enum` they will be declared as `fileprivate`.

The `ErrorCode` protocol in this package does not itself extend the `Error` protocol. It is down to the developer to decide whether their error codes are themselves `Error`s or are instead properties on some other `Error` type. e.g.

```swift
@ErrorCode
enum MyErrorCode {
    case error1
    case error2
}

struct MyError: Error {

    let errorCode: MyErrorCode
    let triggeringError: Error
}
```

or 

```swift
@ErrorCode
enum MyErrorCode: Error {
    case error1
    case error2
}
```

## Nested error codes
The macro supports nesting of error codes as associated values on `enum` cases. This permits the creation of a tree based representation of errors and their associated domains.

```swift
@ErrorCode
enum AppError {
    case repository(Repository)
    case network(Network)
    case decoding
}

@ErrorCode
enum Network: Int {
    case notFound = 404
    case serverError = 500
}

@ErrorCode
enum Repository {
    ...
}
```

The only requirement in this case, is that each case has a maximum of one associate value, and that the type of the associated value conform to `ErrorCode` (**Note:** it does not need to use the `@ErrorCode` macro to accomplish this). The associated values can be named or anonymous, and not every case needs to have an associated value.

Expanding the macro generated code on `AppError` shows:

```swift
extension AppError: ErrorCode {

    private enum OpaqueCode {
        static let repository = "J9xW"
        static let network = "b3Fi"
        static let decoding = "u4kd"
    }

    var opaqueCode: String {
        switch self {
        case let .repository(child):
            OpaqueCode.repository + "-" + childOpaqueCode(for: child)
        case let .network(child):
            OpaqueCode.network + "-" + childOpaqueCode(for: child)
        case .decoding:
            OpaqueCode.decoding
        }
    }

    private func childOpaqueCode(for errorCode: some ErrorCode) -> String {
        errorCode.opaqueCode
    }

    init(opaqueCode: String) throws {

        var components = opaqueCode.split(separator: "-")
        guard components.isEmpty == false else {
            throw OpaqueCodeError.opaqueCodeIsEmpty
        }

        let firstComponent = components.removeFirst()
        switch firstComponent {
        case OpaqueCode.repository:
            let remainingComponents = components.joined(separator: "-")
            self = try .repository(Self.childErrorCode(for: remainingComponents))

        case OpaqueCode.network:
            let remainingComponents = components.joined(separator: "-")
            self = try .network(Self.childErrorCode(for: remainingComponents))

        case OpaqueCode.decoding:
            guard components.isEmpty else {
                throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
            }
            self = .decoding

        default:
            throw OpaqueCodeError.unrecognizedOpaqueCode(String(firstComponent))

        }
    }

    private static func childErrorCode<E: ErrorCode>(for opaqueCode: String) throws -> E {
        try E(opaqueCode: opaqueCode)
    }

    private enum OpaqueCodeError: OpaqueCodeInitializerError {
        case opaqueCodeIsEmpty
        case unrecognizedOpaqueCode(String)
        case unusedOpaqueCodeComponents([String])
    }
}
```

There is some additional code in here that wasn't in the unnested example, as well as some changes to the `opaqueCode` property and `init(opaqueCode:)` initializer. These changes are simply to concatenate the nested codes in the `opaqueCode` property, and to separate the codes in the `init(opaqueCode:)` initializer. The `childOpaqueCode(for:)` and `childErrorCode(for:)` functions are used as a way to convert a nested `ErrorCode` into an opaque code in the `opaqueCode` property, and back again in the `init(opaqueCode:)` initializer. These calls could easily be omitted and the initializer and declarations called directly on nested `ErrorCode` values, however they are extracted into separate functions to facilitate customisation, which is explained below.

## Macro parameters

The macro has a few optional parameters to allow for some customisation.

**NOTE:** Swift macro parameters are passed to the macro as their literal declaration, i.e. functions, parameters and expressions are not resolved beforehand. Therefore only simple literal values are supported as parameters.

### `codeLength`

Sets the length of the generated opaque codes. This must be a single positive `Int` literal, and must be larger than `0`. Shorter code lengths increase the chance that there will be a collision in the generated opaque codes.

### `delimiter`

Sets the `String` used to separate parent and child opaque codes. This must be a single `String` literal, and cannot be empty.

### `codeCharacters`

Accepts a `String`, the unique characters of which are used to generate the opaque codes. This must be a single `String` literal, and must contain at least 5 unique characters. Smaller character sets increase the chance that there will be a collision in the generated opaque codes.

## Customisation

Each of the generated type declarations, functions and properties can be overridden and declared manually within the main `enum` declaration. This will prevent the generation of that declaration by the macro. This is why the `childOpaqueCode(for:)` and `childErrorCode(for:)` functions are extracted; to allow for customisation of child opaque code values without having to manually declare and maintain a whole `opaqueCode` property or `init(opaqueCode:)` initializer, which are both boilerplate heavy switch statements.

**NOTE:** Manual declarations must be in the main `enum` declaration, and not an extension. Swift macros are applied only to the block of code they are attached to and not to the type as a whole, so declarations in extensions cannot be detected and the macro will generate duplicates.

The overridable declarations are:

### `OpaqueCode` type

The `OpaqueCode` type declaration can be declared manually as an `enum`, `struct`, `class` or `actor` to provide custom opaque code values. It must have one static property corresponding to each `case` in it's containing `ErrorCode` `enum`. These must be declared as `static let <enumCaseName> = "<stringLiteral>"` or a compiler error will be generated. These `String` literal declarations must have unique values, but can be of any length. 

### `opaqueCode` property

This property can be manually declared to use a custom implementation for the creation of opaque code values. This property is a requirement of the `ErrorCode` protocol, so must have the appropriate access level, and must have a getter that is not marked as `async` or `throws`.

If this property is declared manually then the `childOpaqueCode(for:)` function is not generated or used.

### `init(opaqueCode: String)` initializer

This initializer can be manually declared to use a custom implementation for the matching of an opaque code value back to an `ErrorCode`. This initializer is the other requirement of the `ErrorCode` protocol, so must also have the appropriate access level. It cannot be marked as `async`, but may optionally be marked as `throws`.

If this property is declared manually then the `childErrorCode(for:)` function is not generated or used.

### `childOpaqueCode(for:)` function

This function is used by the generated `opaqueCode` property, and provides an overridable entry point to modify child opaque `String` values without having to manually declare the boilerplate heavy `opaqueCode` property. If the `opaqueCode` property is declared manually, then this function will not be generated or used. This function can be manually declared in a number of ways, using existentials or generics, as long as it can be called as `self.childOpaqueCode(for: childErrorCode)`.

**NOTE:** Any modifications applied to child opaque codes in this function must be reversed in the `childErrorCode(for:)` function for the nested `ErrorType` initializers to pattern match correctly.

### `childErrorCode(for:)` function

This function is used by the generated `init(opaqueCode: String)` initializer to provide an overridable entry point to modify error code `String` before they are used to create child `ErrorCode` values, but without having to manually declare the boilerplate heavy `init(opaqueCode: String)` initializer. If the `init(opaqueCode: String)` initializer is declared manually then this function will not be generated or used. This function must be declared as `static` as it is used in an initializer, and cannot be marked as `async`, but may optionally be marked as `throws`.

### `OpaqueCodeError` type

This type contains a few errors used in the generated `init(opaqueCode: String)` initializer. It conforms to the `OpaqueCodeInitializerError` protocol which defines errors required by the generated initializer. You may want to manually declare this type if you wish to add your own errors. If you do so, and the generated initializer is being used, then your manual declaration will need to conform to the `OpaqueCodeInitializerError` in order to be used by the generated initializer. If the initializer is manually declared, then this type will not be generated or used, and any manual declaration of this type does not need to conform to `OpaqueCodeInitializerError`.

All of the requirements for manual declarations should be enforced by compiler warnings and errors.

## Extension macro
It may be that you will want to add `ErrorCode` conformance to an existing `enum` not in your control. The standard `@ErrorCode` macro will not work in this case, as the macro cannot inspect the cases declared in order to generate any code, so they must be provided manually along with the `ErrorCode` conformance. The `@ErrorCodeExtension` can be used in this case, but a `static` `errorCodes` array of all cases must be provided for the macro to work off of.

This macro does not support nesting, but provides the rest of the functionality of the `@ErrorCode` macro.

## TODO
1. [x] Custom child code delimeter
3. [x] Custom character set for opaque code generation

## License
This project is licensed under the terms of the MIT license.
