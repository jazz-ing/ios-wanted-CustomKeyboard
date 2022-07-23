//
//  keyboardAuto.swift
//  CustomKeyboard
//
//  Created by 이다훈 on 2022/07/14.
//

import Foundation

class KeyboardAuto {
    
    // MARK: - Hangeul status

    enum Status: Int {
        case start = 0
        case choSung
        case doubleChosung
        case jungSung
        case combinedJungsung
        case jongSung
        case combinedJongsung
        case end
    }
    
    // TODO: 싱글턴일 이유?
    static let shared = KeyboardAuto()
    
    private init() {}

    // MARK: - Properties

    var outputToDisplay = String()
    private var inputContents = String() {
        willSet {
            guard let newInput = newValue.last else { return }
            changeToOutput(from: newInput)
        }
    }
    private var status: Status = .start {
        didSet {
            if status == .end {
                status = .start
            }
        }
    }
    private var isSpaceButtonClicked = false

    // MARK: -

    private func changeToOutput(from newInput: Character) {
        if outputToDisplay == Text.empty {
            allocateStatus(to: newInput)
            completeOutput(from: newInput)
        } else {
            let lastCharacter = outputToDisplay.removeLast()
            allocateStatus(to: newInput, compare: lastCharacter)
            completeOutput(from: newInput, with: lastCharacter)
        }
    }

    private func allocateStatus(to input: Character, compare lastCharacter: Character? = nil) {
        if let lastCharacter = lastCharacter {
            status = modify(status: status, with: input, compare: lastCharacter)
            return
        }
        status = modify(status: status, with: input)
    }

    private func completeOutput(from input: Character, with lastCharacter: Character? = nil) {
        let string = fullfill(status: status, with: input, from: lastCharacter)
        outputToDisplay.append(string)
    }

    private func fullfill(status: Status, with char: Character, from last : Character? = nil) -> String {
        var next = String(char)
        
        switch status {
        case .start:
            if last != nil {
                next = String(last!) + String(char)
            }
        case .choSung:
            if last != nil {
                next = String(last!) + String(char)
            }
        case .doubleChosung:
            guard let index = choSungList.firstIndex(of: char) else {
                return next
            }
            next = String(choSungList[index + 1])
        case .jungSung:
            guard let last = last else {
                return next
            }
            if jungSungList.contains(last) {
                next = String(last) + String(next)
                return next
            }
            if choSungList.contains(last) {
                next = compose(choSung: last, jungSung: char, jongSung: nil)
                return next
            }
            var decomposed = decompose(char: last)
            let jongsung = decomposed.removeLast()
            let jungsung = decomposed.removeLast()
            let chosung = decomposed.removeLast()
            if choSungList.contains(jongsung) {
                next = compose(choSung: chosung, jungSung: jungsung, jongSung: nil) + compose(choSung: jongsung, jungSung: char, jongSung: nil)
            } else {
                var combinedJongsungCharacter = decompose(combinedJongsung: jongsung)
                let secondCombinedCharacter = combinedJongsungCharacter.removeLast()
                let firstCombinedCharacter = combinedJongsungCharacter.removeLast()
                next = compose(choSung: chosung, jungSung: jungsung, jongSung: firstCombinedCharacter) + compose(choSung: secondCombinedCharacter, jungSung: char, jongSung: nil)
            }
        case .combinedJungsung:
            var decomposed = decompose(char: last!)
            _ = decomposed.removeLast()
            let lastJungsung = decomposed.removeLast()
            let jungsung = String([lastJungsung, char])
            let chosung = decomposed.removeLast()
            let combinedJungsung = combinedJungSungList[jungsung]!
            return compose(choSung: chosung, jungSung: combinedJungsung, jongSung: nil)
        case .jongSung:
            var decomposed = decompose(char: last!)
            _ = decomposed.removeLast()
            let jungsung = decomposed.removeLast()
            let chosung = decomposed.removeLast()
            next = compose(choSung: chosung, jungSung: jungsung, jongSung: char)
        case .combinedJongsung:
            var decomposed = decompose(char: last!)
            let jongsung = decomposed.removeLast()
            let jungsung = decomposed.removeLast()
            let chosung = decomposed.removeLast()
            let combinedJongsungCharacter = String([jongsung, char])
            if let combinedJongsung = combinedJongSungList[combinedJongsungCharacter] {
                next = compose(choSung: chosung, jungSung: jungsung, jongSung: combinedJongsung)
            }
        case .end:
            break
        }
        
        return next
    }

