import Flamingo

let kernel = AppKernel()

do {
  let application = try Application(
    kernel: kernel,
    config: Config(root: "Sources/Demo")
  )

  try application.start()
} catch {
  print(error)
}
