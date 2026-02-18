import Foundation
#if canImport(Combine)
import Combine
#else
import OpenCombine
import OpenCombineDispatch
import OpenCombineFoundation
#endif
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

private extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{

    func saveItemsForCurrentUser(
        uris: [SpotifyURIConvertible],
        types: [IDCategory]
    ) -> AnyPublisher<Void, Error> {

        do {

            if uris.isEmpty {
                return ResultPublisher(())
                    .eraseToAnyPublisher()
            }

            let urisString = try SpotifyIdentifier
                .commaSeparatedURIsString(
                    uris, ensureCategoryMatches: types
                )

            return self.apiRequest(
                path: "/me/library",
                queryItems: ["uris": urisString],
                httpMethod: "PUT",
                makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
                bodyData: nil,
                requiredScopes: [.userLibraryModify]
            )
            .decodeSpotifyErrors()
            .map { _, _ in }
            .eraseToAnyPublisher()

        } catch {
            return error.anyFailingPublisher()
        }

    }

    func removeItemsForCurrentUser(
        uris: [SpotifyURIConvertible],
        types: [IDCategory]
    ) -> AnyPublisher<Void, Error> {

        do {

            if uris.isEmpty {
                return ResultPublisher(())
                    .eraseToAnyPublisher()
            }

            let urisString = try SpotifyIdentifier
                .commaSeparatedURIsString(
                    uris, ensureCategoryMatches: types
                )

            return self.apiRequest(
                path: "/me/library",
                queryItems: ["uris": urisString],
                httpMethod: "DELETE",
                makeHeaders: Headers.bearerAuthorizationAndContentTypeJSON(_:),
                bodyData: nil,
                requiredScopes: [.userLibraryModify]
            )
            .decodeSpotifyErrors()
            .map { _, _ in }
            .eraseToAnyPublisher()

        } catch {
            return error.anyFailingPublisher()
        }

    }

    func currentUserLibraryContains(
        uris: [SpotifyURIConvertible],
        types: [IDCategory]
    ) -> AnyPublisher<[Bool], Error> {

        do {

            if uris.isEmpty {
                return ResultPublisher([])
                    .eraseToAnyPublisher()
            }

            let urisString = try SpotifyIdentifier
                .commaSeparatedURIsString(
                    uris, ensureCategoryMatches: types
                )

            return self.getRequest(
                path: "/me/library/contains",
                queryItems: ["uris": urisString],
                requiredScopes: [.userLibraryRead]
            )
            .decodeSpotifyObject(
                [Bool].self,
                maxRetryDelay: self.maxRetryDelay
            )

        } catch {
            return error.anyFailingPublisher()
        }

    }

}

