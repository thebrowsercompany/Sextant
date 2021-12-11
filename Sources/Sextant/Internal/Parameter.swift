import Foundation
import Hitch

typealias ParameterLateBinding = ((Parameter) -> JsonAny)

final class Parameter {
    var evaluated: Bool = false
    var json: Hitch?
    var path: Path?
    var cachedValue: JsonAny = nil
    var lateBinding: ParameterLateBinding?

    init(json: Hitch) {
        self.json = Hitch(hitch: json)
    }

    init(path: Path) {
        self.path = path
    }

    func value() -> JsonAny {
        if let cachedValue = cachedValue {
            return cachedValue
        }
        if let lateBinding = lateBinding {
            cachedValue = lateBinding(self)
        }
        return cachedValue
    }

    class func list<T>(parameters: [Parameter]) -> [T]? {
        var values = [T]()

        let handle: (JsonAny) -> Void = { obj in
            if let typedValue = obj as? T {
                values.append(typedValue)
            }
        }

        for param in parameters {
            guard let value = param.value() else { return nil }

            if let array = value as? JsonArray {
                array.forEach(handle)
            } else {
                handle(value)
            }
        }

        return values
    }
}
