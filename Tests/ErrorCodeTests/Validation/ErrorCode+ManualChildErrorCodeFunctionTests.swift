import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ErrorCode_ManualChildErrorCodeFunctionTests: XCTestCase {

    // MARK: - Opaque code property
    func testErrorCode_willNotGenerateChildErrorCodeFunction_whenManualInitializerDeclaration_isValid() {
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
    
    // MARK: - Generic
    func testErrorCode_willNotGenerateChildErrorCodeFunction_whenManualGenericFunctionDeclaration_isValid() {
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
    
    func testErrorCode_willNotGenerateChildErrorCodeFunction_whenManualGenericFunctionDeclaration_isValid_butNonThrowing() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_isValid_butAsync() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_isValid_butAsyncThrowing() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_whenManualGenericFunctionDeclaration_hasIncorrectParameterCount() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_hasIncorrectFunctionName() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_hasIncorrectGenericInheritanceType() {
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

    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualFGenericunctionDeclaration_hasIncorrectParameterName() {
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

    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_hasIncorrectParameterType() {
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
    

    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_hasIncorrectReturnType() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericFunctionDeclaration_isNotStatic() {
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
    
    // MARK: - Generic where clause
    func testErrorCode_willNotGenerateChildErrorCodeFunction_whenManualGenericWhereFunctionDeclaration_isValid() {
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
    
    func testErrorCode_willNotGenerateChildErrorCodeFunction_whenManualGenericWhereFunctionDeclaration_isValid_butNonThrowing() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_isValid_butAsync() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_isValid_butAsyncThrowing() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_whenManualGenericWhereFunctionDeclaration_hasIncorrectParameterCount() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectFunctionName() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectGenericInheritanceType() {
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

    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectParameterName() {
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

    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectParameterType() {
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

    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_hasIncorrectReturnType() {
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
    
    func testErrorCode_willGenerateChildErrorCodeFunction_andWillGenerateWarning_whenManualGenericWhereFunctionDeclaration_isNotStatic() {
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
