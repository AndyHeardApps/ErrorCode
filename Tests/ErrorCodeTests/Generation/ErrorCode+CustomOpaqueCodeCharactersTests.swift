import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ErrorCode_CustomOpaqueCodeCharactersTests: XCTestCase {

    func testErrorCode_willRespectCustomCustomOpaqueCodeCharacters() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeCharacters: "123456")
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
                    static let value1 = "4565"
                    static let value2 = "1232"
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
    
    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomCustomOpaqueCodeCharacters_isProvidedAsExpression() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeCharacters: "123" + "456")
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeCharactersParsing",
                        id: "invalidOpaqueCodeCharactersParameter"
                    ),
                    message: "\"codeCharacters\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default characters being used.",
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
    
    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomCustomOpaqueCodeCharacters_isProvidedAsFunction() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeCharacters: codeCharacters())
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeCharactersParsing",
                        id: "invalidOpaqueCodeCharactersParameter"
                    ),
                    message: "\"codeCharacters\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default characters being used.",
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

    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomCustomOpaqueCodeCharacters_isProvidedAsNonStringLiteral() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeCharacters: 123456)
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeCharactersParsing",
                        id: "invalidOpaqueCodeCharactersParameter"
                    ),
                    message: "\"codeCharacters\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default characters being used.",
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
    
    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomCustomOpaqueCodeCharacters_isProvidedAsEmptyStringLiteral() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeCharacters: "")
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeCharactersParsing",
                        id: "notEnoughOpaqueCodeCharacters"
                    ),
                    message: "\"codeCharacters\" parameter must contain at least 5 unique characters.",
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
    
    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomCustomOpaqueCodeCharacters_isHasTooFewUniqueCharacters() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(codeCharacters: "1111111111")
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeCharactersParsing",
                        id: "notEnoughOpaqueCodeCharacters"
                    ),
                    message: "\"codeCharacters\" parameter must contain at least 5 unique characters.",
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
