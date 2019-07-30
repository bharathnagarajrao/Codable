/*:

 ### Swift India Conference - 2019

 [Next](@next)

 */

import Foundation

let jsonString = """
[
  {
    "name"                  :  "Roma",
    "country-name"          :  "Mexico",
    "director-name"         :  "Alfonso Cuarón",
    "released-status"       :  true,
    "duration"              :  135
  },
  {
    "name"                  :  "The Shape of Water",
    "country-name"          :  "USA",
    "director-name"         :  "Guillermo del Toro",
    "released-status"       :  true,
    "duration"              :  123
  }
]
"""

guard let jsonData = jsonString.data(using: .utf8) else {
    fatalError("Check your input data & come back again!")
}

struct Movie: Decodable {

    /// Name of the movie
    let name: String

    /// Country of origin
    let countryName: String

    /// Director of the movie
    let directorName: String

    /// Release status
    let releasedStatus: Bool

    /// Duration in minutes
    let duration: Int
}

struct MovieKey: CodingKey {

    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}

extension JSONDecoder.KeyDecodingStrategy {

    static var convertFromKebabCase: JSONDecoder.KeyDecodingStrategy {

        return .custom { codingKeys in
            let codingKey: CodingKey = codingKeys.last!
            let components = codingKey.stringValue.split(separator: "-")

            let joinedString : String
            if components.count == 1 {
                joinedString = String(components[0])
            } else {
                joinedString = ([components[0].lowercased()] +
                    components[1...].map{ $0.capitalized }).joined()
            }
            return MovieKey(stringValue: joinedString)!
        }
    }
}

let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromKebabCase

do {
    let movies = try decoder.decode([Movie].self, from: jsonData)
    dump(movies)
} catch {
    print("Exception - \(error.localizedDescription)")
}
