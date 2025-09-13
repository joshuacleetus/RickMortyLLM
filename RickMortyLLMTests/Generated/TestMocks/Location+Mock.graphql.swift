// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import RickMortyLLM

class Location: MockObject {
  static let objectType: ApolloAPI.Object = RickMortyAPI.Objects.Location
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Location>>

  struct MockFields {
    @Field<String>("name") public var name
  }
}

extension Mock where O == Location {
  convenience init(
    name: String? = nil
  ) {
    self.init()
    _setScalar(name, for: \.name)
  }
}
