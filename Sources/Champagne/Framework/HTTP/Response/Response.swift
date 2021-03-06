/**
  Response extensions.
*/
extension Response {

  typealias DidUpgrade = (Request, Stream) throws -> Void

  /// HTTP status line
  public var statusLine: String {
    return "HTTP/1.1 " + status.statusCode.description + " "
      + status.reasonPhrase + "\n"
  }

  // Connection upgrade.
  var didUpgrade: DidUpgrade? {
    get {
      return storage["response-connection-upgrade"] as? DidUpgrade
    }

    set(didUpgrade) {
      storage["response-connection-upgrade"] = didUpgrade
    }
  }

  /**
    Creates a new response.

    - Parameter status: The status code.
    - Parameter mime: The mime type.
    - Parameter body: Body data.
  */
  init(status: Status, mime: MimeType, body: DataRepresentable) {
    let headers: Headers = [
      "Content-Type": "\(mime.rawValue); charset=utf8"
    ]

    self.init(status: status, headers: headers, body: body.data)
  }

  /**
    Creates a new response.

    - Parameter status: The status code.
    - Parameter headers: Response headers.
    - Parameter body: Body data.
  */
  public init(status: Status, headers: Headers = [:], body: DataConvertible) {
    self.init(status: status, headers: headers, body: body.data)
  }
}

// MARK: - CustomStringConvertible

extension Response: CustomStringConvertible {

  /// String representation.
  public var description: String {
    return statusLine + headers.description
  }
}
