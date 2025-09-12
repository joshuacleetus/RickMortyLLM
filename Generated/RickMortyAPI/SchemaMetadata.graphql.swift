// @generated
// This file was automatically generated and should not be edited.

import ApolloAPI

protocol RickMortyAPI_SelectionSet: ApolloAPI.SelectionSet & ApolloAPI.RootSelectionSet
where Schema == RickMortyAPI.SchemaMetadata {}

protocol RickMortyAPI_InlineFragment: ApolloAPI.SelectionSet & ApolloAPI.InlineFragment
where Schema == RickMortyAPI.SchemaMetadata {}

protocol RickMortyAPI_MutableSelectionSet: ApolloAPI.MutableRootSelectionSet
where Schema == RickMortyAPI.SchemaMetadata {}

protocol RickMortyAPI_MutableInlineFragment: ApolloAPI.MutableSelectionSet & ApolloAPI.InlineFragment
where Schema == RickMortyAPI.SchemaMetadata {}

extension RickMortyAPI {
  typealias SelectionSet = RickMortyAPI_SelectionSet

  typealias InlineFragment = RickMortyAPI_InlineFragment

  typealias MutableSelectionSet = RickMortyAPI_MutableSelectionSet

  typealias MutableInlineFragment = RickMortyAPI_MutableInlineFragment

  enum SchemaMetadata: ApolloAPI.SchemaMetadata {
    static let configuration: any ApolloAPI.SchemaConfiguration.Type = SchemaConfiguration.self

    static func objectType(forTypename typename: String) -> ApolloAPI.Object? {
      switch typename {
      case "Character": return RickMortyAPI.Objects.Character
      case "Characters": return RickMortyAPI.Objects.Characters
      case "Episode": return RickMortyAPI.Objects.Episode
      case "Info": return RickMortyAPI.Objects.Info
      case "Location": return RickMortyAPI.Objects.Location
      case "Query": return RickMortyAPI.Objects.Query
      default: return nil
      }
    }
  }

  enum Objects {}
  enum Interfaces {}
  enum Unions {}

}