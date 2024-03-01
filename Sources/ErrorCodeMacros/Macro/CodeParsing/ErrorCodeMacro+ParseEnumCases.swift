import Foundation
import SwiftSyntax
import SwiftDiagnostics
import SwiftSyntaxMacros

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
                    message: DiagnosticMessage.tooManyAssociatedValuesOnEnumCaseDeclaration
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

// MARK: - Extension case extraction
extension ErrorCodeMacro {
    
    static func parseEnumCases(
        on declaration: ExtensionDeclSyntax,
        opaqueCodeLength: Int,
        opaqueCodeCharacters: [Character],
        context: some MacroExpansionContext
    ) throws -> [EnumCase] {
        
        let arrayDeclaration = try declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { try isValidErrorCodesDeclaration($0, on: declaration.extendedType, context: context) }
            .first
        
        guard let arrayDeclaration else {
            var fixitDeclaration = declaration
            fixitDeclaration.memberBlock.members.append(
                .init(
                    decl: VariableDeclSyntax(
                        leadingTrivia: .newlines(2),
                        modifiers: [
                            .init(name: .keyword(.private), trailingTrivia: .space),
                            .init(name: .keyword(.static), trailingTrivia: .space)
                        ],
                        bindingSpecifier: .init(.keyword(.let), trailingTrivia: .space, presence: .present),
                        bindings: .init {
                            .init(
                                pattern: IdentifierPatternSyntax(identifier: "errorCodes"),
                                typeAnnotation: TypeAnnotationSyntax(
                                    type: ArrayTypeSyntax(
                                        leadingTrivia: .space,
                                        element: IdentifierTypeSyntax(name: .keyword(.Self)),
                                        trailingTrivia: .space
                                    )
                                ),
                                initializer: InitializerClauseSyntax(
                                    equal: .equalToken(trailingTrivia: .space),
                                    value: ArrayExprSyntax(
                                        elements: [
                                            .init(
                                                leadingTrivia: .newline,
                                                expression: EditorPlaceholderExprSyntax(
                                                    placeholder: TokenSyntax(stringLiteral: "<" + "#.value1#>")
                                                ),
                                                trailingComma: .init(.commaToken()),
                                                trailingTrivia: .newline
                                            ),
                                            .init(
                                                expression: EditorPlaceholderExprSyntax(
                                                    placeholder: TokenSyntax(stringLiteral: "<" + "#.value2#>")
                                                ),
                                                trailingTrivia: .newline
                                            )
                                        ]
                                    )
                                )
                            )
                        },
                        trailingTrivia: .newline
                    )
                )
            )
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: declaration,
                    message: DiagnosticMessage.errorCodesDeclarationMissing,
                    fixIt: .replace(
                        message: FixItMessage.addErrorCodesStaticProperty,
                        oldNode: declaration,
                        newNode: fixitDeclaration
                    )
                )
            ])
        }
        
        var enumCases: [EnumCase] = []
        for element in arrayDeclaration.elements {
            guard let memberAccessSyntax = element.expression.as(MemberAccessExprSyntax.self) else {
                throw DiagnosticsError(diagnostics: [
                    .init(
                        node: element,
                        message: DiagnosticMessage.errorCodeNestingNotSupportedInExtensions
                    )
                ])
            }

            enumCases.append(.init(
                name: memberAccessSyntax.declName.baseName,
                opaqueCode: generateOpaqueCode(
                    ofLength: opaqueCodeLength,
                    for: declaration.extendedType.trimmedDescription + "." + memberAccessSyntax.declName.trimmedDescription,
                    opaqueCodeCharacters: opaqueCodeCharacters
                ),
                child: .none
            ))
        }

        return enumCases
    }
    
    private static func isValidErrorCodesDeclaration(
        _ declaration: VariableDeclSyntax,
        on type: TypeSyntax,
        context: some MacroExpansionContext
    ) throws -> ArrayExprSyntax? {
        
        guard 
            declaration.bindings.contains(where: { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == "errorCodes"}),
            declaration.modifiers.contains(where: \.isStaticModifier)
        else {
            return nil
        }
        
        guard
            declaration.bindings.count == 1,
            let binding = declaration.bindings.first
        else {
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: declaration,
                    message: DiagnosticMessage.tooManyBindingsOnErrorCodesDeclaration
                )
            ])
        }
        
        guard
            let typeSyntax = binding.typeAnnotation?.type.as(ArrayTypeSyntax.self),
            let elementType = typeSyntax.element.as(IdentifierTypeSyntax.self),
            elementType.name.text == type.trimmedDescription || typeSyntax.element.as(IdentifierTypeSyntax.self)?.name.text == "Self"
        else {
            var fixItBinding = binding
            fixItBinding.pattern = fixItBinding.pattern.trimmed
            fixItBinding.typeAnnotation = TypeAnnotationSyntax(
                type: ArrayTypeSyntax(
                    leadingTrivia: .space,
                    element: IdentifierTypeSyntax(name: .keyword(.Self)),
                    trailingTrivia: .space
                )
            )
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: binding,
                    message: DiagnosticMessage.incorrectTypeAnnotationOnErrorCodesDeclaration(typeName: type.trimmedDescription),
                    fixIt: .replace(
                        message: FixItMessage.setCorrectTypeAnnotationOnErrorCodesDeclaration,
                        oldNode: binding,
                        newNode: fixItBinding
                    )
                )
            ])
        }
        
        guard let arrayLiteral = binding.initializer?.value.as(ArrayExprSyntax.self) else {
            var fixItBinding = binding
            fixItBinding.initializer = .init(value: ArrayExprSyntax(elements: []))
            throw DiagnosticsError(diagnostics: [
                .init(
                    node: binding,
                    message: DiagnosticMessage.shouldDeclareArrayLiteralForErrorCodesDeclaration,
                    fixIt: .replace(
                        message: FixItMessage.addArrayInitializerForErrorCodesDeclaration,
                        oldNode: binding,
                        newNode: fixItBinding
                    )
                )
            ])
        }
        
        if declaration.modifiers.filter(\.isAccessLevelModifier).first?.name.text != "private" {
            var fixItDeclaration = declaration
            fixItDeclaration.modifiers = fixItDeclaration.modifiers.filter { !$0.isAccessLevelModifier }
            fixItDeclaration.modifiers.append(.init(name: .keyword(.private), trailingTrivia: .space))
            context.diagnose(
                .init(
                    node: declaration,
                    message: DiagnosticMessage.shouldUsePrivateAccessModifierOnErrorCodesDeclaration,
                    fixIt: .replace(
                        message: FixItMessage.setAccessModifierToPrivateOnErrorCodesDeclaration,
                        oldNode: declaration,
                        newNode: fixItDeclaration
                    )
                )
            )
        }
        
        if declaration.bindingSpecifier.text != "let" {
            var fixItDeclaration = declaration
            fixItDeclaration.bindingSpecifier = .keyword(.let, trailingTrivia: .space)
            context.diagnose(
                .init(
                    node: declaration,
                    message: DiagnosticMessage.shouldUseLetBindingSpecifierOnErrorCodesDeclaration,
                    fixIt: .replace(
                        message: FixItMessage.setBindingSpecifierToLetOnErrorCodesDeclaration,
                        oldNode: declaration,
                        newNode: fixItDeclaration
                    )
                )
            )
        }
                
        return arrayLiteral
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case tooManyAssociatedValuesOnEnumCaseDeclaration
        case errorCodesDeclarationMissing
        case errorCodeNestingNotSupportedInExtensions
        case tooManyBindingsOnErrorCodesDeclaration
        case incorrectTypeAnnotationOnErrorCodesDeclaration(typeName: String)
        case shouldDeclareArrayLiteralForErrorCodesDeclaration
        case shouldUsePrivateAccessModifierOnErrorCodesDeclaration
        case shouldUseLetBindingSpecifierOnErrorCodesDeclaration
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .tooManyAssociatedValuesOnEnumCaseDeclaration:
            "\"@ErrorCode\" enum cases may only have up to one associated value, which must also be an \"ErrorCode\"."
            
        case .errorCodesDeclarationMissing:
            "Using the \"@ErrorCodeExtension\" macro on an extension requires that a manual list of cases be provided as a static property \"static let errorCodes: [Self] = []\"."
            
        case .errorCodeNestingNotSupportedInExtensions:
            "Nested error codes are not supported when using the \"@ErrorCodeExtension\" macro."
            
        case .tooManyBindingsOnErrorCodesDeclaration:
            "\"errorCodes\" should declare a single binding."
            
        case let .incorrectTypeAnnotationOnErrorCodesDeclaration(typeName):
            "\"errorCodes\" should explicitly declare a type of \"[Self]\" or \"[\(typeName)]\"."

        case .shouldDeclareArrayLiteralForErrorCodesDeclaration:
            "\"errorCodes\" should include an array literal initializer containing all cases to generate an opaque code for."

        case .shouldUsePrivateAccessModifierOnErrorCodesDeclaration:
            "\"errorCodes\" should be declared as private to avoid namespace pollution."

        case .shouldUseLetBindingSpecifierOnErrorCodesDeclaration:
            "\"errorCodes\" should be bound using \"let\"."

        }
    }
    
    private var messageID: String {
        
        switch self {
        case .tooManyAssociatedValuesOnEnumCaseDeclaration:
            "tooManyAssociatedValuesOnEnumCaseDeclaration"
            
        case .errorCodesDeclarationMissing:
            "errorCodesDeclarationMissing"
            
        case .errorCodeNestingNotSupportedInExtensions:
            "errorCodeNestingNotSupportedInExtensions"
            
        case .tooManyBindingsOnErrorCodesDeclaration:
            "tooManyBindingsOnErrorCodesDeclaration"
            
        case .incorrectTypeAnnotationOnErrorCodesDeclaration:
            "incorrectTypeAnnotationOnErrorCodesDeclaration"
            
        case .shouldDeclareArrayLiteralForErrorCodesDeclaration:
            "shouldDeclareArrayLiteralForErrorCodesDeclaration"
            
        case .shouldUsePrivateAccessModifierOnErrorCodesDeclaration:
            "shouldUsePrivateAccessModifierOnErrorCodesDeclaration"
            
        case .shouldUseLetBindingSpecifierOnErrorCodesDeclaration:
            "shouldUseLetBindingSpecifierOnErrorCodesDeclaration"
            
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
        case .tooManyAssociatedValuesOnEnumCaseDeclaration, .errorCodesDeclarationMissing, .errorCodeNestingNotSupportedInExtensions, .tooManyBindingsOnErrorCodesDeclaration, .incorrectTypeAnnotationOnErrorCodesDeclaration, .shouldDeclareArrayLiteralForErrorCodesDeclaration:
            .error
            
        case .shouldUsePrivateAccessModifierOnErrorCodesDeclaration, .shouldUseLetBindingSpecifierOnErrorCodesDeclaration:
            .warning
            
        }
    }
}

