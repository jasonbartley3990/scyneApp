//
//  extensions.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation
import UIKit

extension UIView {
    var top: CGFloat {
        frame.origin.y
    }
    
    var bottom: CGFloat {
        frame.origin.y+height
    }
    var height: CGFloat {
        frame.size.height
    }
    var width: CGFloat {
        frame.size.width
    }
    var right: CGFloat {
        frame.origin.x+width
    }
    var left: CGFloat {
        frame.origin.x
    }
}

extension Encodable {
    func asDictionary() -> [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
        return json
    }
}

extension Decodable {
    init?(with dictionary: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {return nil}
        guard let result = try? JSONDecoder().decode(Self.self, from: data) else {
            return nil
        }
        self = result
        
    }
}

extension DateFormatter {
    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        //formatter.timeStyle = .short
        return formatter
    }()
    
}

extension DateFormatter {
    static let stringToDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateFormat = "MMM d, yyyy at HH:mm a"
        return formatter
}()
}

extension String {
    static func date(from date: Date) -> String? {
    let formatter = DateFormatter.formatter
    let string = formatter.string(from: date)
    return string
    }
}

extension String {
    func trimingLeadingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: characterSet) }) else {
            return self
        }

        return String(self[index...])
    }
}


extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        
        if secondsAgo < minute {
            return "\(secondsAgo) seconds ago"
        } else if  secondsAgo < hour {
            return "\(secondsAgo / minute) minutes ago"
        } else if  secondsAgo < day {
            return "\(secondsAgo / hour) hours ago"
        } else if secondsAgo < week {
            return "\(secondsAgo / day) days ago"
        } else if secondsAgo < month {
            return "\(secondsAgo / week) weeks ago"
        }
        
        return "usePostedDate"
        
    }
}


