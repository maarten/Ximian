//
//  main.swift
//  ximian
//
//  Created by Maarten Engelen on 26/01/2017.
//  Copyright © 2017 Maarten Engelen. All rights reserved.
//

import Foundation


let cli = CommandLine()

let defaultSwinsianSQLite = "~/Library/Application Support/Swinsian/Library.sqlite"
let defaultItunesXML = "~/Music/iTunes/iTunes Library.xml"
let defaultItunesMusicFolder = "~/Music/iTunes/iTunes Media"

var dateSince1904Components = DateComponents()
dateSince1904Components.year = 1904
dateSince1904Components.month = 1
dateSince1904Components.day = 1
let dateSince1904 = Calendar.current.date(from: dateSince1904Components)!

let swinsianPath = StringOption(shortFlag: "s", longFlag: "swinsian", required: false,
                                helpMessage: "The path to the Swinsian sql file. Defaults to \(defaultSwinsianSQLite)")

let iTunesXMLPath = StringOption(shortFlag: "x", longFlag: "xml", required: false,
                                 helpMessage: "The path to the iTunes XML file. Defaults to \(defaultItunesXML)")

let iTunesMusicFolder = StringOption(shortFlag: "m", longFlag: "music", required: false,
                                        helpMessage: "The path to the iTunes Music Folder. Defaults to \(defaultItunesMusicFolder)")

let printUsage = BoolOption(shortFlag: "h", longFlag: "help", required: false,
                                     helpMessage: "Print this help message")


cli.addOptions(swinsianPath, iTunesXMLPath, iTunesMusicFolder)

do {
    try cli.parse()
    
    if(swinsianPath.value == nil) {
        _ = swinsianPath.setValue([NSString(string: defaultSwinsianSQLite).expandingTildeInPath])
    }
    
    if(iTunesXMLPath.value == nil) {
        _ = iTunesXMLPath.setValue([NSString(string: defaultItunesXML).expandingTildeInPath])
    }
    
    if(iTunesMusicFolder.value == nil) {
        _ = iTunesMusicFolder.setValue([NSString(string: defaultItunesMusicFolder).expandingTildeInPath])
    }
} catch {
    cli.printUsage()
    exit(EX_USAGE);
}

print("Starting Ximian...")
print("Swinsian DB Path: \(swinsianPath.value ?? "")")
print("iTunes XML Path: \(iTunesXMLPath.value ?? "")")
print("iTunes Music Folder Path: \(iTunesMusicFolder.value ?? "")")

let db = SQLiteDB(path: swinsianPath.value!)

