import Foundation

/**
 Too Many Requests - Rate limiting has been applied.

 The ``retryAfter`` property specifies the number of seconds you must wait
 before you try the request again.

 Rate limiting is applied as per application based on Client ID, and regardless
 of the number of users who use the application simultaneously.

 To reduce the amount of requests, use endpoints that fetch multiple entities in
 one request. For example: If you often request single tracks, albums, or
 artists, use endpoints such as Get Several Tracks, Get Several Albums or Get
 Several Artists, instead.

 Read more at the [Spotify web API reference][1].

 [1]: https://developer.spotify.com/documentation/web-api/#rate-limiting
 */
public struct RateLimitedError: LocalizedError, Codable, Hashable {
    
    /// The number of seconds you must wait before you try the request again.
    public let retryAfter: Int?

    /// Spotify's optional reason for the 429 response.
    public let reason: String?

    /// Whether Spotify rejected the request because the application's quota is exhausted.
    public var isQuotaExceeded: Bool {
        reason == "QUOTA_EXCEEDED"
    }

    public init(retryAfter: Int?, reason: String? = nil) {
        self.retryAfter = retryAfter
        self.reason = reason
    }
    
    public var errorDescription: String? {
        if isQuotaExceeded {
            return "This Spotify application has reached its API quota. Try again later or use a different Spotify Client ID."
        }

        var description = "You have made too many requests (rate limiting error)."
        if let seconds = retryAfter {
            if seconds == 1 {
                description += " Try again in 1 second."
            }
            else {
                description += " Try again in \(seconds) seconds."
            }
        }
        else {
            description += " Try again later."
        }
        
        return description
    }
    
}
