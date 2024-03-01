import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension ErrorCodeMacro {
    
    static func shouldGenerateChildOpaqueCodeFunction(
        from declaration: some DeclGroupSyntax,
        with enumCases: [EnumCase],
        isGeneratingOpaqueCodeProperty: Bool,
        context: some MacroExpansionContext
    ) throws -> Bool {
                
        guard enumCases.hasChildren, isGeneratingOpaqueCodeProperty else {
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

        let functionDeclarationIsValid = functionDeclarationIsValidGenericSomeDeclaration(functionDeclaration, diagnostic: &diagnostic) ||
        functionDeclarationIsValidExistentialAnyDeclaration(functionDeclaration, diagnostic: &diagnostic) ||
        functionDeclarationIsValidExistentialDeclaration(functionDeclaration, diagnostic: &diagnostic) ||
        functionDeclarationIsValidGenericParameterDeclaration(functionDeclaration, diagnostic: &diagnostic) ||
        functionDeclarationIsValidGenericWhereDeclaration(functionDeclaration, diagnostic: &diagnostic)
        
        if
            let diagnostic,
            diagnostic.diagMessage.severity == .error || !functionDeclarationIsValid
        {
            context.diagnose(diagnostic)
        }
        
        return functionDeclarationIsValid
    }
    
    private static func functionDeclarationIsValidExistentialDeclaration(
        _ functionDeclaration: FunctionDeclSyntax,
        diagnostic: inout Diagnostic?
    ) -> Bool {
        
        guard
            functionDeclaration.signature.parameterClause.parameters.count == 1,
            let parameterTypeDeclaration = functionDeclaration.signature.parameterClause.parameters.first?.type.as(IdentifierTypeSyntax.self),
            functionDeclaration.genericParameterClause == nil,
            functionDeclaration.genericWhereClause == nil
        else {
            return false
        }

        let functionNameIsCorrect = functionNameIsCorrect(functionDeclaration)
        let parameterNameIsCorrect = parameterNameIsCorrect(functionDeclaration)
        let parameterTypeIsValid = parameterTypeDeclaration.name.text == "ErrorCode"
        let functionReturnTypeIsValid = functionReturnTypeIsValid(functionDeclaration)
        let functionIsNotAsync = functionIsNotAsync(functionDeclaration)
        let functionDoesNotThrow = functionDoesNotThrow(functionDeclaration)
        
        switch (functionNameIsCorrect, parameterNameIsCorrect, parameterTypeIsValid, functionReturnTypeIsValid, functionIsNotAsync, functionDoesNotThrow) {
        case (false, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectFunctionName)

        case (true, false, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterName)

        case (true, true, false, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterType)

        case (true, true, true, false, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectReturnType)

        case (true, true, true, true, false, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncDeclaration)

        case (true, true, true, true, true, false):
            diagnostic = throwingFunctionFixitDiagnostic(for: functionDeclaration)

        case (true, true, true, true, false, false):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncThrowingDeclaration)

        default:
            break
            
        }

        return functionNameIsCorrect &&
        parameterNameIsCorrect &&
        parameterTypeIsValid &&
        functionReturnTypeIsValid &&
        functionIsNotAsync
    }
    
    private static func functionDeclarationIsValidExistentialAnyDeclaration(
        _ functionDeclaration: FunctionDeclSyntax,
        diagnostic: inout Diagnostic?
    ) -> Bool {
        
        guard
            functionDeclaration.signature.parameterClause.parameters.count == 1,
            let parameterTypeDeclaration = functionDeclaration.signature.parameterClause.parameters.first?.type.as(SomeOrAnyTypeSyntax.self),
            functionDeclaration.genericParameterClause == nil,
            functionDeclaration.genericWhereClause == nil
        else {
            return false
        }

        let functionNameIsCorrect = functionNameIsCorrect(functionDeclaration)
        let parameterNameIsCorrect = parameterNameIsCorrect(functionDeclaration)
        let anyKeywordIsPresent = parameterTypeDeclaration.someOrAnySpecifier.tokenKind == .keyword(.any)
        let parameterTypeIsValid = parameterTypeDeclaration.constraint.as(IdentifierTypeSyntax.self)?.name.text == "ErrorCode"
        let functionReturnTypeIsValid = functionReturnTypeIsValid(functionDeclaration)
        let functionIsNotAsync = functionIsNotAsync(functionDeclaration)
        let functionDoesNotThrow = functionDoesNotThrow(functionDeclaration)
        
        switch (functionNameIsCorrect, parameterNameIsCorrect, parameterTypeIsValid, functionReturnTypeIsValid, functionIsNotAsync, functionDoesNotThrow) {
        case (false, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectFunctionName)

        case (true, false, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterName)

        case (true, true, false, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterType)

        case (true, true, true, false, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectReturnType)

        case (true, true, true, true, false, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncDeclaration)

        case (true, true, true, true, true, false):
            diagnostic = throwingFunctionFixitDiagnostic(for: functionDeclaration)

        case (true, true, true, true, false, false):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncThrowingDeclaration)

        default:
            break
            
        }
        
        return functionNameIsCorrect &&
        parameterNameIsCorrect &&
        anyKeywordIsPresent &&
        parameterTypeIsValid &&
        functionReturnTypeIsValid &&
        functionIsNotAsync
    }
    
    private static func functionDeclarationIsValidGenericParameterDeclaration(
        _ functionDeclaration: FunctionDeclSyntax,
        diagnostic: inout Diagnostic?
    ) -> Bool {
        
        guard
            functionDeclaration.signature.parameterClause.parameters.count == 1,
            functionDeclaration.genericParameterClause?.parameters.count == 1,
            let genericParameter = functionDeclaration.genericParameterClause?.parameters.first,
            functionDeclaration.genericWhereClause == nil
        else {
            return false
        }
        
        let functionNameIsCorrect = functionNameIsCorrect(functionDeclaration)
        let parameterNameIsCorrect = parameterNameIsCorrect(functionDeclaration)
        let genericParameterHasNoEachKeyword = genericParameter.eachKeyword == nil
        let genericParameterTypeIsValid = genericParameter.inheritedType?.as(IdentifierTypeSyntax.self)?.name.text == "ErrorCode"
        let genericParameterNameMatchesFunctionParameterType = genericParameter.name.text == functionDeclaration.signature.parameterClause.parameters.first?.type.as(IdentifierTypeSyntax.self)?.name.text
        let functionReturnTypeIsValid = functionReturnTypeIsValid(functionDeclaration)
        let functionIsNotAsync = functionIsNotAsync(functionDeclaration)
        let functionDoesNotThrow = functionDoesNotThrow(functionDeclaration)

        switch (functionNameIsCorrect, parameterNameIsCorrect, genericParameterHasNoEachKeyword, genericParameterTypeIsValid, genericParameterNameMatchesFunctionParameterType, functionReturnTypeIsValid, functionIsNotAsync, functionDoesNotThrow) {
        case (false, true, true, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectFunctionName)

        case (true, false, true, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterName)

        case (true, true, true, false, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectGenericParameterInheritedType)

        case (true, true, true, true, true, false, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectReturnType)

        case (true, true, true, true, true, true, false, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncDeclaration)

        case (true, true, true, true, true, true, true, false):
            diagnostic = throwingFunctionFixitDiagnostic(for: functionDeclaration)

        case (true, true, true, true, true, true, false, false):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncThrowingDeclaration)

        default:
            break
            
        }
        
        return functionNameIsCorrect &&
        parameterNameIsCorrect &&
        genericParameterHasNoEachKeyword &&
        genericParameterTypeIsValid &&
        genericParameterNameMatchesFunctionParameterType &&
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
        
        let functionNameIsCorrect = functionNameIsCorrect(functionDeclaration)
        let parameterNameIsCorrect = parameterNameIsCorrect(functionDeclaration)
        let genericParameterHasNoEachKeyword = genericParameter.eachKeyword == nil
        let genericParameterNameMatchesFunctionParameterType = genericParameter.name.text == functionDeclaration.signature.parameterClause.parameters.first?.type.as(IdentifierTypeSyntax.self)?.name.text
        let whereRequirementTypeNameIsValid = genericParameter.name.text == whereRequirement.requirement
            .as(ConformanceRequirementSyntax.self)?
            .leftType
            .as(IdentifierTypeSyntax.self)?.name.text
        let whereRequirementInheritedTypeIsValid = "ErrorCode" == whereRequirement.requirement
            .as(ConformanceRequirementSyntax.self)?
            .rightType
            .as(IdentifierTypeSyntax.self)?.name.text
        let functionReturnTypeIsValid = functionReturnTypeIsValid(functionDeclaration)
        let functionIsNotAsync = functionIsNotAsync(functionDeclaration)
        let functionDoesNotThrow = functionDoesNotThrow(functionDeclaration)

        switch (functionNameIsCorrect, parameterNameIsCorrect, genericParameterHasNoEachKeyword, genericParameterNameMatchesFunctionParameterType, whereRequirementTypeNameIsValid, whereRequirementInheritedTypeIsValid, functionReturnTypeIsValid, functionIsNotAsync, functionDoesNotThrow) {
        case (false, true, true, true, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectFunctionName)

        case (true, false, true, true, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterName)

        case (true, true, true, true, false, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectWhereRequirementTypeName)

        case (true, true, true, true, true, false, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectWhereRequirementInheritedType)
            
        case (true, true, true, true, true, true, false, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectReturnType)

        case (true, true, true, true, true, true, true, false, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncDeclaration)

        case (true, true, true, true, true, true, true, true, false):
            diagnostic = throwingFunctionFixitDiagnostic(for: functionDeclaration)

        case (true, true, true, true, true, true, true, false, false):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncThrowingDeclaration)

        default:
            break
            
        }
        
        return functionNameIsCorrect &&
        parameterNameIsCorrect &&
        genericParameterHasNoEachKeyword &&
        genericParameterNameMatchesFunctionParameterType &&
        whereRequirementTypeNameIsValid &&
        whereRequirementInheritedTypeIsValid &&
        functionReturnTypeIsValid &&
        functionIsNotAsync
    }
    
    private static func functionDeclarationIsValidGenericSomeDeclaration(
        _ functionDeclaration: FunctionDeclSyntax,
        diagnostic: inout Diagnostic?
    ) -> Bool {
        
        guard
            functionDeclaration.signature.parameterClause.parameters.count == 1,
            let parameterTypeDeclaration = functionDeclaration.signature.parameterClause.parameters.first?.type.as(SomeOrAnyTypeSyntax.self),
            functionDeclaration.genericParameterClause == nil,
            functionDeclaration.genericWhereClause == nil
        else {
            return false
        }

        let functionNameIsCorrect = functionNameIsCorrect(functionDeclaration)
        let parameterNameIsCorrect = parameterNameIsCorrect(functionDeclaration)
        let someKeywordIsPresent = parameterTypeDeclaration.someOrAnySpecifier.tokenKind == .keyword(.some)
        let parameterTypeIsValid = parameterTypeDeclaration.constraint.as(IdentifierTypeSyntax.self)?.name.text == "ErrorCode"
        let functionReturnTypeIsValid = functionReturnTypeIsValid(functionDeclaration)
        let functionIsNotAsync = functionIsNotAsync(functionDeclaration)
        let functionDoesNotThrow = functionDoesNotThrow(functionDeclaration)
        
        switch (functionNameIsCorrect, parameterNameIsCorrect, parameterTypeIsValid, functionReturnTypeIsValid, functionIsNotAsync, functionDoesNotThrow) {
        case (false, true, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectFunctionName)
            
        case (true, false, true, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterName)

        case (true, true, false, true, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectParameterType)

        case (true, true, true, false, true, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectReturnType)

        case (true, true, true, true, false, true):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncDeclaration)

        case (true, true, true, true, true, false):
            diagnostic = throwingFunctionFixitDiagnostic(for: functionDeclaration)
            
        case (true, true, true, true, false, false):
            diagnostic = .init(node: functionDeclaration, message: DiagnosticMessage.incorrectAsyncThrowingDeclaration)

        default:
            break
            
        }
        
        return functionNameIsCorrect &&
        parameterNameIsCorrect &&
        someKeywordIsPresent &&
        parameterTypeIsValid &&
        functionReturnTypeIsValid &&
        functionIsNotAsync
    }
        
    // MARK: - Individual checks
    private static func functionNameIsCorrect(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.name.text == "childOpaqueCode"
    }
    
    private static func parameterNameIsCorrect(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.signature.parameterClause.parameters.first?.firstName.text == "for"
    }
    
    private static func functionReturnTypeIsValid(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.signature.returnClause?.type.as(IdentifierTypeSyntax.self)?.name.text == "String"
    }
    
    private static func functionIsNotAsync(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.signature.effectSpecifiers?.asyncSpecifier == nil
    }
    
    private static func functionDoesNotThrow(_ functionDeclaration: FunctionDeclSyntax) -> Bool {
        
        functionDeclaration.signature.effectSpecifiers?.throwsSpecifier == nil
    }
    
    private static func throwingFunctionFixitDiagnostic(for functionDeclaration: FunctionDeclSyntax) -> Diagnostic {
        
        var fixItFunctionDeclaration = functionDeclaration
        fixItFunctionDeclaration.signature.effectSpecifiers = nil
        
        return .init(
            node: functionDeclaration,
            message: DiagnosticMessage.incorrectThrowingDeclaration,
            fixIt: .replace(
                message: FixItMessage.removeThrowsSpecifier,
                oldNode: functionDeclaration,
                newNode: fixItFunctionDeclaration
            )
        )
    }
}