    private func modify(status: Status, with char: Character, compare last : Character? = nil) -> Status {
        switch status {
        case .start:
            if jungSungList.contains(char) {
                if last != nil {
                    // last에서 종성을 가져오는 기능 구현하여 넣기
                    return Status.jungSung
                }
                return Status.end
            } else if last == char {
                return Status.doubleChosung
            } else {
                return Status.choSung
            }
            
        case .choSung:
            if jungSungList.contains(char) {
                return Status.jungSung
            } else if let last = last,
                      char == last,
                      doubleChoSungList.keys.contains(char) {
                return Status.doubleChosung
            } else {
                return Status.end
            }
            
        case .doubleChosung:
            if jungSungList.contains(char) {
                return Status.jungSung
            }
            return Status.end
            
        case .jungSung:
            if jungSungList.contains(last!) {
                return Status.choSung
            } else if jongSungList.contains(char) {
                return Status.jongSung
            } else if let last = last {
                if jungSungList.contains(last) {
                    return Status.jungSung
                }
                var decomposed = decompose(char: last)
                decomposed.removeLast()
                let lastJungsung = decomposed.last
                if isCanBeCombinedJungSung(with: "\(lastJungsung!)\(char)") {
                    return Status.combinedJungsung
                }
                return Status.end
            } else {
                return Status.end
            }
        case .combinedJungsung:
            if jongSungList.contains(char) {
                return Status.jongSung
            } else if let last = last {
                var decomposed = decompose(char: last)
                _ = decomposed.removeLast()
                let lastJungsung = decomposed.removeLast()
                if isCanBeCombinedJungSung(with: "\(lastJungsung)\(char)") {
                    return Status.combinedJungsung
                }
                return Status.end
            } else {
                return Status.end
            }

        case .jongSung:
            var decomposed = decompose(char: last!)
            let jongsung = decomposed.removeLast()
            if jungSungList.contains(char) {
                return Status.jungSung
            } else if combinedJongsungPossibleList.contains(jongsung) {
                let combinedJongsungCharacter = String(jongsung) + String(char)
                if let _ = combinedJongSungList[combinedJongsungCharacter] {
                    return Status.combinedJongsung
                }
                if jongsung == char {
                    return Status.choSung
                }
                return Status.choSung
            } else {
                return Status.end
            }

        case .combinedJongsung:
            if jungSungList.contains(char) {
                return Status.jungSung
            }
            return Status.end

        case .end:
            return Status.start
        }
    }
    
    // MARK: -
    
    func insert(_ input: String) {
        isSpaceButtonClicked = false
        inputContents.append(input)
    }

    func reset() {
        inputContents.removeAll()
    }
    
    func delete() {
        var currentString = outputToDisplay

        // 변수명 바꾸기
        if isSpaceButtonClicked {
            outputToDisplay.removeLast()
            status = .start
            return
        }

        if outputToDisplay != Text.empty {
            let lastCharacter = currentString.removeLast()
            if choSungList.contains(lastCharacter) ||
                jungSungList.contains(lastCharacter) ||
                lastCharacter == Text.space {
                outputToDisplay.removeLast()
                status = .start
            } else {
                var decomposed = decompose(char: lastCharacter)
                let jongsung = decomposed.removeLast()
                let jungsung = decomposed.removeLast()
                let chosung = decomposed.removeLast()
                if jongsung == " " {
                    outputToDisplay.removeLast()
                    outputToDisplay.append(chosung)
                    status = .choSung
                } else if isCombinedJongsung(with: jongsung) {
                    var combinedJongsungCharacters = decompose(combinedJongsung: jongsung)
                    _ = combinedJongsungCharacters.removeLast()
                    let firstJongsung = combinedJongsungCharacters.removeLast()
                    let string = compose(choSung: chosung, jungSung: jungsung, jongSung: firstJongsung)
                    outputToDisplay.removeLast()
                    outputToDisplay.append(string)
                    status = .jongSung
                } else {
                    outputToDisplay.removeLast()
                    let string = compose(choSung: chosung, jungSung: jungsung, jongSung: nil)
                    outputToDisplay.append(string)
                    status = .jungSung
                }
            }
        }
    }
    
    func space() {
        isSpaceButtonClicked = true
        outputToDisplay.append(Text.space)
    }
    
    // MARK: - Combined hangeul related methods
    
    private func isCanBeCombinedJungSung(with vowels: String) -> Bool {
        return combinedJungSungList.keys.contains(vowels)
    }

