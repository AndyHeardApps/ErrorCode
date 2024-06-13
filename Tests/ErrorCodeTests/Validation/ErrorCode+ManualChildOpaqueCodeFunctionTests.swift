import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import Testing

@Suite(
    "Manual childOpaqueCode function declaration",
    .enabled(if: MacroTesting.shared.isEnabled),
    .tags(.codeValidation)
)
struct ErrorCodeManualChildOpaqueCodeFunctionTests {
    
    // MARK: - Child Opaque code function
    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_whenManualChildOpaqueCodeFunctionDeclaration_isValid() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                var opaqueCode: String {
                    ""
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
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
    
    // MARK: - Existential
    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_whenManualExistentialFunctionDeclaration_isValid() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) -> String {
                    errorCode.opaqueCode
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

    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_andWillGenerateError_whenManualExistentialFunctionDeclaration_isValid_butThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) throws -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) throws -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectThrowingDeclaration"
                    ),
                    message: "\"childOpaqueCode(for: _)\" should not be a throwing function.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"throws\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialFunctionDeclaration_isValid_butAsync() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) async -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) async -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialFunctionDeclaration_isValid_butAsyncThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) async throws -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) async throws -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncThrowingDeclaration"
                    ),
                    message: "Declaration is declared as \"async throws\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_whenManualExistentialFunctionDeclaration_hasIncorrectParameterCount() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode, other: Int) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode, other: Int) -> String {
                    errorCode.opaqueCode
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
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialFunctionDeclaration_hasIncorrectFunctionName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName(for errorCode: ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName(for errorCode: ErrorCode) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectFunctionName"
                    ),
                    message: "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialFunctionDeclaration_hasIncorrectParameterName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(on errorCode: ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(on errorCode: ErrorCode) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectParameterName"
                    ),
                    message: "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialFunctionDeclaration_hasIncorrectParameterType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: Error) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: Error) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectParameterType"
                    ),
                    message: "Declaration has incorrect parameter type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialFunctionDeclaration_hasIncorrectReturnType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) -> Int {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: ErrorCode) -> Int {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectReturnType"
                    ),
                    message: "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    // MARK: - Existential any
    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_whenManualExistentialAnyFunctionDeclaration_isValid() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) -> String {
                    errorCode.opaqueCode
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

    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_andWillGenerateError_whenManualExistentialAnyFunctionDeclaration_isValid_butThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) throws -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) throws -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectThrowingDeclaration"
                    ),
                    message: "\"childOpaqueCode(for: _)\" should not be a throwing function.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"throws\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialAnyFunctionDeclaration_isValid_butAsync() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) async -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) async -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialAnyFunctionDeclaration_isValid_butAsyncThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) async throws -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) async throws -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncThrowingDeclaration"
                    ),
                    message: "Declaration is declared as \"async throws\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_whenManualExistentialAnyFunctionDeclaration_hasIncorrectParameterCount() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode, other: Int) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode, other: Int) -> String {
                    errorCode.opaqueCode
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
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialAnyFunctionDeclaration_hasIncorrectFunctionName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName(for errorCode: any ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName(for errorCode: any ErrorCode) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectFunctionName"
                    ),
                    message: "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialAnyFunctionDeclaration_hasIncorrectParameterName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(on errorCode: any ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(on errorCode: any ErrorCode) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectParameterName"
                    ),
                    message: "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialAnyFunctionDeclaration_hasIncorrectParameterType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any Error) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any Error) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectParameterType"
                    ),
                    message: "Declaration has incorrect parameter type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualExistentialAnyFunctionDeclaration_hasIncorrectReturnType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) -> Int {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: any ErrorCode) -> Int {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectReturnType"
                    ),
                    message: "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    // MARK: - Generic
    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_whenManualGenericFunctionDeclaration_isValid() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) -> String {
                    errorCode.opaqueCode
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

    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_andWillGenerateError_whenManualGenericFunctionDeclaration_isValid_butThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) throws -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) throws -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectThrowingDeclaration"
                    ),
                    message: "\"childOpaqueCode(for: _)\" should not be a throwing function.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"throws\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_isValid_butAsync() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) async -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) async -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_isValid_butAsyncThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) async throws -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) async throws -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncThrowingDeclaration"
                    ),
                    message: "Declaration is declared as \"async throws\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_whenManualExistentialGenericDeclaration_hasIncorrectParameterCount() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E, other: Int) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E, other: Int) -> String {
                    errorCode.opaqueCode
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
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_hasIncorrectFunctionName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName<E: ErrorCode>(for errorCode: E) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName<E: ErrorCode>(for errorCode: E) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectFunctionName"
                    ),
                    message: "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_hasIncorrectParameterName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(on errorCode: E) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(on errorCode: E) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectParameterName"
                    ),
                    message: "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_hasIncorrectGenericParameterType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: Error>(for errorCode: E) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: Error>(for errorCode: E) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectGenericParameterInheritedType"
                    ),
                    message: "Declaration has incorrect generic type constraint and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_hasIncorrectReturnType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) -> Int {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E: ErrorCode>(for errorCode: E) -> Int {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectReturnType"
                    ),
                    message: "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    // MARK: - Generic where
    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_whenManualGenericWhereFunctionDeclaration_isValid() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) -> String where E: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) -> String where E: ErrorCode {
                    errorCode.opaqueCode
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

    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_andWillGenerateError_whenManualGenericWhereFunctionDeclaration_isValid_butThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) throws -> String where E: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) throws -> String where E: ErrorCode {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectThrowingDeclaration"
                    ),
                    message: "\"childOpaqueCode(for: _)\" should not be a throwing function.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"throws\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_isValid_butAsync() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) async -> String where E: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) async -> String where E: ErrorCode {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_isValid_butAsyncThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) async throws -> String where E: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) async throws -> String where E: ErrorCode {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncThrowingDeclaration"
                    ),
                    message: "Declaration is declared as \"async throws\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_whenManualExistentialGenericWhereDeclaration_hasIncorrectParameterCount() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E, other: Int) -> String where E: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E, other: Int) -> String where E: ErrorCode {
                    errorCode.opaqueCode
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
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectFunctionName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName<E>(for errorCode: E) -> String where E: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName<E>(for errorCode: E) -> String where E: ErrorCode {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectFunctionName"
                    ),
                    message: "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectParameterName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(on errorCode: E) -> String where E: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(on errorCode: E) -> String where E: ErrorCode {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectParameterName"
                    ),
                    message: "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectGenericWhereParameterName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) -> String where D: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) -> String where D: ErrorCode {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectWhereRequirementTypeName"
                    ),
                    message: "Declaration where clause has incorrect generic type name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectGenericWhereParameterType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) -> String where E: Error {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) -> String where E: Error {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectWhereRequirementInheritedType"
                    ),
                    message: "Declaration has incorrect generic type constraint and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectReturnType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) -> Int where E: ErrorCode {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode<E>(for errorCode: E) -> Int where E: ErrorCode {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectReturnType"
                    ),
                    message: "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    // MARK: - Generic some
    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_whenManualGenericSomeFunctionDeclaration_isValid() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) -> String {
                    errorCode.opaqueCode
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

    func testErrorCode_willNotGenerateChildOpaqueCodeFunction_andWillGenerateError_whenManualGenericSomeFunctionDeclaration_isValid_butThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) throws -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) throws -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectThrowingDeclaration"
                    ),
                    message: "\"childOpaqueCode(for: _)\" should not be a throwing function.",
                    line: 6,
                    column: 5,
                    severity: .error,
                    fixIts: [
                        .init(message: "Remove \"throws\"")
                    ]
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericSomeFunctionDeclaration_isValid_butAsync() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) async -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) async -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncDeclaration"
                    ),
                    message: "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericSomeFunctionDeclaration_isValid_butAsyncThrowing() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) async throws -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) async throws -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectAsyncThrowingDeclaration"
                    ),
                    message: "Declaration is declared as \"async throws\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_whenManualExistentialGenericSomeDeclaration_hasIncorrectParameterCount() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode, other: Int) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode, other: Int) -> String {
                    errorCode.opaqueCode
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
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericSomeFunctionDeclaration_hasIncorrectFunctionName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName(for errorCode: some ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueName(for errorCode: some ErrorCode) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectFunctionName"
                    ),
                    message: "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericSomeFunctionDeclaration_hasIncorrectParameterName() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(on errorCode: some ErrorCode) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(on errorCode: some ErrorCode) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectParameterName"
                    ),
                    message: "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }

    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericSomeFunctionDeclaration_hasIncorrectParameterType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some Error) -> String {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some Error) -> String {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectParameterType"
                    ),
                    message: "Declaration has incorrect parameter type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
    
    func testErrorCode_willGenerateChildOpaqueCodeFunction_andWillGenerateWarning_whenManualGenericSomeFunctionDeclaration_hasIncorrectReturnType() {
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) -> Int {
                    errorCode.opaqueCode
                }
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(Child)
                case value2

                func childOpaqueCode(for errorCode: some ErrorCode) -> Int {
                    errorCode.opaqueCode
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
                        domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
                        id: "incorrectReturnType"
                    ),
                    message: "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer.",
                    line: 6,
                    column: 5,
                    severity: .warning
                )
            ],
            macros: MacroTesting.shared.testMacros
        )
    }
}
