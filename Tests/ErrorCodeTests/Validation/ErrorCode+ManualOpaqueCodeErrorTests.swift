import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    "Manual OpaqueCodeError declaration",
    .enabled(if: MacroTesting.shared.isEnabled),
    .tags(.codeValidation)
)
struct ErrorCodeManualOpaqueCodeErrorTests {
    
    @Test("Don't generate if valid OpaqueErrorCode type is manually declared")
    func dontGenerateIfValidOpaqueErrorCodeTypeIsManuallyDeclared() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                private enum OpaqueCodeError: OpaqueCodeInitializerError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                private enum OpaqueCodeError: OpaqueCodeInitializerError {
                }
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
            }
            """,
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Don't generate if valid opaqueCode initializer is manually declared")
    func dontGenerateIfValidOpaqueCodeInitializerIsManuallyDeclared() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                }
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
            }
            """,
            macros: MacroTesting.shared.testMacros
        )
    }
}

// MARK: - Enum declaration
extension ErrorCodeManualOpaqueCodeErrorTests {
    
    @Suite("Enum declaration")
    struct EnumDeclaration {
        
        @Test("Error and don't generate when manual OpaqueCodeError declaration has no inheritence clause")
        func errorAndDontGenerateWhenManualDeclarationHasNoInheritenceClause() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                enum OpaqueCodeError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                enum OpaqueCodeError {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
                    ),
                    message: "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add conformance to \"OpaqueCodeInitializerError\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate when manual OpaqueCodeError declaration has incorrect inheritence clause")
        func errorAndDontGenerateWhenManualDeclarationHasIncorrectInheritenceClause() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                enum OpaqueCodeError: Sendable {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                enum OpaqueCodeError: Sendable {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
                    ),
                    message: "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add conformance to \"OpaqueCodeInitializerError\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and don't generate when manual OpaqueCodeError declaration has unnecessary OpaqueCodeInitializerError conformance")
        func warningAndDontGenerateWhenManualOpaqueCodeDeclarationHasUnnecessaryOpaqueCodeInitializerErrorConformance() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                }
            
                enum OpaqueCodeError: OpaqueCodeInitializerError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                }
            
                enum OpaqueCodeError: OpaqueCodeInitializerError {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "unnecessaryOpaqueCodeInitializerErrorConformanceDetected"
                    ),
                    message: "Unnecessary conformance to \"unnecessaryOpaqueCodeInitializerErrorConformanceDetected\". This is only required when the \"init(opaqueCode: _)\" initializer is automatically synthesized, and a custom \"OpaqueCodeError\" is declared. Declaring your own \"init(opaqueCode: _)\" initializer means the functionality provided by the protocol is no longer required. To silence this warning and keep the conformance, move the conformance declaration to an extension of this type.",
                    line: 9,
                    column: 5,
                    severity: .warning,
                    fixIts: [
                        .init(message: "Replace conformance to \"OpaqueCodeInitializerError\" with \"Error\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Struct declaration
extension ErrorCodeManualOpaqueCodeErrorTests {
    
    @Suite("Struct declaration")
    struct StructDeclaration {
        
        @Test("Error and don't generate when manual OpaqueCodeError declaration has no inheritence clause")
        func errorAndDontGenerateWhenManualDeclarationHasNoInheritenceClause() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCodeError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCodeError {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
                    ),
                    message: "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add conformance to \"OpaqueCodeInitializerError\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate when manual OpaqueCodeError declaration has incorrect inheritence clause")
        func errorAndDontGenerateWhenManualDeclarationHasIncorrectInheritenceClause() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCodeError: Sendable {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCodeError: Sendable {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
                    ),
                    message: "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add conformance to \"OpaqueCodeInitializerError\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and don't generate when manual OpaqueCodeError declaration has unnecessary OpaqueCodeInitializerError conformance")
        func warningAndDontGenerateWhenManualOpaqueCodeDeclarationHasUnnecessaryOpaqueCodeInitializerErrorConformance() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                }
            
                struct OpaqueCodeError: OpaqueCodeInitializerError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                }
            
                struct OpaqueCodeError: OpaqueCodeInitializerError {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "unnecessaryOpaqueCodeInitializerErrorConformanceDetected"
                    ),
                    message: "Unnecessary conformance to \"unnecessaryOpaqueCodeInitializerErrorConformanceDetected\". This is only required when the \"init(opaqueCode: _)\" initializer is automatically synthesized, and a custom \"OpaqueCodeError\" is declared. Declaring your own \"init(opaqueCode: _)\" initializer means the functionality provided by the protocol is no longer required. To silence this warning and keep the conformance, move the conformance declaration to an extension of this type.",
                    line: 9,
                    column: 5,
                    severity: .warning,
                    fixIts: [
                        .init(message: "Replace conformance to \"OpaqueCodeInitializerError\" with \"Error\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Class declaration
extension ErrorCodeManualOpaqueCodeErrorTests {
    
    @Suite("Class declaration")
    struct ClassDeclaration {
        
        @Test("Error and don't generate when manual OpaqueCodeError declaration has no inheritence clause")
        func errorAndDontGenerateWhenManualDeclarationHasNoInheritenceClause() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                class OpaqueCodeError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                class OpaqueCodeError {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
                    ),
                    message: "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add conformance to \"OpaqueCodeInitializerError\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate when manual OpaqueCodeError declaration has incorrect inheritence clause")
        func errorAndDontGenerateWhenManualDeclarationHasIncorrectInheritenceClause() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                class OpaqueCodeError: Sendable {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                class OpaqueCodeError: Sendable {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
                    ),
                    message: "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add conformance to \"OpaqueCodeInitializerError\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and don't generate when manual OpaqueCodeError declaration has unnecessary OpaqueCodeInitializerError conformance")
        func warningAndDontGenerateWhenManualOpaqueCodeDeclarationHasUnnecessaryOpaqueCodeInitializerErrorConformance() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                }
            
                class OpaqueCodeError: OpaqueCodeInitializerError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                }
            
                class OpaqueCodeError: OpaqueCodeInitializerError {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "unnecessaryOpaqueCodeInitializerErrorConformanceDetected"
                    ),
                    message: "Unnecessary conformance to \"unnecessaryOpaqueCodeInitializerErrorConformanceDetected\". This is only required when the \"init(opaqueCode: _)\" initializer is automatically synthesized, and a custom \"OpaqueCodeError\" is declared. Declaring your own \"init(opaqueCode: _)\" initializer means the functionality provided by the protocol is no longer required. To silence this warning and keep the conformance, move the conformance declaration to an extension of this type.",
                    line: 9,
                    column: 5,
                    severity: .warning,
                    fixIts: [
                        .init(message: "Replace conformance to \"OpaqueCodeInitializerError\" with \"Error\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Actor declaration
extension ErrorCodeManualOpaqueCodeErrorTests {
    
    @Suite("Actor declaration")
    struct ActorDeclaration {
        
        @Test("Error and don't generate when manual OpaqueCodeError declaration has no inheritence clause")
        func errorAndDontGenerateWhenManualDeclarationHasNoInheritenceClause() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                actor OpaqueCodeError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                actor OpaqueCodeError {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
                    ),
                    message: "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add conformance to \"OpaqueCodeInitializerError\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate when manual OpaqueCodeError declaration has incorrect inheritence clause")
        func errorAndDontGenerateWhenManualDeclarationHasIncorrectInheritenceClause() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                actor OpaqueCodeError: Sendable {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                actor OpaqueCodeError: Sendable {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
                    ),
                    message: "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add conformance to \"OpaqueCodeInitializerError\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and don't generate when manual OpaqueCodeError declaration has unnecessary OpaqueCodeInitializerError conformance")
        func warningAndDontGenerateWhenManualOpaqueCodeDeclarationHasUnnecessaryOpaqueCodeInitializerErrorConformance() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                }
            
                actor OpaqueCodeError: Sendable, OpaqueCodeInitializerError {
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                }
            
                actor OpaqueCodeError: Sendable, OpaqueCodeInitializerError {
                }
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
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
                        id: "unnecessaryOpaqueCodeInitializerErrorConformanceDetected"
                    ),
                    message: "Unnecessary conformance to \"unnecessaryOpaqueCodeInitializerErrorConformanceDetected\". This is only required when the \"init(opaqueCode: _)\" initializer is automatically synthesized, and a custom \"OpaqueCodeError\" is declared. Declaring your own \"init(opaqueCode: _)\" initializer means the functionality provided by the protocol is no longer required. To silence this warning and keep the conformance, move the conformance declaration to an extension of this type.",
                    line: 9,
                    column: 5,
                    severity: .warning,
                    fixIts: [
                        .init(message: "Replace conformance to \"OpaqueCodeInitializerError\" with \"Error\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}
