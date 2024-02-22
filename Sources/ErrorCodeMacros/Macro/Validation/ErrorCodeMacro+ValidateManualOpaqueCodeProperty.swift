import SwiftSyntax
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    static func shouldGenerateOpaqueCodeProperty(
        from declaration: EnumDeclSyntax,
        accessScopeModifier: TokenSyntax?
    ) throws -> Bool {
        
        guard let propertyDeclaration = declaration.memberBlock.members
            .compactMap({ $0.decl.as(VariableDeclSyntax.self) })
            .first(where: { $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "opaqueCode" })
        else {
            return true
        }
        
        try validatePropertyType(on: propertyDeclaration)

        try validateAccessModifier(
            on: propertyDeclaration,
            parentEnumAccessScopeModifier: accessScopeModifier
        )
        
        try validateEffectSpecifiers(on: propertyDeclaration)
                
        return false
    }
    
    private static func validateAccessModifier(
        on propertyDeclaration: VariableDeclSyntax,
        parentEnumAccessScopeModifier: TokenSyntax?
    ) throws {
        
        let propertyAccessScopeModifier = propertyDeclaration.modifiers.first(where: \.isAccessLevelModifier)?.name.tokenKind
        
        var fixItPropertyDeclaration = propertyDeclaration
        fixItPropertyDeclaration.modifiers = fixItPropertyDeclaration.modifiers.filter { !$0.isAccessLevelModifier }
        fixItPropertyDeclaration.bindingSpecifier.leadingTrivia = .space
        fixItPropertyDeclaration.bindingSpecifier.trailingTrivia = .space

        switch parentEnumAccessScopeModifier?.tokenKind {
        case .keyword(.public):
            guard propertyAccessScopeModifier != .keyword(.public) else {
                return
            }
            
            fixItPropertyDeclaration.modifiers.append(.init(name: .keyword(.public)))
            
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: propertyDeclaration,
                    message: DiagnosticMessage.needsToBePublic,
                    fixIt: .replace(
                        message: FixItMessage.makeAccessScopeModifierPublic,
                        oldNode: propertyDeclaration,
                        newNode: fixItPropertyDeclaration
                    )
                )
            ])
            
        case .keyword(.internal), .none:
            guard
                propertyAccessScopeModifier != .keyword(.internal),
                propertyAccessScopeModifier != .keyword(.public),
                propertyAccessScopeModifier != nil
            else {
                return
            }
            
            let fixItPropertyDeclaration1 = fixItPropertyDeclaration
            var fixItPropertyDeclaration2 = fixItPropertyDeclaration
            fixItPropertyDeclaration2.modifiers.append(.init(name: .keyword(.internal)))
            var fixItPropertyDeclaration3 = fixItPropertyDeclaration
            fixItPropertyDeclaration3.modifiers.append(.init(name: .keyword(.public)))
            
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: propertyDeclaration,
                    message: DiagnosticMessage.needsToBeInternal,
                    fixIts: [
                        .replace(
                            message: FixItMessage.removeAccessScopeModifier,
                            oldNode: propertyDeclaration,
                            newNode: fixItPropertyDeclaration1
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierInternal,
                            oldNode: propertyDeclaration,
                            newNode: fixItPropertyDeclaration2
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierPublic,
                            oldNode: propertyDeclaration,
                            newNode: fixItPropertyDeclaration3
                        )
                    ]
                )
            ])

        case .keyword(.fileprivate), .keyword(.private):
            guard
                propertyAccessScopeModifier != .keyword(.fileprivate),
                propertyAccessScopeModifier != .keyword(.internal),
                propertyAccessScopeModifier != .keyword(.public),
                propertyAccessScopeModifier != nil
            else {
                return
            }
            
            let fixItPropertyDeclaration1 = fixItPropertyDeclaration
            var fixItPropertyDeclaration2 = fixItPropertyDeclaration
            fixItPropertyDeclaration2.modifiers.append(.init(name: .keyword(.fileprivate)))
            var fixItPropertyDeclaration3 = fixItPropertyDeclaration
            fixItPropertyDeclaration3.modifiers.append(.init(name: .keyword(.internal)))
            var fixItPropertyDeclaration4 = fixItPropertyDeclaration
            fixItPropertyDeclaration4.modifiers.append(.init(name: .keyword(.public)))
            
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: propertyDeclaration,
                    message: DiagnosticMessage.needsToBeFilePrivate,
                    fixIts: [
                        .replace(
                            message: FixItMessage.removeAccessScopeModifier,
                            oldNode: propertyDeclaration,
                            newNode: fixItPropertyDeclaration1
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierFilePrivate,
                            oldNode: propertyDeclaration,
                            newNode: fixItPropertyDeclaration2
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierInternal,
                            oldNode: propertyDeclaration,
                            newNode: fixItPropertyDeclaration3
                        ),
                        .replace(
                            message: FixItMessage.makeAccessScopeModifierPublic,
                            oldNode: propertyDeclaration,
                            newNode: fixItPropertyDeclaration4
                        )
                    ]
                )
            ])

        default:
            return
            
        }
    }
    
    private static func validatePropertyType(on propertyDeclaration: VariableDeclSyntax) throws {
        
        guard
            let typeAnnotation = propertyDeclaration.bindings.first?.typeAnnotation,
            typeAnnotation.type.as(IdentifierTypeSyntax.self)?.name.text != "String"
        else {
            return
        }
        
        var fixItTypeAnnotation = typeAnnotation
        fixItTypeAnnotation.type = "String"
        
        throw DiagnosticsError(diagnostics: [
            .init(
                node: typeAnnotation,
                message: DiagnosticMessage.needsToBeStringType,
                fixIt: .replace(
                    message: FixItMessage.makePropertyTypeString,
                    oldNode: typeAnnotation, 
                    newNode: fixItTypeAnnotation
                )
            )
        ])
    }
    
    private static func validateEffectSpecifiers(on propertyDeclaration: VariableDeclSyntax) throws {
        
        guard
            case let .accessors(accessorList) = propertyDeclaration.bindings.first?.accessorBlock?.accessors,
            let getterDeclaration = accessorList.first(where: { $0.accessorSpecifier.tokenKind == .keyword(.get) }),
            let effectSpecifiers = getterDeclaration.effectSpecifiers
        else {
            return
        }

        var fixItGetterDeclaration = getterDeclaration
        fixItGetterDeclaration.effectSpecifiers = nil
        
        if effectSpecifiers.asyncSpecifier != nil && effectSpecifiers.throwsSpecifier != nil {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: effectSpecifiers,
                    message: DiagnosticMessage.incorrectAsyncThrowingDeclaration,
                    fixIt: .replace(
                        message: FixItMessage.removeAsyncThrowsSpecifiers,
                        oldNode: getterDeclaration,
                        newNode: fixItGetterDeclaration
                    )
                )
            ])
        } else if effectSpecifiers.asyncSpecifier != nil {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: effectSpecifiers,
                    message: DiagnosticMessage.incorrectAsyncDeclaration,
                    fixIt: .replace(
                        message: FixItMessage.removeAsyncSpecifier,
                        oldNode: getterDeclaration,
                        newNode: fixItGetterDeclaration
                    )
                )
            ])
        } else if effectSpecifiers.throwsSpecifier != nil {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: effectSpecifiers,
                    message: DiagnosticMessage.incorrectThrowingDeclaration,
                    fixIt: .replace(
                        message: FixItMessage.removeThrowsSpecifier,
                        oldNode: getterDeclaration,
                        newNode: fixItGetterDeclaration
                    )
                )
            ])
        }
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case needsToBePublic
        case needsToBeInternal
        case needsToBeFilePrivate
        case needsToBeStringType
        case incorrectThrowingDeclaration
        case incorrectAsyncDeclaration
        case incorrectAsyncThrowingDeclaration
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .needsToBePublic:
            "\"opaqueCode\" needs to be declared as \"public\"."
            
        case .needsToBeInternal:
            "\"opaqueCode\" needs to be declared as \"internal\", \"public\", or with no access modifier."
            
        case .needsToBeFilePrivate:
            "\"opaqueCode\" needs to be declared as \"fileprivate\", \"internal\", \"public\", or with no access modifier."
            
        case .needsToBeStringType:
            "\"opaqueCode\" should be of type \"String\"."
            
        case .incorrectThrowingDeclaration:
            "\"opaqueCode\" should not have a throwing getter."
            
        case .incorrectAsyncDeclaration:
            "\"opaqueCode\" should not have an async getter."
            
        case .incorrectAsyncThrowingDeclaration:
            "\"opaqueCode\" should not have an async throwing getter."
            
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .needsToBePublic:
            "needsToBePublic"
            
        case .needsToBeInternal:
            "needsToBeInternal"
            
        case .needsToBeFilePrivate:
            "needsToBeFilePrivate"
            
        case .needsToBeStringType:
            "needsToBeStringType"
            
        case .incorrectThrowingDeclaration:
            "incorrectThrowingDeclaration"
            
        case .incorrectAsyncDeclaration:
            "incorrectAsyncDeclaration"
            
        case .incorrectAsyncThrowingDeclaration:
            "incorrectAsyncThrowingDeclaration"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .needsToBePublic, .needsToBeInternal, .needsToBeFilePrivate, .needsToBeStringType, .incorrectThrowingDeclaration, .incorrectAsyncDeclaration, .incorrectAsyncThrowingDeclaration:
            .error
        }
    }
}

