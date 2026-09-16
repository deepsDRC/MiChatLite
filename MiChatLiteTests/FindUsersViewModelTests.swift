//
//  FindUsersViewModelTests.swift
//  MiChatLite
//
//  Created by Deepu Ramachandran on 16/09/26.
//

import XCTest
@testable import MiChatLite

@MainActor
final class FindUsersViewModelTests: XCTestCase {
    fileprivate var mockService: MockFindUsersService!
    var vm: FindUsersViewModel!

    override func setUp() {
        super.setUp()

        mockService = MockFindUsersService()
        vm = FindUsersViewModel(findUserService: mockService)
    }

    func testFetchProfilesWithoutSearchTextReturnsAllProfiles() async {
        vm.searchText = ""
        await vm.fetchUserProfiles()
        let profiles = vm.userProfiles

        XCTAssertFalse(profiles.isEmpty)
        XCTAssertEqual(profiles.count, 3)
    }

    func testFetchProfilesWithSearchTextReturnsSingleProfile() async {
        vm.searchText = "ali"
        await vm.fetchUserProfiles()
        let profiles = vm.userProfiles
        
        XCTAssertFalse(profiles.isEmpty)
        XCTAssertTrue(profiles.count == 1)
        XCTAssertTrue(
            profiles.allSatisfy { profile in
                profile.displayName.localizedCaseInsensitiveContains(vm.searchText) ||
                profile.username.localizedCaseInsensitiveContains(vm.searchText)
            }
        )
    }

    func testEmptyProfilesWithNoMatchSearch() async {
        vm.searchText = "no-match-searchquery"
        await vm.fetchUserProfiles()
        XCTAssertEqual(vm.userProfiles.count, 0)
        XCTAssertNil(vm.errorMessage)
    }

    func testFetchProfilesWhenServiceFailsSetsError() async {
        vm.searchText = "no-match-searchquery"
        mockService.mockShouldFail = true

        await vm.fetchUserProfiles()

        guard let errorMessage = vm.errorMessage else {
            XCTFail("No error message")
            return
        }

        XCTAssertNotNil(errorMessage)
    }


}

enum MockFindUsersServiceError: LocalizedError {
    case noMatch

    var localizedDescription: String { "No match" }
}

fileprivate final class MockFindUsersService: FindUsersServiceProtocol {

    var mockShouldFail: Bool = false

    var profiles: [Profile] = [
        Profile(
            id: UUID(),
            username: "alice",
            displayName: "alice",
            avatarURL: nil,
            createdAt: Date()
        ),
        Profile(
            id: UUID(),
            username: "bob",
            displayName: "bob",
            avatarURL: nil,
            createdAt: Date()
        ),
        Profile(
            id: UUID(),
            username: "sam",
            displayName: "sam",
            avatarURL: nil,
            createdAt: Date()
        ),
    ]

    func fetchUserProfiles(for searchText: String) async throws -> [MiChatLite
        .Profile]
    {
        if mockShouldFail {
            throw MockFindUsersServiceError.noMatch
        }

        if searchText.isEmpty {
            return self.profiles
        }

        return profiles.filter { profile in
            profile.displayName.localizedCaseInsensitiveContains(searchText) ||
            profile.username.localizedCaseInsensitiveContains(searchText)
        }
    }
}
