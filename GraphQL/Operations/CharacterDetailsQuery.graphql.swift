// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class CharacterDetailsQuery: GraphQLQuery {
  public static let operationName: String = "CharacterDetails"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query CharacterDetails($id: ID!) { character(id: $id) { __typename id name status species type gender image origin { __typename name } location { __typename name } episode { __typename id name air_date episode } } }"#
    ))

  public var id: RickMortyAPI.ID

  public init(id: RickMortyAPI.ID) {
    self.id = id
  }

  public var __variables: Variables? { ["id": id] }

  public struct Data: RickMortyAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: any ApolloAPI.ParentType { RickMortyAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("character", Character?.self, arguments: ["id": .variable("id")]),
    ] }

    /// Get a specific character by ID
    public var character: Character? { __data["character"] }

    /// Character
    ///
    /// Parent Type: `Character`
    public struct Character: RickMortyAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: any ApolloAPI.ParentType { RickMortyAPI.Objects.Character }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("id", RickMortyAPI.ID?.self),
        .field("name", String?.self),
        .field("status", String?.self),
        .field("species", String?.self),
        .field("type", String?.self),
        .field("gender", String?.self),
        .field("image", String?.self),
        .field("origin", Origin?.self),
        .field("location", Location?.self),
        .field("episode", [Episode?].self),
      ] }

      /// The id of the character.
      public var id: RickMortyAPI.ID? { __data["id"] }
      /// The name of the character.
      public var name: String? { __data["name"] }
      /// The status of the character ('Alive', 'Dead' or 'unknown').
      public var status: String? { __data["status"] }
      /// The species of the character.
      public var species: String? { __data["species"] }
      /// The type or subspecies of the character.
      public var type: String? { __data["type"] }
      /// The gender of the character ('Female', 'Male', 'Genderless' or 'unknown').
      public var gender: String? { __data["gender"] }
      /// Link to the character's image.
      /// All images are 300x300px and most are medium shots or portraits since they are intended to be used as avatars.
      public var image: String? { __data["image"] }
      /// The character's origin location
      public var origin: Origin? { __data["origin"] }
      /// The character's last known location
      public var location: Location? { __data["location"] }
      /// Episodes in which this character appeared.
      public var episode: [Episode?] { __data["episode"] }

      /// Character.Origin
      ///
      /// Parent Type: `Location`
      public struct Origin: RickMortyAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { RickMortyAPI.Objects.Location }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String?.self),
        ] }

        /// The name of the location.
        public var name: String? { __data["name"] }
      }

      /// Character.Location
      ///
      /// Parent Type: `Location`
      public struct Location: RickMortyAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { RickMortyAPI.Objects.Location }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String?.self),
        ] }

        /// The name of the location.
        public var name: String? { __data["name"] }
      }

      /// Character.Episode
      ///
      /// Parent Type: `Episode`
      public struct Episode: RickMortyAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: any ApolloAPI.ParentType { RickMortyAPI.Objects.Episode }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("id", RickMortyAPI.ID?.self),
          .field("name", String?.self),
          .field("air_date", String?.self),
          .field("episode", String?.self),
        ] }

        /// The id of the episode.
        public var id: RickMortyAPI.ID? { __data["id"] }
        /// The name of the episode.
        public var name: String? { __data["name"] }
        /// The air date of the episode.
        public var air_date: String? { __data["air_date"] }
        /// The code of the episode.
        public var episode: String? { __data["episode"] }
      }
    }
  }
}
