import SwiftSyntax

extension ErrorCodeMacro {
    
    static func generatedOpaqueCodeInitializer(
        for enumCases: [EnumCase],
        accessScopeModifier: TokenSyntax?,
        childCodeDelimiter: String
    ) throws -> DeclSyntax {
        
        let initializerDeclaration = InitializerDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: .init(
                [
                    accessScopeModifier.map { DeclModifierSyntax(name: $0) }
                ]
                .compactMap { $0 }
            ),
            signature: .init(
                parameterClause: .init(
                    parameters: [
                        .init(
                            firstName: "opaqueCode",
                            type: TypeSyntax(stringLiteral: "String")
                        )
                    ]
                ),
                effectSpecifiers: .init(throwsClause: .init(throwsSpecifier: .keyword(.throws)))
            ),
            body: .init(statements: bodyStatements(enumCases: enumCases, childCodeDelimiter: childCodeDelimiter))
        )

        return DeclSyntax(initializerDeclaration)
    }
    
    private static func bodyStatements(
        enumCases: [EnumCase],
        childCodeDelimiter: String
    ) -> CodeBlockItemListSyntax {
        
        if enumCases.hasChildren {
            return [
                .init(item: .init(componentsDeclaration(childCodeDelimiter: childCodeDelimiter))),
                .init(item: .init(guardStatement(enumCasesHaveChildren: true))),
                .init(item: .init(firstComponentDeclaration)),
                .init(item: .init(switchStatement(enumCases: enumCases, enumCasesHaveChildren: true, childCodeDelimiter: childCodeDelimiter)))
            ]
        } else {
            return [
                .init(item: .init(guardStatement(enumCasesHaveChildren: false))),
                .init(item: .init(switchStatement(enumCases: enumCases, enumCasesHaveChildren: false, childCodeDelimiter: childCodeDelimiter)))
            ]
        }
    }
    
    private static func componentsDeclaration(childCodeDelimiter: String) -> VariableDeclSyntax {
        
        .init(
            leadingTrivia: .newlines(2),
            bindingSpecifier: .keyword(.var),
            bindings: [
                .init(
                    pattern: IdentifierPatternSyntax(identifier: "components"),
                    initializer: .init(
                        value: FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(baseName: "opaqueCode"),
                                declName: DeclReferenceExprSyntax(baseName: "split")
                            ),
                            leftParen: .leftParenToken(),
                            arguments: [
                                .init(
                                    label: "separator",
                                    expression: StringLiteralExprSyntax(content: childCodeDelimiter)
                                )
                            ],
                            rightParen: .rightParenToken()
                        )
                    )
                )
            ]
        )
    }
    
    private static func guardStatement(enumCasesHaveChildren: Bool) -> GuardStmtSyntax {
        
        GuardStmtSyntax(
            leadingTrivia: enumCasesHaveChildren ? .newline : .newlines(2),
            guardKeyword: .keyword(.guard, trailingTrivia: .space),
            conditions: [
                .init(
                    condition: .expression(
                        .init(
                            SequenceExprSyntax(elements: [
                                .init(
                                    MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(baseName: enumCasesHaveChildren ? "components" : "opaqueCode"),
                                        declName: DeclReferenceExprSyntax(baseName: "isEmpty")
                                    )
                                ),
                                .init(BinaryOperatorExprSyntax(operator: .binaryOperator("=="))),
                                .init(BooleanLiteralExprSyntax(false))
                            ])
                        )
                    )
                )
            ],
            body: .init(statements: [
                .init(
                    item: .stmt(
                        .init(
                            ThrowStmtSyntax(
                                expression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: "OpaqueCodeError"),
                                    declName: DeclReferenceExprSyntax(baseName: "opaqueCodeIsEmpty")
                                )
                            )
                        )
                    )
                )
            ]),
            trailingTrivia: .newlines(2)
        )
    }
    
    private static var firstComponentDeclaration: VariableDeclSyntax {
        
        .init(
            bindingSpecifier: .keyword(.let),
            bindings: [
                .init(
                    pattern: IdentifierPatternSyntax(identifier: "firstComponent"),
                    initializer: .init(
                        value: FunctionCallExprSyntax(
                            calledExpression: MemberAccessExprSyntax(
                                base: DeclReferenceExprSyntax(baseName: "components"),
                                declName: DeclReferenceExprSyntax(baseName: "removeFirst")
                            ),
                            leftParen: .leftParenToken(),
                            arguments: [],
                            rightParen: .rightParenToken()
                        )
                    )
                )
            ]
        )
    }
    
    private static func switchStatement(
        enumCases: [EnumCase],
        enumCasesHaveChildren: Bool,
        childCodeDelimiter: String
    ) -> SwitchExprSyntax {
        
        .init(
            subject: DeclReferenceExprSyntax(baseName: enumCasesHaveChildren ? "firstComponent" : "opaqueCode"),
            cases: .init(
                enumCases.map { enumCase -> SwitchCaseListSyntax.Element in
                    if enumCase.child.exists {
                        .switchCase(nestedEnumCase(for: enumCase, childCodeDelimiter: childCodeDelimiter))
                    } else {
                        .switchCase(unnestedEnumCase(for: enumCase, enumCasesHaveChildren: enumCasesHaveChildren))
                    }
                } 
                + CollectionOfOne(.switchCase(defaultEnumCase(enumCasesHaveChildren: enumCasesHaveChildren)))
            ),
            rightBrace: .rightBraceToken(leadingTrivia: .newlines(2))
        )
    }
    
    private static func unnestedEnumCase(
        for enumCase: EnumCase,
        enumCasesHaveChildren: Bool
    ) -> SwitchCaseSyntax {
        
        let guardStatement = CodeBlockItemSyntax(
            item: .init(
                GuardStmtSyntax(
                    conditions: [
                        .init(
                            condition: .expression(
                                .init(MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: "components"),
                                    declName: DeclReferenceExprSyntax(baseName: "isEmpty"))
                                )
                            )
                        )
                    ],
                    body: .init(statements: [
                        .init(
                            item: .stmt(
                                .init(
                                    ThrowStmtSyntax(
                                        expression: FunctionCallExprSyntax(
                                            calledExpression: MemberAccessExprSyntax(
                                                base: DeclReferenceExprSyntax(baseName: "OpaqueCodeError"),
                                                declName: DeclReferenceExprSyntax(baseName: "unusedOpaqueCodeComponents")
                                            ),
                                            leftParen: .leftParenToken(),
                                            arguments: [
                                                LabeledExprSyntax(
                                                    expression: FunctionCallExprSyntax(
                                                        calledExpression: MemberAccessExprSyntax(
                                                            base: DeclReferenceExprSyntax(baseName: "components"),
                                                            declName: DeclReferenceExprSyntax(baseName: "map")
                                                        ),
                                                        leftParen: .leftParenToken(),
                                                        arguments: [
                                                            LabeledExprSyntax(
                                                                expression: MemberAccessExprSyntax(
                                                                    base: DeclReferenceExprSyntax(baseName: "String"),
                                                                    declName: DeclReferenceExprSyntax(baseName: .keyword(.`init`))
                                                                )
                                                            )
                                                        ],
                                                        rightParen: .rightParenToken()
                                                    )
                                                )
                                            ],
                                            rightParen: .rightParenToken()
                                        )
                                    )
                                )
                            )
                        )
                    ])
                )
            )
        )
            
        let selfAssignment = CodeBlockItemSyntax(
                item: .expr(
                    .init(
                        SequenceExprSyntax(elements: [
                            .init(DeclReferenceExprSyntax(baseName: .keyword(.`self`))),
                            .init(AssignmentExprSyntax()),
                            .init(MemberAccessExprSyntax(declName: DeclReferenceExprSyntax(baseName: enumCase.name)))
                        ])
                    )
                )
            )
        
        return .init(
            leadingTrivia: .newline,
            label: .init(
                .init(
                    caseItems: [
                        .init(
                            pattern: ExpressionPatternSyntax(
                                expression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: "OpaqueCode"),
                                    declName: DeclReferenceExprSyntax(baseName: enumCase.name)
                                )
                            )
                        )
                    ]
                )
            ),
            statements: enumCasesHaveChildren ? [
                guardStatement,
                selfAssignment
            ] : [
                selfAssignment
            ],
            trailingTrivia: .newline
        )
    }
    
    private static func nestedEnumCase(
        for enumCase: EnumCase,
        childCodeDelimiter: String
    ) -> SwitchCaseSyntax {
        
        .init(
                leadingTrivia: .newline,
                label: .init(
                    .init(
                        caseItems: [
                            .init(
                                pattern: ExpressionPatternSyntax(
                                    expression: MemberAccessExprSyntax(
                                        base: DeclReferenceExprSyntax(baseName: "OpaqueCode"),
                                        declName: DeclReferenceExprSyntax(baseName: enumCase.name)
                                    )
                                )
                            )
                        ]
                    )
                ),
                statements: [
                    .init(
                        item: .init(
                            VariableDeclSyntax(
                                bindingSpecifier: .keyword(.let), 
                                bindings: [
                                    .init(
                                        pattern: IdentifierPatternSyntax(identifier: "remainingComponents"),
                                        initializer: .init(value: FunctionCallExprSyntax(
                                            calledExpression: MemberAccessExprSyntax(
                                                base: DeclReferenceExprSyntax(baseName: "components"),
                                                declName: DeclReferenceExprSyntax(baseName: "joined")
                                            ),
                                            leftParen: .leftParenToken(),
                                            arguments: [
                                                LabeledExprSyntax(
                                                    label: "separator",
                                                    expression: StringLiteralExprSyntax(content: childCodeDelimiter)
                                                )
                                            ],
                                            rightParen: .rightParenToken()
                                        ))
                                    )
                                ]
                            )
                        )
                    ),
                    .init(
                        item: .expr(
                            .init(
                                SequenceExprSyntax(elements: [
                                    .init(DeclReferenceExprSyntax(baseName: .keyword(.`self`))),
                                    .init(AssignmentExprSyntax()),
                                    .init(TryExprSyntax(
                                        expression: FunctionCallExprSyntax(
                                            calledExpression: MemberAccessExprSyntax(
                                                declName: DeclReferenceExprSyntax(baseName: enumCase.name)
                                            ),
                                            leftParen: .leftParenToken(),
                                            arguments: [
                                                LabeledExprSyntax(
                                                    label: enumCase.child.name,
                                                    expression: FunctionCallExprSyntax(
                                                        calledExpression: MemberAccessExprSyntax(
                                                            base: DeclReferenceExprSyntax(baseName: .keyword(.Self)),
                                                            declName: DeclReferenceExprSyntax(baseName: "childErrorCode")
                                                        ),
                                                        leftParen: .leftParenToken(),
                                                        arguments: [
                                                            LabeledExprSyntax(
                                                                label: "for",
                                                                expression: DeclReferenceExprSyntax(baseName: "remainingComponents")
                                                            )
                                                        ],
                                                        rightParen: .rightParenToken()
                                                    )
                                                )
                                            ],
                                            rightParen: .rightParenToken()
                                        )
                                    ))
                                ])
                            )
                        )
                    )
                ],
                trailingTrivia: .newline
            )
    }

    private static func defaultEnumCase(enumCasesHaveChildren: Bool) -> SwitchCaseSyntax {
        
        .init(
            leadingTrivia: .newline,
            label: .init(SwitchDefaultLabelSyntax()),
            statements: [
                .init(
                    item: .init(
                        ThrowStmtSyntax(
                            expression: FunctionCallExprSyntax(
                                calledExpression: MemberAccessExprSyntax(
                                    base: DeclReferenceExprSyntax(baseName: "OpaqueCodeError"),
                                    declName: DeclReferenceExprSyntax(baseName: "unrecognizedOpaqueCode")
                                ),
                                leftParen: .leftParenToken(),
                                arguments: [
                                    enumCasesHaveChildren ? LabeledExprSyntax(
                                        expression: FunctionCallExprSyntax(
                                            calledExpression: DeclReferenceExprSyntax(baseName: "String"),
                                            leftParen: .leftParenToken(),
                                            arguments: [
                                                LabeledExprSyntax(
                                                    expression: DeclReferenceExprSyntax(baseName: "firstComponent")
                                                )
                                            ],
                                            rightParen: .rightParenToken()
                                        )
                                    ) : LabeledExprSyntax(
                                        expression: DeclReferenceExprSyntax(baseName: "opaqueCode")
                                    )
                                ],
                                rightParen: .rightParenToken()
                            )
                        )
                    )
                )
            ]
        )
    }
}
