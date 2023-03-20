import Foundation
import System

struct RTFDNote: Processable {
    var name: String { url.lastPathComponent }
    
    var url: URL
    var targetDir: URL

    init?(url: URL, targetDir: URL) {
        guard url.pathExtension == "rtfd" else {
            return nil
        }
        self.url = url
        self.targetDir = targetDir
    }

    var associatedDirectory: URL {
        var path = FilePath(url.absoluteString)
        path.extension = nil
        return URL(string: path.string)!
    }

    var noteURL: URL {
        noteFileURL(rtfdURL: url)
    }

    var outputAssociatedDirectoryURL: URL {
        return targetDir.appending(path: associatedDirectory.lastPathComponent)
    }

    var outputRTFDURL: URL {
        return targetDir.appending(path: url.lastPathComponent)
    }

    var outputTXTURL: URL {
        return noteFileURL(rtfdURL: outputRTFDURL)
    }

    private func noteFileURL(rtfdURL: URL) -> URL {
        rtfdURL.appending(component: "TXT.rtf")
    }

    func process() throws -> Output {
        let fm = FileManager.default

        if fm.fileExists(atPath: associatedDirectory.path) {
            if fm.fileExists(atPath: outputAssociatedDirectoryURL.path) {
                try fm.removeItem(at: outputAssociatedDirectoryURL)
            }
            try fm.copyItem(at: associatedDirectory, to: outputAssociatedDirectoryURL)
        }

        if fm.fileExists(atPath: url.path) {
            if fm.fileExists(atPath: outputRTFDURL.path) {
                try fm.removeItem(at: outputRTFDURL)
            }
            try fm.copyItem(at: url, to: outputRTFDURL)
        }

        let n = try Note(contentOf: noteURL)
        let resultingNote = n.substituteLinks()
        try resultingNote.content.write(to: outputTXTURL, atomically: true, encoding: .utf8)
        
        return .init(url: outputRTFDURL, tags: resultingNote.tags)
    }
}