public extension SpotifyAPI where
    AuthorizationManager: SpotifyScopeAuthorizationManager
{

    // MARK: Library (Requires Authorization Scopes)

    /**
     Get the saved albums for the current user.

     See also ``currentUserSavedAlbumsContains(_:)``.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     To get just the albums, use:
     ```
     results.items.map(\.item)
     ```

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - limit: The maximum number of albums to return. Default: 20; Minimum: 1;
             Maximum: 50.
       - offset: The index of the first album to return. Default: 0. Use with
             `limit` to get the next set of albums.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". Provide this parameter if you want to apply [Track
             Relinking][3].
     - Returns: An array of the full versions of ``Album`` objects wrapped in a
           ``SavedItem`` object, wrapped in a ``PagingObject``.

     [1]: https://developer.spotify.com/documentation/web-api/reference/get-users-saved-albums
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func currentUserSavedAlbums(
        limit: Int? = nil,
        offset: Int? = nil,
        market: String? = nil
    ) -> AnyPublisher<PagingObject<SavedAlbum>, Error> {

        return self.getRequest(
            path: "/me/albums",
            queryItems: [
                "limit": limit,
                "offset": offset,
                "market": market
            ],
            requiredScopes: [.userLibraryRead]
        )
        .decodeSpotifyObject(
            PagingObject<SavedAlbum>.self,
            maxRetryDelay: self.maxRetryDelay
        )

    }

    /**
     Get the saved tracks for the current user.

     See also ``currentUserSavedTracksContains(_:)``.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     To get just the tracks, use:
     ```
     results.items.map(\.item)
     ```

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - limit: The maximum number of tracks to return. Default: 20;
             Minimum: 1; Maximum: 50.
       - offset: The index of the first track to return. Default: 0. Use with
             `limit` to get the next set of tracks.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". Provide this parameter if you want to apply [Track
             Relinking][3].
     - Returns: An array of the full versions of ``Track`` objects wrapped in a
           ``SavedItem`` object, wrapped in a ``PagingObject``.

     [1]: https://developer.spotify.com/documentation/web-api/reference/get-users-saved-tracks
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://developer.spotify.com/documentation/general/guides/track-relinking-guide/
     */
    func currentUserSavedTracks(
        limit: Int? = nil,
        offset: Int? = nil,
        market: String? = nil
    ) -> AnyPublisher<PagingObject<SavedTrack>, Error> {

        return self.getRequest(
            path: "/me/tracks",
            queryItems: [
                "limit": limit,
                "offset": offset,
                "market": market
            ],
            requiredScopes: [.userLibraryRead]
        )
        .decodeSpotifyObject(
            PagingObject<SavedTrack>.self,
            maxRetryDelay: self.maxRetryDelay
        )

    }

    /**
     Get the saved episodes for the current user.

     **This API endpoint is in beta and could change without warning.**

     See also ``currentUserSavedEpisodesContains(_:)``.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     To get just the episodes, use:
     ```
     results.items.map(\.item)
     ```

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - limit: The maximum number of episodes to return. Default: 20; Minimum:
             1; Maximum: 50.
       - offset: The index of the first episode to return. Default: 0. Use with
             `limit` to get the next set of episodes.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token".
     - Returns: An array of the full versions of ``Show`` objects wrapped in
           a ``SavedItem`` object, wrapped in a ``PagingObject``.

     [1]: https://developer.spotify.com/documentation/web-api/reference/get-users-saved-episodes
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func currentUserSavedEpisodes(
        limit: Int? = nil,
        offset: Int? = nil,
        market: String? = nil
    ) -> AnyPublisher<PagingObject<SavedEpisode>, Error> {

        return self.getRequest(
            path: "/me/episodes",
            queryItems: [
                "limit": limit,
                "offset": offset,
                "market": market
            ],
            requiredScopes: [.userLibraryRead]
        )
        .decodeSpotifyObject(
            PagingObject<SavedEpisode>.self,
            maxRetryDelay: self.maxRetryDelay
        )

    }

    /**
     Get the saved shows for the current user.

     See also ``currentUserSavedShowsContains(_:)``.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     To get just the shows, use:
     ```
     results.items.map(\.item)
     ```

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - limit: The maximum number of shows to return. Default: 20; Minimum: 1;
             Maximum: 50.
       - offset: The index of the first show to return. Default: 0. Use with
             `limit` to get the next set of shows.
     - Returns: An array of the full versions of ``Show`` objects wrapped in
           a ``SavedItem`` object, wrapped in a ``PagingObject``.

     [1]: https://developer.spotify.com/documentation/web-api/reference/get-users-saved-shows
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     */
    func currentUserSavedShows(
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<SavedShow>, Error> {

        return self.getRequest(
            path: "/me/shows",
            queryItems: [
                "limit": limit,
                "offset": offset
            ],
            requiredScopes: [.userLibraryRead]
        )
        .decodeSpotifyObject(
            PagingObject<SavedShow>.self,
            maxRetryDelay: self.maxRetryDelay
        )

    }

    /**
     Get the saved audiobooks for the current user.

     See also ``currentUserSavedAudiobooksContains(_:)``.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     To get just the audiobooks, use:
     ```
     results.items.map(\.item)
     ```

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - limit: The maximum number of audiobooks to return. Default: 20; Minimum:
             1; Maximum: 50.
       - offset: The index of the first audiobook to return. Default: 0. Use
             with `limit` to get the next set of audiobooks.
     - Returns: An array of the full versions of ``Audiobook`` objects wrapped
           in a ``SavedItem`` object, wrapped in a ``PagingObject``.

     [1]: https://developer.spotify.com/documentation/web-api/reference/get-users-saved-audiobooks
     */
    func currentUserSavedAudiobooks(
        limit: Int? = nil,
        offset: Int? = nil
    ) -> AnyPublisher<PagingObject<Audiobook>, Error> {

        return self.getRequest(
            path: "/me/audiobooks",
            queryItems: [
                "limit": limit,
                "offset": offset
            ],
            requiredScopes: [.userLibraryRead]
        )
        .decodeSpotifyObject(
            PagingObject<Audiobook>.self,
            maxRetryDelay: self.maxRetryDelay
        )

    }

    /**
     Check if one or more albums is saved in the current user's "Your Music"
     library.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of album URIs. Maximum: 50. Duplicate albums in
           the request will result in duplicate values in the response. A single
           invalid URI causes the entire request to fail. Passing in an empty
           array will immediately cause an empty array of results to be returned
           without a network request being made.
     - Returns: An array of `true` or `false` values, in the order requested,
           indicating whether the user's library contains each album.

     [1]: https://developer.spotify.com/documentation/web-api/reference/check-library-contains
     */
    func currentUserSavedAlbumsContains(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Bool], Error> {

        return self.currentUserLibraryContains(
            uris: uris, types: [.album]
        )

    }

    /**
     Check if one or more tracks is saved in the current user's "Your Music"
     library.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of track URIs. Maximum: 50. Duplicate tracks in
           the request will result in duplicate values in the response. A single
           invalid URI causes the entire request to fail. Passing in an empty
           array will immediately cause an empty array of results to be returned
           without a network request being made.
     - Returns: An array of `true` or `false` values, in the order requested,
           indicating whether the user's library contains each track.

     [1]: https://developer.spotify.com/documentation/web-api/reference/check-library-contains
     */
    func currentUserSavedTracksContains(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Bool], Error> {

        return self.currentUserLibraryContains(
            uris: uris, types: [.track]
        )

    }

    /**
     Check if one or more episodes is saved in the current user's "Your Music"
     library.

     **This API endpoint is in beta and could change without warning.**

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of episode URIs. Maximum: 50. Duplicate episodes
           in the request will result in duplicate values in the response. A
           single invalid URI causes the entire request to fail. Passing in an
           empty array will immediately cause an empty array of results to be
           returned without a network request being made.
     - Returns: An array of `true` or `false` values,
           in the order requested, indicating whether the user's
           library contains each episode.

     [1]: https://developer.spotify.com/documentation/web-api/reference/check-library-contains
     */
    func currentUserSavedEpisodesContains(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Bool], Error> {

        return self.currentUserLibraryContains(
            uris: uris, types: [.episode]
        )

    }

    /**
     Check if one or more shows is saved in the current user's "Your Music"
     library.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of show URIs. Maximum: 50. Duplicate shows in
           the request will result in duplicate values in the response. A single
           invalid URI causes the entire request to fail. Passing in an empty
           array will immediately cause an empty array of results to be returned
           without a network request being made.
     - Returns: An array of `true` or `false` values, in the order requested,
           indicating whether the user's library contains each show.

     [1]: https://developer.spotify.com/documentation/web-api/reference/check-library-contains
     */
    func currentUserSavedShowsContains(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Bool], Error> {

        return self.currentUserLibraryContains(
            uris: uris, types: [.show]
        )

    }

    /**
     Check if one or more audiobooks is saved in the current user's "Your Music"
     library.

     This endpoint requires the ``Scope/userLibraryRead`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of audiobook URIs. Maximum: 50. Duplicate
           audiobooks in the request will result in duplicate values in the
           response. A single invalid URI causes the entire request to fail.
           Passing in an empty array will immediately cause an empty array of
           results to be returned without a network request being made.
     - Returns: An array of `true` or `false` values, in the order requested,
           indicating whether the user's library contains each audiobook.

     [1]: https://developer.spotify.com/documentation/web-api/reference/check-library-contains
     */
    func currentUserSavedAudiobooksContains(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<[Bool], Error> {

        return self.currentUserLibraryContains(
            uris: uris,
            types: [.audiobook, .show]
        )

    }

    /**
     Save albums for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of album URIs. Maximum: 50. Duplicates will be
           ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/save-library-items
     */
    func saveAlbumsForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.saveItemsForCurrentUser(
            uris: uris, types: [.album]
        )

    }

    /**
     Save tracks for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of track URIs. Maximum: 50. Duplicates will be
           ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/save-library-items
     */
    func saveTracksForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.saveItemsForCurrentUser(
            uris: uris, types: [.track]
        )

    }

    /**
     Save episodes for the current user.

     **This API endpoint is in beta and could change without warning.**

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of episode URIs. Maximum: 50. Duplicates will be
           ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/save-library-items
     */
    func saveEpisodesForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.saveItemsForCurrentUser(
            uris: uris, types: [.episode]
        )

    }

    /**
     Save shows for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of show URIs. Maximum: 50. Duplicates will be
           ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/save-library-items
     */
    func saveShowsForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.saveItemsForCurrentUser(
            uris: uris, 
            types: [.show]
        )

    }

    /**
     Save audiobooks for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of audiobook URIs. Maximum: 50. Duplicates will
           be ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/save-library-items
     */
    func saveAudiobooksForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.saveItemsForCurrentUser(
            uris: uris,
            types: [.audiobook, .show]
        )

    }

    /**
     Remove saved albums for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of album URIs. Maximum: 50. Duplicates will be
           ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/remove-library-items
     */
    func removeSavedAlbumsForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.removeItemsForCurrentUser(
            uris: uris,
            types: [.album]
        )

    }

    /**
     Remove saved tracks for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of track URIs. Maximum: 50. Duplicates will be
           ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/remove-library-items
     */
    func removeSavedTracksForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.removeItemsForCurrentUser(
            uris: uris,
            types: [.track]
        )

    }

    /**
     Remove saved episodes for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of episode URIs. Maximum: 50. Duplicates will be
           ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/remove-library-items
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func removeSavedEpisodesForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.removeItemsForCurrentUser(
            uris: uris,
            types: [.episode]
        )

    }

    /**
     Remove saved shows for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameters:
       - uris: An array of show URIs. Maximum: 50. Duplicates will be ignored.
             A single invalid URI causes the entire request to fail. Passing in
             an empty array will prevent a network request from being made.
       - market: An [ISO 3166-1 alpha-2 country code][2] or the string
             "from_token". If a country code is specified, only shows that are
             available in that market will be removed. If a valid user access
             token is specified in the request header, the country associated
             with the user account will take priority over this parameter.
             **Note: If neither market or user country are provided, the**
             **content is considered unavailable for the client.** Users can
             view the country that is associated with their account in the
             [account settings][3].

     [1]: https://developer.spotify.com/documentation/web-api/reference/remove-library-items
     [2]: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
     [3]: https://www.spotify.com/account/overview/
     */
    func removeSavedShowsForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.removeItemsForCurrentUser(
            uris: uris,
            types: [.show]
        )

    }

    /**
     Remove saved audiobooks for the current user.

     This endpoint requires the ``Scope/userLibraryModify`` scope.

     Read more at the [Spotify web API reference][1].

     - Parameter uris: An array of audiobook URIs. Maximum: 50. Duplicates will
           be ignored. A single invalid URI causes the entire request to fail.
           Passing in an empty array will prevent a network request from being
           made.

     [1]: https://developer.spotify.com/documentation/web-api/reference/remove-library-items
     */
    func removeSavedAudiobooksForCurrentUser(
        _ uris: [SpotifyURIConvertible]
    ) -> AnyPublisher<Void, Error> {

        return self.removeItemsForCurrentUser(
            uris: uris,
            types: [.audiobook, .show]
        )

    }

}
