//
//  FDFileManager.swift
//  FishingDiary
//
//  Created by Y0000591 on 2023/09/08.
//

import Foundation

enum FileStorageError: Error {
    case createError
    case readError
    case saveError
    case deleteError
    
    var description: String {
        switch self {
        case .createError:
            return "error: file storage [create error]"
        case .readError:
            return "error: file storage [read error]"
        case .saveError:
            return "error: file storage [save error]"
        case .deleteError:
            return "error: file storage [delete error]"
        }
    }
}

typealias FileCreateResult = Result<Bool, FileStorageError>

struct StartPointData: Codable {
    var time: String
    var latitude: String
    var longitude: String
    var sequence: Int
}

enum FDFilePathType {
    case pointPath
    case todayPath
    
    var url: URL {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let baseUrl = URL(fileURLWithPath: documentsDirectoryPath)
        switch self {
        case .pointPath:
            return baseUrl.appendingPathComponent("point")
        case .todayPath:
            return baseUrl.appendingPathComponent("point").appendingPathComponent(Date.todayStringForPath())
        }
    }
    
    var path: String {
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        
        switch self {
        case .pointPath:
            let baseUrl = URL(fileURLWithPath: documentsDirectoryPath)
            let pointUrl = baseUrl.appendingPathComponent("point")
            return pointUrl.path
        case .todayPath:
            let baseUrl = URL(fileURLWithPath: documentsDirectoryPath)
            let todayUrl = baseUrl.appendingPathComponent("point").appendingPathComponent(Date.todayStringForPath())
            return todayUrl.path
        }
        
    }
}

// MARK: - File 관리 Class
class FDFileManager: NSObject {
    // MARK: - Variables
    static let shared = FDFileManager()
    
    // MARK: - Public functions
    func getFilePath(_ pathType: FDFilePathType) -> String {
        return pathType.path
    }
    
    func getFileUrl(_ pathType: FDFilePathType, _ nameType: String) -> URL {
        return URL(fileURLWithPath: pathType.path).appendingPathComponent(nameType)
    }
    
    func getFilePathList(_ pathType: FDFilePathType) -> [String]! {
        guard let fileList = try? FileManager.default.contentsOfDirectory(atPath: getFilePath(pathType)) else {
            return [String]()
        }
        return fileList
    }
    
    func getFileList(_ url: URL) -> [String]! {
        guard let fileList = try? FileManager.default.contentsOfDirectory(atPath: url.path) else {
            return [String]()
        }
        return fileList
    }
    
    func getDirPathList(_ pathType: FDFilePathType) -> [URL]! {
        guard let dirList = try? FileManager.default.contentsOfDirectory(at: pathType.url, includingPropertiesForKeys: nil, options: []) else {
            return [URL]()
        }
        return dirList.filter{ $0.hasDirectoryPath }
    }
    
    func getDirList(_ pathUrl: URL) -> [URL]! {
        guard let dirList = try? FileManager.default.contentsOfDirectory(at: pathUrl, includingPropertiesForKeys: nil, options: []) else {
            return [URL]()
        }
        return dirList.filter{ $0.hasDirectoryPath }
    }
    
    func existOfDirPath(_ pathType: FDFilePathType) -> Bool{
        var exist = false
        guard let fileList = try? FileManager.default.contentsOfDirectory(atPath: getFilePath(pathType)) else {
            print("not exist in path : \(getFilePath(pathType))")
            return exist
        }
        print("exist list count : \(fileList.count) \nin path : \(getFilePath(pathType))")
        exist = fileList.count > 0 ? true:false
        return exist
    }
    
    /// Create default file path
    func createDefaultDirectories() {
        
        if !FileManager.default.fileExists(atPath: getFilePath(.pointPath)) {
            do{
                try FileManager.default.createDirectory(atPath: getFilePath(.pointPath), withIntermediateDirectories: false, attributes: nil)
                print("make directory : \(getFilePath(.pointPath))")
            }catch {
                print(error)
            }
        }
        
    }
    
    /// Create file path
    func createFilePath(_ pathType: FDFilePathType) -> FileCreateResult {
        // create file path
        if !FileManager.default.fileExists(atPath: getFilePath(pathType)) {
            do{
                try FileManager.default.createDirectory(atPath: getFilePath(pathType), withIntermediateDirectories: false, attributes: nil)
                return .success(true)
            }catch {
                print(error)
                return .failure(.createError)
            }
        }
        
        else {
            return .failure(.createError)
        }
    }
    
    func createFilePath(_ pathType: FDFilePathType, _ pathName: String) -> FileCreateResult {
        // create file path
        if !FileManager.default.fileExists(atPath: getFileUrl(pathType, pathName).path) {
            do{
                try FileManager.default.createDirectory(atPath: getFileUrl(pathType, pathName).path, withIntermediateDirectories: false, attributes: nil)
                print("create file path : \(getFileUrl(pathType, pathName).path)")
                return .success(true)
            }catch {
                print(error)
                return .failure(.createError)
            }
        }
        
        else {
            return .failure(.createError)
        }
    }
    
