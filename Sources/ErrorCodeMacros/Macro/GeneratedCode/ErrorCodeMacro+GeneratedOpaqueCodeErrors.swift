import SwiftSyntax

extension ErrorCodeMacro {
    
    static func generatedOpaqueCodeErrors() -> DeclSyntax {
        
        let enumSyntax = EnumDeclSyntax(
            leadingTrivia: .newlines(2),
            modifiers: [
                .init(name: .keyword(.private))
            ],
            name: "OpaqueCodeError",
            inheritanceClause: .init(
                inheritedTypes: [
                    .init(type: TypeSyntax(stringLiteral: "OpaqueCodeInitializerError"))
                ]
            ),
            memberBlock: .init(
                members: .init {
                    EnumCaseDeclSyntax(
                        leadingTrivia: .newline,
                        elements: [
                            .init(name: "opaqueCodeIsEmpty")
                        ]
                    )
                    EnumCaseDeclSyntax(
                        leadingTrivia: .newline,
                        elements: [
                            .init(
                                name: "unrecognizedOpaqueCode",
                                parameterClause: .init(
                                    parameters: .init {
                                        .init(type: TypeSyntax(stringLiteral: "String"))
                                    }
                                )
                            )
                        ]
                    )
                    EnumCaseDeclSyntax(
                        leadingTrivia: .newline,
                        elements: [
                            .init(
                                name: "unusedOpaqueCodeComponents",
                                parameterClause: .init(
                                    parameters: .init {
                                        .init(type: TypeSyntax(stringLiteral: "[String]"))
                                    }
                                )
                            )
                        ]
                    )
                }
            )
        )
        
        return DeclSyntax(enumSyntax)
    }
}
