public protocol Kernel: class, ServiceProvider {

  /// Kernel configuration.
  static var scheme: KernelScheme { get }

  /// Application-specific middleware.
  var middleware: [Middleware] { get }

  /// Application modes.
  var mods: [Mod.Type] { get }
}

public extension Kernel {

  /// Application-specific middleware.
  var middleware: [Middleware] {
    return []
  }

  /**
   Registers services on application container.

   - Parameter container: Application container.
  */
  func registerServices(on container: Container) throws {}
}
