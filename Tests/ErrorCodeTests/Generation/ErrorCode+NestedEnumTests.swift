import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class ErrorCode_NestedEnumTests: XCTestCase {

    func testErrorCode_willExpandUnnamedNestedEnumCorrectly() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode1 {
                case value1(TestCode2)
                case value2
            }
            
            @ErrorCode
            enum TestCode2 {
                case value3
                case value4
            }
            """,
            expandedSource: """
            enum TestCode1 {
                case value1(TestCode2)
                case value2
            }
            enum TestCode2 {
                case value3
                case value4
            }

            extension TestCode1: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "4hKx"
                    static let value2 = "T6jM"
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

            extension TestCode2: ErrorCode {

                private enum OpaqueCode {
                    static let value3 = "5iLy"
                    static let value4 = "Q3gJ"
                }

                var opaqueCode: String {
                    switch self {
                    case .value3:
                        OpaqueCode.value3
                    case .value4:
                        OpaqueCode.value4
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value3:
                        self = .value3

                    case OpaqueCode.value4:
                        self = .value4

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
    
    func testErrorCode_willExpandNamedNestedEnumCorrectly() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode1 {
                case value1(child: TestCode2)
                case value2
            }
            
            @ErrorCode
            enum TestCode2 {
                case value3
                case value4
            }
            """,
            expandedSource: """
            enum TestCode1 {
                case value1(child: TestCode2)
                case value2
            }
            enum TestCode2 {
                case value3
                case value4
            }

            extension TestCode1: ErrorCode {

                private enum OpaqueCode {
                    static let value1 = "4hKx"
                    static let value2 = "T6jM"
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
                        self = try .value1(child: Self.childErrorCode(for: remainingComponents))

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

            extension TestCode2: ErrorCode {

                private enum OpaqueCode {
                    static let value3 = "5iLy"
                    static let value4 = "Q3gJ"
                }

                var opaqueCode: String {
                    switch self {
                    case .value3:
                        OpaqueCode.value3
                    case .value4:
                        OpaqueCode.value4
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value3:
                        self = .value3

                    case OpaqueCode.value4:
                        self = .value4

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
    
    func testErrorCode_willGenerateError_forEnumCaseWithTooManyAssociatedValues() throws {
        #if canImport(ErrorCodeMacros)
        assertMacroExpansion(
            """
            @ErrorCode
            enum TestCode1 {
                case value1(child: TestCode2, other: Int)
                case value2
            }
            
            @ErrorCode
            enum TestCode2 {
                case value3
                case value4
            }
            """,
            expandedSource:
            """
            enum TestCode1 {
                case value1(child: TestCode2, other: Int)
                case value2
            }
            enum TestCode2 {
                case value3
                case value4
            }
            
            extension TestCode2: ErrorCode {

                private enum OpaqueCode {
                    static let value3 = "5iLy"
                    static let value4 = "Q3gJ"
                }

                var opaqueCode: String {
                    switch self {
                    case .value3:
                        OpaqueCode.value3
                    case .value4:
                        OpaqueCode.value4
                    }
                }

                init(opaqueCode: String) throws {

                    guard opaqueCode.isEmpty == false else {
                        throw OpaqueCodeError.opaqueCodeIsEmpty
                    }

                    switch opaqueCode {
                    case OpaqueCode.value3:
                        self = .value3

                    case OpaqueCode.value4:
                        self = .value4

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
                        id: "tooManyAssociatedValuesOnEnumCaseDeclaration"
                    ),
                    message: "\"@ErrorCode\" enum cases may only have up to one associated value, which must also be an \"ErrorCode\".",
                    line: 3,
                    column: 10,
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
