import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct ErrorCodeMacro {}

// MARK: - Constants
extension ErrorCodeMacro {}

// MARK: - Member macro
extension ErrorCodeMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
       
        guard node.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ErrorCodeExtension" else {
            return []
        }

        guard let extensionDeclaration = declaration.as(ExtensionDeclSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: declaration,
                    message: DiagnosticMessage.notAnExtension
                )
            ])
        }
        
        if inheritanceClause(syntax: extensionDeclaration.inheritanceClause) != nil {
            var fixItDeclaration = extensionDeclaration
            if fixItDeclaration.inheritanceClause == nil {
                fixItDeclaration.inheritanceClause = .init(inheritedTypes: [])
            }
            fixItDeclaration.extendedType = fixItDeclaration.extendedType.trimmed
            fixItDeclaration.inheritanceClause = fixItDeclaration.inheritanceClause?.trimmed
            if !fixItDeclaration.inheritanceClause!.inheritedTypes.isEmpty {
                let lastIndex = fixItDeclaration.inheritanceClause!.inheritedTypes.indices.last!
                fixItDeclaration.inheritanceClause!.inheritedTypes[lastIndex].trailingComma = .commaToken()
            }
            fixItDeclaration.inheritanceClause?.inheritedTypes.append(
                .init(
                    leadingTrivia: .space,
                    type: IdentifierTypeSyntax(name: "ErrorCode"),
                    trailingTrivia: .space
                )
            )

            context.diagnose(
                .init(
                    node: declaration,
                    message: DiagnosticMessage.extensionDoesNotAddErrorCodeConformance,
                    fixIt: .replace(
                        message: FixItMessage.addErrorCodeConformance,
                        oldNode: declaration,
                        newNode: fixItDeclaration
                    )
                )
            )
        }
        
        let (opaqueCodeLengthIsDeclaredManually, opaqueCodeLength) = parseCustomOpaqueCodeLength(
            from: node,
            context: context
        )
        let (opaqueCodeCharactersIsDeclaredManually, opaqueCodeCharacters) = parseCustomOpaqueCodeCharacters(
            from: node,
            context: context
        )
        let enumCases = try parseEnumCases(
            on: extensionDeclaration,
            opaqueCodeLength: opaqueCodeLength,
            opaqueCodeCharacters: opaqueCodeCharacters,
            context: context
        )
        
        let accessScopeModifier = extensionDeclaration.modifiers.first(where: \.isNeededAccessLevelModifier)?.minimumProtocolWitnessVisibilityForAccessModifier ?? .keyword(.public)
        
        let shouldGenerateOpaqueCodeStaticValues = try shouldGenerateOpaqueCodeStaticValues(
            from: extensionDeclaration,
            enumCases: enumCases
        )
        
        let shouldGenerateOpaqueCodeProperty = try shouldGenerateOpaqueCodeProperty(
            from: extensionDeclaration,
            accessScopeModifier: accessScopeModifier
        )
                        
        let shouldGenerateOpaqueCodeInitializer = try shouldGenerateOpaqueCodeInitializer(
            from: extensionDeclaration,
            accessScopeModifier: accessScopeModifier,
            context: context
        )
        
        let shouldGenerateOpaqueCodeErrors = shouldGenerateOpaqueCodeErrors(
            from: extensionDeclaration,
            isGeneratingOpaqueCodeInitializer: shouldGenerateOpaqueCodeInitializer,
            context: context
        )

        var declarations: [DeclSyntax] = []
        if shouldGenerateOpaqueCodeStaticValues {
            try declarations.append(
                generatedOpaqueCodeStaticValues(
                    of: node,
                    attachedTo: extensionDeclaration,
                    with: enumCases,
                    definingOpaqueCodeLength: opaqueCodeLength,
                    context: context
                )
            )
        }

        if shouldGenerateOpaqueCodeProperty {
            try declarations.append(
                generatedOpaqueCodeProperty(
                    for: enumCases,
                    accessScopeModifier: accessScopeModifier,
                    childCodeDelimiter: ""
                )
            )
        }
        
        if shouldGenerateOpaqueCodeInitializer {
            try declarations.append(
                generatedOpaqueCodeInitializer(
                    for: enumCases,
                    accessScopeModifier: accessScopeModifier,
                    childCodeDelimiter: ""
                )
            )
        }

        if shouldGenerateOpaqueCodeErrors {
            declarations.append(
                generatedOpaqueCodeErrors()
            )
        }
        
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
        
        return declarations
    }
}

// MARK: - Extension macro
extension ErrorCodeMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        guard node.attributeName.as(IdentifierTypeSyntax.self)?.name.text == "ErrorCode" else {
            return []
        }
        
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
            from: declaration,
            enumCases: enumCases
        )
        
        let shouldGenerateOpaqueCodeProperty = try shouldGenerateOpaqueCodeProperty(
            from: declaration,
            accessScopeModifier: accessScopeModifier
        )
        
        let shouldGenerateChildOpaqueCodeFunction = try shouldGenerateChildOpaqueCodeFunction(
            from: declaration,
            with: enumCases,
            isGeneratingOpaqueCodeProperty: shouldGenerateOpaqueCodeProperty,
            context: context
        )
                
        let shouldGenerateOpaqueCodeInitializer = try shouldGenerateOpaqueCodeInitializer(
            from: declaration,
            accessScopeModifier: accessScopeModifier,
            context: context
        )
        
        let shouldGenerateChildErrorCodeFunction = shouldGenerateChildErrorCodeFunction(
            from: declaration,
            with: enumCases,
            isGeneratingOpaqueCodeInitializer: shouldGenerateOpaqueCodeInitializer,
            context: context
        )
        
        let shouldGenerateOpaqueCodeErrors = shouldGenerateOpaqueCodeErrors(
            from: declaration,
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
                            attachedTo: declaration,
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
        case notAnExtension
        case extensionDoesNotAddErrorCodeConformance
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
            
        case .notAnExtension:
            "Macro \"@ErrorCodeExtension\" can only be applied to an extension of an enum."

        case .extensionDoesNotAddErrorCodeConformance:
            "Macro \"@ErrorCodeExtension\" is a member macro and can not automatically add \"ErrorCode\" conformance."
            
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
            
        case .notAnExtension:
            "notAnExtension"
            
        case .extensionDoesNotAddErrorCodeConformance:
            "extensionDoesNotAddErrorCodeConformance"
            
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
        case .notAnEnum, .notAnExtension:
            .error
            
        case .extensionDoesNotAddErrorCodeConformance, .customOpaqueCodeLengthDeclaredAlongsideManualOpaqueCodeStaticValues, .customOpaqueCodeCharactersDeclaredAlongsideManualOpaqueCodeStaticValues, .customOpaqueCodeDelimiterDeclaredAlongsideManualInitializerAndProperty, .customOpaqueCodeDelimiterDeclaredOnEnumWithNoChildren:
            .warning
            
        }
    }
}

// MARK: - Fix it message
extension ErrorCodeMacro {
    fileprivate enum FixItMessage {
        
        case addErrorCodeConformance
    }
}

extension ErrorCodeMacro.FixItMessage: SwiftDiagnostics.FixItMessage {
    
    var message: String {
        
        switch self {
        case .addErrorCodeConformance:
            "Add \"ErrorCode\" conformance"
            
        }
    }
    
    private var messageID: String {
    
        switch self {
        case .addErrorCodeConformance:
            "addErrorCodeConformance"
            
        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        
        .init(
            domain: "ErrorCodeMacro",
            id: messageID
        )
    }
}
