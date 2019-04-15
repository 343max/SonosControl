// Copyright Max von Webel. All Rights Reserved.

import Foundation

struct Keychain {
  enum KeychainError: Error {
    case error(status: OSStatus)
  }

  static func add(tag: String, key: Data) throws {
    let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                kSecAttrApplicationTag as String: tag,
                                kSecValueData as String: key]
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else {
      throw KeychainError.error(status: status)
    }
  }

  static func get(tag: String) throws -> Data? {
    let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                kSecAttrApplicationTag as String: tag,
                                kSecReturnData as String: true]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    if status == errSecItemNotFound {
      return nil
    }
    guard status == errSecSuccess else {
      throw KeychainError.error(status: status)
    }
    return item as? Data
  }

  static func delete(tag: String) throws {
    let query: [String: Any] = [kSecClass as String: kSecClassKey,
                                kSecAttrApplicationTag as String: tag]
    let status = SecItemDelete(query as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw KeychainError.error(status: status)
    }
  }

  static func set(tag: String, key: Data) throws {
    try delete(tag: tag)
    try add(tag: tag, key: key)
  }
}

extension Keychain {
  static func add<T>(tag: String, value: T) throws where T: Encodable {
    let data = try JSONEncoder().encode(value)
    try add(tag: tag, key: data)
  }

  static func set<T>(tag: String, value: T) throws where T: Encodable {
    try delete(tag: tag)
    try add(tag: tag, value: value)
  }

  static func get<T>(tag: String, type: T.Type) throws -> T? where T: Decodable {
    guard let data = try get(tag: tag) else {
      return nil
    }
    return try JSONDecoder().decode(type, from: data)
  }
}
