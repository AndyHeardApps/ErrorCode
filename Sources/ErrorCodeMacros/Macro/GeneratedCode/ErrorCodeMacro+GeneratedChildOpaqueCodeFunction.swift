import SwiftSyntax

extension ErrorCodeMacro {
    
    static func generatedChildOpaqueCodeFunction() -> DeclSyntax {
        
        let functionDeclaration = FunctionDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: [
                .init(name: .keyword(.private))
            ],
            name: "childOpaqueCode",
            signature: .init(
                parameterClause: .init(
                    parameters: [
                        .init(
                            firstName: "for",
                            secondName: "errorCode",
                            type: SomeOrAnyTypeSyntax(
                                someOrAnySpecifier: .keyword(.some),
                                constraint: TypeSyntax(stringLiteral: "ErrorCode")
                            )
                        )
                    ]
                ),
                returnClause: .init(type: TypeSyntax(stringLiteral: "String"))
            ),
            body: CodeBlockSyntax {
                CodeBlockItemSyntax(stringLiteral: "errorCode.opaqueCode")
            }
        )
        
        return DeclSyntax(functionDeclaration)
    }
}
