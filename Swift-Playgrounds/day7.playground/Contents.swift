import Foundation
import RegexBuilder

let fileURL = Bundle.main.url(forResource: "Input", withExtension: nil)
let input = try String(contentsOf: fileURL!, encoding: String.Encoding.utf8)

enum Line {
    case cd(CDInstruction)
    case ls
    case dir(Directory)
    case file(File)
}

enum CDInstruction {
    case root
    case dirName(String)
    case back

    static func parseFrom(_ raw: String) -> CDInstruction {
        switch raw {
        case "/": return .root
        case "..": return .back
        default: return .dirName(raw)
        }
    }
}

class FileSystemEntity {
    var size: Int
    var name: String

    init(name: String = "", size: Int = 0) {
        self.name = name
        self.size = size
    }
}

class Directory: FileSystemEntity, Identifiable {
    var contents: [FileSystemEntity]

    init(name: String = "", size: Int = 0, contents: [FileSystemEntity] = []) {
        self.contents = contents

        super.init(name: name, size: size)
    }
}

class File: FileSystemEntity {
}

let cdRegex = Regex {
    "$ cd "
    Capture(OneOrMore(.any))
}

let lsRegex = Regex {
    "$ ls"
}

let dirRegex = Regex {
    "dir "
    Capture(OneOrMore(.word))
}

let fileRegex = Regex {
    Capture(OneOrMore(.digit))
    " "
    Capture(OneOrMore(.any))
}


func parseLines(_ stringInput: String) -> [Line] {
    var result: [Line] = []

    stringInput.split(whereSeparator: \.isNewline).forEach { line in
        if let match = String(line).wholeMatch(of: cdRegex) {
            let rawInstruction = String(match.1)
            result.append(.cd(CDInstruction.parseFrom(rawInstruction)))
        } else if let _ = String(line).wholeMatch(of: lsRegex) {
            result.append(.ls)
        } else if let match = String(line).wholeMatch(of: dirRegex) {
            let dirName = String(match.1)
            result.append(.dir(Directory(name: dirName)))
        } else if let match = String(line).wholeMatch(of: fileRegex) {
            let size = Int(match.1) ?? 0
            let name = String(match.2)
            result.append(.file(File(name: name, size: size)))
        } else {
            print("Can't parse: \(line)")
        }
    }

    return result
}

func makeFileSystemFrom(_ lines: [Line]) -> Directory {
    var rootDir = Directory(name: "/")
    var path: [Directory] = [rootDir]

    for line in lines {
        switch line {
        case .cd(let cdInstruction):
            switch cdInstruction {
            case .root:
                path = [rootDir]
            case .dirName(let name):
                if let dir = path.last?.contents.first(where: { $0 is Directory && $0.name == name }) as? Directory {

                    path.append(dir)
                }

            case .back:
                guard path.count > 1 else { break }
                path.removeLast()
            }
        case .ls:
            continue
        case .dir(let dir):
            rootDir = add(dir, to: rootDir, at: path)
        case .file(let file):
            rootDir = add(file, to: rootDir, at: path)
        }
    }

    return rootDir
}

func add(_ fileSystemEntity: FileSystemEntity, to rootDir: Directory, at path: [Directory]) -> Directory {
    var updatedRootDir = rootDir
    var currentDir = updatedRootDir

    path.dropFirst().forEach { pathComponent in
        if let dir = currentDir.contents.first(where: { $0 is Directory && $0.name == pathComponent.name }) as? Directory {
            currentDir = dir
        } else {
            print("I poop myself when add")
        }
    }
    currentDir.contents.append(fileSystemEntity)

    return updatedRootDir
}

func getDirectoryFrom(_ dir: Directory, for path: [Directory]) -> Directory {
    var currentDir = dir
    path.dropFirst().forEach { pathComponent in
        if let dir = currentDir.contents.first(where: { $0 is Directory && $0.name == pathComponent.name }) as? Directory {
            currentDir = dir
        } else {
            print("I poop myself when getDirectoryFrom")
        }
    }

    return currentDir
}

var calculatedDirectories = [Directory]()

func calculateDirectorySize(_ dir: Directory) -> Directory {
    let filesSize = dir.contents.filter({ $0 is File }).map { $0.size }.reduce(0, +)
    var directoriesSize = 0
    var newDir = Directory(name: dir.name)

    for fileSystemEntity in dir.contents {
        if let directory = fileSystemEntity as? Directory {
            let calculatedDir = calculateDirectorySize(directory)
            newDir.contents.append(calculatedDir)
            calculatedDirectories.append(calculatedDir)
//            print(calculatedDir.name, calculatedDir.contents.count, calculatedDir.size)

            directoriesSize += calculatedDir.size
        } else {
            newDir.contents.append(fileSystemEntity)
        }
    }

    newDir.size = filesSize + directoriesSize

    return newDir
}

func directoriesIn(_ dir: Directory, withSizeUnder maxSize: Int) -> [Directory] {
    var result: [Directory] = []

    for directory in dir.contents {
        if let directory = directory as? Directory {
            if directory.size <= maxSize {
                result.append(directory)
                let fittingDirectories = directoriesIn(directory, withSizeUnder: maxSize)
                result.append(contentsOf: fittingDirectories)
            } else {
                let fittingDirectories = directoriesIn(directory, withSizeUnder: maxSize)
                result.append(contentsOf: fittingDirectories)
            }
        }
    }

    return result
}

var fileSystem = makeFileSystemFrom(parseLines(input))
let calculatedFileSystem = calculateDirectorySize(fileSystem)
let deletionDirectoryCandidates = directoriesIn(calculatedFileSystem, withSizeUnder: 100_000)
print("Task 1 answer is \(deletionDirectoryCandidates.map({ $0.size }).reduce(0, +))")

let neededSpace = 30000000 + calculatedFileSystem.size - 70000000
print("Needed space is \(neededSpace)")

let deletionDirectories = calculatedDirectories.filter({ $0.size >= neededSpace })
let deletionDirectoriesSorted = deletionDirectories.map({ $0.size }).sorted()

print("Dir to delete has size of \(deletionDirectoriesSorted.first!)")
