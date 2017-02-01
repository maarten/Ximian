
import Foundation


internal extension AEXMLElement {
    func addIntegerKey(key: String, val: Optional<Int>) {
        if val != nil {
            self.addChild(name: "key", value: key, attributes: [:])
            self.addChild(name: "integer", value: String(val!), attributes: [:])
        }
    }
    
    func addStringKey(key: String, val: Optional<String>) {
        if val != nil {
            self.addChild(name: "key", value: key, attributes: [:])
            self.addChild(name: "string", value: val!, attributes: [:])
        }
    }

    func addDateKey(key: String, val: Optional<Date>) {
        if val != nil {
            self.addChild(name: "key", value: key, attributes: [:])
            self.addChild(name: "date", value: val!.iso8601, attributes: [:])
        }
    }

    func addBoolKey(key: String, val: Optional<Bool>) {
        if val != nil {
            self.addChild(name: "key", value: key, attributes: [:])
            if(val!) {
                self.addChild(name: "true")
            } else {
                self.addChild(name: "false")
            }
        }
    }
    
    func addTrack(id: Int) {
        let trackDict = self.addChild(name: "dict")
        trackDict.addChild(name: "key", value: "Track ID", attributes: [:])
        trackDict.addChild(name: "integer", value: String(id), attributes: [:])
    }
    
    func addTrackList(tracks: [[String:Any]]) {
        let playlistArray = self.addChild(name: "array")
        for row in tracks {
            playlistArray.addTrack(id: row["track_id"] as! Int)
        }
    }
}

internal extension Date {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()

    var iso8601: String {
        return Date.iso8601Formatter.string(from: self)
    }
}


internal extension Bool {
    init<T: Integer>(_ num: T) {
        self.init(num != 0)
    }
}
