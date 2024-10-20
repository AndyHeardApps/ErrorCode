import SwiftSyntax

extension ErrorCodeMacro {

    static func generatedChildErrorCodeFunction() -> DeclSyntax {
        
        let functionDeclaration = FunctionDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: [
                .init(name: .keyword(.private)),
                .init(name: .keyword(.static))
            ],
            name: "childErrorCode",
            genericParameterClause: .init(parameters: [
                GenericParameterSyntax(
                    name: TokenSyntax(stringLiteral: "E"),
                    colon: .colonToken(),
                    inheritedType: IdentifierTypeSyntax(name: "ErrorCode")
                )
            ]),
            signature: .init(
                parameterClause: .init(
                    parameters: [
                        .init(
                            firstName: "for",
                            secondName: "opaqueCode",
                            type: TypeSyntax(stringLiteral: "String")
                        )
                    ]
                ),
                effectSpecifiers: .init(throwsClause: .init(throwsSpecifier: .keyword(.throws))),
                returnClause: .init(type: TypeSyntax(stringLiteral: "E"))
            ),
            body: CodeBlockSyntax {
                CodeBlockItemSyntax(stringLiteral: "try E(opaqueCode: opaqueCode)")
            }
        )
        
        return DeclSyntax(functionDeclaration)
    }
}
