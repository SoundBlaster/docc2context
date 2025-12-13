import Docc2contextCore
import Foundation

let command = BenchmarkCommand()
let result = command.run(arguments: CommandLine.arguments)
if !result.output.isEmpty {
    print(result.output)
}
exit(Int32(result.exitCode))
