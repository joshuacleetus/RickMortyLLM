// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import RickMortyLLM

class Characters: MockObject {
  static let objectType: ApolloAPI.Object = RickMortyAPI.Objects.Characters
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Characters>>

  struct MockFields {
    @Field<Info>("info") public var info
    @Field<[Character?]>("results") public var results
  }
}

extension Mock where O == Characters {
  convenience init(
    info: Mock<Info>? = nil,
    results: [Mock<Character>?]? = nil
  ) {
    self.init()
    _setEntity(info, for: \.info)
    _setList(results, for: \.results)
  }
}
