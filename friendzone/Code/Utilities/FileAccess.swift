//
//  FileAccess.swift
//  friendzone
//
//  Created by Paul Kühnel on 19.05.22.
//

import Foundation
import Combine

enum LoadingError: Error {
    case noPath
    case fileNotFound
    case parsingError(decodingError: DecodingError)
    case unknown(error: Error)
}

enum SavingError: Error {
    case noPath
    case errorWhileSaving
    case encodingError(encodingError: EncodingError)
    case unknown(error: Error)
}

enum DeletionError: Error {
    case noPath
    case unknown(error: Error)
}

class FileAccess {
    private let folderName: String
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let backgroundQueue: DispatchQueue
    
    init(folderName: String, decoder: JSONDecoder = .init(), encoder: JSONEncoder = .init()) {
        self.folderName = folderName
        self.decoder = decoder
        self.encoder = encoder
        self.backgroundQueue = .global(qos: .default)
    }
    
    let documentsPath: URL? = {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }()
    
    func save<T: Encodable>(filename: String, object: T) -> AnyPublisher<Void, SavingError> {
        return Future<Void, SavingError> { [weak self] promise in
            self?.backgroundQueue.async { [weak self] in
                guard let self = self else { return }
                let data: Data
                
                do {
                    data = try self.encoder.encode(object)
                } catch let error as EncodingError {
                    promise(.failure(.encodingError(encodingError: error)))
                    return
                } catch {
                    promise(.failure(.unknown(error: error)))
                    return
                }
                
                guard let path = self.documentsPath,
                      self.createFolderIfNeeded()
                else {
                    promise(.failure(.noPath))
                    return
                }
                
                let url = path
                    .appendingPathComponent(self.folderName)
                    .appendingPathComponent(filename)
                
                do {
                    try data.write(to: url)
                    promise(.success(()))
                    return
                } catch {
                    promise(.failure(.errorWhileSaving))
                    return
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func load<T: Decodable>(fromFilename filename: String) -> AnyPublisher<T, LoadingError> {
        return Future<T, LoadingError> { [weak self] promise in
            guard let self = self else { return }
            self.backgroundQueue.async {
                
                guard let path = self.documentsPath else {
                    promise(.failure(.noPath))
                    return
                }
                
                let url = path
                    .appendingPathComponent(self.folderName)
                    .appendingPathComponent(filename)
                
                let data: Data
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    promise(.failure(.fileNotFound))
                    return
                }
                
                do {
                    let decoded = try self.decoder.decode(T.self, from: data)
                    
                    promise(.success(decoded))
                    return
                } catch let error as DecodingError {
                    promise(.failure(.parsingError(decodingError: error)))
                    return
                } catch {
                    promise(.failure(.unknown(error: error)))
                    return
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func deleteFile(at filename: String) -> Result<Void, DeletionError> {
        guard let path = documentsPath else { return .failure(.noPath) }
        let url = path
            .appendingPathComponent(self.folderName)
            .appendingPathComponent(filename)
        
        do {
            try FileManager.default.removeItem(at: url)
            return .success(())
        } catch {
            print(error)
            return .failure(.unknown(error: error))
        }
    }
    
    private func createFolderIfNeeded() -> Bool {
        guard let path = documentsPath else { return false }
        let folderPath = path.appendingPathComponent(folderName)
        
        do {
            try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true, attributes: nil)
            return true
        } catch {
            return false
        }
    }
    
}
