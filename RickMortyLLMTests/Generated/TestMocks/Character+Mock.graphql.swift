// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import RickMortyLLM

class Character: MockObject {
  static let objectType: ApolloAPI.Object = RickMortyAPI.Objects.Character
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Character>>

  struct MockFields {
    @Field<[Episode?]>("episode") public var episode
    @Field<String>("gender") public var gender
    @Field<RickMortyAPI.ID>("id") public var id
    @Field<String>("image") public var image
    @Field<Location>("location") public var location
    @Field<String>("name") public var name
    @Field<Location>("origin") public var origin
    @Field<String>("species") public var species
    @Field<String>("status") public var status
    @Field<String>("type") public var type
  }
}

extension Mock where O == Character {
  convenience init(
    episode: [Mock<Episode>?] = [],
    gender: String? = nil,
    id: RickMortyAPI.ID? = nil,
    image: String? = nil,
    location: Mock<Location>? = nil,
    name: String? = nil,
    origin: Mock<Location>? = nil,
    species: String? = nil,
    status: String? = nil,
    type: String? = nil
  ) {
    self.init()
    _setList(episode, for: \.episode)
    _setScalar(gender, for: \.gender)
    _setScalar(id, for: \.id)
    _setScalar(image, for: \.image)
    _setEntity(location, for: \.location)
    _setScalar(name, for: \.name)
    _setEntity(origin, for: \.origin)
    _setScalar(species, for: \.species)
    _setScalar(status, for: \.status)
    _setScalar(type, for: \.type)
  }
}
