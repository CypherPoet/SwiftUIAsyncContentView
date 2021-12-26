import SwiftUI

extension Task where
    Success == Never,
    Failure == Never
{
    internal static func sleep(seconds: Double) async throws {
        let nanoseconds = UInt64(seconds) * Constants.secondsInNanosecond
        
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}


