import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    static func shouldGenerateChildErrorCodeFunction(
        from declaration: some DeclGroupSyntax,
        with enumCases: [EnumCase],
        isGeneratingOpaqueCodeInitializer: Bool,
        context: some MacroExpansionContext
    ) -> Bool {
                
        guard enumCases.hasChildren, isGeneratingOpaqueCodeInitializer else {
            return false
        }
        
        let functionDeclarations = declaration.memberBlock.members
            .compactMap { $0.decl.as(FunctionDeclSyntax.self) }
        
        for functionDeclaration in functionDeclarations {
            guard functionDeclarationIsValid(functionDeclaration, context: context) else {
                continue
            }

            return false
        }
        
        return true
    }
    
    private static func functionDeclarationIsValid(
        _ functionDeclaration: FunctionDeclSyntax,
        context: some MacroExpansionContext
    ) -> Bool {

        var diagnostic: Diagnostic?
        
        let functionDeclarationIsValid = functionDeclarationIsValidGenericParameterDeclaration(functionDeclaration, diagnostic: &diagnostic) ||
        functionDeclarationIsValidGenericWhereDeclaration(functionDeclaration, diagnostic: &diagnostic)
        
        if
            let diagnostic,
            diagnostic.diagMessage.severity == .error || !functionDeclarationIsValid
        {
            context.diagnose(diagnostic)
        }

        return functionDeclarationIsValid
    }
    
    private static func functionDeclarationIsValidGenericParameterDeclaration(
        _ functionDeclaration: FunctionDeclSyntax,
        diagnostic: inout Diagnostic?
    ) -> Bool {
        
        guard
            functionDeclaration.signature.parameterClause.parameters.count == 1,
            functionDeclaration.genericParameterClause?.parameters.count == 1,
            let genericParameter = functionDeclaration.genericParameterClause?.parameters.first
        else {
            return false
        }
        
        let functionIsStatic = functionIsStatic(functionDeclaration)
        let functionNameIsCorrect = functionNameIsCorrect(functionDeclaration)
        let genericParameterHasNoEachKeyword = genericParameter.eachKeyword == nil
        let genericParameterInheritedTypeIsValid = genericParameter.inheritedType?.as(IdentifierTypeSyntax.self)?.name.text == "ErrorCode"
        let parameterNameIsCorrect = parameterNameIsCorrect(functionDeclaration)
        let parameterTypeIsCorrect = parameterTypeIsCorrect(functionDeclaration)
        let functionReturnTypeIsValid = functionReturnTypeIsValid(
            functionDeclaration,
            genericParameter: genericParameter
        )
        let functionIsNotAsync = functionIsNotAsync(functionDeclaration)
        
        switch (functionIsStatic, functionNameIsCorrect, genericParameterHasNoEachKeyword, genericParameterInheritedTypeIsValid, parameterNameIsCorrect, parameterTypeIsCorrect, functionReturnTypeIsValid, functionIsNotAsync) {
        case (false, true, true, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.functionIsNotStatic)
            
        case (true, false, true, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectFunctionName)
            
        case (true, true, true, false, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectGenericParameterInheritedType)
            
        case (true, true, true, true, false, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterName)

        case (true, true, true, true, true, false, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterType)
            
        case (true, true, true, true, true, true, false, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectReturnType)
        
        case (true, true, true, true, true, true, true, false):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncDeclaration)

        default:
            break
            
        }

        return functionIsStatic &&
        functionNameIsCorrect &&
        genericParameterHasNoEachKeyword &&
        genericParameterInheritedTypeIsValid &&
        parameterNameIsCorrect &&
        parameterTypeIsCorrect &&
        functionReturnTypeIsValid &&
        functionIsNotAsync
    }
    
    private static func functionDeclarationIsValidGenericWhereDeclaration(
        _ functionDeclaration: FunctionDeclSyntax,
        diagnostic: inout Diagnostic?
    ) -> Bool {
        
        guard
            functionDeclaration.signature.parameterClause.parameters.count == 1,
            functionDeclaration.genericParameterClause?.parameters.count == 1,
            let genericParameter = functionDeclaration.genericParameterClause?.parameters.first,
            functionDeclaration.genericWhereClause?.requirements.count == 1,
            let whereRequirement = functionDeclaration.genericWhereClause?.requirements.first
        else {
            return false
        }
        
        let functionIsStatic = functionIsStatic(functionDeclaration)
        let functionNameIsCorrect = functionNameIsCorrect(functionDeclaration)
        let genericParameterHasNoEachKeyword = genericParameter.eachKeyword == nil
        let whereRequirementTypeNameIsValid = genericParameter.name.text == whereRequirement.requirement
            .as(ConformanceRequirementSyntax.self)?
            .leftType
            .as(IdentifierTypeSyntax.self)?.name.text
        let whereRequirementInheritedTypeIsValid = "ErrorCode" == whereRequirement.requirement
            .as(ConformanceRequirementSyntax.self)?
            .rightType
            .as(IdentifierTypeSyntax.self)?.name.text
        let parameterNameIsCorrect = parameterNameIsCorrect(functionDeclaration)
        let parameterTypeIsCorrect = parameterTypeIsCorrect(functionDeclaration)
        let functionReturnTypeIsValid = functionReturnTypeIsValid(
            functionDeclaration,
            genericParameter: genericParameter
        )
        let functionIsNotAsync = functionIsNotAsync(functionDeclaration)
        
        switch (functionIsStatic, functionNameIsCorrect, genericParameterHasNoEachKeyword, whereRequirementTypeNameIsValid, whereRequirementInheritedTypeIsValid, parameterNameIsCorrect, parameterTypeIsCorrect, functionReturnTypeIsValid, functionIsNotAsync) {
        case (false, true, true, true, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.functionIsNotStatic)
            
        case (true, false, true, true, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectFunctionName)

        case (true, true, true, true, false, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectWhereRequirementInheritedType)

        case (true, true, true, true, true, false, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterName)
            
        case (true, true, true, true, true, true, false, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterType)

        case (true, true, true, true, true, true, true, false, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectReturnType)

        case (true, true, true, true, true, true, true, true, false):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncDeclaration)

        default:
            break
            
        }
        
        return functionIsStatic &&
        functionNameIsCorrect &&
        genericParameterHasNoEachKeyword &&
        whereRequirementTypeNameIsValid &&
        whereRequirementInheritedTypeIsValid &&
        parameterNameIsCorrect &&
        parameterTypeIsCorrect &&
        functionReturnTypeIsValid &&
        functionIsNotAsync
    }
    
    // MARK: - Individual checks
    private static func functionIsStatic(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.modifiers.contains(where: \.isStaticModifier)
    }
    
    private static func functionNameIsCorrect(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.name.text == "childErrorCode"
    }
    
    private static func parameterNameIsCorrect(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.signature.parameterClause.parameters.first?.firstName.text == "for"
    }
    
    private static func parameterTypeIsCorrect(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.signature.parameterClause.parameters.first?.type.as(IdentifierTypeSyntax.self)?.name.text == "String"
    }
    
    private static func functionReturnTypeIsValid(
        _ functionDeclaration: FunctionDeclSyntax,
        genericParameter: GenericParameterSyntax
    ) -> Bool {
        
        functionDeclaration.signature.returnClause?.type.as(IdentifierTypeSyntax.self)?.name.text == genericParameter.name.text
    }
    
    private static func functionIsNotAsync(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.signature.effectSpecifiers?.asyncSpecifier == nil
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case functionIsNotStatic
        case incorrectFunctionName
        case incorrectGenericParameterInheritedType
        case incorrectWhereRequirementInheritedType
        case incorrectParameterName
        case incorrectParameterType
        case incorrectReturnType
        case incorrectAsyncDeclaration
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
        
        switch self {
        case .functionIsNotStatic:
            "Declaration is not static and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectFunctionName:
            "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectGenericParameterInheritedType, .incorrectWhereRequirementInheritedType:
            "Declaration has incorrect generic type constraint and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectParameterName:
            "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."
            
        case .incorrectParameterType:
            "Declaration has incorrect parameter type and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectReturnType:
            "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."
            
        case .incorrectAsyncDeclaration:
            "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childErrorCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        }
    }
    
    private var messageID: String {
        
        switch self {
        case .functionIsNotStatic:
            "functionIsNotStatic"
            
        case .incorrectFunctionName:
            "incorrectFunctionName"
            
        case .incorrectGenericParameterInheritedType:
            "incorrectGenericParameterInheritedType"
            
        case .incorrectWhereRequirementInheritedType:
            "incorrectWhereRequirementInheritedType"
            
        case .incorrectParameterName:
            "incorrectParameterName"
            
        case .incorrectParameterType:
            "incorrectParameterType"
            
        case .incorrectReturnType:
            "incorrectReturnType"
            
        case .incorrectAsyncDeclaration:
            "incorrectAsyncDeclaration"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualChildErrorCodeDeclarationValidation",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .functionIsNotStatic, .incorrectFunctionName, .incorrectGenericParameterInheritedType, .incorrectWhereRequirementInheritedType, .incorrectParameterName, .incorrectParameterType, .incorrectReturnType, .incorrectAsyncDeclaration:
            .warning
            
        }
    }
}
