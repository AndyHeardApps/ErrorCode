import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ErrorCode_ManualOpaqueCodePropertyTests: XCTestCase {
    
    // MARK: - Opaque code property
    func testErrorCode_willNotGenerateOpaqueCodeProperty_whenManualOpaqueCodePropertyDeclaration_isValid() {
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
    
    // MARK: - Public error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsPublic() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsPublic() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsPublic() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsPublic() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsPublic() {
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

    // MARK: - Internal error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsInernal() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsInternal() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsInternal() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsInternal() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsInternal() {
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

    // MARK: - Explicit internal error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsExplicitInternal() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsExplicitInternal() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsExplicitInternal() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsExplicitInternal() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsExplicitInternal() {
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

    // MARK: - File private error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsFilePrivate() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsFilePrivate() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsFilePrivate() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsFilePrivate() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsFilePrivate() {
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

    // MARK: - Private error codes
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsPublic_andContainingEnumIsPrivate() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsInternal_andContainingEnumIsPrivate() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsExplicitInternal_andContainingEnumIsPrivate() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillNotGenerateError_whenManualOpaqueCodePropertyDeclarationIsFilePrivate_andContainingEnumIsPrivate() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclarationIsPrivate_andContainingEnumIsPrivate() {
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

    // MARK: - Property type
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclaration_hasIncorrectPropertyType() {
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
    
    // MARK: - Effect modifiers
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclaration_isValid_butHasAsyncGetter() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclaration_isValid_butHasThrowingGetter() {
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

    func testErrorCode_willNotGenerateOpaqueCodeProperty_andWillGenerateError_whenManualOpaqueCodePropertyDeclaration_isValid_butHasAsyncThrowingGetter() {
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
