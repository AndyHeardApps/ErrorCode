import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    "Extension expansion",
    .enabled(if: MacroTesting.shared.isEnabled),
    .tags(.codeGeneration)
)
struct ErrorCodeExtensionTests {
    
    @Test("Un-nested extension")
    func unnested() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Error when applied to non-extension declaration")
    func errorWhenAppliedToNonExtensionDeclaration() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning when opaque codes are manually declared alongside code length parameter")
    func warningWhenOpaqueCodesAreManuallyDeclaredAlongsideCodeLengthParameter() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning when opaque codes are manually declared alongside code characters parameter")
    func warningWhenOpaqueCodesAreManuallyDeclaredAlongsideCodeCharactersParameter() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning when error code conformance is not manually declared")
    func warningWhenErrorCodeConformanceIsNotManuallyDeclared() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Error when errorCodes not declared")
    func errorWhenErrorCodesNotDeclared() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Error when nested errorCodes are declared")
    func errorWhenNestedErrorCodesAreDeclared() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Ignore other declarations")
    func ignoreOtherDeclarations() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Error when errorCodes contains too many bindings")
    func errorWhenErrorCodesContainsTooManyBindings() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Error when errorCodes has incorrect type annotation")
    func errorWhenErrorCodesHasIncorrectTypeAnnotation() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Error when errorCodes has no initializer")
    func errorWhenErrorCodesHasNoInitializer() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning when errorCodes is not declared as private")
    func warningWhenErrorCodesIsNotDeclaredAsPrivate() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
    
    @Test("Warning when errorCodes is not declared as let")
    func warningWhenErrorCodesIsNotDeclaredAsLet() {
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
            macros: MacroTesting.shared.testMacros
        )
    }
}
