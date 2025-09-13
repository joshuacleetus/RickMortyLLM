// @generated
// This file was automatically generated and should not be edited.

import ApolloTestSupport
import RickMortyLLM

class Info: MockObject {
  static let objectType: ApolloAPI.Object = RickMortyAPI.Objects.Info
  static let _mockFields = MockFields()
  typealias MockValueCollectionType = Array<Mock<Info>>

  struct MockFields {
    @Field<Int>("count") public var count
    @Field<Int>("next") public var next
    @Field<Int>("pages") public var pages
    @Field<Int>("prev") public var prev
  }
}

extension Mock where O == Info {
  convenience init(
    count: Int? = nil,
    next: Int? = nil,
    pages: Int? = nil,
    prev: Int? = nil
  ) {
    self.init()
    _setScalar(count, for: \.count)
    _setScalar(next, for: \.next)
    _setScalar(pages, for: \.pages)
    _setScalar(prev, for: \.prev)
  }
}
