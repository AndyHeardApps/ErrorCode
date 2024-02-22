import SwiftSyntax

extension ErrorCodeMacro {
    
    static func generatedOpaqueCodeProperty(
        for enumCases: [EnumCase],
        accessScopeModifier: TokenSyntax?,
        childCodeDelimiter: String
    ) throws -> DeclSyntax {
        
        let propertyDeclaration = VariableDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: .init {
                if let accessScopeModifier {
                    DeclModifierSyntax(name: accessScopeModifier)
                }
            },
            bindingSpecifier: .keyword(.var),
            bindings: .init {
                PatternBindingSyntax(
                    pattern: IdentifierPatternSyntax(identifier: "opaqueCode"),
                    typeAnnotation: TypeAnnotationSyntax(type: IdentifierTypeSyntax(name: "String")),
                    accessorBlock: .init(
                        accessors: .getter(
                            CodeBlockItemListSyntax([
                                CodeBlockItemSyntax(
                                    item: .init(
                                        SwitchExprSyntax(
                                            subject: DeclReferenceExprSyntax(baseName: .keyword(.`self`)),
                                            cases: .init {
                                                for enumCase in enumCases {
                                                    if enumCase.child.exists {
                                                        SwitchCaseSyntax(
                                                            label: .init(
                                                                .init(
                                                                    caseItems: [
                                                                        SwitchCaseItemSyntax(
                                                                            pattern: ValueBindingPatternSyntax(
                                                                                bindingSpecifier: .keyword(.let),
                                                                                pattern: ExpressionPatternSyntax(
                                                                                    expression: FunctionCallExprSyntax(
                                                                                        calledExpression: MemberAccessExprSyntax(name: .identifier(enumCase.name.text)),
                                                                                        leftParen: .leftParenToken(),
                                                                                        arguments: [
                                                                                            .init(
                                                                                                expression: PatternExprSyntax(
                                                                                                    pattern: IdentifierPatternSyntax(
                                                                                                        identifier: .identifier("child")
                                                                                                    )
                                                                                                )
                                                                                            )
                                                                                        ],
                                                                                        rightParen: .rightParenToken()
                                                                                    )
                                                                                )
                                                                            )
                                                                        )
                                                                    ]
                                                                )
                                                            ),
                                                            statements: [
                                                                .init(
                                                                    item: .init(
                                                                        SequenceExprSyntax {
                                                                            ExprListSyntax {
                                                                                MemberAccessExprSyntax(
                                                                                    base: DeclReferenceExprSyntax(baseName: "OpaqueCode"),
                                                                                    name: enumCase.name
                                                                                )
                                                                                BinaryOperatorExprSyntax(operator: .binaryOperator("+"))
                                                                                StringLiteralExprSyntax(content: childCodeDelimiter)
                                                                                BinaryOperatorExprSyntax(operator: .binaryOperator("+"))
                                                                                FunctionCallExprSyntax(
                                                                                    calledExpression: DeclReferenceExprSyntax(baseName: .identifier("childOpaqueCode")),
                                                                                    leftParen: .leftParenToken(),
                                                                                    arguments: [
                                                                                        .init(
                                                                                            label: "for",
                                                                                            expression: DeclReferenceExprSyntax(baseName: .identifier("child"))
                                                                                        )
                                                                                    ],
                                                                                    rightParen: .rightParenToken()
                                                                                )
                                                                            }
                                                                        }
                                                                    )
                                                                )
                                                            ]
                                                        )
                                                    } else {
                                                        SwitchCaseSyntax(
                                                            label: .init(
                                                                .init(
                                                                    caseItems: [
                                                                        SwitchCaseItemSyntax(
                                                                            pattern: ExpressionPatternSyntax(
                                                                                expression: MemberAccessExprSyntax(name: enumCase.name)
                                                                            )
                                                                        )
                                                                    ]
                                                                )
                                                            ),
                                                            statements: [
                                                                .init(
                                                                    item: .init(
                                                                        MemberAccessExprSyntax(
                                                                            base: DeclReferenceExprSyntax(baseName: "OpaqueCode"),
                                                                            name: enumCase.name
                                                                        )
                                                                    )
                                                                )
                                                            ]
                                                        )
                                                    }
                                                }
                                            }
                                        )
                                    )
                                )
                            ])
                        )
                    )
                )
            }
        )
        
        return DeclSyntax(propertyDeclaration)
    }
}
