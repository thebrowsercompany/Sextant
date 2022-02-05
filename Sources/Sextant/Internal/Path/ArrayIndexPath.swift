import Foundation
import Hitch
import Spanker

@usableFromInline
struct ArrayIndexPath: Path {
    @usableFromInline
    let parentAny: JsonAny = nil

    @usableFromInline
    let parentDictionary: JsonDictionary? = nil

    @usableFromInline
    let parentArray: JsonArray?

    @usableFromInline
    let parentElement: JsonElement?

    @usableFromInline
    let item: JsonAny

    @usableFromInline
    let index: Int

    @inlinable @inline(__always)
    init(array: JsonArray,
         index: Int,
         item: JsonAny) {
        parentArray = array
        parentElement = nil
        self.index = index
        self.item = item
    }

    @inlinable @inline(__always)
    init(element: JsonElement,
         index: Int,
         item: JsonAny) {
        parentArray = nil
        parentElement = element
        self.index = index
        self.item = item
    }

    @usableFromInline
    @discardableResult
    func set(value: JsonAny) -> Bool {
        guard let parentElement = parentElement else { error("invalid set operation"); return false }
        guard parentElement.type == .array else { error("invalid set operation"); return false }
        guard index >= 0 && index < parentElement.count else { return false }
        parentElement.replace(at: index, value: JsonElement(unknown: value))
        return true
    }

    @usableFromInline
    @discardableResult
    func map(block: MapObjectBlock) -> Bool {
        guard let parentElement = parentElement else { error("invalid set operation"); return false }
        guard parentElement.type == .array else { error("invalid set operation"); return false }
        guard let valueElement = parentElement[element: index] else { return false }
        if let result = block(valueElement) {
            parentElement.replace(at: index, value: result)
        } else {
            parentElement.remove(at: index)
        }
        return true
    }

    @usableFromInline
    @discardableResult
    func forEach(block: ForEachObjectBlock) -> Bool {
        guard let parentElement = parentElement else { error("invalid set operation"); return false }
        guard parentElement.type == .array else { error("invalid set operation"); return false }
        guard let valueElement = parentElement[element: index] else { return false }
        block(valueElement)
        return true
    }

    @usableFromInline
    @discardableResult
    func filter(block: FilterObjectBlock) -> Bool {
        guard let parentElement = parentElement else { error("invalid set operation"); return false }
        guard parentElement.type == .array else { error("invalid set operation"); return false }
        guard let valueElement = parentElement[element: index] else { return false }
        if block(valueElement) == false {
            parentElement.remove(at: index)
        }
        return true
    }
}
