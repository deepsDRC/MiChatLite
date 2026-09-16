//
//  FindUsersServiceTests.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import XCTest
@testable import MiChatLite

@MainActor
final class FindUsersServiceTests: XCTestCase {
    private let service = FindUsersService()

    func testFetchUsersWithoutSearchTextReturnsProfiles() async throws {
        let profiles = try await service.fetchUserProfiles(for: "")

        XCTAssertFalse(profiles.isEmpty)
    }

    func testFetchUsersWithSearchTextReturnsProfiles() async throws {
        let profiles = try await service.fetchUserProfiles(for: "ali")

        XCTAssertFalse(profiles.isEmpty)
        XCTAssertTrue(
            profiles.allSatisfy { profile in
                profile.username.localizedCaseInsensitiveContains("ali") ||
                profile.displayName.localizedCaseInsensitiveContains("ali")
            }
        )
    }

    func testFetchUserProfilesWithNoMatchingSearchReturnsEmptyProfiles() async throws {
        let profiles = try await service.fetchUserProfiles(for: "not-matching-username")
        XCTAssertTrue(profiles.isEmpty)
    }
}
