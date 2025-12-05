import Docc2contextCore
import Foundation

@main
struct RepositoryValidationApp {
    static func main() {
        let command = RepositoryValidationCommand()
        let result = command.run(arguments: CommandLine.arguments)
        print(result.output)
        exit(Int32(result.exitCode))
    }
}
