import SwiftSyntaxMacros
#if canImport(ErrorCodeMacros)
@testable import ErrorCodeMacros
#endif

struct MacroTesting {
    
    // MARK: - Static properties
    static let shared = MacroTesting()
    
    // MARK: - Properties
    let testMacros: [String : Macro.Type]
    let isEnabled: Bool
    
    // MARK: - Initializer
    private init() {
        
        #if canImport(ErrorCodeMacros)
        self.testMacros = [
            "obfuscate" : ErrorCodeMacro.self
        ]
        self.isEnabled = true
        #else
        self.testMacros = [:]
        self.isEnabled = false
        #endif
    }
}
