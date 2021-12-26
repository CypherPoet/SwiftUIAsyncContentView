import Foundation

public enum LoadingState<Value> {
   case idle
   case loading
   case failed(Error)
   case loaded(Value)
}


// MARK: -  Computeds
extension LoadingState {
   
   public var isLoading: Bool {
       switch self {
       case .idle,
           .failed,
           .loaded:
           return false
       case .loading:
           return true
       }
   }
}
