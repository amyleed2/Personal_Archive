import Foundation

extension URLSessionConfiguration {
    /// Applies configuration changes in the given block and returns the same instance for chaining.
    ///
    /// Usage:
    /// ```swift
    /// let configuration = URLSessionConfiguration.default.apply {
    ///     $0.allowsCellularAccess = true
    ///     $0.timeoutIntervalForRequest = 15
    /// }
    /// ```
    func apply(_ block: (URLSessionConfiguration) -> Void) -> URLSessionConfiguration {
        block(self)
        return self
    }
}
