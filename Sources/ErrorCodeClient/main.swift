import ErrorCode

@ErrorCode
enum ErrorCodes {
    
    case networking(subCode: NetworkingErrorCode)
    case repository
    case coding(CodingErrorCode)
}

@ErrorCode
public enum NetworkingErrorCode {
    
    case httpStatusCode(statusCode: HTTPStatusCode)
    case noInternet
    case badRequest
}

@ErrorCode(codeLength: 6)
public enum HTTPStatusCode: Int {
    
    case badRequest = 400
    case notFound = 404
}

public enum CodingErrorCode: Sendable {
    
    case encoding
    case decoding
}

@ErrorCodeExtension
extension CodingErrorCode: ErrorCode {
    
    private static let errorCodes: [Self] = [
        .encoding,
        .decoding
    ]
}

print(ErrorCodes.networking(subCode: .httpStatusCode(statusCode: .badRequest)).opaqueCode) // 8BUT-gjmR-Tk1iR6
print(ErrorCodes.repository.opaqueCode) // 6DWR
print(ErrorCodes.coding(.decoding).opaqueCode) // 0Dqd-cTit

print(try ErrorCodes(opaqueCode: "8BUT-gjmR-Tk1iR6")) // networking(subCode: .httpStatusCode(statusCode: .notFound))
print(try ErrorCodes(opaqueCode: "6DWR")) // repository
