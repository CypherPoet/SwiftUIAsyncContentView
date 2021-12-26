// AsyncContentView.swift
//
// Created by CypherPoet.
// ✌️
//
    
import SwiftUI


public struct AsyncContentView<
    SourceObject: LoadableObject,
    LoadingView: View,
    ErrorView: View,
    Content: View
> {
    public typealias DefaultLoadingView = ProgressView<EmptyView, EmptyView>
    public typealias LoadingViewBuilder = (() -> LoadingView)

    public typealias DefaultErrorView = EmptyView
    public typealias ErrorViewBuilder = ((Error) -> ErrorView)
    
    public typealias ContentViewBuilder = ((SourceObject.Output) -> Content)
    
    
    @ObservedObject
    var source: SourceObject
    
    var loadingView: LoadingViewBuilder
    var errorView: ErrorViewBuilder
    var content: ContentViewBuilder
    
    
    // MARK: -  Init
    public init(
        source: SourceObject,
        @ViewBuilder loadingView: @escaping LoadingViewBuilder,
        @ViewBuilder errorView: @escaping ErrorViewBuilder,
        @ViewBuilder content: @escaping ContentViewBuilder
    ) {
        self.source = source
        self.loadingView = loadingView
        self.errorView = errorView
        self.content = content
    }
}


// MARK: - `View` Body
extension AsyncContentView: View {

    public var body: some View {
        switch source.loadingState {
        case .idle:
            Color.clear.task {
                await source.load()
            }
        case .loading:
            loadingView()
        case .failed(let error):
            errorView(error)
        case .loaded(let output):
            content(output)
        }
    }
}


extension AsyncContentView where
    LoadingView == DefaultLoadingView
{
    /// Initializes an ``AsyncContentView`` with a default loading view.
    public init(
        source: SourceObject,
        @ViewBuilder errorView: @escaping ErrorViewBuilder,
        @ViewBuilder content: @escaping ContentViewBuilder
    ) {
        self.init(
            source: source,
            loadingView: { LoadingView() },
            errorView: errorView,
            content: content
        )
    }
}


extension AsyncContentView where
    ErrorView == DefaultErrorView
{
    /// Initializes an ``AsyncContentView`` with a default error view.
    public init(
        source: SourceObject,
        @ViewBuilder loadingView: @escaping LoadingViewBuilder,
        @ViewBuilder content: @escaping ContentViewBuilder
    ) {
        self.init(
            source: source,
            loadingView: loadingView,
            errorView: { _ in ErrorView() },
            content: content
        )
    }
}


extension AsyncContentView where
    LoadingView == DefaultLoadingView,
    ErrorView == DefaultErrorView
{
    /// Initializes an ``AsyncContentView`` with a default loading view
    /// and default error view.
    public init(
        source: SourceObject,
        @ViewBuilder content: @escaping ContentViewBuilder
    ) {
        self.init(
            source: source,
            loadingView: { LoadingView() },
            errorView: { _ in ErrorView() },
            content: content
        )
    }
}



#if DEBUG

// MARK: - Previews

public struct AsyncContentView_Previews: PreviewProvider {

    
    public final class SampleLoadableObject: LoadableObject {
        public var loadingState: LoadingState<String> = .idle
        
        public func load() async {
            loadingState = .loaded("Swift 🔥")
        }
    }
    
    
    public final class SampleDelayedLoadableObject: LoadableObject {
        
        @Published
        public var loadingState: LoadingState<String> = .idle
        
        private var taskWithDelay: Task<Void, Error>?
        
        
        func simulateDelay(for seconds: Double = 1.0) async {
            loadingState = .loading
            
            do {
                try await Task.sleep(seconds: seconds)
                loadingState = .loaded("Swift 🔥🔥🔥🔥")
            } catch {
                loadingState = .failed(error)
            }
        }
        
        
        public func load() async {
            Task {
                await simulateDelay()
            }
        }
    }
    
    
    public struct DemoView: View {
        
        @StateObject
        private var previewSource: SampleDelayedLoadableObject
        
        
        public init() {
            _previewSource = StateObject(
                wrappedValue: SampleDelayedLoadableObject()
            )
        }
        
        
        public var body: some View {
            AsyncContentView(
                source: previewSource,
                loadingView: {
                    ProgressView("Loading")
                },
                errorView: { error in
                    Text("Failed with error: \(error.localizedDescription)")
                },
                content: { text in
                    Text(text)
                }
            )
        }
    }



    public static var previews: some View {
        DemoView()
    }
}

#endif

