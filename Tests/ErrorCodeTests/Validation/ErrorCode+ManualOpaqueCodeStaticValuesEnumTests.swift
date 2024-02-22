import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ErrorCode_ManualCodeStaticValuesEnumTests: XCTestCase {
    
    func testErrorCode_willNotGenerateOpaqueCodeValues_andWillNotGenerateError_whenManuallyDeclared_asEnum() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                enum OpaqueCode {
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeValues_andWillNotGenerateError_whenManuallyDeclared_asStruct() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCode {
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeValues_andWillNotGenerateError_whenManuallyDeclared_asClass() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                class OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                class OpaqueCode {
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeValues_andWillNotGenerateError_whenManuallyDeclared_asActor() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                actor OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                actor OpaqueCode {
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCode_andWillGenerateError_whenNamingCollisionExists_butIsPropertyDeclaration() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                var OpaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2

                var OpaqueCode: String {
                    ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "opaqueCodeNamingCollision"
                    ),
                    message: "\"OpaqueCode\" has been declared on this type, but is not an \"enum\", \"struct\", \"class\" or \"actor\". Avoid naming collisions on this type, and declare \"OpaqueCode\" as one of the types mentioned.",
                    line: 6,
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
    
    func testErrorCode_willGenerateOpaqueCode_andWillNotGenerateError_whenNamingCollisionExists_butIsStaticPropertyDeclaration() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                static var OpaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2

                static var OpaqueCode: String {
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCode_andWillGenerateError_whenNamingCollisionExists_butIsFunctionDeclaration() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                func OpaqueCode() {}
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2

                func OpaqueCode() {}
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "opaqueCodeNamingCollision"
                    ),
                    message: "\"OpaqueCode\" has been declared on this type, but is not an \"enum\", \"struct\", \"class\" or \"actor\". Avoid naming collisions on this type, and declare \"OpaqueCode\" as one of the types mentioned.",
                    line: 6,
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
    
    func testErrorCode_willNotGenerateOpaqueCode_andWillGenerateError_whenOpaqueCode_isMissingCase() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
                case value3
            
                enum OpaqueCode {
                    static let value1 = ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
                case value3

                enum OpaqueCode {
                    static let value1 = ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "missingManualOpaqueCodes"
                    ),
                    message: "No variable for enum case \"value2\", \"value3\". \"OpaqueCode\" must have one static String variable to match each enum case.",
                    line: 7,
                    column: 21,
                    severity: .error,
                    fixIts: [
                        .init(message: "Add missing cases")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCode_andWillGenerateError_whenOpaqueCode_isNotDeclaredAsStatic() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
            
                struct OpaqueCode {
                    let value1 = ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1

                struct OpaqueCode {
                    let value1 = ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "manualOpaqueCodeIsNotDeclaredAsStaticLet"
                    ),
                    message: "\"OpaqueCode\" for \"value1\" must be declared as a \"static let\" property.",
                    line: 6,
                    column: 9,
                    severity: .error,
                    fixIts: [
                        .init(message: "Change declaration to \"static let\"")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCode_andWillGenerateError_whenOpaqueCode_isNotDeclaredAsLet() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
            
                struct OpaqueCode {
                    static var value1 = ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1

                struct OpaqueCode {
                    static var value1 = ""
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "manualOpaqueCodeIsNotDeclaredAsStaticLet"
                    ),
                    message: "\"OpaqueCode\" for \"value1\" must be declared as a \"static let\" property.",
                    line: 6,
                    column: 9,
                    severity: .error,
                    fixIts: [
                        .init(message: "Change declaration to \"static let\"")
                    ]
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCode_andWillGenerateError_whenOpaqueCode_isNotDeclaredAsStringLiteral() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
            
                struct OpaqueCode {
                    static let value1: String = { "" }
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1

                struct OpaqueCode {
                    static let value1: String = { "" }
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "manualOpaqueCodeIsNotStringLiteral"
                    ),
                    message: "\"OpaqueCode\" for \"value1\" must be declared as a static string literal.",
                    line: 6,
                    column: 37,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCode_andWillGenerateError_whenDuplicateOpaqueCodesExist() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCode {
                    static let value1 = "1"
                    static let value2 = "1"
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCode {
                    static let value1 = "1"
                    static let value2 = "1"
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "duplicateManualOpaqueCode"
                    ),
                    message: "\"OpaqueCode\" must each have a unique value. \"value1\" has a duplicate value \"1\".",
                    line: 6,
                    column: 23,
                    severity: .error
                ),
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "duplicateManualOpaqueCode"
                    ),
                    message: "\"OpaqueCode\" must each have a unique value. \"value2\" has a duplicate value \"1\".",
                    line: 6,
                    column: 23,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willIgnoreUnrelatedDeclarations() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCode {
                    static let value1 = "1"
                    static let value2 = "2"
            
                    func someFunction() {}
                    var someProperty: Int { 0 }
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2

                struct OpaqueCode {
                    static let value1 = "1"
                    static let value2 = "2"

                    func someFunction() {}
                    var someProperty: Int { 0 }
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCode_andWillGenerateError_whenOpaqueCode_hasNoInitializer() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCode {
                    static let value1 = "1"
                    static let value2: String
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                struct OpaqueCode {
                    static let value1 = "1"
                    static let value2: String
                }
            }
            """,
            diagnostics: [
                .init(
                    id: .init(
                        domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
                        id: "manualOpaqueCodeIsMissingInitializer"
                    ),
                    message: "\"OpaqueCode\" for \"value2\" has no initializer, but must be declared as a static string literal.",
                    line: 8,
                    column: 20,
                    severity: .error
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
