import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    "Enum expansion",
    .enabled(if: MacroTesting.shared.isEnabled),
    .tags(.codeGeneration)
)
struct ErrorCodeEnumTests {

    @Test("Un-nested enum")
    func unnested() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Different codes for same case names in different types")
    func differentCodesForSameCaseNamesInDifferentTypes() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Error when applied to non-enum declaration")
    func errorWhenAppliedToNonEnumDeclaration() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Error when colliding codes are generated")
    func errorWhenCollidingCodesAreGenerated() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning when opaque codes are manually declared alongside code length parameter")
    func warningWhenOpaqueCodesAreManuallyDeclaredAlongSideCodeLengthParameter() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning when opaque codes are manually declared alongside code characters parameter")
    func warningWhenOpaqueCodesAreManuallyDeclaredAlongsideCodeCharactersParameter() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning when opaque code initializer and property are manually declared alongside code delimiter parameter")
    func warningWhenOpaqueCodeInitializerAndPropertyAreManuallyDeclaredAlongsideCodeDelimiterParameter() {
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
            macros: MacroTesting.shared.testMacros
        )
    }

    @Test("Warning when enum with no nested cases is declared alongside delimiter parameter")
    func warningWhenEnumWithNoNestedCasesIsDeclaredAlongsideDelimiterParameter() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
}