// MARK: - Fix it message
extension ErrorCodeMacro {
    fileprivate enum FixItMessage {
        
        case addErrorCodesStaticProperty
        case setCorrectTypeAnnotationOnErrorCodesDeclaration
        case addArrayInitializerForErrorCodesDeclaration
        case setAccessModifierToPrivateOnErrorCodesDeclaration
        case setBindingSpecifierToLetOnErrorCodesDeclaration
    }
}

extension ErrorCodeMacro.FixItMessage: SwiftDiagnostics.FixItMessage {
    
    var message: String {
        
        switch self {
        case .addErrorCodesStaticProperty:
            "Add \"errorCodes\" property"
            
        case .setCorrectTypeAnnotationOnErrorCodesDeclaration:
            "Set type annotation to \"[Self]\""
            
        case .addArrayInitializerForErrorCodesDeclaration:
            "Add array initializer"
            
        case .setAccessModifierToPrivateOnErrorCodesDeclaration:
            "Make \"errorCodes\" \"private\""
            
        case .setBindingSpecifierToLetOnErrorCodesDeclaration:
            "Bind \"errorCodes\" using \"let\""

        }
    }
    
    private var messageID: String {
    
        switch self {
        case .addErrorCodesStaticProperty:
            "addErrorCodesStaticProperty"
            
        case .setCorrectTypeAnnotationOnErrorCodesDeclaration:
            "setCorrectTypeAnnotationOnErrorCodesDeclaration"
            
        case .addArrayInitializerForErrorCodesDeclaration:
            "addArrayInitializerForErrorCodesDeclaration"
            
        case .setAccessModifierToPrivateOnErrorCodesDeclaration:
            "setAccessModifierToPrivateOnErrorCodesDeclaration"
            
        case .setBindingSpecifierToLetOnErrorCodesDeclaration:
            "setBindingSpecifierToLetOnErrorCodesDeclaration"

        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        
        .init(
            domain: "ErrorCodeMacro.CaseParsing",
            id: messageID
        )
    }
}

extension Collection where Element == ErrorCodeMacro.EnumCase {
    
    var hasChildren: Bool {
        
        !self.allSatisfy { !$0.child.exists }
    }
}
