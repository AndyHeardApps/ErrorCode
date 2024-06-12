import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ErrorCode_ManualOpaqueCodeInitializerTests: XCTestCase {
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_whenManualOpaqueCodeInitializerDeclaration_isValid() {
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
    
    // MARK: - Public error codes
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPublic_andContainingEnumIsPublic() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsInternal_andContainingEnumIsPublic() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsExplicitInternal_andContainingEnumIsPublic() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsFilePrivate_andContainingEnumIsPublic() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPrivate_andContainingEnumIsPublic() {
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
    
    // MARK: - Internal error codes
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPublic_andContainingEnumIsInternal() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsInternal_andContainingEnumIsInternal() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsExplicitInternal_andContainingEnumIsInternal() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsFilePrivate_andContainingEnumIsInternal() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPrivate_andContainingEnumIsInternal() {
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

    // MARK: - Explicit internal error codes
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPublic_andContainingEnumIsExplicitInternal() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsInternal_andContainingEnumIsExplicitInternal() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsExplicitInternal_andContainingEnumIsExpliitlyInternal() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsFilePrivate_andContainingEnumIsExplicitInternal() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPrivate_andContainingEnumIsExplicitInternal() {
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

    // MARK: - File private error codes
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPublic_andContainingEnumIsFilePrivate() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsInternal_andContainingEnumIsFilePrivate() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsExplicitInternal_andContainingEnumIsFilePrivate() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsFilePrivate_andContainingEnumIsFilePrivate() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPrivate_andContainingEnumIsFilePrivate() {
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

    // MARK: - Private error codes
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPublic_andContainingEnumIsPrivate() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsInternal_andContainingEnumIsPrivate() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsExplicitInternal_andContainingEnumIsPrivate() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclarationIsFilePrivate_andContainingEnumIsPrivate() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclarationIsPrivate_andContainingEnumIsPrivate() {
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

    // MARK: - Effect specifiers
    func testErrorCode_willGenerateOpaqueCodeInitializer_andWillGenerateWarning_whenManualOpaqueCodeInitializerDeclaration_isValid_butAsync() {
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
    
    func testErrorCode_willGenerateOpaqueCodeInitializer_andWillGenerateWarning_whenManualOpaqueCodeInitializerDeclaration_isValid_butAsyncThrowing() {
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
    
    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillNotGenerateError_whenManualOpaqueCodeInitializerDeclaration_isValid_butNotThrowing() {
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
    
    func testErrorCode_willGenerateOpaqueCodeInitializer_andWillGenerateWarning_whenManualOpaqueCodeInitializerDeclaration_hasIncorrectParameterName() {
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

    func testErrorCode_willGenerateOpaqueCodeInitializer_andWillGenerateWarning_whenManualOpaqueCodeInitializerDeclaration_hasIncorrectParameterType() {
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

    func testErrorCode_willGenerateOpaqueCodeInitializer_andWillNotGenerateWarning_whenOtherUnrelatedInitializersAreDeclared() {
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

    func testErrorCode_willNotGenerateOpaqueCodeInitializer_andWillGenerateError_whenManualOpaqueCodeInitializerDeclaration_isValid_butFailable() {
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
    
    func testErrorCode_willGenerateOpaqueCodeInitializer_andWillGenerateWarning_whenManualOpaqueCodeInitializerDeclaration_isValid_butFailableAsync() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1
                case value2
            
                init?(opaqueCode: String) async throws {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1
                case value2
            
                init?(opaqueCode: String) async throws {
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
