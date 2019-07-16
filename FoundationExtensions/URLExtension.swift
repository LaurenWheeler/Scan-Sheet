import Foundation
extension URL {
    func extendedAttribute(forName name: String) throws -> Data  {
        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            var data = Data(count: length)
            let count = data.count
            let result =  data.withUnsafeMutableBytes {
                getxattr(fileSystemPath, name, $0, count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            return data
        }
        return data
    }
    func setExtendedAttribute(data: Data, forName name: String) throws {
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0, data.count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }
    func removeExtendedAttribute(forName name: String) throws {
        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = removexattr(fileSystemPath, name, 0)
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }
    func listExtendedAttributes() throws -> [String] {
        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }
            var data = Data(count: length)
            let count = data.count
            let result = data.withUnsafeMutableBytes {
                listxattr(fileSystemPath, $0, count, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            let list = data.split(separator: 0).compactMap {
                String(data: Data($0), encoding: .utf8)
            }
            return list
        }
        return list
    }
    private static func posixError(_ err: Int32) -> NSError {
        return NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}
