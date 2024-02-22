import SwiftSyntax
import SwiftDiagnostics

// MARK: - Manual opaque code
extension ErrorCodeMacro {
    
    fileprivate struct ManualOpaqueCode {
        let variableDeclaration: VariableDeclSyntax
        let name: TokenSyntax
        let value: ExprSyntax
    }
}

// MARK: - Manual opaque code validation
extension ErrorCodeMacro {
    
    static func shouldGenerateOpaqueCodeStaticValues(
        from declaration: EnumDeclSyntax,
        enumCases: [EnumCase]
    ) throws -> Bool {
        
        guard let memberBlock = try extractManualOpaqueCodeDeclarationMemberBlock(from: declaration) else {
            return true
        }
        
        let (opaqueCodesByName, opaqueCodesByValue) = try sortMembers(
            in: memberBlock.members,
            matching: enumCases
        )
        
        var diagnostics: [Diagnostic] = []
        var missingEnumCases: [EnumCase] = []
        for enumCase in enumCases {
            if let opaqueCode = opaqueCodesByName[enumCase.name.text] {
                validateOpaqueCodeIsStringLiteral(
                    opaqueCode: opaqueCode,
                    diagnostics: &diagnostics
                )
                validateOpaqueCodeIsStaticLet(
                    opaqueCode: opaqueCode,
                    diagnostics: &diagnostics
                )
            } else {
                missingEnumCases.append(enumCase)
            }
        }
        
        if !missingEnumCases.isEmpty {
            addMissingOpaqueCode(
                for: missingEnumCases,
                in: memberBlock,
                diagnostics: &diagnostics
            )
        }
        
        for (_, opaqueCodes) in opaqueCodesByValue where opaqueCodes.count > 1 {
            for opaqueCode in opaqueCodes {
                diagnostics.append(
                    .init(
                        node: memberBlock,
                        message: DiagnosticMessage.duplicateManualOpaqueCode(opaqueCode)
                    )
                )
            }
        }
        
        if diagnostics.isEmpty {
            return false
        } else {
            throw DiagnosticsError(diagnostics: diagnostics)
        }
    }
    
