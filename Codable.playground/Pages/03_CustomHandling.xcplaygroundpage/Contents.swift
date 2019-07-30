/*:

 ### Swift India Conference - 2019

 [Previous](@previous)

 */

import Foundation

let jsonString = """
{
    "name"        :  "Roma",
    "country"     :  "Mexico",
    "director"    :  "Alfonso Cuarón",
    "released"    :  true,
    "duration"    :  135,
    "ticketPrice" :  [250,500]
}
"""

guard let jsonData = jsonString.data(using: .utf8) else {
    fatalError("Check your input data & come back again!")
}

extension KeyedDecodingContainer {

    func decodeIfPresent<T: Decodable>(_ key: Key) -> T? {
        do {
            return try decodeIfPresent(T.self, forKey: key)
        } catch DecodingError.typeMismatch(_, _) {
            /*
             Attempt to convert the input type to required type
             Handles basic types - Int, String, Double, Bool
             */
            if let integer = try? decode(Int.self, forKey: key) {
                return TypeConverter.convert(T.self, from: integer)
            } else if let double = try? decode(Double.self, forKey: key) {
                return TypeConverter.convert(T.self, from: double)
            } else if let bool = try? decode(Bool.self, forKey: key) {
                return TypeConverter.convert(T.self, from: bool)
            } else if let string = try? decode(String.self, forKey: key) {
                return TypeConverter.convert(T.self, from: string)
            }
            // throw DecodingError? 🔥
            return nil
        } catch {
            // Handle generic error
            return nil
        }
    }

}

struct TypeConverter {

    /// Converts input type to expected type
    ///
    /// Handles basic types - Int, String, Double, Bool
    ///
    /// Ex : "28" -> 28, "1" -> true
    /// - Parameters:
    ///   - expectedType: Expected type
    ///   - inputValue: Input value
    /// - Returns: Converted value in expected type if present
    static func convert<T, I>(_ expectedType: T.Type, from inputValue: I) -> T? {

        //Compare the expected type & get the values accordingly
        switch expectedType {
        case is String.Type:
            return TypeConverter.string(from: inputValue) as? T
        case is Double.Type:
            return TypeConverter.double(from: inputValue) as? T
        case is Int.Type:
            return TypeConverter.int(from: inputValue) as? T
        case is Bool.Type:
            return TypeConverter.bool(from: inputValue) as? T
        default:
            //If the expected type don't fall under any of the above cases, return nil
            return nil
        }
    }


    /// String from generic input data
    ///
    /// Handles basic types - Int, String, Double, Bool
    ///
    /// Ex: 2019 => "2019", 99.99 => "99.99", true => "true"
    /// - Parameter inputValue: Input value
    /// - Returns: Optional String
    static func string<T>(from inputValue: T) -> String? {

        switch inputValue {
        case is Int:
            guard let unwrappedInteger = inputValue as? Int else { return nil }
            return String(unwrappedInteger)
        case is Double:
            guard let unwrappedDouble = inputValue as? Double else { return nil }
            return String(unwrappedDouble)
        case is Bool:
            guard let unwrappedBool = inputValue as? Bool else { return nil }
            return String(unwrappedBool)
        case is String:
            return inputValue as? String
        default:
            return nil
        }
    }


    /// Double from generic input data
    ///
    /// Handles basic types - Int, String, Double
    ///
    /// Note: Bool is not supported
    /// Ex: "99.99" => 99.99
    /// - Parameter inputValue: Input value
    /// - Returns: Optional Double
    static func double<T>(from inputValue: T) -> Double? {

        switch inputValue {
        case is Int:
            guard let unwrappedInteger = inputValue as? Int else { return nil }
            return Double(unwrappedInteger)
        case is Double:
            return inputValue as? Double
        case is String:
            guard let unwrappedString = inputValue as? String else { return nil }
            return Double(unwrappedString)
        default:
            //Note: Bool to Double is not supported
            return nil
        }
    }


    /// Int from generic input data
    ///
    /// Handles basic types - Int, String, Double, Bool
    ///
    /// Ex: "2019" => 2019, 99.99 => 99
    /// - Parameter inputValue: Input value
    /// - Returns: Optional Int
    static func int<T>(from inputValue: T) -> Int? {

        switch inputValue {
        case is Int:
            return inputValue as? Int
        case is Double:
            guard let unwrappedDouble = inputValue as? Double else { return nil }
            return Int(unwrappedDouble)
        case is Bool:
            guard let unwrappedBool = inputValue as? Bool else { return nil }
            return NSNumber(value: unwrappedBool).intValue
        case is String:
            guard let unwrappedString = inputValue as? String else { return nil }
            return Int(unwrappedString)
        default:
            return nil
        }
    }


    /// Bool from generic input data
    ///
    /// Handles only basic types - Int, String, Double, Bool
    ///
    /// Ex: 1 => true, 99.99 => true, "0" => false, "yes" => true
    /// - Parameter inputValue: Input value
    /// - Returns: Optional Bool
    static func bool<T>(from inputValue: T) -> Bool? {

        switch inputValue {
        case is Int:
            guard let unwrappedInteger = inputValue as? Int else { return nil }
            return NSNumber(integerLiteral: unwrappedInteger).boolValue
        case is Double:
            guard let unwrappedDouble = inputValue as? Double else { return nil }
            return NSNumber(floatLiteral: unwrappedDouble).boolValue
        case is Bool:
            return inputValue as? Bool
        case is String:
            guard let unwrappedString = inputValue as? String else { return nil }
            return unwrappedString.boolValue()
        default:
            return nil
        }
    }

}

extension String {

    /// Extract Bool from input which can be represented in different ways
    ///
    /// "1", "yes", "true" are treated as true
    ///
    /// "0", "no", "false" are treated as false
    /// - Returns: Optional Bool
    func boolValue() -> Bool? {
        let trueValues  = ["1", "yes", "true"]
        let falseValues = ["0", "no", "false"]
        if trueValues.contains(where: {$0.caseInsensitiveCompare(self) == .orderedSame}) {
            return true
        } else if falseValues.contains(where: {$0.caseInsensitiveCompare(self) == .orderedSame}) {
            return false
        }
        return nil
    }
}

struct Movie: Codable {

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

    /// Ticket Price
    let ticketPrice: ClosedRange<Int>

    private enum CodingKeys: String, CodingKey {
        case name
        case country
        case director
        case released
        case duration
        case ticketPrice
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = container.decodeIfPresent(.name) ?? ""
        country = container.decodeIfPresent(.country) ?? ""
        director = container.decodeIfPresent(.director) ?? ""
        released = container.decodeIfPresent(.released) ?? false
        duration = container.decodeIfPresent(.duration) ?? 0
        //New in swift 5 - Range, ClosedRange, etc conforms to Codable 🎉
        ticketPrice = try! container.decodeIfPresent(ClosedRange.self, forKey: .ticketPrice) ?? 100...150
    }
}


do {
    let movie = try JSONDecoder().decode(Movie.self, from: jsonData)
    dump(movie)
} catch {
    print("Exception - \(error.localizedDescription)")
}

