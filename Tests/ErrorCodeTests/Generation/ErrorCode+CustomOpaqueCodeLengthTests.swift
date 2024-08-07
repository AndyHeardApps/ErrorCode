import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    "Custom opaque code length",
    .enabled(if: MacroTesting.shared.isEnabled),
    .tags(.codeGeneration)
)
struct ErrorCodeCustomOpaqueCodeLengthTests {

    @Test("Respects custom value")
    func respectsCustomValue() {
        assertMacroExpansion(
            """
            @ErrorCode(codeLength: 6)
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
                    static let value1 = "Bc9gnG"
                    static let value2 = "aDkHCf"
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning and use default value when provided as expression")
    func warningAndUseDefaultValueWhenProvidedAsExpression() {
        assertMacroExpansion(
            """
            @ErrorCode(codeLength: 4 + 4)
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeLengthParsing",
                        id: "invalidCodeLengthParameter"
                    ),
                    message: "\"codeLength\" parameter must be provided as a single positive Integer literal expression. Expressions, parameters and function calls will be ignored and result in the default code length being used.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning and use default value when provided as function")
    func warningAndUseDefaultValueWhenProvidedAsFunction() {
        assertMacroExpansion(
            """
            @ErrorCode(codeLength: codeLength())
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeLengthParsing",
                        id: "invalidCodeLengthParameter"
                    ),
                    message: "\"codeLength\" parameter must be provided as a single positive Integer literal expression. Expressions, parameters and function calls will be ignored and result in the default code length being used.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    @Test("Warning and use default value when provided as non integer literal")
    func warningAndUseDefaultValueWhenProvidedAsNonIntegerLiteral() {
        assertMacroExpansion(
            """
            @ErrorCode(codeLength: "6")
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeLengthParsing",
                        id: "invalidCodeLengthParameter"
                    ),
                    message: "\"codeLength\" parameter must be provided as a single positive Integer literal expression. Expressions, parameters and function calls will be ignored and result in the default code length being used.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning and use default value when provided as negative integer literal")
    func warningAndUseDefaultValueWhenProvidedAsNegativeIntegerLiteral() {
        assertMacroExpansion(
            """
            @ErrorCode(codeLength: -1)
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeLengthParsing",
                        id: "invalidCodeLengthParameter"
                    ),
                    message: "\"codeLength\" parameter must be provided as a single positive Integer literal expression. Expressions, parameters and function calls will be ignored and result in the default code length being used.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    @Test("Warning and use value of one when provided as zero")
    func warningAndUseValueOfOneWhenProvidedAsZero() {
        assertMacroExpansion(
            """
            @ErrorCode(codeLength: 0)
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
                    static let value1 = "6"
                    static let value2 = "V"
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
                        domain: "ErrorCodeMacro.CustomOpaqueCodeLengthParsing",
                        id: "cannotUseZeroForOpaqueCodeLengthParameter"
                    ),
                    message: "\"codeLength\" parameter cannot be \"0\". A value of \"1\" will be used instead.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
}
