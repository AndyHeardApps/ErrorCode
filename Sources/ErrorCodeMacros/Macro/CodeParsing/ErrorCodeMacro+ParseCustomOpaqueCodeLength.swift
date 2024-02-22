import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    private static let defaultCodeLength = 4

    static func parseCustomOpaqueCodeLength(
        from node: AttributeSyntax,
        context: MacroExpansionContext
    ) -> (isManuallyDeclared: Bool, codeLength: Int) {
        
        guard
            let labeledList = node.arguments?.as(LabeledExprListSyntax.self),
            let codeLengthArgument = labeledList.first(where: { $0.label?.text == "codeLength" })
        else {
            return (false, defaultCodeLength)
        }
        
        guard
            let integerLiteralExpression = codeLengthArgument.expression.as(IntegerLiteralExprSyntax.self),
            let codeLength = Int(integerLiteralExpression.literal.text)
        else {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.invalidCodeLengthParameter
                )
            )
            return (false, defaultCodeLength)
        }
        
        guard codeLength > .zero else {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.cannotUseZeroForOpaqueCodeLengthParameter
                )
            )
            return (true, 1)
        }

        return (true, codeLength)
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case invalidCodeLengthParameter
        case cannotUseZeroForOpaqueCodeLengthParameter
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .invalidCodeLengthParameter:
            "\"codeLength\" parameter must be provided as a single positive Integer literal expression. Expressions, parameters and function calls will be ignored and result in the default code length being used."
                        
        case .cannotUseZeroForOpaqueCodeLengthParameter:
            "\"codeLength\" parameter cannot be \"0\". A value of \"1\" will be used instead."
            
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .invalidCodeLengthParameter:
            "invalidCodeLengthParameter"
            
        case .cannotUseZeroForOpaqueCodeLengthParameter:
            "cannotUseZeroForOpaqueCodeLengthParameter"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.CustomOpaqueCodeLengthParsing",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .invalidCodeLengthParameter, .cannotUseZeroForOpaqueCodeLengthParameter:
            .warning
            
        }
    }
}
