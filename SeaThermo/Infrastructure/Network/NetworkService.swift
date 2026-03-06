import Foundation

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
    case parsing(Error)
    case noResponse
    case noData     // > respose data가 없을 경우
    case apiError(code: String, message: String)
}

protocol NetworkService {
    var baseURL: String { get }
    
    func request<T: Decodable>(with endpoint: Endpoint<T>) async throws -> T
}

// MARK: - Generic Response Decoders

protocol ResponseDecoder {
    func decode<T: Decodable>(_ data: Data) throws -> T
}

class JSONResponseDecoder: ResponseDecoder {
    private let jsonDecoder = JSONDecoder()
    
    init() { }
    
    func decode<T: Decodable>(_ data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}

class RawDataResponseDecoder: ResponseDecoder {
    init() { }
    
    enum CodingKeys: String, CodingKey {
        case `default` = ""
    }
    func decode<T: Decodable>(_ data: Data) throws -> T {
        if T.self is Data.Type, let data = data as? T {
            return data
        } else {
            let context = DecodingError.Context(
                codingPath: [CodingKeys.default],
                debugDescription: "Expected Data type"
            )
            throw Swift.DecodingError.typeMismatch(T.self, context)
        }
    }
}

// MARK: - Implementation

final class DefaultNetworkService: NetworkService {
    
    let baseURL: String
    private let session: URLSession
    private let logger: NetworkErrorLogger
    
    init(
        baseURL: String,
        session: URLSession = .shared,
        logger: NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.baseURL = baseURL
        self.session = session
        self.logger = logger
    }
    
    func request<T: Decodable>(with endpoint: Endpoint<T>) async throws -> T {
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.urlRequest()
        } catch {
            throw NetworkError.urlGeneration
        }
        
        logger.log(request: urlRequest)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                let error = NetworkError.error(statusCode: httpResponse.statusCode, data: data)
                logger.log(error: error)
                throw error
            }
            
            guard let resolvedData = resolveData(data) else {
                throw NetworkError.noData
            }
            
            logger.log(responseData: resolvedData, response: response)
            
            do {
                let decodedResult: T = try endpoint.responseDecoder.decode(resolvedData)
                return decodedResult
            } catch {
                logger.log(error: error)
                throw NetworkError.parsing(error)
            }
        } catch let error as NetworkError {
            throw error
        } catch {
            let networkError = resolve(error: error)
            logger.log(error: networkError)
            throw networkError
        }
    }
    
    // > data convert, www.nifs.go.kr 로부터 EUC_KR로 인코딩된 데이터를 utf8로 변경해준다
    private func resolveData(_ data: Data?) -> Data? {
        guard let originData = data else { return nil }
        let convertStr = NSString(data: originData, encoding: encEUC_KR)
        let responseString = (convertStr != nil) ? convertStr! : NSString(data: originData, encoding: encUTF8)
        guard let utf8Data = responseString?.data(using: String.Encoding.utf8.rawValue) else {
            return data
        }
        
        return utf8Data
    }
    
    private let encEUC_KR = CFStringConvertEncodingToNSStringEncoding(
        CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
    )
    
    private let encUTF8 = CFStringConvertEncodingToNSStringEncoding(
        CFStringEncoding(CFStringBuiltInEncodings.UTF8.rawValue)
    )
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

// MARK: - Logger

protocol NetworkErrorLogger {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
}

final class DefaultNetworkErrorLogger: NetworkErrorLogger {
    init() { }

    func log(request: URLRequest) {
        print("-------------")
        print("request: \(request.url!)")
        print("headers: \(String(describing: request.allHTTPHeaderFields))")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody {
            if let result = try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: Any] {
                printIfDebug("body: \(String(describing: result))")
            } else if let resultString = String(data: httpBody, encoding: .utf8) ?? String(data: httpBody, encoding: .ascii) {
                printIfDebug("body: \(resultString)")
            } else {
                printIfDebug("body: (Unable to decode body data)")
            }
        } else {
            printIfDebug("body: nil")
        }
    }

    func log(responseData data: Data?, response: URLResponse?) {
        guard let data = data else { return }
        if let dataDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            printIfDebug("responseData: \(String(describing: dataDict))")
        } else {
            printIfDebug("not json:\n \(String(data: data, encoding: .utf8) ?? "")")
        }
    }

    func log(error: Error) {
        printIfDebug("\(error)")
    }
}

// MARK: - NetworkError extension

extension NetworkError {
    var isNotFoundError: Bool { return hasStatusCode(404) }
    
    func hasStatusCode(_ codeError: Int) -> Bool {
        switch self {
        case let .error(code, _):
            return code == codeError
        default: return false
        }
    }
}

extension Dictionary where Key == String {
    func prettyPrint() -> String {
        var string: String = ""
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            if let nstr = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                string = nstr as String
            }
        }
        return string
    }
}

func printIfDebug(_ string: String) {
    #if DEBUG
    print(string)
    #endif
}
