import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    static func shouldGenerateOpaqueCodeErrors(
        from declaration: EnumDeclSyntax,
        isGeneratingOpaqueCodeInitializer: Bool,
        context: some MacroExpansionContext
    ) -> Bool {
        
        guard let manualOpaqueCodeErrorDeclaration = extractManualOpaqueCodeErrorDeclaration(from: declaration) else {
            return isGeneratingOpaqueCodeInitializer
        }
        
        if isGeneratingOpaqueCodeInitializer {
            assertInheritenceClauseContainsOpaqueCodeInitializerError(
                declaration: manualOpaqueCodeErrorDeclaration,
                context: context
            )
        } else {
            checkForUnnecessaryOpaqueCodeInitializerErrorConformance(
                declaration: manualOpaqueCodeErrorDeclaration,
                context: context
            )
        }
        
        return false
    }
    
    private static func extractManualOpaqueCodeErrorDeclaration(from declaration: EnumDeclSyntax) -> DeclGroupSyntax? {
        
        if
            let enumDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(EnumDeclSyntax.self) })
                .first(where: { $0.name.text == "OpaqueCodeError" })
        {
            enumDeclaration
            
        } else if
            let structDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(StructDeclSyntax.self) })
                .first(where: { $0.name.text == "OpaqueCodeError" })
        {
            structDeclaration
            
        } else if
            let classDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(ClassDeclSyntax.self) })
                .first(where: { $0.name.text == "OpaqueCodeError" })
        {
            classDeclaration
            
        } else if
            let actorDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(ActorDeclSyntax.self) })
                .first(where: { $0.name.text == "OpaqueCodeError" })
        {
            actorDeclaration
            
        } else {
            nil
            
        }
    }
    
    private static func assertInheritenceClauseContainsOpaqueCodeInitializerError(
        declaration: some DeclGroupSyntax,
        context: some MacroExpansionContext
    ) {
        
        let inheritedTypeNames = declaration.inheritanceClause?.inheritedTypes
            .compactMap { type in
                type.as(InheritedTypeSyntax.self)?
                    .type
                    .as(IdentifierTypeSyntax.self)?
                    .name.text
            } ?? []
        
        guard !inheritedTypeNames.contains("OpaqueCodeInitializerError") else {
            return
        }

        var fixItDeclaration = declaration
        if fixItDeclaration.inheritanceClause == nil {
            fixItDeclaration.inheritanceClause = .init(inheritedTypes: [])
        }
        fixItDeclaration.inheritanceClause = fixItDeclaration.inheritanceClause?.trimmed
        if !fixItDeclaration.inheritanceClause!.inheritedTypes.isEmpty {
            let lastIndex = fixItDeclaration.inheritanceClause!.inheritedTypes.indices.last!
            fixItDeclaration.inheritanceClause!.inheritedTypes[lastIndex].trailingComma = .commaToken()
        }
        fixItDeclaration.inheritanceClause?.inheritedTypes.append(
            .init(
                leadingTrivia: .space,
                type: IdentifierTypeSyntax(name: "OpaqueCodeInitializerError"),
                trailingTrivia: .space
            )
        )
        
        context.diagnose(
            .init(
                node: declaration,
                message: DiagnosticMessage.opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError,
                fixIt: .replace(
                    message: FixItMessage.addOpaqueCodeInitializerErrorConformance,
                    oldNode: declaration,
                    newNode: fixItDeclaration
                )
            )
        )
    }
    
    private static func checkForUnnecessaryOpaqueCodeInitializerErrorConformance(
        declaration: some DeclGroupSyntax,
        context: some MacroExpansionContext
    ) {
        
        let inheritedTypeNames = declaration.inheritanceClause?.inheritedTypes
            .compactMap { type in
                type.as(InheritedTypeSyntax.self)?
                    .type
                    .as(IdentifierTypeSyntax.self)?
                    .name.text
            } ?? []
        
        guard inheritedTypeNames.contains("OpaqueCodeInitializerError") else {
            return
        }
        
        var fixItDeclaration = declaration
        fixItDeclaration.inheritanceClause!.inheritedTypes = declaration.inheritanceClause!.inheritedTypes
            .filter {
                $0.type.as(IdentifierTypeSyntax.self)?
                .name.text != "OpaqueCodeInitializerError"
            }
        fixItDeclaration.inheritanceClause!.inheritedTypes.append(
            .init(
                type: IdentifierTypeSyntax(name: "Error"),
                trailingTrivia: .space
            )
        )

        context.diagnose(
            .init(
                node: declaration,
                message: DiagnosticMessage.unnecessaryOpaqueCodeInitializerErrorConformanceDetected,
                fixIt: .replace(
                    message: FixItMessage.replaceOpaqueCodeInitializerErrorConformanceWithErrorConformance,
                    oldNode: declaration,
                    newNode: fixItDeclaration
                )
            )
        )
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError
        case unnecessaryOpaqueCodeInitializerErrorConformanceDetected
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError:
            "\"OpaqueCodeError\" should conform to the \"OpaqueCodeInitializerError\" protocol."
            
        case .unnecessaryOpaqueCodeInitializerErrorConformanceDetected:
            "Unnecessary conformance to \"unnecessaryOpaqueCodeInitializerErrorConformanceDetected\". This is only required when the \"init(opaqueCode: _)\" initializer is automatically synthesized, and a custom \"OpaqueCodeError\" is declared. Declaring your own \"init(opaqueCode: _)\" initializer means the functionality provided by the protocol is no longer required. To silence this warning and keep the conformance, move the conformance declaration to an extension of this type."
            
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError:
            "opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError"
         
        case .unnecessaryOpaqueCodeInitializerErrorConformanceDetected:
            "unnecessaryOpaqueCodeInitializerErrorConformanceDetected"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .opaqueCodeErrorDeclarationShouldConformToOpaqueCodeInitializerError:
            .error
            
        case .unnecessaryOpaqueCodeInitializerErrorConformanceDetected:
            .warning
            
        }
    }
}

// MARK: - Fix it message
extension ErrorCodeMacro {
    fileprivate enum FixItMessage {
        
        case addOpaqueCodeInitializerErrorConformance
        case replaceOpaqueCodeInitializerErrorConformanceWithErrorConformance
    }
}

extension ErrorCodeMacro.FixItMessage: SwiftDiagnostics.FixItMessage {
    
    var message: String {
        
        switch self {
        case .addOpaqueCodeInitializerErrorConformance:
            "Add conformance to \"OpaqueCodeInitializerError\""
            
        case .replaceOpaqueCodeInitializerErrorConformanceWithErrorConformance:
            "Replace conformance to \"OpaqueCodeInitializerError\" with \"Error\""
            
        }
    }
    
    private var messageID: String {
    
        switch self {
        case .addOpaqueCodeInitializerErrorConformance:
            "addOpaqueCodeInitializerErrorConformance"
            
        case .replaceOpaqueCodeInitializerErrorConformanceWithErrorConformance:
            "replaceOpaqueCodeInitializerErrorConformanceWithErrorConformance"
            
        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualOpaqueCodeErrorDeclarationValidation",
            id: messageID
        )
    }
}