// MARK: - Fix it message
extension ErrorCodeMacro {
    fileprivate enum FixItMessage {
        
        case makeAccessScopeModifierPublic
        case makeAccessScopeModifierInternal
        case makeAccessScopeModifierFilePrivate
        case removeAccessScopeModifier
        case makePropertyTypeString
        case removeThrowsSpecifier
        case removeAsyncSpecifier
        case removeAsyncThrowsSpecifiers
    }
}

extension ErrorCodeMacro.FixItMessage: SwiftDiagnostics.FixItMessage {
    
    var message: String {
        
        switch self {
        case .makeAccessScopeModifierPublic:
            "Make \"opaqueCode\" \"public\""
            
        case .makeAccessScopeModifierInternal:
            "Make \"opaqueCode\" \"internal\""

        case .makeAccessScopeModifierFilePrivate:
            "Make \"opaqueCode\" \"fileprivate\""

        case .removeAccessScopeModifier:
            "Remove access modifier"
            
        case .makePropertyTypeString:
            "Change \"opaqueCode\" type to \"String\""
            
        case .removeThrowsSpecifier:
            "Remove \"throws\""
            
        case .removeAsyncSpecifier:
            "Remove \"async\""
            
        case .removeAsyncThrowsSpecifiers:
            "Remove \"async throws\""

        }
    }
    
    private var messageID: String {
    
        switch self {
        case .makeAccessScopeModifierPublic:
            "makeAccessScopeModifierPublic"
            
        case .makeAccessScopeModifierInternal:
            "makeAccessScopeModifierInternal"

        case .makeAccessScopeModifierFilePrivate:
            "makeAccessScopeModifierFilePrivate"

        case .removeAccessScopeModifier:
            "removeAccessScopeModifier"

        case .makePropertyTypeString:
            "makePropertyTypeString"
            
        case .removeThrowsSpecifier:
            "removeThrowsSpecifier"
            
        case .removeAsyncSpecifier:
            "removeAsyncSpecifier"

        case .removeAsyncThrowsSpecifiers:
            "removeAsyncThrowsSpecifiers"

        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualOpaqueCodePropertyDeclarationValidation",
            id: messageID
        )
    }
}
