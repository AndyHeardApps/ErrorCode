import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    static func shouldGenerateOpaqueCodeInitializer(
        from declaration: some DeclGroupSyntax,
        accessScopeModifier: TokenSyntax?,
        context: some MacroExpansionContext
    ) throws -> Bool {
                
        let initializerDeclarations = declaration.memberBlock.members
            .compactMap { $0.decl.as(InitializerDeclSyntax.self) }
        
        for initializerDeclaration in initializerDeclarations {
            guard initializerDeclarationIsValid(initializerDeclaration, context: context) else {
                continue
            }
            
            try assertInitializerDeclarationIsNotFailable(initializerDeclaration)

            try validateAccessModifier(
                on: initializerDeclaration,
                parentEnumAccessScopeModifier: accessScopeModifier
            )
            
            return false
        }
        
        return true
    }
    
    private static func initializerDeclarationIsValid(
        _ initializerDeclaration: InitializerDeclSyntax,
        context: some MacroExpansionContext
    ) -> Bool {
        
        let parameterCountIsCorrect = initializerDeclaration.signature.parameterClause.parameters.count == 1
        let parameterNameIsCorrect = initializerDeclaration.signature.parameterClause.parameters.first?.firstName.text == "opaqueCode"
        let parameterTypeConstraintIsValid = initializerDeclaration.signature.parameterClause.parameters.first?.type.as(IdentifierTypeSyntax.self)?.name.text == "String"
        let returnTypeIsValid = initializerDeclaration.signature.returnClause == nil
        let isNotAsync = initializerDeclaration.signature.effectSpecifiers?.asyncSpecifier == nil
        
        switch (parameterCountIsCorrect, parameterNameIsCorrect, parameterTypeConstraintIsValid, isNotAsync) {
        case (true, false, true, true):
            context.diagnose(.init(node: initializerDeclaration, message: DiagnosticMessage.incorrectParameterName))

        case (true, true, false, true):
            context.diagnose(.init(node: initializerDeclaration, message: DiagnosticMessage.incorrectParameterType))

        case (true, true, true, false):
            context.diagnose(.init(node: initializerDeclaration, message: DiagnosticMessage.incorrectAsyncDeclaration))

        default:
            break
            
        }

        return parameterCountIsCorrect &&
        parameterNameIsCorrect &&
        parameterTypeConstraintIsValid &&
        returnTypeIsValid &&
        isNotAsync
    }
    
    private static func assertInitializerDeclarationIsNotFailable(_ initializerDeclaration: InitializerDeclSyntax) throws {
        
        guard initializerDeclaration.optionalMark != nil else {
            return
        }
        
        var fixItInitializerDeclaration = initializerDeclaration
        fixItInitializerDeclaration.optionalMark = nil
        throw DiagnosticsError(diagnostics: [
            .init(
                node: initializerDeclaration,
                message: DiagnosticMessage.incorrectFailableInitializer,
                fixIt: .replace(
                    message: FixItMessage.removeFailableQuestionMark,
                    oldNode: initializerDeclaration,
                    newNode: fixItInitializerDeclaration
                )
            )
        ])
    }
    
    private static func validateAccessModifier(
        on initializerDeclaration: InitializerDeclSyntax,
        parentEnumAccessScopeModifier: TokenSyntax?
    ) throws {
        
        let initializerAccessScopeModifier = initializerDeclaration.modifiers.first(where: \.isAccessLevelModifier)?.name.tokenKind
        
        var fixItInitializerDeclaration = initializerDeclaration
        fixItInitializerDeclaration.modifiers = fixItInitializerDeclaration.modifiers.filter { !$0.isAccessLevelModifier }
        fixItInitializerDeclaration = fixItInitializerDeclaration.trimmed

        switch parentEnumAccessScopeModifier?.tokenKind {
        case .keyword(.public):
            guard initializerAccessScopeModifier != .keyword(.public) else {
                return
            }
            
            fixItInitializerDeclaration.modifiers.append(.init(name: .keyword(.public), trailingTrivia: .space))
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: initializerDeclaration,
                    message: DiagnosticMessage.needsToBePublic,
                    fixIt: .replace(
                        message: FixItMessage.makeAccessScopeModifierPublic,
                        oldNode: initializerDeclaration,
                        newNode: fixItInitializerDeclaration
                    )
                )
            ])
            
        case .keyword(.internal), .none:
            guard
                initializerAccessScopeModifier != .keyword(.internal),
                initializerAccessScopeModifier != .keyword(.public),
                initializerAccessScopeModifier != nil
            else {
                return
            }
            
            let fixItInitializerDeclaration1 = fixItInitializerDeclaration
            var fixItInitializerDeclaration2 = fixItInitializerDeclaration
            fixItInitializerDeclaration2.modifiers.append(.init(name: .keyword(.internal), trailingTrivia: .space))
            var fixItInitializerDeclaration3 = fixItInitializerDeclaration
            fixItInitializerDeclaration3.modifiers.append(.init(name: .keyword(.public), trailingTrivia: .space))

            throw DiagnosticsError(diagnostics: [
                .init(
                    node: initializerDeclaration,
                    message: DiagnosticMessage.needsToBeInternal,
                    fixIts: [
                        .replace(
                            message: FixItMessage.removeAccessScopeModifier,
                            oldNode: initializerDeclaration,
                            newNode: fixItInitializerDeclaration1
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierInternal,
                            oldNode: initializerDeclaration,
                            newNode: fixItInitializerDeclaration2
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierPublic,
                            oldNode: initializerDeclaration,
                            newNode: fixItInitializerDeclaration3
                        )
                    ]
                )
            ])

        case .keyword(.fileprivate), .keyword(.private):
            guard
                initializerAccessScopeModifier != .keyword(.fileprivate),
                initializerAccessScopeModifier != .keyword(.internal),
                initializerAccessScopeModifier != .keyword(.public),
                initializerAccessScopeModifier != nil
            else {
                return
            }
            
            let fixItInitializerDeclaration1 = fixItInitializerDeclaration
            var fixItInitializerDeclaration2 = fixItInitializerDeclaration
            fixItInitializerDeclaration2.modifiers.append(.init(name: .keyword(.fileprivate), trailingTrivia: .space))
            var fixItInitializerDeclaration3 = fixItInitializerDeclaration
            fixItInitializerDeclaration3.modifiers.append(.init(name: .keyword(.internal), trailingTrivia: .space))
            var fixItInitializerDeclaration4 = fixItInitializerDeclaration
            fixItInitializerDeclaration4.modifiers.append(.init(name: .keyword(.public), trailingTrivia: .space))

            throw DiagnosticsError(diagnostics: [
                .init(
                    node: initializerDeclaration,
                    message: DiagnosticMessage.needsToBeFilePrivate,
                    fixIts: [
                        .replace(
                            message: FixItMessage.removeAccessScopeModifier,
                            oldNode: initializerDeclaration,
                            newNode: fixItInitializerDeclaration1
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierFilePrivate,
                            oldNode: initializerDeclaration,
                            newNode: fixItInitializerDeclaration2
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierInternal,
                            oldNode: initializerDeclaration,
                            newNode: fixItInitializerDeclaration3
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierPublic,
                            oldNode: initializerDeclaration,
                            newNode: fixItInitializerDeclaration4
                        )
                    ]
                )
            ])

        default:
            return
            
        }
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case incorrectFailableInitializer
        case needsToBePublic
        case needsToBeInternal
        case needsToBeFilePrivate
        case incorrectParameterName
        case incorrectParameterType
        case incorrectAsyncDeclaration
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .incorrectFailableInitializer:
            "\"init(opaqueCode: _)\" should not be a failable initializer."
            
        case .needsToBePublic:
            "\"init(opaqueCode: _)\" needs to be declared as \"public\"."
            
        case .needsToBeInternal:
            "\"init(opaqueCode: _)\" needs to be declared as \"internal\", \"public\", or with no access modifier."
            
        case .needsToBeFilePrivate:
            "\"init(opaqueCode: _)\" needs to be declared as \"fileprivate\", \"internal\", \"public\", or with no access modifier."
            
        // TODO: - inject macro name
        case .incorrectParameterName:
            "Declaration has incorrect parameter name and does not satisfy \"ErrorCode\" protocol requirement. The default \"init(opaqueCode: _)\" initializer will still be generated and used by the macro.\n\nTo silence this warning, move this initializer in to an extension of this type."
            
        case .incorrectParameterType:
            "Declaration has incorrect parameter type and does not satisfy \"ErrorCode\" protocol requirement. The default \"init(opaqueCode: _)\" initializer will still be generated and used by the macro.\n\nTo silence this warning, move this initializer in to an extension of this type."
        
        case .incorrectAsyncDeclaration:
            "Declaration is declared as \"async\" and does not satisfy \"ErrorCode\" protocol requirement. The default \"init(opaqueCode: _)\" initializer will still be generated and used by the macro.\n\nTo silence this warning, move this initializer in to an extension of this type."

        }
    }
    
    private var messageID: String {
        
        switch self {
        case .incorrectFailableInitializer:
            "incorrectFailableInitializer"
            
        case .needsToBePublic:
            "needsToBePublic"
            
        case .needsToBeInternal:
            "needsToBeInternal"
            
        case .needsToBeFilePrivate:
            "needsToBeFilePrivate"
            
        case .incorrectParameterName:
            "incorrectParameterName"
            
        case .incorrectParameterType:
            "incorrectParameterType"
            
        case .incorrectAsyncDeclaration:
            "incorrectAsyncDeclaration"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .incorrectFailableInitializer, .needsToBePublic, .needsToBeInternal, .needsToBeFilePrivate:
            .error
            
        case .incorrectParameterName, .incorrectParameterType, .incorrectAsyncDeclaration:
            .warning
            
        }
    }
}

