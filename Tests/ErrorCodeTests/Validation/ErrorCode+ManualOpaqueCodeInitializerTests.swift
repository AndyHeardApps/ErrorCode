import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    "Manual opaqueCode initializer declaration",
    .enabled(if: MacroTesting.shared.isEnabled),
    .tags(.codeValidation)
)
struct ErrorCodeManualOpaqueCodeInitializerTests {
    
    @Test("Don't generate if valid initializer is manually declared")
    func dontGenerateIfValidInitializerIsManuallyDeclared() {
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
    
    @Test("Generate when other unrelated initializers are declared")
    func generateWhenOtherUnrelatedInitializersAreDeclared() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(otherParameter: Int) {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(otherParameter: Int) {
                    ""
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
    
    @Test("Warning and generate when declaration has incorrect parameter name")
    func warningAndGenerateWhenDeclarationHasIncorrectParameterName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueName: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueName: String) throws {
                    ""
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
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "incorrectParameterName"
                    ),
                    message: "Declaration has incorrect parameter name and does not satisfy \"ErrorCode\" protocol requirement. The default \"init(opaqueCode: _)\" initializer will still be generated and used by the macro.\n\nTo silence this warning, move this initializer in to an extension of this type.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning and generate when declaration has incorrect parameter type")
    func warningAndGenerateWhenDeclarationHasIncorrectParameterType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: Int) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: Int) throws {
                    ""
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
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "incorrectParameterType"
                    ),
                    message: "Declaration has incorrect parameter type and does not satisfy \"ErrorCode\" protocol requirement. The default \"init(opaqueCode: _)\" initializer will still be generated and used by the macro.\n\nTo silence this warning, move this initializer in to an extension of this type.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
}

// MARK: - Public error codes
extension ErrorCodeManualOpaqueCodeInitializerTests {
    
    @Suite("Public enum")
    struct PublicEnum {
        