    func writeFilePath(_ data: Data, _ pathType: FDFilePathType, _ fileName: String, completion:((Bool) -> Void)? = nil) {
        let filePath = URL(fileURLWithPath: getFilePath(pathType)).appendingPathComponent(fileName)
        do {
            try data.write(to: filePath)
            print("write succ file path : \(filePath)")
            if let completeHandler = completion {
                completeHandler(true)
            }
        } catch let error {
            print(error)
            if let completeHandler = completion {
                completeHandler(false)
            }
        }
    }
    
    func writePointFilePath(_ data: Data, _ dirNum: String, _ fileName: String, completion:((Bool) -> Void)? = nil) {
        let filePath = URL(fileURLWithPath: getFilePath(.todayPath))
            .appendingPathComponent(dirNum)
            .appendingPathComponent(fileName)
        do {
            try data.write(to: filePath)
            print("write succ file path : \(filePath)")
            if let completeHandler = completion {
                completeHandler(true)
            }
        } catch let error {
            print(error)
            if let completeHandler = completion {
                completeHandler(false)
            }
        }
    }
    
    /// 파일 삭제
    func removeFilePath(_ pathType: FDFilePathType, _ nameType: String) {
        let filePath = getFileUrl(pathType, nameType)
        if FileManager.default.fileExists(atPath: filePath.path) {
            do{
                print("delete file path : \(filePath)")
                try FileManager.default.removeItem(atPath: filePath.path)
            }catch {
                print(error)
            }
        }
    }
    
    func getPointFile(pathUrl: URL, fileName: String) -> [LocationData]? {
        do {
            let fileUrl = pathUrl.appendingPathComponent(fileName)
            let data = try Data(contentsOf: fileUrl)
            
            if let pointList = try? JSONDecoder().decode([LocationData].self, from: data) {
                return pointList
            } else {
                print("getPointFile json decode error")
                return nil
            }
        }
        
        catch {
            print("getPointFile error")
            return nil
        }
    }
    
    func getStartPointFile(fileName: String) -> [StartPointData]? {
        guard let fileLocation = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileLocation)
            if let pointList = try? JSONDecoder().decode([StartPointData].self, from: data) {
                return pointList
            } else {
                print("getPointFile json decode error")
                return nil
            }
        } catch {
            return nil
        }
    }
}

// MARK: - Public Data Repository functions
extension FDFileManager {
    
    func createPointDate() -> FileCreateResult{
        if !self.existOfDirPath(.todayPath) {
            return self.createFilePath(.todayPath)
        }
        
        else {
            return .failure(.createError)
        }
    }
    
    func createPointData() -> FileCreateResult{
        if let dirList = self.getDirPathList(.todayPath) {
            return self.createFilePath(.todayPath, "\(dirList.count)")
        }
        
        else {
            return self.createFilePath(.todayPath, "0")
        }
    }
    
    func savePoints(locations: [LocationData]) {
        guard let jsonEncodeData = try? JSONEncoder().encode(locations) else {
            print("error : json encode failed")
            return
        }
        
        if let dirList = self.getDirPathList(.todayPath) {
            self.writePointFilePath(jsonEncodeData, "\(dirList.count-1)", Date.todayStringForSave())
        }
    }
    
    func fetchPointDateList(completion: (Result<[PointDate], FileStorageError>) -> Void) {
        if self.existOfDirPath(.pointPath) {
            if let dirList = self.getDirPathList(.pointPath), dirList.count > 0 {
                var pointDates = [PointDate]()
                for dir in dirList {
                    let pointDate = PointDate(date: dir.lastPathComponent, datePath: dir)
                    pointDates.append(pointDate)
                }
                
                completion(.success(pointDates))
            }
            
            else { completion(.failure(.readError)) }
        }
        
        else { completion(.failure(.readError)) }
    }
    
    func fetchPointDataList(pointDate: PointDate, completion: (Result<[PointData], FileStorageError>) -> Void) {
        guard let dirPath = pointDate.datePath else {
            completion(.failure(.readError))
            return
        }
        
        if let pointDirList = FDFileManager.shared.getDirList(dirPath), pointDirList.count > 0 {
            var pointList = [PointData]()
            for point in pointDirList {
                let pointData = PointData(dataName: point.lastPathComponent,
                                          dataPath: point)
                pointList.append(pointData)
            }
            
            completion(.success(pointList))
        }
        
        else {
            completion(.failure(.readError))
        }
    }
    
    func fetchLocations(pointData: PointData, completion: (Result<[LocationData], FileStorageError>) -> Void) {
        guard let path = pointData.dataPath, let fileList = self.getFileList(path) else {
            completion(.failure(.readError))
            return
        }
        
        var list = [LocationData]()
        if fileList.count > 0 {
            for file in fileList {
                if let pointList = FDFileManager.shared.getPointFile(pathUrl: path, fileName: file) {
                    for point in pointList {
                        list.append(point)
                        //print("\(point)")
                    }
                }
            }
            
            let locations = list.sorted(by: {$0.sequence < $1.sequence})
            completion(.success(locations))
        }
        
        else {
            completion(.failure(.readError))
        }
    }
}
