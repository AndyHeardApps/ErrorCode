import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ErrorCodeMacro {}

// MARK: - Constants
extension ErrorCodeMacro {}

// MARK: - Extension macro
extension ErrorCodeMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: Syntax(declaration),
                    message: DiagnosticMessage.notAnEnum
                )
            ])
        }

        let (opaqueCodeLengthIsDeclaredManually, opaqueCodeLength) = parseCustomOpaqueCodeLength(
            from: node,
            context: context
        )
        let (childCodeDelimiterIsDeclaredManually, childCodeDelimiter) = parseCustomChildCodeDelimiter(
            from: node,
            context: context
        )
        let (opaqueCodeCharactersIsDeclaredManually, opaqueCodeCharacters) = parseCustomOpaqueCodeCharacters(
            from: node,
            context: context
        )
        let enumCases = try parseEnumCases(
            on: enumDeclaration,
            opaqueCodeLength: opaqueCodeLength,
            opaqueCodeCharacters: opaqueCodeCharacters
        )
        let accessScopeModifier = declaration.modifiers.first(where: \.isNeededAccessLevelModifier)?.minimumProtocolWitnessVisibilityForAccessModifier
        
        let shouldGenerateOpaqueCodeStaticValues = try shouldGenerateOpaqueCodeStaticValues(
            from: enumDeclaration,
            enumCases: enumCases
        )
        
        let shouldGenerateOpaqueCodeProperty = try shouldGenerateOpaqueCodeProperty(
            from: enumDeclaration,
            accessScopeModifier: accessScopeModifier
        )
        
        let shouldGenerateChildOpaqueCodeFunction = try shouldGenerateChildOpaqueCodeFunction(
            from: enumDeclaration,
            with: enumCases,
            isGeneratingOpaqueCodeProperty: shouldGenerateOpaqueCodeProperty,
            context: context
        )
                
        let shouldGenerateOpaqueCodeInitializer = try shouldGenerateOpaqueCodeInitializer(
            from: enumDeclaration,
            accessScopeModifier: accessScopeModifier,
            context: context
        )
        
        let shouldGenerateChildErrorCodeFunction = shouldGenerateChildErrorCodeFunction(
            from: enumDeclaration,
            with: enumCases,
            isGeneratingOpaqueCodeInitializer: shouldGenerateOpaqueCodeInitializer,
            context: context
        )
        
        let shouldGenerateOpaqueCodeErrors = shouldGenerateOpaqueCodeErrors(
            from: enumDeclaration,
            isGeneratingOpaqueCodeInitializer: shouldGenerateOpaqueCodeInitializer,
            context: context
        )

        let errorCodeExtension = try ExtensionDeclSyntax(
            extendedType: type,
            inheritanceClause: inheritanceClause(syntax: declaration.inheritanceClause),
            memberBlock: .init(
                members: .init {
                    if shouldGenerateOpaqueCodeStaticValues {
                        try generatedOpaqueCodeStaticValues(
                            of: node,
                            attachedTo: enumDeclaration,
                            with: enumCases,
                            definingOpaqueCodeLength: opaqueCodeLength,
                            context: context
                        )
                    }
                    
                    if shouldGenerateOpaqueCodeProperty {
                        try generatedOpaqueCodeProperty(
                            for: enumCases,
                            accessScopeModifier: accessScopeModifier,
                            childCodeDelimiter: childCodeDelimiter
                        )
                    }
                    
                    if shouldGenerateChildOpaqueCodeFunction {
                        generatedChildOpaqueCodeFunction()
                    }
                    
                    if shouldGenerateOpaqueCodeInitializer {
                        try generatedOpaqueCodeInitializer(
                            for: enumCases,
                            accessScopeModifier: accessScopeModifier,
                            childCodeDelimiter: childCodeDelimiter
                        )
                    }

                    if shouldGenerateChildErrorCodeFunction  {
                        generatedChildErrorCodeFunction()
                    }
                    
                    if shouldGenerateOpaqueCodeErrors {
                        generatedOpaqueCodeErrors()
                    }
                }
            )
        )
        
        if opaqueCodeLengthIsDeclaredManually && !shouldGenerateOpaqueCodeStaticValues {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues
                )
            )
        }
        
        if opaqueCodeCharactersIsDeclaredManually && !shouldGenerateOpaqueCodeStaticValues {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues
                )
            )
        }

        if childCodeDelimiterIsDeclaredManually, !(shouldGenerateOpaqueCodeInitializer || shouldGenerateOpaqueCodeProperty) {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.customOpaqueCodeDelimiterDeclaredAlongsideManualInitializerAndProperty
                )
            )
        }
        
        if childCodeDelimiterIsDeclaredManually, !enumCases.hasChildren {
            context.diagnose(
                .init(
                    node: node,
                    message: DiagnosticMessage.customOpaqueCodeDelimiterDeclaredOnEnumWithNoChildren
                )
            )
        }
        
        return [
            errorCodeExtension
        ]
    }
    
    private static func inheritanceClause(syntax: InheritanceClauseSyntax?) -> InheritanceClauseSyntax? {
        
        let inheritedTypeNames = syntax?.inheritedTypes
            .compactMap { type in
                type.as(InheritedTypeSyntax.self)?
                    .type
                    .as(IdentifierTypeSyntax.self)?
                    .name.text
            } ?? []
        
        if inheritedTypeNames.contains("ErrorCode") {
            return nil
        }
            
        let inheritanceClause = InheritanceClauseSyntax(
            inheritedTypes: [
                .init(
                    type: IdentifierTypeSyntax(name: "ErrorCode")
                )
            ]
        )
        
        return inheritanceClause
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case notAnEnum
        case customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues
        case customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues
        case customOpaqueCodeDelimiterDeclaredAlongsideManualInitializerAndProperty
        case customOpaqueCodeDelimiterDeclaredOnEnumWithNoChildren
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .notAnEnum:
            "Macro \"@ErrorCode\" can only be applied to an enum."
            
        case .customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues:
            "\"OpaqueCode\" values are declared manually, so the \"codeLength\" parameter will be ignored."
            
        case .customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues:
            "\"OpaqueCode\" values are declared manually, so the \"codeCharacters\" parameter will be ignored."

        case .customOpaqueCodeDelimiterDeclaredAlongsideManualInitializerAndProperty:
            "\"opaqueCode\" property and \"init(opaqueCode: _)\" are declared manually, so the \"delimiter\" parameter will be ignored."
            
        case .customOpaqueCodeDelimiterDeclaredOnEnumWithNoChildren:
            "Enum has no nested errors, so the \"delimiter\" parameter will be ignored."

        }
    }
    
    private var messageID: String {
        
        switch self {
        case .notAnEnum:
            "notAnEnum"
            
        case .customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues:
            "customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues"
            
        case .customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues:
            "customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues"
            
        case .customOpaqueCodeDelimiterDeclaredAlongsideManualInitializerAndProperty:
            "customOpaqueCodeDelimiterDeclaredAlongsideManualInitializerAndProperty"
            
        case .customOpaqueCodeDelimiterDeclaredOnEnumWithNoChildren:
            "customOpaqueCodeDelimiterDeclaredOnEnumWithNoChildren"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .notAnEnum:
            .error
            
        case .customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues, .customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues, .customOpaqueCodeDelimiterDeclaredAlongsideManualInitializerAndProperty, .customOpaqueCodeDelimiterDeclaredOnEnumWithNoChildren:
            .warning
            
        }
    }
}
