/*:

 ### Swift India Conference - 2019

 [Previous](@previous)                                                      [Next](@next)

 */

//  Copyright 2019 Bharath Nagaraj Rao. All rights reserved.

import Foundation

let jsonString = """
{
    "name"      :  "Roma",
    "ctryName"  :  "Mexico",
    "dirName"   :  "Alfonso Cuarón",
    "released"  :  true,
    "duration"  :  135,
    "artists"   : {
                    "leadActress" : "Yalitza Aparicio",
                    "leadActor"   : "Fernando Grediaga"
                  }
}
"""

guard let jsonData = jsonString.data(using: .utf8) else {
    fatalError("Check your input data & come back again!")
}

struct Movie: Decodable {

    /// Name of the movie
    let name: String

    /// Country of origin
    let country: String

    /// Director of the movie
    let director: String

    /// Release status
    let released: Bool

    /// Duration in minutes
    let duration: Int

    /// Lead actor
    let leadActor: String

    /// Lead actress
    let leadActress: String

    private enum CodingKeys: String, CodingKey {
        case name
        case country  = "ctryName"
        case director = "dirName"
        case released
        case duration
        case artists
    }

    private enum ArtistCodingKeys: String, CodingKey {
        case leadActor
        case leadActress
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        director = try container.decodeIfPresent(String.self, forKey: .director) ?? ""
        released = try container.decodeIfPresent(Bool.self, forKey: .released) ?? false
        duration = try container.decodeIfPresent(Int.self, forKey: .duration) ?? 0

        let artistContainer = try container.nestedContainer(keyedBy: ArtistCodingKeys.self, forKey: .artists)
        leadActor = try artistContainer.decodeIfPresent(String.self, forKey: .leadActor) ?? ""
        leadActress = try artistContainer.decodeIfPresent(String.self, forKey: .leadActress) ?? ""
    }
}

do {
    let movie = try JSONDecoder().decode(Movie.self, from: jsonData)
    dump(movie)
} catch {
    print("Exception - \(error.localizedDescription)")
}

