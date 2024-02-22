import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    private static let defaultChildCodeDelimiter = "-"

    static func parseCustomChildCodeDelimiter(
        from node: AttributeSyntax,
        context: MacroExpansionContext
    ) -> (isManuallyDeclared: Bool, delimiter: String) {
        
        guard
            let labeledList = node.arguments?.as(LabeledExprListSyntax.self),
            let delimiterArgument = labeledList.first(where: { $0.label?.text == "delimiter" })
        else {
            return (false, defaultChildCodeDelimiter)
        }
        
        guard 
            let stringLiteralExpression = delimiterArgument.expression.as(StringLiteralExprSyntax.self),
            let delimiter = stringLiteralExpression.segments.first?.as(StringSegmentSyntax.self)?.content,
            !delimiter.text.isEmpty
        else {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.invalidChildCodeDelimiterParameter
                )
            )
            return (false, defaultChildCodeDelimiter)
        }

        return (true, delimiter.text)
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case invalidChildCodeDelimiterParameter
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .invalidChildCodeDelimiterParameter:
            "\"childCodeDelimiter\" parameter must be provided as a single, non-empty String literal expression. Expressions, parameters, function calls and empty strings will be ignored and result in the default delimiter being used."
                        
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .invalidChildCodeDelimiterParameter:
            "invalidChildCodeDelimiterParameter"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.CustomChildCodeDelimiterParsing",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .invalidChildCodeDelimiterParameter:
            .warning
            
        }
    }
}
