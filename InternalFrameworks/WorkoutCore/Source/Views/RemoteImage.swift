import Foundation
import ComposableArchitecture
import UIKit
import SwiftUI

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
            return environment.client
                .getImageData(at: key)
                .receive(on: DispatchQueue.main)
                .catchToEffect()
                .map { RemoteImageAction.imageLoaded($0) }
        
    case .imageLoaded(.success(let data)):
        let image = UIImage(data: data)
        state.imageData = data
        
    default: break
    }
    
    return .none
}