        @Test("Don't generate for public initializer")
        func dontGenerateForPublicInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
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
            }
            """,
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for internal initializer")
        func errorAndDontGenerateForInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBePublic"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"public\".",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for explicit internal initializer")
        func errorAndDontGenerateForExplicitInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBePublic"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"public\".",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for fileprivate initializer")
        func errorAndDontGenerateForFileprivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBePublic"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"public\".",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for private initializer")
        func errorAndDontGenerateForPrivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBePublic"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"public\".",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Internal error codes
extension ErrorCodeManualOpaqueCodeInitializerTests {
    
    @Suite("Internal enum")
    struct InternalEnum {
        
        @Test("Don't generate for public initializer")
        func dontGenerateForPublicInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
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
        
        @Test("Don't generate for internal initializer")
        func dontGenerateForInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
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
        
        @Test("Don't generate for explicit internal initializer")
        func dontGenerateForExplicitInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
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
        
        @Test("Error and don't generate for fileprivate initializer")
        func errorAndDontGenerateForFileprivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBeInternal"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"init(opaqueCode: _)\" \"internal\""),
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for private initializer")
        func errorAndDontGenerateForPrivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBeInternal"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"init(opaqueCode: _)\" \"internal\""),
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Explicit internal error codes
extension ErrorCodeManualOpaqueCodeInitializerTests {
    
    @Suite("Explicit internal enum")
    struct ExplicitInternalEnum {
        
        @Test("Don't generate for public initializer")
        func dontGenerateForPublicInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
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
        
        @Test("Don't generate for internal initializer")
        func dontGenerateForInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
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
        
        @Test("Don't generate for explicit internal initializer")
        func dontGenerateForExplicitInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
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
        
        @Test("Error and don't generate for fileprivate initializer")
        func errorAndDontGenerateForFileprivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBeInternal"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"init(opaqueCode: _)\" \"internal\""),
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for private initializer")
        func errorAndDontGenerateForPrivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBeInternal"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"init(opaqueCode: _)\" \"internal\""),
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - File private error codes
extension ErrorCodeManualOpaqueCodeInitializerTests {
    
    @Suite("File private enum")
    struct FilePrivateEnum {
        
        @Test("Don't generate for public initializer")
        func dontGenerateForPublicInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate var opaqueCode: String {
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
        
        @Test("Don't generate for internal initializer")
        func dontGenerateForInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate var opaqueCode: String {
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
        
        @Test("Don't generate for explicit internal initializer")
        func dontGenerateForExplicitInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate var opaqueCode: String {
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
        
        @Test("Don't generate for explicit file private initializer")
        func dontGenerateForExplicitFilePrivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate var opaqueCode: String {
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
        
        @Test("Error and don't generate for explicit private initializer")
        func errorAndDontGenerateForExplicitPrivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBeFilePrivate"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"fileprivate\", \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"init(opaqueCode: _)\" \"fileprivate\""),
                        .init(message: "Make \"init(opaqueCode: _)\" \"internal\""),
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Private error codes
extension ErrorCodeManualOpaqueCodeInitializerTests {
    
    @Suite("Private enum")
    struct PrivateEnum {
        
        @Test("Don't generate for public initializer")
        func dontGenerateForPublicInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                public init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate var opaqueCode: String {
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
        
        @Test("Don't generate for internal initializer")
        func dontGenerateForInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate var opaqueCode: String {
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
        
        @Test("Don't generate for explicit internal initializer")
        func dontGenerateForExplicitInternalInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                internal init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate var opaqueCode: String {
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
        
        @Test("Don't generate for explicit file private initializer")
        func dontGenerateForExplicitFilePrivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                fileprivate init(opaqueCode: String) throws {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate var opaqueCode: String {
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
        
        @Test("Error and don't generate for explicit private initializer")
        func errorAndDontGenerateForExplicitPrivateInitializer() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                private init(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "needsToBeFilePrivate"
                    ),
                    message: "\"init(opaqueCode: _)\" needs to be declared as \"fileprivate\", \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"init(opaqueCode: _)\" \"fileprivate\""),
                        .init(message: "Make \"init(opaqueCode: _)\" \"internal\""),
                        .init(message: "Make \"init(opaqueCode: _)\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Effect specifiers
extension ErrorCodeManualOpaqueCodeInitializerTests {
    
    @Suite("Effect specifiers")
    struct EffectSpecifiers {
        
        @Test("Warning and generate when async")
        func warningAndGenerateWhenAsync() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) async {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) async {
                    ""
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
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and does not satisfy \"ErrorCode\" protocol requirement. The default \"init(opaqueCode: _)\" initializer will still be generated and used by the macro.\n\nTo silence this warning, move this initializer in to an extension of this type.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when async throwing")
        func warningAndGenerateWhenAsyncThrowing() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) async throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) async throws {
                    ""
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
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and does not satisfy \"ErrorCode\" protocol requirement. The default \"init(opaqueCode: _)\" initializer will still be generated and used by the macro.\n\nTo silence this warning, move this initializer in to an extension of this type.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Don't generate when throwing")
        func dontGenerateWhenThrowing() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init(opaqueCode: String) {
                    ""
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
                
        @Test("Error and don't generate when failable")
        func errorAndDontGenerateWhenFailable() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init?(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init?(opaqueCode: String) throws {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "incorrectFailableInitializer"
                    ),
                    message: "\"init(opaqueCode: _)\" should not be a failable initializer.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"?\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and generate when failable async")
        func warningAndGenerateWhenFailableAsync() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init?(opaqueCode: String) async {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init?(opaqueCode: String) async {
                    ""
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
                        domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and does not satisfy \"ErrorCode\" protocol requirement. The default \"init(opaqueCode: _)\" initializer will still be generated and used by the macro.\n\nTo silence this warning, move this initializer in to an extension of this type.",
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