// MARK: - Fix it message
extension ErrorCodeMacro {
    fileprivate enum FixItMessage {
        
        case removeFailableQuestionMark
        case makeAccessScopeModifierPublic
        case makeAccessScopeModifierInternal
        case makeAccessScopeModifierFilePrivate
        case removeAccessScopeModifier
    }
}

extension ErrorCodeMacro.FixItMessage: SwiftDiagnostics.FixItMessage {
    
    var message: String {
        
        switch self {
        case .removeFailableQuestionMark:
            "Remove \"?\""
            
        case .makeAccessScopeModifierPublic:
            "Make \"init(opaqueCode: _)\" \"public\""
            
        case .makeAccessScopeModifierInternal:
            "Make \"init(opaqueCode: _)\" \"internal\""

        case .makeAccessScopeModifierFilePrivate:
            "Make \"init(opaqueCode: _)\" \"fileprivate\""

        case .removeAccessScopeModifier:
            "Remove access modifier"
        }
    }
    
    private var messageID: String {
    
        switch self {
        case .removeFailableQuestionMark:
            "removeFailableQuestionMark"
            
        case .makeAccessScopeModifierPublic:
            "makeAccessScopeModifierPublic"
            
        case .makeAccessScopeModifierInternal:
            "makeAccessScopeModifierInternal"

        case .makeAccessScopeModifierFilePrivate:
            "makeAccessScopeModifierFilePrivate"

        case .removeAccessScopeModifier:
            "removeAccessScopeModifier"
        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualOpaqueCodeInitializerDeclarationValidation",
            id: messageID
        )
    }
}
