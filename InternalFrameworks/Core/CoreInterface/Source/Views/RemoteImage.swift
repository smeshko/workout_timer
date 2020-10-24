import Foundation
import ComposableArchitecture
import UIKit
import SwiftUI
import CoreLogic

public struct RemoteImage: View {
    
    private let store: Store<RemoteImageState, RemoteImageAction>
    private let key: String
    
    public init(key: String) {
        self.key = key
        
        self.store = Store<RemoteImageState, RemoteImageAction>(
            initialState: RemoteImageState(),
            reducer: remoteImageReducer,
            environment: RemoteImageEnvironment()
        )
    }
    
    public var body: some View {
        WithViewStore(store) { viewStore in
            Image(uiImage: UIImage(data: viewStore.imageData ?? Data()) ?? UIImage())
                .resizable()
                .onAppear { viewStore.send(.keyProvided(self.key)) }
        }
    }
}

public enum RemoteImageAction {
    case keyProvided(String)
    case imageLoaded(Result<Data, NetworkError>)
}

public struct RemoteImageState: Equatable {
    var imageData: Data?
    public init() {}
}

public struct RemoteImageEnvironment {
    let client: WebClient = .live
    
    public init() {}
}

public let remoteImageReducer = Reducer<RemoteImageState, RemoteImageAction, RemoteImageEnvironment> { state, action, environment in
    
    switch action {
    case .keyProvided(let key):
        guard key.contains("/") else {
            let data = UIImage(namedSharedAsset: "bodyweight-1").pngData()!
            return Effect(value: RemoteImageAction.imageLoaded(.success(data)))
        }
        return environment.client
            .getImageData(at: key)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map { RemoteImageAction.imageLoaded($0) }
        
    case .imageLoaded(.success(let data)):
        guard let _ = UIImage(data: data) else {
            return Effect(value: RemoteImageAction.imageLoaded(.failure(.incorrectResponse)))
        }
        state.imageData = data

    case .imageLoaded(.failure):
        state.imageData = UIImage(namedSharedAsset: "bodyweight-1").pngData()
    }
    
    return .none
}
