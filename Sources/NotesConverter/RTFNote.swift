import Foundation
import System

protocol Processable {
    var name: String { get }
    func process() throws -> Output
}

struct Output: Equatable {
    var url: URL
    var tags: [Tag]
}


struct RTFNote: Processable {
    var name: String { url.lastPathComponent }
    
    var url: URL
    var targetDir: URL

    var outputURL: URL {
        targetDir.appending(path: url.lastPathComponent)
    }

    init?(url: URL, targetDir: URL) {
        guard url.pathExtension == "rtf" else {
            return nil
        }
        self.url = url
        self.targetDir = targetDir
    }

    func process() throws -> Output {
        let n = try Note(contentOf: url)
        let resultingNote = n.substituteLinks()
        try resultingNote.content.write(to: outputURL, atomically: true, encoding: .utf8)
        return .init(url: outputURL, tags: resultingNote.tags)
    }
}
