import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ErrorCodeMacros)
import ErrorCodeMacros

let testMacros: [String: Macro.Type] = [
    "ErrorCode": ErrorCodeMacro.self,
    "ErrorCodeExtension": ErrorCodeMacro.self
]
#endif

final class ErrorCode_BasicEnumTests: XCTestCase {

    // MARK: - Enum
    func testErrorCode_willExpand_unnestedEnumCorrectly() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            }
            
            extension TestCode: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willCreateDifferentOpaqueCodes_forIdenticalEnumCases_inDifferentEnums() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode1 {
                case value1
            }
            
            @ErrorCode
            enum TestCode2 {
                case value1
            }
            """,
            expandedSource: """
            enum TestCode1 {
                case value1
            }
            enum TestCode2 {
                case value1
            }

            extension TestCode1: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "4hKx"
                }

                var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

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

            extension TestCode2: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "BoR4"
                }

                var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

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

            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willGenerateError_whenAppliedToNonEnumDeclaration() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            struct TestCode {
            }
            """,
            expandedSource:
            """
            struct TestCode {
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "notAnEnum"
                    ),
                    message: "Macro \"@ErrorCode\" can only be applied to an enum.",
                    line: 1,
                    column: 1,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willGenerateError_whenCollidingOpaqueCodesAreGenerated() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeLength: 1)
            enum TestCode {
                case value1
                case value1
            }
            """,
            expandedSource:
            """
            enum TestCode {
                case value1
                case value1
            }
            
            extension TestCode: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "6"
                    static let value1 = "6"
                }

                var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value1:
                        OpaqueCode.value1
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value1:
                        self = .value1

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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.GeneratedOpaqueCodes",
                        id: "opaqueCodeCollision"
                    ),
                    message: "Generated opaque code collision on: \"value1\".",
                    line: 1,
                    column: 1,
                    severity: .error,
                    fixIts: [
                        .init(message: "Specify a longer code length with \"@ErrorCode(codeLength: 2)\""),
                        .init(message: "Declare opaque codes manually")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willGenerateWarning_whenOpaqueCodeStaticValuesAreManuallyDeclared_alongsideCodeLengthParameter() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeLength: 4)
            enum TestCode {
                case value1
                case value2
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            
            extension TestCode: ErrorCode {

                var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues"
                    ),
                    message: "\"OpaqueCode\" values are declared manually, so the \"codeLength\" parameter will be ignored.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willGenerateWarning_whenOpaqueCodeStaticValuesAreManuallyDeclared_alongsideCodeCharactersParameter() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeCharacters: "1234567890")
            enum TestCode {
                case value1
                case value2
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            
            extension TestCode: ErrorCode {

                var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues"
                    ),
                    message: "\"OpaqueCode\" values are declared manually, so the \"codeCharacters\" parameter will be ignored.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willGenerateWarning_whenOpaqueCodeInitializerAndPropertyAreManuallyDeclared_alongsideDelimiterParameter() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(delimiter: ".")
            enum TestCode {
                case value1(TestCode2)
                case value2
            
                var opaqueCode: String {
                    ""
                }
            
                init(opaqueCode: String) {
                    self = .value1
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(TestCode2)
                case value2
            
                var opaqueCode: String {
                    ""
                }
            
                init(opaqueCode: String) {
                    self = .value1
                }
            }
            
            extension TestCode: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "customOpaqueCodeDelimiterDeclaredAlongsideManualInitializerAndProperty"
                    ),
                    message: "\"opaqueCode\" property and \"init(opaqueCode: _)\" are declared manually, so the \"delimiter\" parameter will be ignored.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willGenerateWarning_whenEnumWithNoNestedCasesIsDeclared_alongsideDelimiterParameter() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(delimiter: ".")
            enum TestCode {
                case value1
                case value2
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            }
            
            extension TestCode: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }
            
                init(opaqueCode: String) throws {
            
                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }
            
                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1
            
                    case OpaqueCode.value2:
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "customOpaqueCodeDelimiterDeclaredOnEnumWithNoChildren"
                    ),
                    message: "Enum has no nested errors, so the \"delimiter\" parameter will be ignored.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // MARK: - Extension
    func testErrorCodeExtension_willExpand_unnestedExtensionCorrectly() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                public var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                public init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            macros: ["ErrorCodeExtension" : ErrorCodeMacro.self]
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCodeExtension_willGenerateError_whenAppliedToNonExtensionDeclaration() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            enum TestCode: ErrorCode {
            }
            """,
            expandedSource:
            """
            enum TestCode: ErrorCode {
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "notAnExtension"
                    ),
                    message: "Macro \"@ErrorCodeExtension\" can only be applied to an extension of an enum.",
                    line: 1,
                    column: 1,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCodeExtension_willGenerateWarning_whenOpaqueCodeStaticValuesAreManuallyDeclared_alongsideCodeLengthParameter() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension(codeLength: 4)
            extension TestCode: ErrorCode {
            
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
            
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                public var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                public init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues"
                    ),
                    message: "\"OpaqueCode\" values are declared manually, so the \"codeLength\" parameter will be ignored.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCodeExtension_willGenerateWarning_whenOpaqueCodeStaticValuesAreManuallyDeclared_alongsideCodeCharactersParameter() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension(codeCharacters: "1234567890")
            extension TestCode: ErrorCode {
            
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
            
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                public var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                public init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues"
                    ),
                    message: "\"OpaqueCode\" values are declared manually, so the \"codeCharacters\" parameter will be ignored.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCodeExtension_willGenerateWarning_whenErrorCodeConformanceIsNotManuallyDeclared() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode {
            
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            }
            """,
            expandedSource: """
            extension TestCode {
            
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                public var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                public init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro",
                        id: "extensionDoesNotAddErrorCodeConformance"
                    ),
                    message: "Macro \"@ErrorCodeExtension\" is a member macro and can not automatically add \"ErrorCode\" conformance.",
                    line: 1,
                    column: 1,
                    severity: .warning,
                    fixIts: [
                        .init(message: "Add \"ErrorCode\" conformance")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCodeExtension_willGenerateError_whenErrorCodesIsNotDeclared() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.CaseParsing",
                        id: "errorCodesDeclarationMissing"
                    ),
                    message: "Using the \"@ErrorCodeExtension\" macro on an extension requires that a manual list of cases be provided as a static property \"static let errorCodes: [Self] = []\".",
                    line: 1,
                    column: 1,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add \"errorCodes\" property")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCodeExtension_willGenerateError_whenNestedErrorCodesAreDeclared() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
                        
                private static let errorCodes: [Self] = [
                    .value1(1),
                    .value2
                ]
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
                        
                private static let errorCodes: [Self] = [
                    .value1(1),
                    .value2
                ]
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.CaseParsing",
                        id: "errorCodeNestingNotSupportedInExtensions"
                    ),
                    message: "Nested error codes are not supported when using the \"@ErrorCodeExtension\" macro.",
                    line: 5,
                    column: 9,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCodeExtension_willIgnoreOtherDeclarations() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
                        
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            
                var errorCodes: [Int] { [] }
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
                        
                private static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            
                var errorCodes: [Int] { [] }
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                public var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                public init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCodeExtension_willGenerateError_whenErrorCodesContainsTooManyBindings() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
                        
                private static let errorCodes, let errorCodes2: [Self] = [
                    .value1,
                    .value2
                ]
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
                        
                private static let errorCodes, let errorCodes2: [Self] = [
                    .value1,
                    .value2
                ]
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.CaseParsing",
                        id: "tooManyBindingsOnErrorCodesDeclaration"
                    ),
                    message: "\"errorCodes\" should declare a single binding.",
                    line: 4,
                    column: 5,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCodeExtension_willGenerateError_whenErrorCodesHasIncorrectTypeAnnotation() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
                        
                private static let errorCodes: [Int] = [
                    .value1,
                    .value2
                ]
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
                        
                private static let errorCodes: [Int] = [
                    .value1,
                    .value2
                ]
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.CaseParsing",
                        id: "incorrectTypeAnnotationOnErrorCodesDeclaration"
                    ),
                    message: "\"errorCodes\" should explicitly declare a type of \"[Self]\" or \"[TestCode]\".",
                    line: 4,
                    column: 24,
                    severity: .error,
                    fixIts: [
                        .init(message: "Set type annotation to \"[Self]\"")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCodeExtension_willGenerateError_whenErrorCodesHasNoInitializer() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
                        
                private static let errorCodes: [Self]
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
                        
                private static let errorCodes: [Self]
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.CaseParsing",
                        id: "shouldDeclareArrayLiteralForErrorCodesDeclaration"
                    ),
                    message: "\"errorCodes\" should include an array literal initializer containing all cases to generate an opaque code for.",
                    line: 4,
                    column: 24,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add array initializer")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCodeExtension_willGenerateWarning_whenErrorCodesIsNotDeclaredAsPrivate() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
                        
                static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
                        
                static let errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                public var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                public init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.CaseParsing",
                        id: "shouldUsePrivateAccessModifierOnErrorCodesDeclaration"
                    ),
                    message: "\"errorCodes\" should be declared as private to avoid namespace pollution.",
                    line: 4,
                    column: 5,
                    severity: .warning,
                    fixIts: [
                        .init(message: "Make \"errorCodes\" \"private\"")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCodeExtension_willGenerateWarning_whenErrorCodesIsNotDeclaredAsLet() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCodeExtension
            extension TestCode: ErrorCode {
                        
                private static var errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            }
            """,
            expandedSource: """
            extension TestCode: ErrorCode {
                        
                private static var errorCodes: [Self] = [
                    .value1,
                    .value2
                ]
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                public var opaqueCode: String {
                    switch self {
                    case .value1:
                        OpaqueCode.value1
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                public init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value1:
                        self = .value1

                    case OpaqueCode.value2:
                        self = .value2

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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.CaseParsing",
                        id: "shouldUseLetBindingSpecifierOnErrorCodesDeclaration"
                    ),
                    message: "\"errorCodes\" should be bound using \"let\".",
                    line: 4,
                    column: 5,
                    severity: .warning,
                    fixIts: [
                        .init(message: "Bind \"errorCodes\" using \"let\"")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
