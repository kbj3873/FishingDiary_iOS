import Foundation

enum NetworkError: Error {
    case error(statusCode: Int, data: Data?)
    case notConnected
    case cancelled
    case generic(Error)
    case urlGeneration
    case noData     // > respose data가 없을 경우
}

protocol NetworkService {
    func request(endpoint: Requestable) async throws -> Data?
}

// MARK: - Implementation

final class DefaultNetworkService {
    
    private let encEUC_KR = CFStringConvertEncodingToNSStringEncoding(
        CFStringEncoding(CFStringEncodings.EUC_KR.rawValue)
    )
    
    private let encUTF8 = CFStringConvertEncodingToNSStringEncoding(
        CFStringEncoding(CFStringBuiltInEncodings.UTF8.rawValue)
    )
    
    private let config: NetworkConfigurable
    private let session: URLSession
    private let logger: NetworkErrorLogger
    
    init(
        config: NetworkConfigurable,
        session: URLSession = .shared,
        logger: NetworkErrorLogger = DefaultNetworkErrorLogger()
    ) {
        self.session = session
        self.config = config
        self.logger = logger
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
    
    private func resolve(error: Error) -> NetworkError {
        let code = URLError.Code(rawValue: (error as NSError).code)
        switch code {
        case .notConnectedToInternet: return .notConnected
        case .cancelled: return .cancelled
        default: return .generic(error)
        }
    }
}

extension DefaultNetworkService: NetworkService {
    
    func request(endpoint: Requestable) async throws -> Data? {
        let urlRequest: URLRequest
        do {
            urlRequest = try endpoint.urlRequest(with: config)
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
            return resolvedData
        } catch let error as NetworkError {
            throw error
        } catch {
            let networkError = resolve(error: error)
            logger.log(error: networkError)
            throw networkError
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
        print("headers: \(request.allHTTPHeaderFields!)")
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
            printIfDebug("not json:\n \(String(data: data, encoding: .utf8)!)")
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
