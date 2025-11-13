import Foundation
import Docc2contextCore

@main
struct Docc2contextApp {
    static func main() {
        let command = Docc2contextCommand()
        let result = command.run(arguments: CommandLine.arguments)
        print(result.output)
        exit(Int32(result.exitCode))
    }
}