// [1] Setup iTunes XML
let xml = AEXMLDocument()
let rootDict = xml.addChild(name: "plist", value: "", attributes: ["version": "1.0"]).addChild(AEXMLElement(name: "dict"))
rootDict.addIntegerKey(key: "Major Version", val: 1)
rootDict.addIntegerKey(key: "Minor Version", val: 1)
rootDict.addStringKey(key: "Application Version", val: "12.5.4.42")
rootDict.addDateKey(key: "Date", val: Date())
rootDict.addIntegerKey(key: "Features", val: 5)
rootDict.addBoolKey(key: "Show Content Ratings", val: true)
rootDict.addStringKey(key: "Library Persistent ID", val: "0000000000000002")
rootDict.addStringKey(key: "Music Folder", val: "file://\(iTunesMusicFolder.value!)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))

// [2] Add tracks
rootDict.addChild(name: "key", value: "Tracks", attributes: [:])
let trackDict = rootDict.addChild(name: "dict")


let trackData = db.query(sql: "SELECT title, artist, albumartist, album, grouping, genre, filesize, length, tracknumber, year, bpm, dateadded, bitrate, samplerate, comment, playcount, lastplayed, compilation, track_id, path FROM track")

for row in trackData {
    trackDict.addChild(name: "key", value: String(row["track_id"] as! Int), attributes: [:])
    let currentTrackDict = trackDict.addChild(name: "dict")
    
    currentTrackDict.addIntegerKey(key: "Track ID", val: row["track_id"] as! Int?)
    currentTrackDict.addStringKey(key: "Name", val: row["title"] as! String?)
    currentTrackDict.addStringKey(key: "Album Artist", val: row["albumartist"] as! String?)
    currentTrackDict.addStringKey(key: "Album", val: row["album"] as! String?)
    currentTrackDict.addStringKey(key: "Grouping", val: row["grouping"] as! String?)
    currentTrackDict.addStringKey(key: "Genre", val: row["genre"] as! String?)
    currentTrackDict.addIntegerKey(key: "Size", val: row["filesize"] as! Int?)
    currentTrackDict.addIntegerKey(key: "Total Time", val: Int((row["length"] as! Double) * 1000))
    currentTrackDict.addIntegerKey(key: "Track Numer", val: row["tracknumber"] as! Int?)
    currentTrackDict.addIntegerKey(key: "Year", val: row["year"] as! Int?)
    currentTrackDict.addIntegerKey(key: "BPM", val: row["bpm"] as! Int?)
    currentTrackDict.addIntegerKey(key: "Bit Rate", val: row["bitrate"] as! Int?)
    currentTrackDict.addIntegerKey(key: "Sample Rate", val: row["samplerate"] as! Int?)
    currentTrackDict.addStringKey(key: "Comment", val: row["comment"] as! String?)
    currentTrackDict.addIntegerKey(key: "Play Count", val: row["playcount"] as! Int?)
    currentTrackDict.addBoolKey(key: "Compilation", val: Bool(row["compilation"] as! Int))
    currentTrackDict.addStringKey(key: "Persistent ID", val: String(format:"%0.16X", row["track_id"] as! Int))
    currentTrackDict.addStringKey(key: "Location", val: "file://\(row["path"] as! String)".addingPercentEncoding(withAllowedCharacters: .urlPathAllowed))
    currentTrackDict.addStringKey(key: "Kind", val: "MPEG audio file")
    currentTrackDict.addDateKey(key: "Date Added", val: Date(timeIntervalSinceReferenceDate: row["dateadded"] as! Double))
    
    if(row["lastplayed"] != nil) {
        let lastPlayedDate = Date(timeIntervalSinceReferenceDate: row["lastplayed"] as! Double)
        currentTrackDict.addDateKey(key: "Play Date UTC", val: lastPlayedDate)
        currentTrackDict.addIntegerKey(key: "Play Date", val: Int(lastPlayedDate.timeIntervalSince(dateSince1904)))
    }
}

// [3] Start playlists
rootDict.addChild(name: "key", value: "Playlists", attributes: [:])
let playListArray = rootDict.addChild(name: "array")

// [4] MASTER PLAYLIST
let masterPlayListDict = playListArray.addChild(name: "dict")
masterPlayListDict.addBoolKey(key: "Master", val: true)
masterPlayListDict.addIntegerKey(key: "Playlist ID", val: 1)
masterPlayListDict.addStringKey(key: "Playlist Persistent ID", val: String(format:"%0.16X", 1))
masterPlayListDict.addBoolKey(key: "All Items", val: true)
masterPlayListDict.addBoolKey(key: "Visible", val: false)
masterPlayListDict.addStringKey(key: "Name", val: "Library")
masterPlayListDict.addChild(name: "key", value: "PlayList Items", attributes: [:])
masterPlayListDict.addTrackList(tracks: trackData)

// [5] PLAYLISTS
let playListData = db.query(sql: "SELECT p.playlist_id, p.name, p.pindex, plfp.playlistfolder_id, p.smartpredicate, p.smart, p.folder FROM playlist p LEFT JOIN playlistfolderplaylist plfp ON p.playlist_id = plfp.playlist_id ORDER BY plfp.playlistfolder_id, p.pindex")
var playlistTracks = [Int: OrderedSet<Int>]()
var playlistDetails = [Int: AEXMLElement]()
var playlistParents = [Int:Int]()

for row in playListData {
    let playlistDict = playListArray.addChild(name: "dict")
    
    let playlistId = (row["playlist_id"] as! Int) + 1
    
    if playlistTracks[playlistId] == nil {
        playlistTracks[playlistId] = OrderedSet()
    }
    
    // General items
    playlistDict.addStringKey(key: "Name", val: row["name"] as? String)
    playlistDict.addIntegerKey(key: "Playlist ID", val: playlistId)
    playlistDict.addStringKey(key: "Playlist Persistent ID", val: String(format: "%0.16X", playlistId))
    playlistDict.addBoolKey(key: "All Items", val: true)
    
    if let parentFolderId = row["playlistfolder_id"] as! Int? {
        playlistDict.addStringKey(key: "Parent Persistent ID", val: String(format: "%0.16X", parentFolderId + 1))
        playlistParents[playlistId] = parentFolderId + 1
    }
    
    if row["folder"] as! Int == 1 {
        // [5.1] FOLDER PLAYLIST
        playlistDict.addBoolKey(key: "Folder", val: true)
    } else if row["smart"] as! Int == 1 {
        // [5.2] SMART PLAYLIST
        guard let predicate = NSKeyedUnarchiver.unarchiveObject(with: row["smartpredicate"] as! Data) as? NSPredicate else {
            print("Couldn't convert smartpredicate field to NSPredicate, skipping..")
            continue
        }
        
        let smartSQL = "SELECT title, artist, albumartist, album, grouping, genre, filesize, length, tracknumber, year, bpm, dateadded, bitrate, samplerate, comment, playcount, lastplayed, compilation, track_id, path FROM track WHERE \(predicate.toSQL())"
        
        let trackData = db.query(sql: smartSQL)
        
        for row in trackData {
            (playlistTracks[playlistId] ?? OrderedSet()).append(row["track_id"] as! Int)
        }
    } else {
        // [5.3] REGULAR PLAYLIST
        let tracks = db.query(sql: "SELECT * FROM playlisttrack WHERE playlist_id = \(row["playlist_id"] as! Int)")
        
        for row in tracks {
            (playlistTracks[playlistId] ?? OrderedSet()).append(row["track_id"] as! Int)
        }
    }
    
    playlistDetails[playlistId] = playlistDict
}

// [6] BACKFILL FOLDER PLAYLIST ITEMS
for (playlistId, tracks) in playlistTracks {
    var parentId = playlistParents[playlistId]
    while parentId != nil {
        (playlistTracks[parentId!] ?? OrderedSet()).append(contentsOf: tracks)
        
        parentId = playlistParents[parentId!]
    }
}

// [7] Merge all tracks into XML definition
for (playlistId, tracks) in playlistTracks {
    if let details = playlistDetails[playlistId] {
        details.addChild(name: "key", value: "PlayList Items", attributes: [:])

        let trackList = details.addChild(name: "array")
        tracks.forEach({trackList.addTrack(id: $0)})
    }
}

do {
    try xml.xml.write(toFile: iTunesXMLPath.value!, atomically: false, encoding: String.Encoding.utf8)
    print("Written iTunes XML to \(iTunesXMLPath.value!)")
} catch {
    print("Error writing iTunes XML file")
}
