import Foundation
import RegexBuilder

struct Tag: Equatable, RawRepresentable {
    var rawValue: String
}

struct ProcessedNote: Equatable {
    var content: String
    var tags: [Tag]
}

struct Note {
    var content: String

    func substituteLinks() -> ProcessedNote {
        let tag = Reference(Substring.self)

        let tagAllowedChars = CharacterClass.word.union(.anyOf("/-"))
        let regex = Regex {
            ##"{\field{\*\fldinst{HYPERLINK "bear://x-callback-url/open-tag?name="##
            OneOrMore(tagAllowedChars)
            ##""}}{\fldrslt"##
            ZeroOrMore(.any)
            Capture(as: tag) {
                "#"
                OneOrMore(tagAllowedChars)
            }
            ##"}}"##
        }

        do {
            var output = Substring(content)
            var matches: [Regex<(Substring, Substring)>.Match] = []
            while let match = try regex.firstMatch(in: output) {
                print("\t\tFound tag link for tag: \(match[tag])")
                matches.append(match)
                output = output[match.range.upperBound...]
            }

            var substituted = content
            matches.reversed().forEach { output in
                substituted.replaceSubrange(output.range, with: output[tag])
            }

            let tags = matches.map {
                Tag(rawValue: String($0[tag]))
            }
            return .init(content: substituted, tags: tags)
            
        } catch {
            return .init(content: content, tags: [])
        }
    }
}

extension Note {
    init(contentOf url: URL) throws {
        let content = try String(contentsOf: url, encoding: .ascii)
        self.init(content: content)
    }
}
