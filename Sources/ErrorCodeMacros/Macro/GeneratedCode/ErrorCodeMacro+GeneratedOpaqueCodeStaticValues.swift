import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    static func generatedOpaqueCodeStaticValues(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        with enumCases: [EnumCase],
        definingOpaqueCodeLength currentOpaqueCodeLength: Int,
        context: some MacroExpansionContext
    ) throws -> DeclSyntax {
        
        let enumDeclaration = generatedOpaqueCodeValuesEnumDeclaraton(for: enumCases, placeholderValues: false)
        
        assertNoDuplicateGeneratedOpaqueCodes(
            generatedFrom: node,
            attachedTo: declaration,
            with: enumCases,
            definingOpaqueCodeLength: currentOpaqueCodeLength,
            context: context
        )

        return DeclSyntax(enumDeclaration)
    }
    
    private static func generatedOpaqueCodeValuesEnumDeclaraton(
        for enumCases: [EnumCase],
        placeholderValues: Bool
    ) -> EnumDeclSyntax {
        
        EnumDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: [
                .init(name: .keyword(.private), trailingTrivia: .space)
            ],
            enumKeyword: .keyword(.enum, trailingTrivia: .space, presence: .present),
            name: TokenSyntax(.stringSegment("OpaqueCode"), trailingTrivia: .space, presence: .present),
            memberBlock: .init(
                members: .init {
                    for enumCase in enumCases {
                        VariableDeclSyntax(
                            leadingTrivia: .newline,
                            modifiers: [
                                .init(name: .keyword(.static), trailingTrivia: .space)
                            ],
                            bindingSpecifier: .init(.keyword(.let), trailingTrivia: .space, presence: .present),
                            bindings: .init {
                                .init(
                                    pattern: IdentifierPatternSyntax(identifier: enumCase.name, trailingTrivia: .space),
                                    initializer: InitializerClauseSyntax(
                                        equal: .equalToken(trailingTrivia: .space),
                                        value: ExprSyntax(fromProtocol: placeholderValues ? EditorPlaceholderExprSyntax(placeholder: TokenSyntax(stringLiteral: "\"<" + "#\(enumCase.name.text)#>\"")) : StringLiteralExprSyntax(content: enumCase.opaqueCode.text))
                                    )
                                )
                            }
                        )
                    }
                },
                rightBrace: .rightBraceToken(leadingTrivia: .newline)
            )
        )
    }
    
    private static func assertNoDuplicateGeneratedOpaqueCodes(
        generatedFrom node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        with enumCases: [EnumCase],
        definingOpaqueCodeLength currentOpaqueCodeLength: Int,
        context: some MacroExpansionContext
    ) {
        
        var usedOpaqueCodes: Set<String> = []
        var duplicateCases: [EnumCase] = []
        for enumCase in enumCases {
            if usedOpaqueCodes.contains(enumCase.opaqueCode.text) {
                duplicateCases.append(enumCase)
            } else {
                usedOpaqueCodes.insert(enumCase.opaqueCode.text)
            }
        }
        
        guard !duplicateCases.isEmpty else {
            return
        }
        
        let fixItDeclarationMembers = MemberBlockItemListSyntax {
            declaration.memberBlock.members
            generatedOpaqueCodeValuesEnumDeclaraton(
                for: enumCases, 
                placeholderValues: true
            )
        }
        
        var fixitNode = node
        if var arguments = fixitNode.arguments?.as(LabeledExprListSyntax.self) {
            arguments = arguments.filter { $0.label?.text != "codeLength" }
            arguments.insert(
                .init(
                    label: "codeLength",
                    colon: .colonToken(trailingTrivia: .space),
                    expression: IntegerLiteralExprSyntax(integerLiteral: currentOpaqueCodeLength + 1),
                    trailingComma: arguments.isEmpty ? nil : .commaToken(trailingTrivia: .space)
                ),
                at: arguments.startIndex
            )
            fixitNode.arguments = .argumentList(arguments)
        } else {
            fixitNode.leftParen = .leftParenToken()
            fixitNode.arguments = .argumentList([
                .init(
                    label: "codeLength",
                    colon: .colonToken(trailingTrivia: .space),
                    expression: IntegerLiteralExprSyntax(integerLiteral: currentOpaqueCodeLength + 1)
                )
            ])
            fixitNode.rightParen = .rightParenToken()
        }

        context.diagnose(
            .init(
                node: Syntax(declaration),
                message: DiagnosticMessage.opaqueCodeCollision(duplicateCases),
                fixIts: [
                    .replace(
                        message: FixItMessage.useLongerGeneratedCodes(currentLength: currentOpaqueCodeLength, macroName: node.attributeName.trimmedDescription),
                        oldNode: node,
                        newNode: fixitNode
                    ),
                    .replace(
                        message: FixItMessage.declareManualOpaqueCodes,
                        oldNode: declaration.memberBlock.members,
                        newNode: fixItDeclarationMembers
                    )
                ]
            )
        )
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case opaqueCodeCollision([ErrorCodeMacro.EnumCase])
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case let .opaqueCodeCollision(enumCases):
            "Generated opaque code collision on: \(enumCases.map(\.name.text).map { "\"\($0)\"" }.joined(separator: ", "))."
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .opaqueCodeCollision:
            "opaqueCodeCollision"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.GeneratedOpaqueCodes",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .opaqueCodeCollision:
            .error
        }
    }
}

// MARK: - Fix it message
extension ErrorCodeMacro {
    fileprivate enum FixItMessage {
        
        case useLongerGeneratedCodes(currentLength: Int, macroName: String)
        case declareManualOpaqueCodes
    }
}

extension ErrorCodeMacro.FixItMessage: SwiftDiagnostics.FixItMessage {
    
    var message: String {
        
        switch self {
        case let .useLongerGeneratedCodes(currentLength, macroName):
            "Specify a longer code length with \"@\(macroName)(codeLength: \(currentLength + 1))\""
            
        case .declareManualOpaqueCodes:
            "Declare opaque codes manually"
        
        }
    }
    
    private var messageID: String {
    
        switch self {
        case .useLongerGeneratedCodes:
            "useLongerGeneratedCodes"
            
        case .declareManualOpaqueCodes:
            "declareManualOpaqueCodes"

        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        
        .init(
            domain: "ErrorCodeMacro.GeneratedOpaqueCodes",
            id: messageID
        )
    }
}
