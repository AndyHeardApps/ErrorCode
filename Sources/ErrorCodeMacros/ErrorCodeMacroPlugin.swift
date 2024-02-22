import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct ErrorCodePlugin: CompilerPlugin {
    
    let providingMacros: [Macro.Type] = [
        ErrorCodeMacro.self,
    ]
}
