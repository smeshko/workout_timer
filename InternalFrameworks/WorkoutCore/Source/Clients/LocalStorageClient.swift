import Combine
import ComposableArchitecture
import Foundation

public enum StorageError: Error {
  case documentsDirectoryNotFound
  case savingFailed
  case fileNotFound
  case readingFromFileFailed
  case deletingFileFailed
}

public struct LocalStorageClient {
  public var readFromFile: (String, String) -> Effect<Data, StorageError>
  public var write: (Data, String, String) -> Effect<Void, StorageError>
  public var readFiles: (String) -> Effect<[Data], StorageError>
  public var delete: (String) -> Effect<Void, StorageError>
}

extension LocalStorageClient {
  
  public static let live = LocalStorageClient(
    readFromFile: { name, ext in
      Effect<Data, StorageError>.future { promise in
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let fileURL = directory
            .appendingPathComponent(name)
            .appendingPathExtension(ext)
          do {
            let data = try Data(contentsOf: fileURL)
            promise(.success(data))
          } catch {
            promise(.failure(.readingFromFileFailed))
          }
        } else {
          promise(.failure(.fileNotFound))
        }
      }.eraseToEffect()
      
  },
    write: { data, fileName, ext in
      Effect<Void, StorageError>.future { promise in
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let fileURL = directory
            .appendingPathComponent(fileName)
            .appendingPathExtension(ext)
          do {
            try data.write(to: fileURL, options: [.atomic])
            promise(.success(()))
          } catch {
            promise(.failure(.savingFailed))
          }
        } else {
          promise(.failure(.documentsDirectoryNotFound))
        }
      }.eraseToEffect()
      
  },
    readFiles: { ext in
      Effect<[Data], StorageError>.future { promise in
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          do {
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: []).filter { $0.pathExtension == ext }
            let data = try files.map { try Data(contentsOf: $0) }
            promise(.success(data))
          } catch {
            promise(.failure(.readingFromFileFailed))
          }
        } else {
          promise(.failure(.documentsDirectoryNotFound))
        }
        
      }.eraseToEffect()
      
  },
    delete: { fileName -> Effect<Void, StorageError> in
      Effect<Void, StorageError>.future { promise in
        if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          let path = directory.appendingPathComponent(fileName)
          if FileManager.default.fileExists(atPath: path.absoluteString) {
            do {
              try FileManager.default.removeItem(at: path)
              promise(.success(()))
            } catch {
              promise(.failure(.deletingFileFailed))
            }
          }
        } else {
          promise(.failure(.documentsDirectoryNotFound))
        }
      }.eraseToEffect()
  })
  
  public static let mock = LocalStorageClient(
    readFromFile: { name, ext in
      .fireAndForget {
        print("Read file named \(name).\(ext)")
      }
  },
    write: { data, fileName, ext in
      .fireAndForget {
        print("Writing to file named \(fileName).\(ext)")
      }
  },
    readFiles: { ext in
      .fireAndForget {
        print("Reading all files with extension \(ext)")
      }
  },
    delete: { fileName -> Effect<Void, StorageError> in
      .fireAndForget {
        print("Deleteing file named \(fileName)")
      }
  })
}
