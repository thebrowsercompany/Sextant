import Foundation
import Hitch

private let hitchDot = Hitch(".")

final class FunctionPathToken: PathToken {
    var fragment: Hitch

    var functionName: Hitch
    var functionParams: [Parameter]
    var pathFunction: PathFunction?

    init(fragment: Hitch,
         parameters: [Parameter]) {

        if parameters.count == 0 {
            self.fragment = Hitch(hitch: fragment).append(UInt8.parenOpen).append(UInt8.parenClose)
        } else {
            self.fragment = Hitch(hitch: fragment)
                .append(UInt8.parenOpen)
                .append(UInt8.dot)
                .append(UInt8.dot)
                .append(UInt8.dot)
                .append(UInt8.parenClose)
        }

        self.functionName = self.fragment
        self.functionParams = parameters
        self.pathFunction = PathFunction(hitch: self.fragment)
    }

    override func evaluate(currentPath: Hitch,
                           parentPath: Path,
                           jsonObject: JsonAny,
                           evaluationContext: EvaluationContext) -> EvaluationStatus {
        guard let pathFunction = pathFunction else {
            return .error("Unknown path function \(pathFragment())")
        }

        evaluateParameters(currentPath: currentPath,
                           parentPath: parentPath,
                           jsonObject: jsonObject,
                           evaluationContext: evaluationContext)

        guard let result = pathFunction.invoke(currentPath: currentPath,
                                               parentPath: parentPath,
                                               jsonObject: jsonObject,
                                               evaluationContext: evaluationContext,
                                               parameters: functionParams) else {
            return .error("Path function invocation failed for \(pathFragment())")
        }

        let evalResult = evaluationContext.add(path: Hitch.combine(currentPath, hitchDot, functionName),
                                               operation: parentPath,
                                               jsonObject: result)
        guard evalResult == .done else { return evalResult }

        if let next = next {
            return next.evaluate(currentPath: currentPath,
                                 parentPath: parentPath,
                                 jsonObject: result,
                                 evaluationContext: evaluationContext)
        }

        return .done
    }

    func evaluateParameters(currentPath: Hitch,
                            parentPath: Path,
                            jsonObject: JsonAny,
                            evaluationContext: EvaluationContext) {

        for param in functionParams {
            guard param.evaluated == false else { continue }

            if let path = param.path {
                param.lateBinding = { _ in
                    guard let evaluationContext = path.evaluate(jsonObject: evaluationContext.rootJsonObject,
                                                                rootJsonObject: evaluationContext.rootJsonObject) else {
                        return nil
                    }
                    return evaluationContext.jsonObject()
                }
                param.evaluated = true
            }

            if let json = param.json {
                param.lateBinding = { _ in
                    let value = try? JSONSerialization.jsonObject(with: json.dataNoCopy(),
                                                                  options: [.allowFragments])
                    if let value = value as? String {
                        return Hitch(stringLiteral: value)
                    }
                    return value
                }
                param.evaluated = true
            }
        }
    }

    override func isTokenDefinite() -> Bool {
        return true
    }

    override func pathFragment() -> String {
        return "." + fragment.description
    }
}
