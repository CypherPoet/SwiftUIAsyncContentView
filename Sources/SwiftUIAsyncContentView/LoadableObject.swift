//
//  LoadableObject.swift
//

import Foundation


@MainActor
public protocol LoadableObject: ObservableObject {
    associatedtype Output
    
    var loadingState: LoadingState<Output> { get }
    
    func load() async
}