    private static func extractManualOpaqueCodeDeclarationMemberBlock(from declaration: EnumDeclSyntax) throws -> MemberBlockSyntax? {
        
        if 
            let enumDeclaration = declaration.memberBlock.members
            .compactMap({ $0.decl.as(EnumDeclSyntax.self) })
            .first(where: { $0.name.text == "OpaqueCode" })
        {
            enumDeclaration.memberBlock
            
        } else if
            let structDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(StructDeclSyntax.self) })
                .first(where: { $0.name.text == "OpaqueCode" })
        {
            structDeclaration.memberBlock
            
        } else if
            let classDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(ClassDeclSyntax.self) })
                .first(where: { $0.name.text == "OpaqueCode" })
        {
            classDeclaration.memberBlock
            
        } else if 
            let actorDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(ActorDeclSyntax.self) })
                .first(where: { $0.name.text == "OpaqueCode" })
        {
            actorDeclaration.memberBlock
            
        } else if
            let propertyDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(VariableDeclSyntax.self) })
                .first(where: { variableDeclaration in
                    variableDeclaration.bindings
                        .compactMap { $0.pattern.as(IdentifierPatternSyntax.self) }
                        .contains(where: {
                            $0.identifier.text == "OpaqueCode"
                        })
                }),
            !propertyDeclaration.modifiers.contains(where: \.isStaticModifier)
        {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: propertyDeclaration,
                    message: DiagnosticMessage.opaqueCodeNamingCollision
                )
            ])
            
        } else if
            let functionDeclaration = declaration.memberBlock.members
                .compactMap({ $0.decl.as(FunctionDeclSyntax.self) })
                .first(where: { $0.name.text == "OpaqueCode" })
        {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(
                    node: functionDeclaration,
                    message: DiagnosticMessage.opaqueCodeNamingCollision
                )
            ])
            
        } else {
            nil
            
        }
    }
    
    private static func sortMembers(
        in memberBlockItemList: MemberBlockItemListSyntax,
        matching enumCases: [EnumCase]
    ) throws -> (opaqueCodesByName: [String : ManualOpaqueCode], opaqueCodesByValue: [String : [ManualOpaqueCode]]) {
        
        var opaqueCodesByName: [String : ManualOpaqueCode] = [:]
        var opaqueCodesByValue: [String : [ManualOpaqueCode]] = [:]
        let enumCaseNames = Set(enumCases.map(\.name.text))
        
        for member in memberBlockItemList {
            
            guard let variableDeclaration = member.decl.as(VariableDeclSyntax.self) else {
                continue
            }
            
            let bindings = variableDeclaration.bindings.compactMap { $0.as(PatternBindingSyntax.self) }
            for binding in bindings {
                
                guard 
                    let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier,
                    enumCaseNames.contains(name.text)
                else {
                    continue
                }
                
                guard let value = binding.initializer?.value else {
                    throw DiagnosticsError(diagnostics: [
                        .init(
                            node: binding,
                            message: DiagnosticMessage.manualOpaqueCodeIsMissingInitializer(name.text)
                        )
                    ])
                }
                
                let manualOpaqueCode = ManualOpaqueCode(
                    variableDeclaration: variableDeclaration,
                    name: name,
                    value: value
                )
                
                opaqueCodesByName[name.text] = manualOpaqueCode
                
                var existingOpaqueCodesByValue = opaqueCodesByValue[value.description] ?? []
                existingOpaqueCodesByValue.append(manualOpaqueCode)
                opaqueCodesByValue[value.description] = existingOpaqueCodesByValue
            }
        }
        
        return (opaqueCodesByName, opaqueCodesByValue)
    }
    
    private static func validateOpaqueCodeIsStringLiteral(
        opaqueCode: ManualOpaqueCode,
        diagnostics: inout [Diagnostic]
    ) {
        
        guard opaqueCode.value.kind != .stringLiteralExpr else {
            return
        }
        
        diagnostics.append(
            .init(
                node: opaqueCode.value,
                message: DiagnosticMessage.manualOpaqueCodeIsNotStringLiteral(opaqueCode)
            )
        )
    }
    
    private static func validateOpaqueCodeIsStaticLet(
        opaqueCode: ManualOpaqueCode,
        diagnostics: inout [Diagnostic]
    ) {
        
        guard
            !opaqueCode.variableDeclaration.modifiers.contains(where: \.isStaticModifier) ||
            opaqueCode.variableDeclaration.bindingSpecifier.tokenKind != .keyword(.let)
        else {
            return
        }
        
        var fixItDeclaration = opaqueCode.variableDeclaration
        fixItDeclaration.modifiers = [DeclModifierSyntax(name: .keyword(.static))]
        fixItDeclaration.modifiers.trailingTrivia = .space
        fixItDeclaration.bindingSpecifier = .keyword(.let)
        fixItDeclaration.bindingSpecifier.trailingTrivia = .space

        diagnostics.append(
            .init(
                node: opaqueCode.variableDeclaration,
                message: DiagnosticMessage.manualOpaqueCodeIsNotDeclaredAsStaticLet(opaqueCode),
                fixIt: .replace(
                    message: FixItMessage.changeDeclarationToStaticLet,
                    oldNode: opaqueCode.variableDeclaration,
                    newNode: fixItDeclaration
                )
            )
        )
    }
    
    private static func addMissingOpaqueCode(
        for enumCases: [EnumCase],
        in memberBlock: MemberBlockSyntax,
        diagnostics: inout [Diagnostic]
    ) {
        
        var fixItMemberBlock = memberBlock
        fixItMemberBlock.leadingTrivia = .newlines(2)
        for enumCase in enumCases {
            fixItMemberBlock.members.append(
                .init(
                    decl: VariableDeclSyntax(
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
                                    value: ExprSyntax(
                                        fromProtocol: EditorPlaceholderExprSyntax(
                                            placeholder: TokenSyntax(stringLiteral: "\"<" + "#\(enumCase.name.text)#>\"")
                                        )
                                    )
                                )
                            )
                        }
                    )
                )
            )
        }
        
        diagnostics.append(
            .init(
                node: memberBlock,
                message: DiagnosticMessage.missingManualOpaqueCodes(enumCases),
                fixIt: .replace(
                    message: FixItMessage.insertMissingOpaqueCodes,
                    oldNode: memberBlock,
                    newNode: fixItMemberBlock
                )
            )
        )
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case opaqueCodeNamingCollision
        case duplicateManualOpaqueCode(ErrorCodeMacro.ManualOpaqueCode)
        case missingManualOpaqueCodes([ErrorCodeMacro.EnumCase])
        case manualOpaqueCodeIsNotStringLiteral(ErrorCodeMacro.ManualOpaqueCode)
        case manualOpaqueCodeIsMissingInitializer(String)
        case manualOpaqueCodeIsNotDeclaredAsStaticLet(ErrorCodeMacro.ManualOpaqueCode)
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .opaqueCodeNamingCollision:
            "\"OpaqueCode\" has been declared on this type, but is not an \"enum\", \"struct\", \"class\" or \"actor\". Avoid naming collisions on this type, and declare \"OpaqueCode\" as one of the types mentioned."
            
        case let .duplicateManualOpaqueCode(opaqueCode):
            "\"OpaqueCode\" must each have a unique value. \"\(opaqueCode.name.text)\" has a duplicate value \(opaqueCode.value.description)."
            
        case let .missingManualOpaqueCodes(errorCodes):
            "No variable for enum case \(errorCodes.map { "\"\($0.name.text)\"" }.joined(separator: ", ")). \"OpaqueCode\" must have one static String variable to match each enum case."
            
        case let .manualOpaqueCodeIsNotStringLiteral(opaqueCode):
            "\"OpaqueCode\" for \"\(opaqueCode.name.text)\" must be declared as a static string literal."

        case let .manualOpaqueCodeIsMissingInitializer(name):
            "\"OpaqueCode\" for \"\(name)\" has no initializer, but must be declared as a static string literal."

        case let .manualOpaqueCodeIsNotDeclaredAsStaticLet(opaqueCode):
            "\"OpaqueCode\" for \"\(opaqueCode.name.text)\" must be declared as a \"static let\" property."

        }   
    }
    
    private var messageID: String {
        
        switch self {
        case .opaqueCodeNamingCollision:
            "opaqueCodeNamingCollision"
            
        case .duplicateManualOpaqueCode:
            "duplicateManualOpaqueCode"
            
        case .missingManualOpaqueCodes:
            "missingManualOpaqueCodes"
            
        case .manualOpaqueCodeIsNotStringLiteral:
            "manualOpaqueCodeIsNotStringLiteral"
            
        case .manualOpaqueCodeIsMissingInitializer:
            "manualOpaqueCodeIsMissingInitializer"
            
        case .manualOpaqueCodeIsNotDeclaredAsStaticLet:
            "manualOpaqueCodeIsNotDeclaredAsStaticLet"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .opaqueCodeNamingCollision, .duplicateManualOpaqueCode, .missingManualOpaqueCodes, .manualOpaqueCodeIsNotStringLiteral, .manualOpaqueCodeIsMissingInitializer, .manualOpaqueCodeIsNotDeclaredAsStaticLet:
            .error
        }
    }
}

// MARK: - Fix it message
extension ErrorCodeMacro {
    fileprivate enum FixItMessage {
        
        case insertMissingOpaqueCodes
        case changeDeclarationToStaticLet
    }
}

extension ErrorCodeMacro.FixItMessage: SwiftDiagnostics.FixItMessage {
    
    var message: String {
        
        switch self {
        case .insertMissingOpaqueCodes:
            "Add missing cases"
            
        case .changeDeclarationToStaticLet:
            "Change declaration to \"static let\""
            
        }
    }
    
    private var messageID: String {
    
        switch self {
        case .insertMissingOpaqueCodes:
            "insertMissingOpaqueCodes"
            
        case .changeDeclarationToStaticLet:
            "changeDeclarationToStaticLet"

        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualOpaqueCodeDeclarationValidation",
            id: messageID
        )
    }
}
