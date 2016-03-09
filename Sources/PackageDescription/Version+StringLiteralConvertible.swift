/*
 This source file is part of the Swift.org open source project

 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

extension Version: StringLiteralConvertible {

    public init(stringLiteral value: String) {
        self.init(value.characters)!
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension Version {

    public init?(_ versionString: String) {
        self.init(versionString.characters)
    }

    public init?(_ characters: String.CharacterView) {
        let prereleaseStartIndex = characters.index(of: "-")
        let metadataStartIndex = characters.index(of: "+")

        let requiredEndIndex = prereleaseStartIndex ?? metadataStartIndex ?? characters.endIndex
        let requiredCharacters = characters.prefix(upTo: requiredEndIndex)
        let requiredComponents = requiredCharacters.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false).map{ String($0) }.flatMap{ Int($0) }.filter{ $0 >= 0 }

        guard requiredComponents.count == 3 else {
            return nil
        }

        self.major = requiredComponents[0]
        self.minor = requiredComponents[1]
        self.patch = requiredComponents[2]

        if let prereleaseStartIndex = prereleaseStartIndex {
            let prereleaseEndIndex = metadataStartIndex ?? characters.endIndex
            let prereleaseCharacters = characters[prereleaseStartIndex.successor()..<prereleaseEndIndex]
            prereleaseIdentifiers = prereleaseCharacters.split(separator: ".").map{ String($0) }
        } else {
            prereleaseIdentifiers = []
        }

        var buildMetadataIdentifier: String? = nil
        if let metadataStartIndex = metadataStartIndex {
            let buildMetadataCharacters = characters.suffix(from: metadataStartIndex.successor())
            if !buildMetadataCharacters.isEmpty {
                buildMetadataIdentifier = String(buildMetadataCharacters)
            }
        }
        self.buildMetadataIdentifier = buildMetadataIdentifier
    }
}
