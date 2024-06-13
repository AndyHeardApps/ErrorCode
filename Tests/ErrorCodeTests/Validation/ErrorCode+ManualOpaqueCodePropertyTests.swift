import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    "Manual opaqueCode property declaration",
    .enabled(if: MacroTesting.shared.isEnabled),
    .tags(.codeValidation)
)
struct ErrorCodeManualOpaqueCodePropertyTests {
    
    // MARK: - Opaque code property
    @Test("Don't generate if valid property is manually declared")
    func dontGenerateIfValidInitializerIsManuallyDeclared() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
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
    
    @Test("Warning and don't generate when declaration has incorrect type")
    func warningAndDontGenerateWhenDeclarationHasIncorrectType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: Int {
                    0
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: Int {
                    0
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBeStringType"
                    ),
                    message: "\"opaqueCode\" should be of type \"String\".",
                    line: 6,
                    column: 19,
                    severity: .error,
                    fixIts: [
                        .init(message: "Change \"opaqueCode\" type to \"String\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
}

// MARK: - Public error codes
extension ErrorCodeManualOpaqueCodePropertyTests {
    
    @Suite("Public enum")
    struct PublicEnum {

        @Test("Don't generate for public property")
        func dontGenerateForPublicProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
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
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for internal property")
        func errorAndDontGenerateForInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBePublic"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"public\".",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for explicit internal property")
        func errorAndDontGenerateForExplicitInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBePublic"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"public\".",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for fileprivate property")
        func errorAndDontGenerateForFileprivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBePublic"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"public\".",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for private property")
        func errorAndDontGenerateForPrivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            public enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            public enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBePublic"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"public\".",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Internal error codes
extension ErrorCodeManualOpaqueCodePropertyTests {
    
    @Suite("Internal enum")
    struct InternalEnum {
        
        @Test("Don't generate for public property")
        func dontGenerateForPublicProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
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
        
        @Test("Don't generate for internal property")
        func dontGenerateForInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
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
        
        @Test("Don't generate for explicit internal property")
        func dontGenerateForExplicitInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
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
        
        @Test("Error and don't generate for fileprivate property")
        func errorAndDontGenerateForFileprivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBeInternal"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"opaqueCode\" \"internal\""),
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for private property")
        func errorAndDontGenerateForPrivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBeInternal"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"opaqueCode\" \"internal\""),
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}
 
// MARK: - Explicit internal error codes
extension ErrorCodeManualOpaqueCodePropertyTests {
    
    @Suite("Explicit internal enum")
    struct ExplicitInternalEnum {
        
        @Test("Don't generate for public property")
        func dontGenerateForPublicProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
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
        
        @Test("Don't generate for internal property")
        func dontGenerateForInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
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
        
        @Test("Don't generate for explicit internal property")
        func dontGenerateForExplicitInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
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
        
        @Test("Error and don't generate for fileprivate property")
        func errorAndDontGenerateForFileprivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBeInternal"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"opaqueCode\" \"internal\""),
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Error and don't generate for private property")
        func errorAndDontGenerateForPrivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            internal enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            internal enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBeInternal"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"opaqueCode\" \"internal\""),
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}
 
// MARK: - File private error codes
extension ErrorCodeManualOpaqueCodePropertyTests {
    
    @Suite("File private enum")
    struct FilePrivateEnum {
       
        @Test("Don't generate for public property")
        func dontGenerateForPublicProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate init(opaqueCode: String) throws {
            
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
        
        @Test("Don't generate for internal property")
        func dontGenerateForInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate init(opaqueCode: String) throws {
            
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
        
        @Test("Don't generate for explicit internal property")
        func dontGenerateForExplicitInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate init(opaqueCode: String) throws {
            
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
        
        @Test("Don't generate for explicit file private property")
        func dontGenerateForExplicitFilePrivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate init(opaqueCode: String) throws {
            
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
        
        @Test("Error and don't generate for explicit private property")
        func errorAndDontGenerateForExplicitPrivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            fileprivate enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            fileprivate enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBeFilePrivate"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"fileprivate\", \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"opaqueCode\" \"fileprivate\""),
                        .init(message: "Make \"opaqueCode\" \"internal\""),
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}

// MARK: - Private error codes
extension ErrorCodeManualOpaqueCodePropertyTests {
    
    @Suite("Private enum")
    struct PrivateEnum {

        @Test("Don't generate for public property")
        func dontGenerateForPublicProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                public var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate init(opaqueCode: String) throws {
            
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
        
        @Test("Don't generate for internal property")
        func dontGenerateForInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate init(opaqueCode: String) throws {
            
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
        
        @Test("Don't generate for explicit internal property")
        func dontGenerateForExplicitInternalProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                internal var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate init(opaqueCode: String) throws {
            
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
        
        @Test("Don't generate for explicit file private property")
        func dontGenerateForExplicitFilePrivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                fileprivate var opaqueCode: String {
                    ""
                }
            }
            
            extension TestCode: ErrorCode {
            
                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            
                fileprivate init(opaqueCode: String) throws {
            
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
        
        @Test("Error and don't generate for explicit private property")
        func errorAndDontGenerateForExplicitPrivateProperty() {
            assertMacroExpansion(
            """
            @ErrorCode
            private enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            private enum TestCode {
                case value1
                case value2
            
                private var opaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "needsToBeFilePrivate"
                    ),
                    message: "\"opaqueCode\" needs to be declared as \"fileprivate\", \"internal\", \"public\", or with no access modifier.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove access modifier"),
                        .init(message: "Make \"opaqueCode\" \"fileprivate\""),
                        .init(message: "Make \"opaqueCode\" \"internal\""),
                        .init(message: "Make \"opaqueCode\" \"public\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}
    
// MARK: - Effect modifiers
extension ErrorCodeManualOpaqueCodePropertyTests {
    
    @Suite("Effect specifiers")
    struct EffectSpecifiers {
        
        @Test("Warning and don't generate when async")
        func warningAndDontGenerateWhenAsync() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    get async {
                        ""
                    }
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    get async {
                        ""
                    }
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "\"opaqueCode\" should not have an async getter.",
                    line: 7,
                    column: 13,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"async\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and don't generate when throwing")
        func warningAndDontGenerateWhenThrowing() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    get throws {
                        ""
                    }
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    get throws {
                        ""
                    }
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "incorrectThrowingDeclaration"
                    ),
                    message: "\"opaqueCode\" should not have a throwing getter.",
                    line: 7,
                    column: 13,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"throws\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
        
        @Test("Warning and don't generate when async throwing")
        func warningAndDontGenerateWhenAsyncThrowing() {
            assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    get async throws {
                        ""
                    }
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                var opaqueCode: String {
                    get async throws {
                        ""
                    }
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
                        id: "incorrectAsyncThrowingDeclaration"
                    ),
                    message: "\"opaqueCode\" should not have an async throwing getter.",
                    line: 7,
                    column: 13,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"async throws\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
            )
        }
    }
}