// MARK: - Diagnostic message
extension ErrorCodeMacro {
    fileprivate enum DiagnosticMessage {
        
        case incorrectFunctionName
        case incorrectGenericParameterInheritedType
        case incorrectWhereRequirementTypeName
        case incorrectWhereRequirementInheritedType
        case incorrectParameterName
        case incorrectParameterType
        case incorrectReturnType
        case incorrectThrowingDeclaration
        case incorrectAsyncDeclaration
        case incorrectAsyncThrowingDeclaration
    }
}

extension ErrorCodeMacro.DiagnosticMessage: SwiftDiagnostics.DiagnosticMessage {
    
    var message: String {
     
        switch self {
        case .incorrectFunctionName:
            "Declaration has incorrect name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."
            
        case .incorrectGenericParameterInheritedType, .incorrectWhereRequirementInheritedType:
            "Declaration has incorrect generic type constraint and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."
            
        case .incorrectWhereRequirementTypeName:
            "Declaration where clause has incorrect generic type name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectParameterName:
            "Declaration has incorrect parameter name and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectParameterType:
            "Declaration has incorrect parameter type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectReturnType:
            "Declaration has incorrect return type and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectThrowingDeclaration:
            "\"childOpaqueCode(for: _)\" should not be a throwing function."
            
        case .incorrectAsyncDeclaration:
            "Declaration is declared as \"async\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."

        case .incorrectAsyncThrowingDeclaration:
            "Declaration is declared as \"async throws\" and will not be used by the \"@ErrorCode\" macro. The default \"childOpaqueCode(for: _)\" function will still be generated and used by \"@ErrorCode\".\n\nTo silence this warning, move this function in to an extension of this type, or declare your own \"init(opaqueCode: _)\" initializer."
        
        }
    }
    
