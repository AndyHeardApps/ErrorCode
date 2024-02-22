import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ErrorCode_CustomChildCodeDelimiterTests: XCTestCase {

    func testErrorCode_willRespectCustomChildCodeDelimiter() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(delimiter: ".")
            enum TestCode {
                case value1(TestCode2)
                case value2
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(TestCode2)
                case value2
            }
            
            extension TestCode: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "liBc"
                    static let value2 = "M7aD"
                }

                var opaqueCode: String {
                    switch self {
                    case let .value1(child):
                        OpaqueCode.value1 + "." + childOpaqueCode(for: child)
                    case .value2:
                        OpaqueCode.value2
                    }
                }

                private func childOpaqueCode(for errorCode: some ErrorCode) -> String {
                    errorCode.opaqueCode
                }

                init(opaqueCode: String) throws {

                    var components = opaqueCode.split(separator: ".")
                    guard components.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    let firstComponent = components.removeFirst()
                    switch firstComponent {
                    case OpaqueCode.value1:
                        let remainingComponents = components.joined(separator: ".")
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
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomChildCodeDelimiter_isProvidedAsExpression() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(delimiter: "-" + "-")
            enum TestCode {
                case value1(TestCode2)
                case value2
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(TestCode2)
                case value2
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
                        domain: "ErrorCodeMacro.CustomChildCodeDelimiterParsing",
                        id: "invalidChildCodeDelimiterParameter"
                    ),
                    message: "\"childCodeDelimiter\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default delimiter being used.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomChildCodeDelimiter_isProvidedAsFunction() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(delimiter: delimiter())
            enum TestCode {
                case value1(TestCode2)
                case value2
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(TestCode2)
                case value2
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
                        domain: "ErrorCodeMacro.CustomChildCodeDelimiterParsing",
                        id: "invalidChildCodeDelimiterParameter"
                    ),
                    message: "\"childCodeDelimiter\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default delimiter being used.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }

    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomChildCodeDelimiter_isProvidedAsNonStringLiteral() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(delimiter: 1)
            enum TestCode {
                case value1(TestCode2)
                case value2
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(TestCode2)
                case value2
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
                        domain: "ErrorCodeMacro.CustomChildCodeDelimiterParsing",
                        id: "invalidChildCodeDelimiterParameter"
                    ),
                    message: "\"childCodeDelimiter\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default delimiter being used.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
    func testErrorCode_willGenerateWarning_andUseDefaultValue_whenCustomChildCodeDelimiter_isProvidedAsEmptyStringLiteral() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode(delimiter: "")
            enum TestCode {
                case value1(TestCode2)
                case value2
            }
            """,
            expandedSource: """
            enum TestCode {
                case value1(TestCode2)
                case value2
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
                        domain: "ErrorCodeMacro.CustomChildCodeDelimiterParsing",
                        id: "invalidChildCodeDelimiterParameter"
                    ),
                    message: "\"childCodeDelimiter\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default delimiter being used.",
                    line: 1,
                    column: 1,
                    severity: .warning
                )
            ],
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
