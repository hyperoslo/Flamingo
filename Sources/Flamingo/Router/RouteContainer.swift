@_exported import HTTP

/**
  Route container keeps and builds routes relative to the root path.
*/
public class RouteContainer: RouteGetBuilding, RoutePostBuilding,
  RoutePutBuilding, RoutePatchBuilding, RouteDeleteBuilding, RouteOptionsBuilding {
  /// Root path.
  public let path: String

  /// List of registerd routes.
  public var routes: [Route] = []

  /// Append leading slash to the route path
  public var appendLeadingSlash = true

  /// Append trailing slash to the route path
  public var appendTrailingSlash = false

  /**
    Creates a new `RouteContainer` instance.

    - Parameter path: The root path..
  */
  public init(path: String = "") {
    self.path = path
  }

  /**
    Builds a route and adds responder as an action on the corresponding method.

    - Parameter method: The request method.
    - Parameter path: Route path.
    - Parameter middleware: Route-specific middleware.
    - Parameter responder: The responder.
  */
  public func add(method: Request.Method, path: String, middleware: [Middleware], responder: Responder) {
    let action = middleware.chain(to: responder)
    let path = absolutePathFor(path)

    if let route = routeFor(absolutePath: path) {
      route.addAction(method: method, action: action)
    } else {
      let route = BasicRoute(path: path, actions: [method: action])
      routes.append(route)
    }
  }

  /**
    Adds a fallback on a given path.

    - Parameter path: Route path.
    - Parameter middleware: Route-specific middleware.
    - Parameter responder: The responder.
  */
  public func fallback(on path: String, middleware: [Middleware], responder: Responder) {
    let fallback = middleware.chain(to: responder)
    let path = absolutePathFor(path)

    if let route = routeFor(absolutePath: path) {
      route.fallback = fallback
    } else {
      let route = BasicRoute(path: path, fallback: fallback)
      routes.append(route)
    }
  }

  /**
    Removes all routes
  */
  public func clear() {
    routes.removeAll()
  }
}

// MARK: - Fallbacks

public extension RouteContainer {

  /**
    Adds a fallback on a given path.

    - Parameter path: Route path.
    - Parameter middleware: Route-specific middleware.
    - Parameter respond: The responder.
  */
  func fallback(_ path: String = "", middleware: [Middleware] = [], respond: Respond) {
    fallback(on: path, middleware: middleware, responder: BasicResponder(respond))
  }

  /**
    Adds a fallback on a given path.

    - Parameter path: Route path.
    - Parameter middleware: Route-specific middleware.
    - Parameter responder: The responder.
  */
  func fallback(_ path: String = "", middleware: [Middleware] = [], responder: Responder) {
    fallback(on: path, middleware: middleware, responder: responder)
  }
}

// MARK: - Root

public extension RouteContainer {

  /**
    Adds a responder on the root path (`GET /`).

    - Parameter middleware: Route-specific middleware.
    - Parameter responder: The responder.
  */
  func root(middleware: [Middleware] = [], responder: Responder) {
    get("", middleware: middleware, responder: responder)
  }

  /**
    Adds a responder on the root path (`GET /`).

    - Parameter middleware: Route-specific middleware.
    - Parameter respond: The responder.
  */
  func root(middleware: [Middleware] = [], respond: Respond) {
    get("", middleware: middleware, responder: BasicResponder(respond))
  }
}

// MARK: - Namespace

public extension RouteContainer {

  /**
    Builds a set of routes scoped by the given path.
    Allows to create nested route structures.

    - Parameter path: Namespace path.
    - Parameter middleware: Route-specific middleware.
    - Parameter build: Closure to fill in a new container with routes.
  */
  func namespace(_ path: String, middleware: [Middleware] = [], build: (container: RouteContainer) -> Void) {
    let container = RouteContainer(path: path)

    build(container: container)

    for route in container.routes {
      for (method, action) in route.actions {
        add(method: method,
          path: route.path,
          middleware: middleware,
          responder: action
        )
      }

      fallback(route.path, responder: route.fallback)
    }
  }
}

// MARK: - Resources

public extension RouteContainer {

  /**
    Adds resource controller for specified path.

    - Parameter path: Path associated with resource controller.
    - Parameter middleware: Route-specific middleware.
    - Parameter controller: Controller type to use.
  */
  func resources<T: ResourceController>(_ path: String,
                                          middleware: [Middleware] = [],
                                          controller: T.Type) {
    resources(path, middleware: middleware) {
      return controller.init()
    }
  }

  /**
    Creates standard Index, New, Show, Edit, Create, Destroy and Update routes
    using the respond method from a supplied `ResourceController`.

    - Parameter path: Path associated with resource controller.
    - Parameter middleware: Route-specific middleware.
    - Parameter factory: Closure to instantiate a new instance of controller.
  */
  func resources<T: ResourceController>(_ path: String,
                                          middleware: [Middleware] = [],
                                          buildController factory: () -> T) {
    get(path, middleware: middleware, respond: factory().index)
    get(path + "/new", middleware: middleware, respond: factory().new)
    get(path + "/:id", middleware: middleware, respond: factory().show)
    get(path + "/:id/edit", middleware: middleware, respond: factory().edit)
    post(path, middleware: middleware, respond: factory().create)
    delete(path + "/:id", middleware: middleware, respond: factory().destroy)
    patch(path + "/:id", middleware: middleware, respond: factory().update)
  }
}

// MARK: - Use

public extension RouteContainer {

  /**
    Uses routing controller on specified path.

    - Parameter path: Path associated with resource controller.
    - Parameter middleware: Route-specific middleware.
    - Parameter controller: Controller type to use.
  */
  func use<T: RoutingController>(_ path: String = "",
                                   middleware: [Middleware] = [],
                                   controller: T.Type) {
    use(path, middleware: middleware) {
      return controller.init()
    }
  }

  /**
    Uses routing controller on specified path.

    - Parameter path: Path associated with resource controller.
    - Parameter middleware: Route-specific middleware.
    - Parameter controller: Controller type to use.
  */
  func use<T: RoutingController>(_ path: String = "",
                                   middleware: [Middleware] = [],
                                   buildController factory: () -> T) {
    let builder = factory()
    namespace(path, middleware: middleware, build: builder.draw)
  }
}
