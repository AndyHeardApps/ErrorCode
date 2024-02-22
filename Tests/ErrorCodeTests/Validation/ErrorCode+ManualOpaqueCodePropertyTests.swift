import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ErrorCode_ManualOpaqueCodePropertyTests: XCTestCase {
    
    // MARK: - Opaque code property
    func testErrorCode_willNotGenerateOpaqueCodeProperty_whenManualOpaqueCodePropertyDeclaration_isValid() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // MARK: - Public error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsPublic() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsPublic() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsPublic() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsPublic() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsPublic() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Internal error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsInernal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Explicit internal error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsExplicitInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsExplicitInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsExplicitInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsExplicitInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsExplicitInternal() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - File private error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsFilePrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsFilePrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsFilePrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsFilePrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsFilePrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Private error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsPrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsPrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsPrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsPrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsPrivate() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    // MARK: - Property type
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclaration_hasIncorrectPropertyType() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    // MARK: - Effect modifiers
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclaration_isValid_butHasAsyncGetter() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclaration_isValid_butHasThrowingGetter() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclaration_isValid_butHasAsyncThrowingGetter() throws {
        #if canImport(ErrorCodeMacros)
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
