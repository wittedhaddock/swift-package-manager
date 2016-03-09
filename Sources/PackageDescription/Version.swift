/*
 This source file is part of the Swift.org open source project

 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors

 -------------------------------------------------------------------------
 [A semantic version](http://semver.org).
*/

public struct Version {
    public let (major, minor, patch): (Int, Int, Int)
    public let prereleaseIdentifiers: [String]
    public let buildMetadataIdentifier: String?
    
    public init(_ major: Int, _ minor: Int, _ patch: Int, prereleaseIdentifiers: [String] = [], buildMetadataIdentifier: String? = nil) {
        self.major = Swift.max(major, 0)
        self.minor = Swift.max(minor, 0)
        self.patch = Swift.max(patch, 0)
        self.prereleaseIdentifiers = prereleaseIdentifiers
        self.buildMetadataIdentifier = buildMetadataIdentifier
    }
}

// MARK: Equatable

extension Version: Equatable {}

public func ==(v1: Version, v2: Version) -> Bool {
    guard v1.major == v2.major && v1.minor == v2.minor && v1.patch == v2.patch else {
        return false
    }
    
    if v1.prereleaseIdentifiers != v2.prereleaseIdentifiers {
        return false
    }
    
    return v1.buildMetadataIdentifier == v2.buildMetadataIdentifier
}

// MARK: Comparable

extension Version: Comparable {}

public func <(lhs: Version, rhs: Version) -> Bool {
    let lhsComparators = [lhs.major, lhs.minor, lhs.patch]
    let rhsComparators = [rhs.major, rhs.minor, rhs.patch]
    
    if lhsComparators != rhsComparators {
        return lhsComparators.lexicographicallyPrecedes(rhsComparators)
    }
    
    guard lhs.prereleaseIdentifiers.count > 0 else {
        return false // Non-prerelease lhs >= potentially prerelease rhs
    }
    
    guard rhs.prereleaseIdentifiers.count > 0 else {
        return true // Prerelease lhs < non-prerelease rhs 
    }
    
    for (lhsPrereleaseIdentifier, rhsPrereleaseIdentifier) in zip(lhs.prereleaseIdentifiers, rhs.prereleaseIdentifiers) {
        if lhsPrereleaseIdentifier == rhsPrereleaseIdentifier {
            continue
        }
        
        let typedLhsIdentifier: Any = Int(lhsPrereleaseIdentifier) ?? lhsPrereleaseIdentifier
        let typedRhsIdentifier: Any = Int(rhsPrereleaseIdentifier) ?? rhsPrereleaseIdentifier
        
        switch (typedLhsIdentifier, typedRhsIdentifier) {
            case let (int1 as Int, int2 as Int): return int1 < int2
            case let (string1 as String, string2 as String): return string1 < string2
            case (is Int, is String): return true // Int prereleases < String prereleases
            case (is String, is Int): return false
        default:
            return false
        }
    }
    
    return lhs.prereleaseIdentifiers.count < rhs.prereleaseIdentifiers.count
}

// MARK: BidirectionalIndexType

extension Version: BidirectionalIndex {
    public func successor() -> Version {
        return Version(major, minor, patch.successor())
    }

    public func predecessor() -> Version {
        if patch == 0 {
            if minor == 0 {
                return Version(major - 1, Int.max, Int.max)
            } else {
                return Version(major, minor - 1, Int.max)
            }
        } else {
            return Version(major, minor, patch - 1)
        }
    }
}

// MARK: CustomStringConvertible

extension Version: CustomStringConvertible {
    public var description: String {
        var base = "\(major).\(minor).\(patch)"
        if prereleaseIdentifiers.count > 0 {
            base += "-" + prereleaseIdentifiers.joined(separator: ".")
        }
        if let buildMetadataIdentifier = buildMetadataIdentifier {
            base += "+" + buildMetadataIdentifier
        }
        return base
    }
}