    private func isCombinedJongsung(with jongsung: Character) -> Bool {
        if let _ = combinedJongSungList.values.firstIndex(of: jongsung) {
            return true
        }
        return false
    }
    
    private func decompose(combinedJongsung: Character) -> String {
        if let index = combinedJongSungList.values.firstIndex(of: combinedJongsung) {
            let combinedJongsungCharacter = combinedJongSungList[index].key
            return combinedJongsungCharacter
        }
        return String(combinedJongsung)
    }

    // MARK: - Calculating unicode methods
    
    private let baseUnicodeValue = 0xAC00
    
    private func compose(choSung: Character, jungSung: Character, jongSung: Character?) -> String {
        var choSungIndex = 0
        var jungSungIndex = 0
        var jongSungIndex = 0
        
        for i in 0..<choSungList.count {
            if choSungList[i] == choSung { choSungIndex = i }
        }

        for i in 0..<jungSungList.count {
            if jungSungList[i] == jungSung { jungSungIndex = i }
        }

        if let jongSung = jongSung {
            for i in 0..<jongSungList.count {
                if jongSungList[i] == jongSung { jongSungIndex = i }
            }
        }

        let calculatedValue: Int = (choSungIndex * jungSungList.count * jongSungList.count)
        + (jungSungIndex * jongSungList.count)
        + (jongSungIndex)
        + baseUnicodeValue
        
        if let unicode = Unicode.Scalar(calculatedValue) {
            let character = Character(unicode)
            return String(character)
        }

        return Text.empty
    }
    
    private func decompose(char: Character) -> String {
        let unicode = char.unicodeScalarCodePoint()
        
        let jongSung = (unicode - UInt32(baseUnicodeValue)) % UInt32(jongSungList.count)
        let jungSung = (
            (unicode - UInt32(baseUnicodeValue) - jongSung) /
            UInt32(jongSungList.count) %
            UInt32(jungSungList.count)
        )
        let choSung = (
            (
                (unicode - UInt32(baseUnicodeValue) - jongSung) /
                UInt32(jongSungList.count) - jungSung
            ) /
            UInt32(jungSungList.count)
        )
        
        return "\(choSungList[Int(choSung)])\(jungSungList[Int(jungSung)])\(jongSungList[Int(jongSung)])"
    }

    // MARK: - Hangeul List

    private let choSungList: [Character] = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]

    private let jungSungList: [Character] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ","ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]

    private let jongSungList: [Character] = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ","ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

    private let combinedJongsungPossibleList: [Character] = ["ㄱ", "ㄴ", "ㄹ", "ㅂ"]

    private let combinedJungSungList: [String : Character] = [
        "ㅗㅏ" : "ㅘ",
        "ㅗㅐ" : "ㅙ",
        "ㅗㅣ" : "ㅚ",
        "ㅜㅓ" : "ㅝ",
        "ㅜㅔ" : "ㅞ",
        "ㅜㅣ" : "ㅟ",
        "ㅡㅣ" : "ㅢ",
        "ㅓㅣ" : "ㅔ",
        "ㅏㅣ" : "ㅐ",
        "ㅕㅣ" : "ㅖ",
        "ㅑㅣ" : "ㅒ",
        "ㅘㅣ" : "ㅙ",
        "ㅝㅣ" : "ㅞ"
    ]
    
    private let doubleChoSungList: [Character: Character] = [
        "ㄱ": "ㄲ",
        "ㄷ": "ㄸ",
        "ㅂ": "ㅃ",
        "ㅅ": "ㅆ",
        "ㅈ": "ㅉ"
    ]
    
    private let combinedJongSungList: [String : Character] = [
        "ㄱㅅ" : "ㄳ",
        "ㄴㅈ" : "ㄵ",
        "ㄴㅎ" : "ㄶ",
        "ㄹㄱ" : "ㄺ",
        "ㄹㅁ" : "ㄻ",
        "ㄹㅂ" : "ㄼ",
        "ㄹㅅ" : "ㄽ",
        "ㄹㅌ" : "ㄾ",
        "ㄹㅍ" : "ㄿ",
        "ㄹㅎ" : "ㅀ",
        "ㅂㅅ" : "ㅄ"
    ]

}

// MARK: - NameSpaces

extension KeyboardAuto {
    
    private enum Text {
        static let empty: String = ""
        static let space: Character = " "
    }

}

// TODO: 파일 분리해야함
extension Character {
    
    func unicodeScalarCodePoint() -> UInt32 {
        let unicodeScalars = self.unicodeScalars
        
        return unicodeScalars[unicodeScalars.startIndex].value
    }
    
}
