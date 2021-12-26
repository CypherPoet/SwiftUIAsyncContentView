import SwiftUI
import PlaygroundSupport
import SwiftUIAsyncContentView


PlaygroundPage.current.needsIndefiniteExecution = true

let sampleView = VStack {
    SwiftUIAsyncContentView.AsyncContentView_Previews.DemoView()
}
.frame(width: 200, height: 200, alignment: .center)


PlaygroundPage.current.setLiveView(sampleView)
