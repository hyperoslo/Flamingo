/**
  Request extensions
*/
extension Request {

  /// URL parameters
  public var parameters: [String: String] {
    get {
      return storage["fl-parameters"] as? [String: String] ?? [:]
    }
    set(parameters) {
      storage["fl-parameters"] = parameters
    }
  }
}

/**
  Message extensions
*/
public extension Message {

  /// Converts body data to string
  var bodyString: String? {
    var bufferBody = body
    return try? bufferBody.becomeBuffer().description
  }
}
