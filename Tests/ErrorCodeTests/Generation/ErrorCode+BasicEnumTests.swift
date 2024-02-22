import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ErrorCodeMacros)
import ErrorCodeMacros

let testMacros: [String: Macro.Type] = [
    "ErrorCode": ErrorCodeMacro.self,
]
#endif

final class ErrorCode_BasicEnumTests: XCTestCase {

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
}