    private var messageID: String {
        
        switch self {
        case .incorrectFunctionName:
            "incorrectFunctionName"
            
        case .incorrectParameterName:
            "incorrectParameterName"
            
        case .incorrectGenericParameterInheritedType:
            "incorrectGenericParameterInheritedType"
            
        case .incorrectWhereRequirementTypeName:
            "incorrectWhereRequirementTypeName"
            
        case .incorrectWhereRequirementInheritedType:
            "incorrectWhereRequirementInheritedType"
            
        case .incorrectParameterType:
            "incorrectParameterType"
            
        case .incorrectReturnType:
            "incorrectReturnType"
            
        case .incorrectThrowingDeclaration:
            "incorrectThrowingDeclaration"
            
        case .incorrectAsyncDeclaration:
            "incorrectAsyncDeclaration"
            
        case .incorrectAsyncThrowingDeclaration:
            "incorrectAsyncThrowingDeclaration"
            
        }
    }
    
    var diagnosticID: MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
            id: messageID
        )
    }
    
    var severity: DiagnosticSeverity {
        
        switch self {
        case .incorrectThrowingDeclaration:
            .error
            
        case .incorrectFunctionName, .incorrectGenericParameterInheritedType, .incorrectWhereRequirementTypeName, .incorrectWhereRequirementInheritedType, .incorrectParameterName, .incorrectParameterType, .incorrectReturnType, .incorrectAsyncDeclaration, .incorrectAsyncThrowingDeclaration:
            .warning
            
        }
    }
}

// MARK: - Fix it message
extension ErrorCodeMacro {
    fileprivate enum FixItMessage {
        
        case removeThrowsSpecifier
    }
}

extension ErrorCodeMacro.FixItMessage: SwiftDiagnostics.FixItMessage {
    
    var message: String {
        
        switch self {
        case .removeThrowsSpecifier:
            "Remove \"throws\""
            
        }
    }
    
    private var messageID: String {
    
        switch self {
        case .removeThrowsSpecifier:
            "removeThrowsSpecifier"
            
        }
    }
    
    var fixItID: SwiftDiagnostics.MessageID {
        
        .init(
            domain: "ErrorCodeMacro.ManualChildOpaqueCodeFunctionDeclarationValidation",
            id: messageID
        )
    }
}
