import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    "Manual childErrorCode function",
    .enabled(if: MacroTesting.shared.isEnabled),
    .tags(.codeValidation)
)
struct ErrorCodeManualChildErrorCodeFunctionTests {}

// MARK: - Manual initializer
extension ErrorCodeManualChildErrorCodeFunctionTests {
    
    @Suite("Manual initializer")
    struct OpaqueCodeProperty {
        
        @Test("Don't generate if valid initializer is manually declared")
        func dontGenerateIfValidInitializerIsManuallyDeclared() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                init(opaqueCode: String) throws {
                    self = .value2
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                init(opaqueCode: String) throws {
                    self = .value2
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
                    }
                }
            
                private func childOpaqueCode(for errorCode: some ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Generic
extension ErrorCodeManualChildErrorCodeFunctionTests {
    
    @Suite("Generic function")
    struct Generic {
        
        @Test("Don't generate if valid function is manually declared")
        func dontGenerateIfValidGenericFunctionIsManuallyDeclared() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
                    default:
                        throw OpaqueCodeError.unrecognizedOpaqueCode(String(firstComponent))
            
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
        
        @Test("Don't generate if valid generic, non-throwing function is manually declared")
        func dontGenerateIfValidGenericNonThrowingFunctionIsManuallyDeclared() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
                    default:
                        throw OpaqueCodeError.unrecognizedOpaqueCode(String(firstComponent))
            
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
        
        @Test("Warning and generate when manual function declaration is async")
        func warningAndGenerateWhenManualFunctionDeclarationIsAsync() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) async -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) async -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration is async throwing")
        func warningAndGenerateWhenManualFunctionDeclarationIsAsyncThrowing() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) async throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) async throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Generate when manual function declaration has incorrect parameter count")
        func generateWhenManualFunctionDeclarationHasIncorrectParameterCount() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String, other: Int) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String, other: Int) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect function name")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectFunctionName() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorName<E: ErrorCode>(for opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorName<E: ErrorCode>(for opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectFunctionName"
                    ),
                    message: "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect generic inheritance clause type")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectGenericInheritanceClauseType() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E: Error>(for opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E: Error>(for opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectGenericParameterInheritedType"
                    ),
                    message: "Declaration has incorrect generic type constraint and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect parameter name")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectParameterName() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E: ErrorCode>(on opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E: ErrorCode>(on opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectParameterName"
                    ),
                    message: "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect parameter type")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectParameterType() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E: ErrorCode>(for opaqueCode: Int) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E: ErrorCode>(for opaqueCode: Int) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectParameterType"
                    ),
                    message: "Declaration has incorrect parameter type and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect return type")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectReturnType() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) throws -> Int {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E: ErrorCode>(for opaqueCode: String) throws -> Int {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectReturnType"
                    ),
                    message: "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration is not static")
        func warningAndGenerateWhenManualFunctionDeclarationIsNotStatic() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                func childErrorCode<E: ErrorCode>(for opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                func childErrorCode<E: ErrorCode>(for opaqueCode: String) throws -> E {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "functionIsNotStatic"
                    ),
                    message: "Declaration is not static and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Generic where clause
extension ErrorCodeManualChildErrorCodeFunctionTests {
    
    @Suite("Generic where")
    struct GenericWhere {
        
        @Test("Don't generate if valid function is manually declared")
        func dontGenerateIfValidGenericFunctionIsManuallyDeclared() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
                    default:
                        throw OpaqueCodeError.unrecognizedOpaqueCode(String(firstComponent))
            
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
        
        @Test("Don't generate if valid generic, non-throwing function is manually declared")
        func dontGenerateIfValidGenericNonThrowingFunctionIsManuallyDeclared() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E>(for opaqueCode: String) -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E>(for opaqueCode: String) -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
                    default:
                        throw OpaqueCodeError.unrecognizedOpaqueCode(String(firstComponent))
            
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
        
        @Test("Warning and generate when manual function declaration is async")
        func warningAndGenerateWhenManualFunctionDeclarationIsAsync() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String) async -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String) async -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration is async throwing")
        func warningAndGenerateWhenManualFunctionDeclarationIsAsyncThrowing() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String) async throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String) async throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Generate when manual function declaration has incorrect parameter count")
        func generateWhenManualFunctionDeclarationHasIncorrectParameterCount() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String, other: Int) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String, other: Int) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect function name")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectFunctionName() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorName<E>(for opaqueCode: String) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorName<E>(for opaqueCode: String) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectFunctionName"
                    ),
                    message: "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect generic inheritance clause type")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectGenericInheritanceClauseType() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E>(for opaqueCode: String) throws -> E where E: Error {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E>(for opaqueCode: String) throws -> E where E: Error {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectWhereRequirementInheritedType"
                    ),
                    message: "Declaration has incorrect generic type constraint and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect parameter name")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectParameterName() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E>(on opaqueCode: String) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E>(on opaqueCode: String) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectParameterName"
                    ),
                    message: "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect parameter type")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectParameterType() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E>(for opaqueCode: Int) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
                
                static func childErrorCode<E>(for opaqueCode: Int) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectParameterType"
                    ),
                    message: "Declaration has incorrect parameter type and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration has incorrect return type")
        func warningAndGenerateWhenManualFunctionDeclarationHasIncorrectReturnType() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String) throws -> Int where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                static func childErrorCode<E>(for opaqueCode: String) throws -> Int where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "incorrectReturnType"
                    ),
                    message: "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when manual function declaration is not static")
        func warningAndGenerateWhenManualFunctionDeclarationIsNotStatic() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2
            
                func childErrorCode<E>(for opaqueCode: String) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2
            
                func childErrorCode<E>(for opaqueCode: String) throws -> E where E: ErrorCode {
                    try E(opaqueCode: opaqueCode)
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "-" + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
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
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: "-")
                        self = try .value1(Self.childErrorCode(for: remainingComponents))
            
                    case OpaqueCode.value2:
                        guard components.isEmpty else {
                            throw OpaqueCodeError.unusedOpaqueCodeComponents(components.map(String.init))
                        }
                        self = .value2
            
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
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
                        id: "functionIsNotStatic"
                    ),
                    message: "Declaration is not static and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}
