import ArgumentParser
import Foundation
import System

@main
struct NotesConverter: ParsableCommand {
    @Option
    var inputDirectory: String?

    @Option
    var outputDirectory: String?

    func run() throws {
        let fm = FileManager.default

        func resolve(_ path: String?) -> URL {
            URL(filePath: path ?? ".")
        }

        let input = resolve(inputDirectory)
        let output = resolve(outputDirectory ?? inputDirectory)

        print("input directory: \(input)")
        print("output directory: \(output)")

        try fm.createDirectory(at: output, withIntermediateDirectories: true)

        let noteURLS = try fm.contentsOfDirectory(at: input, includingPropertiesForKeys: nil)
        print("Found \(noteURLS.count) notes in input directory:")

        let rtfs = noteURLS
            .filter { $0.pathExtension == "rtf" }
            .map { url -> Result<Output, ProcessingError> in
                if let note = RTFNote(url: url, targetDir: output) {
                    return process(note)
                } else {
                    return .failure(.init(name: url.lastPathComponent))
                }
            }

        let rtfds = noteURLS
            .filter { $0.pathExtension == "rtfd" }
            .compactMap { url -> Result<Output, ProcessingError> in
                if let note = RTFDNote(url: url, targetDir: output) {
                    return process(note)
                } else {
                    return .failure(.init(name: url.lastPathComponent))
                }
            }

        let results = rtfs + rtfds

        let failed = results.compactMap { result -> ProcessingError? in
            switch result {
            case let .failure(error):
                return error
            case .success:
                return nil
            }
        }

        let successWithoutTags = results.compactMap { result -> Output? in
            switch result {
            case .failure:
                return nil
            case let .success(output):
                if output.tags.isEmpty {
                    return output
                } else {
                    return nil
                }
            }
        }


        let successCount = results.count - failed.count
        print("Processed \(successCount) notes succesfully.")
        if !failed.isEmpty {
            print("Failed to process the following notes:")
            failed.forEach { error in
                print("\t\(error.name)")
            }
        }
        print("\n")
        if !successWithoutTags.isEmpty {
            print("The following notes did not have tags (\(successWithoutTags.count)):")
            successWithoutTags.forEach { output in
                print("\t\(output.url.lastPathComponent)")
            }
        }
    }

    struct ProcessingError: Error {
        var name: String
    }

    func process(_ p: some Processable) -> Result<Output, ProcessingError> {
        defer { print("\n") }

        do {
            print("\tProcessing: \(p.name)")
            return .success(try p.process())
        } catch {
            print("\t Error processing: \(error)")
            return .failure(ProcessingError(name: p.name))
        }
    }
}



