// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import RickMortyLLM

class Episode: MockObject {
  static let objectType: ApolloAPI.Object = RickMortyAPI.Objects.Episode
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Episode>>

  struct MockFields {
    @Field<String>("air_date") public var air_date
    @Field<String>("episode") public var episode
    @Field<RickMortyAPI.ID>("id") public var id
    @Field<String>("name") public var name
  }
}

extension Mock where O == Episode {
  convenience init(
    air_date: String? = nil,
    episode: String? = nil,
    id: RickMortyAPI.ID? = nil,
    name: String? = nil
  ) {
    self.init()
    _setScalar(air_date, for: \.air_date)
    _setScalar(episode, for: \.episode)
    _setScalar(id, for: \.id)
    _setScalar(name, for: \.name)
  }
}
