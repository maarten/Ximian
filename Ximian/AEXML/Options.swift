//
//  Options.swift
//  AEXML
//
//  Created by Marko Tadic on 9/10/16.
//  Copyright © 2016 AE. All rights reserved.
//

import Foundation

/// Options used in `AEXMLDocument`
public struct AEXMLOptions {
    
    /// Values used in XML Document header
    public struct DocumentHeader {
        /// Version value for XML Document header (defaults to 1.0).
        public var version = 1.0
        
        /// Encoding value for XML Document header (defaults to "utf-8").
        public var encoding = "utf-8"
        
        /// Standalone value for XML Document header (defaults to "no").
        public var standalone = "no"
        
        /// XML Document header
        // Modified to return exact iTunes XML header, some readers need this to be able to process the iTunes XML file
        public var xmlString: String {
            return "<?xml version=\"\(version)\" encoding=\"\(encoding)\"?>\n" +
            "<!DOCTYPE plist PUBLIC \"-//Apple Computer//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
        }
    }
    
    /// Values used in XML Document header (defaults to `DocumentHeader()`)
    public var documentHeader = DocumentHeader()
        
    /// Designated initializer - Creates and returns default `AEXMLOptions`.
    public init() {}
    
}
