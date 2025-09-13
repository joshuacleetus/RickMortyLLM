// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import RickMortyLLM

class Query: MockObject {
  static let objectType: ApolloAPI.Object = RickMortyAPI.Objects.Query
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Query>>

  struct MockFields {
    @Field<Character>("character") public var character
    @Field<Characters>("characters") public var characters
  }
}

extension Mock where O == Query {
  convenience init(
    character: Mock<Character>? = nil,
    characters: Mock<Characters>? = nil
  ) {
    self.init()
    _setEntity(character, for: \.character)
    _setEntity(characters, for: \.characters)
  }
}
