import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    private static let defaultOpaqueCodeCharacters = Set("abcdefghijklmonpqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890").sorted()

    static func parseCustomOpaqueCodeCharacters(
        from node: AttributeSyntax,
        context: MacroExpansionContext
    ) -> (isManuallyDeclared: Bool, characters: [Character]) {
        
        guard
            let labeledList = node.arguments?.as(LabeledExprListSyntax.self),
            let codeCharactersArgument = labeledList.first(where: { $0.label?.text == "codeCharacters" })
        else {
            return (false, defaultOpaqueCodeCharacters)
        }
        
        guard
            let stringLiteralExpression = codeCharactersArgument.expression.as(StringLiteralExprSyntax.self),
            let codeCharacters = stringLiteralExpression.segments.first?.as(StringSegmentSyntax.self)?.content
        else {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.invalidOpaqueCodeCharactersParameter
                )
            )
            return (false, defaultOpaqueCodeCharacters)
        }
        
        let codeCharacterSet = Set(codeCharacters.text).sorted()
        guard codeCharacterSet.count > 4 else {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.notEnoughOpaqueCodeCharacters
                )
            )
            return (true, defaultOpaqueCodeCharacters)
        }

        return (true, codeCharacterSet)
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case invalidOpaqueCodeCharactersParameter
        case notEnoughOpaqueCodeCharacters
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .invalidOpaqueCodeCharactersParameter:
            "\"codeCharacters\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default characters being used."
                       
        case .notEnoughOpaqueCodeCharacters:
            "\"codeCharacters\" parameter must contain at least 5 unique characters."
            
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .invalidOpaqueCodeCharactersParameter:
            "invalidOpaqueCodeCharactersParameter"
            
        case .notEnoughOpaqueCodeCharacters:
            "notEnoughOpaqueCodeCharacters"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.CustomOpaqueCodeCharactersParsing",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .invalidOpaqueCodeCharactersParameter, .notEnoughOpaqueCodeCharacters:
            .warning
            
        }
    }
}
