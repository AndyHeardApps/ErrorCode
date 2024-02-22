import Foundation
import SwiftSyntax
import SwiftDiagnostics

// MARK: - Enum case
extension ErrorCodeMacro {
    
    struct EnumCase {
        let name: TokenSyntax
        let opaqueCode: TokenSyntax
        let child: Child
    }
}

// MARK: - Enum case child
extension ErrorCodeMacro.EnumCase {
    
    enum Child {
        case none
        case named(String)
        case unnamed
    }
}

extension ErrorCodeMacro.EnumCase.Child {
    
    var exists: Bool {
        switch self {
        case .named, .unnamed:
            true
        case .none:
            false
        }
    }
    
    var name: String? {
        switch self {
        case let .named(name):
            name
        case .none, .unnamed:
            nil
        }
    }
}

// MARK: - Enum case extraction
extension ErrorCodeMacro {
    
    static func parseEnumCases(
        on declaration: EnumDeclSyntax,
        opaqueCodeLength: Int,
        opaqueCodeCharacters: [Character]
    ) throws -> [EnumCase] {
        
        let caseDeclarations = declaration.memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .flatMap(\.elements)
        
        let enumCases = try caseDeclarations
            .map { element in
                try EnumCase(
                    name: element.name,
                    opaqueCode: generateOpaqueCode(
                        ofLength: opaqueCodeLength,
                        for: declaration.name.text + "." + element.name.text,
                        opaqueCodeCharacters: opaqueCodeCharacters
                    ),
                    child: parseElementChild(element)
                )
            }
        
        return enumCases
    }
    
    private static func generateOpaqueCode(
        ofLength opaqueCodeLength: Int,
        for value: String,
        opaqueCodeCharacters: [Character]
    ) -> TokenSyntax {
        
        var opaqueCodeIndices: [Int] = []
        for index in 0..<opaqueCodeLength {
            let value = value.utf8.reduce(5381 * (index+opaqueCodeLength)) {
                ($0 << 5) &+ $0 &+ Int($1&*$1)
            }
            opaqueCodeIndices.append(value)
        }

        let opaqueCode = opaqueCodeIndices
            .map { opaqueCodeCharacters[Int($0.magnitude) % opaqueCodeCharacters.count] }
        
        return TokenSyntax(stringLiteral: String(opaqueCode))
    }
    
    private static func parseElementChild(_ element: EnumCaseElementListSyntax.Element) throws -> EnumCase.Child {
        
        guard let parameters = element.parameterClause?.parameters else {
            return .none
        }
        
        guard parameters.count <= 1 else {
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: element,
                    message: DiagnosticMessage.tooManyAssociatedValues
                )
            ])
        }
        
        if let parameterName = parameters.first?.firstName?.text {
            return .named(parameterName)
        } else {
            return .unnamed
        }
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case tooManyAssociatedValues
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .tooManyAssociatedValues:
            "\"@ErrorCode\" enum cases may only have up to one associated value, which must also be an \"ErrorCode\"."
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .tooManyAssociatedValues:
            "tooManyAssociatedValues"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.CaseParsing",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .tooManyAssociatedValues:
            .error
        }
    }
}

extension Collection where Element == ErrorCodeMacro.EnumCase {
    
    var hasChildren: Bool {
        
        !self.allSatisfy { !$0.child.exists }
    }
}
