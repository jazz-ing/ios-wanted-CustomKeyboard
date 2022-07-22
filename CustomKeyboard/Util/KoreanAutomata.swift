//
//  keyboardAuto.swift
//  CustomKeyboard
//
//  Created by 이다훈 on 2022/07/14.
//

import Foundation

/*
 흐름을 생각해보자!

 1. 키보드 버튼을 누른다
 2. contents(button.titleLabel.text)를 inputContents.append한다.
 3. inputContents가 변하면(didSet) allocateHangeulStatus()를 실행해 해당 contents의 status를 정한다.
 4. 한 글자가 완성되면(status == .end) hangeulWithStatus를 compose을 통해 조합해 outputStrings에 추가한다.

 ⚠️ 상태가 end일때만 outputStrings에 추가하면 안된다.
 입력할때마다 조합한 글자를 label에 보여줘야함!! "ㄱ"에서 "ㅏ"를 입력하면 바로 "가"를 보여줘야됨!!

 */

class KeyboardAuto {

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

    static let shared = KeyboardAuto()

    private init() {}

    private var inputContents = String() {
        didSet {
            allocateHangeulStatus()
        }
    }

    private var outputToDisplay = String() {
        didSet {
            print(outputToDisplay)
        }
    }

    private var status: Status = .start {
        didSet {
            if status == .end {
                status = .start
            }
        }
    }
    //
    // 새로 입력된 character의 status를 정해서 tupleArray에 넣는다.
    // decide, sort
    private func allocateHangeulStatus() {
        // TODO: 리팩토링 하는 방법도 있을 것 같다.
        var queue = inputContents
        // ㄱ, ㅗ, ㅏ, ㅣ,
//        if queue.count >= 2 {
//            let input = queue.removeLast()
//            let input2 = queue.removeLast()
//
//            if jungSungList2.contains("\(input2)\(input)") {
//                let index = jungSungList2.firstIndex(of: "\(input2)\(input)") ?? -1
//                queue.append(jungSungList[index])
//            } else {
//                queue.append(input2)
//                queue.append(input)
//            }
//        }

        let input = queue.removeLast()

        if queue.count >= 1 {
            let lastCharacter = outputToDisplay.removeLast()
            status = modify(status: status, with: input, compare: lastCharacter)
            let string = fullfill(status: status, with: input, from: lastCharacter)
            outputToDisplay.append(string)
        } else {
            status = modify(status: status, with: input)
            let string = fullfill(status: status, with: input)
            outputToDisplay.append(string)
        }
    }


    private func fullfill(status: Status, with char: Character, from last : Character? = nil) -> String {
        var next = String(char)

        switch status {
        case .start:
            if last != nil {
                next = "\(last!)\(char)"
            }
        case .choSung:
            if last != nil {
                next = "\(last!)\(char)"
            }
        case .doubleChosung:
            guard let index = choSungList.firstIndex(of: char) else {
                return next
            }
            next = String(choSungList[index + 1])

        // 초성에 중성 합치기 last가 초성이라면, 그냥 합치지만, 조합된 글자라면, 종성을 떼어올 수 있는지 확인하여, 분해 재조합을 한다.
        case .jungSung:
            guard let last = last else {
                return next
            }
            if jungSungList.contains(char) {
                next = String(compose(choSung: last, jungSung: char, jongSung: nil)!)
                return next
            }
        case .combinedJungsung:
            guard let last = last else {
                return next
            }
            // last 의 문자 나누고
            var decomposed = decompose(char: last)
            // 모음 합치고
            _ = decomposed.removeLast()
            let jung = decomposed.removeLast()
            let cho = decomposed.removeLast()
            
            if combinedJungSungList.keys.contains("\(jung)\(char)") {
                if let charIndex = combinedJungSungList.index(forKey: "\(jung)\(char)") {
                    let composedJung = combinedJungSungList[charIndex].value
                    
                    next = String(compose(choSung: cho, jungSung: composedJung, jongSung: nil)!)
                }
            }
            // 이전 글자 분해하여, 중성 조합하여, 재조합하여 반환
        case .jongSung:
            guard let last = last else {
                return next
            }
            var decomposed = decompose(char: last)
            let jong = char
            _ = decomposed.removeLast() // "" 빈문자열이 나옴 왜..?
            let jung = decomposed.removeLast()
            let cho = decomposed.removeLast()
            next = String(compose(choSung: cho, jungSung: jung, jongSung: jong)!)
            // PEPPO: last = 모음 , char = 종성일때
            // Q: 초,중,종성 다 받았을때 초성은 어떻게 가지고 오지?
//            if jungSungList.contains(last) && jongSungList.contains(char) {
//                next = compose(choSung: "ㄱ", jungSung: last, jongSung: char) ?? next
//                return next
//            }
            //이전 글자 분해하여 재조합 반환
        case .combinedJongsung:
            let combinedJongsung = String([last!, char])
            return String(combinedJongSungList[combinedJongsung]!)
        case .end: break
//            guard let last = last else {
//                return next
//            }
//            // PEPPO: 종성 다음 모음이 왔을때
//            //
//            if jongSungList.contains(last) && jungSungList.contains(char) { // last가 초성인 경우
//                next = compose(choSung: last, jungSung: char, jongSung: nil) ?? next
//                return next }

        }

        return next
    }

    private func modify(status: Status, with char: Character, compare last : Character? = nil) -> Status {
        switch status {
        case .start:
            if jungSungList.contains(char) { // 모음인 경우. 구현 필요
                if last == nil {
                    return Status.end
                } else {
                    // TODO: ㄱㅏㅁㅣ 일때 '가미'가 되게 구현하기
                    return Status.choSung
                    // last에서 종성을 가져오는 기능 구현하여 넣기
                }
                return Status.jungSung
            } else { // 자음인 경우
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
            // TODO: [x] ㅏ + ㅣ 가 들어올경우
            if jongSungList.contains(char) {
                return Status.jongSung
            } else if let last = last {
                
                var decomposed = decompose(char: last)
                _ = decomposed.removeLast()
                let firstJung = decomposed.removeLast()
                let secondJung = decomposed.removeLast()
                if (combinedJungSungList["\(firstJung)\(char)"] != nil) {
                    return Status.combinedJungsung
                } else if (combinedJungSungList["\(firstJung)\(secondJung)"] != nil) {
                    return Status.combinedJungsung
                }
            } else {
                return Status.end
            }

        case .combinedJungsung:
            
            if jongSungList.contains(char) {
                return Status.jongSung
            } else if let last = last {
                var decomposed = decompose(char: last)
                _ = decomposed.removeLast()
                let jung = decomposed.removeLast()
                let cho = decomposed.removeLast()
                if isCanBeCombinedJungSung(with: "\(jung)\(char)") {
                    return Status.combinedJungsung
                }
            } else {
                return Status.end
            }
                       
            // TODO: "ㅘ + ㅣ , ㅝ + ㅣ 의 경우

        // TODO: 이미 종성이 있는데 종성이 또 들어온 경우, 종성 조합하기
        case .jongSung:
            if combinedJongsungPossibleList.contains(last!) {
                return Status.combinedJongsung
            }
            
            if jungSungList.contains(char) {
                return Status.jungSung
            }
            
//            else {
//                return Status.end
//            }

        case .combinedJongsung:
            return Status.end
        case .end:
            guard let last = last else {
                return Status.start
            }

            // PEPPO: 종성 다음 모음이 나올때
            if jungSungList.contains(char) && jongSungList.contains(last) {
                return Status.jungSung
            }

        }
        return status
    }

    func insert(_ input: String) {
        inputContents.append(input)
    }

    func reset() {
        inputContents.removeAll()
    }

    private func isCanBeCombinedJungSung(with vowels: String) -> Bool {
//        let temp = String(vowels.sorted())
        return combinedJungSungList.keys.contains(vowels)
    }

    private func takeJongsung(to char: Character, from last : Character) -> Character {
        //last를 분해해서, 종성을 떼어내고, toDisplayList에서 바꿔줌.
        //떼어낸 종성을 초성으로 하여, char와 붙여 return
        return "R"
    }

    // 받으면 합치는 메소드 실행.
    // 합치는 메소드는 2단계
    //1단계 : ㄱㄱ -> ㄲ 같은 조합 후
    // 생겨난 것을 가지고, 글자 생성.
    // but 이 때 , ㄱㅏㄴㅈㅏㅇ 이라고 할 때, 갅ㅏㅇ가 될 수도 있음. 이를 방지키 위해서는 모음을 기준으로 나누어야 함. 이 방법을 생각 해 볼 것.
    // 아니야 틀렸음. 다음 index를 보고 평가하여 어디까지 집어넣을지 결정하면 됨.
    // 중성을 넣었을 때, 다음 중성과의 사이의 자음들을 보고 평가를 해야 함.

    /*
    private func 입력을모음으로나누기(input: String) -> [String] {
        var 나뉜애들 = [input]

        let 모음들 = input.filter({
            jung.contains($0)
        }).compactMap { String($0) }

        모음들.forEach { vowel in
            let 기준 = 나뉜애들
            var temp = [String]()
            기준.forEach{
                let 값 = $0.components(separatedBy: vowel)
                temp.append(contentsOf: 값)
            }
            나뉜애들 = temp
        }
    }
    */
    // delegate, 날짜변환, post 성공시 tableView 업로드. <- 이거라도 하자
    // 오토마타 2명 (중성 1명, 종성 1명) 페포: 중성 - 날라: 종성
    //
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

    private let choSungList: [Character] = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]

    private let jungSungList: [Character] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ","ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]

    private let jungSungList2: [String] = ["ㅏ", "ㅏㅣ", "ㅑ", "ㅒ", "ㅓ", "ㅓㅣ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ","ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]

    private let jongSungList: [Character] = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ","ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]

    private let combinedJongsungPossibleList: [Character] = ["ㄱ", "ㄴ", "ㄹ", "ㅂ"]

    private let baseUnicodeValue = 0xAC00

    func compose(choSung: Character, jungSung: Character, jongSung: Character?) -> Character? {

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

        let calculatedValue: Int = (choSungIndex * jungSungList.count * jongSungList.count) + (jungSungIndex * jongSungList.count) + (jongSungIndex) + baseUnicodeValue

        if let unicode = Unicode.Scalar(calculatedValue) {
            return Character(unicode)
        }

        return nil
    }

    func decompose(char: Character) -> String {
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
            ) / UInt32(jungSungList.count)
        )

        return "\(choSungList[Int(choSung)])\(jungSungList[Int(jungSung)])\(jongSungList[Int(jongSung)])"
    }

}

extension Character {

    func unicodeScalarCodePoint() -> UInt32 {
        let unicodeScalars = self.unicodeScalars

        return unicodeScalars[unicodeScalars.startIndex].value
    }

}

//========================================================

////
////  keyboardAuto.swift
////  CustomKeyboard
////
////  Created by 이다훈 on 2022/07/14.
////
//
//import Foundation
//
///*
// 흐름을 생각해보자!
//
// 1. 키보드 버튼을 누른다
// 2. contents(button.titleLabel.text)를 inputContents.append한다.
// 3. inputContents가 변하면(didSet) allocateHangeulStatus()를 실행해 해당 contents의 status를 정한다.
// 4. 한 글자가 완성되면(status == .end) hangeulWithStatus를 combination을 통해 조합해 outputStrings에 추가한다.
//
// ⚠️ 상태가 end일때만 outputStrings에 추가하면 안된다.
// 입력할때마다 조합한 글자를 label에 보여줘야함!! "ㄱ"에서 "ㅏ"를 입력하면 바로 "가"를 보여줘야됨!!
//
// */
//
//class KeyboardAuto {
//
//    enum Status: Int {
//        case start = 0
//        case choSung
//        case doubleChosung
//        case jungSung
//        case combinedJungsung
//        case jongSung
//        case combinedJongsung
//        case end
//    }
//
//    static let shared = KeyboardAuto()
//
//    private init() {}
//
//    var hangeulWithStatus: [(Character, Status)] = []
//
//    func test() -> Character {
//        // FIXME: "ㄱㅐㅁㅣ"인 경우 "갬"까지 세개만 카운트되고 "ㅣ"는 들어갈 데가 없다.
//        var choSung = Character("초")
//        var jungSung = Character("중")
//        var jongSung = Character("종")
//
//        for hangeul in hangeulWithStatus {
//            switch hangeul.1 {
//            case .choSung, .doubleChosung:
//                choSung = hangeul.0
//            case .jungSung, .combinedJungsung:
//                jungSung = hangeul.0
//            case .jongSung, .combinedJongsung:
//                jongSung = hangeul.0
//            default:
//                break
//            }
//        }
//
//        // FIXME: 초성인 경우에는 combination을 안하고 바로 초성을 리턴해야 한다.
//        let combinatedCharacter = compose(
//            choSung: choSung,
//            jungSung: jungSung,
//            jongSung: jongSung
//        ) ?? Character("")
//        return jungSung == Character("중") ? choSung : combinatedCharacter
//    }
//
//    private var inputContents = String() {
//        didSet {
//            allocateHangeulStatus()
////            let combinatedCharacter = test()
////            outputToDisplay = String(combinatedCharacter)
//        }
//    }
//
//    private var outputToDisplay = String() {
//        didSet {
//            print(outputToDisplay)
//        }
//    }
//
//    private var status: Status = .start {
//        didSet {
//            if status == .end {
//                status = .start
//            }
//        }
//    }
//
//    private func allocateHangeulStatus() {
//        var queue = inputContents
//        let input = queue.removeLast()
//
//        if queue.count >= 1 {
//            let lastCharacter = outputToDisplay.removeLast()
//            status = modify(status: status, with: input, compare: lastCharacter)
//            let string = fullfill(status: status, with: input, from: lastCharacter)
//            outputToDisplay.append(string)
////            hangeulWithStatus.append((character, status))
//        } else {
//            status = modify(status: status, with: input)
//            let character = fullfill(status: status, with: input)
//            outputToDisplay.append(character)
////            hangeulWithStatus.append((character, status))
//        }
//    }
//
//    private func fullfill(status: Status, with char: Character, from last : Character? = nil) -> String {
//        var next = String(char)
//
//        switch status {
//        case .start:
//            if last != nil {
//                next = String(last!) + String(char)
//            }
//        case .choSung:
//            if last != nil {
//                next = String(last!) + String(char)
//            }
//        case .doubleChosung:
//            guard let index = choSungList.firstIndex(of: char) else {
//                return next
//            }
//            next = String(choSungList[index + 1])
//        // 초성에 중성 합치기 last가 초성이라면, 그냥 합치지만, 조합된 글자라면, 종성을 떼어올 수 있는지 확인하여, 분해 재조합을 한다.
//        case .jungSung:
//            guard let last = last else {
//                return next
//            }
//
//            if jungSungList.contains(last) {
//                next = String(last) + String(next)
//                return next
//            }
//
//            // ㄱㅏ
//            // 감ㅏ
//            if choSungList.contains(last) {
//                next = String(compose(choSung: last, jungSung: char, jongSung: nil)!)
//                return next
//            }
//            var decomposed = decompose(char: last)
//            let jongsung = decomposed.removeLast()
//            let jungsung = decomposed.removeLast()
//            let chosung = decomposed.removeLast()
//            if choSungList.contains(jongsung) {
//                next = String(compose(choSung: chosung, jungSung: jungsung, jongSung: nil)!) + String(compose(choSung: jongsung, jungSung: char, jongSung: nil)!)
//            } else {
//                let index = combinedJongSungList.values.firstIndex(of: jongsung)!
//                var combinedJongsungCharacter = combinedJongSungList[index].key
//                let secondCombinedCharacter = combinedJongsungCharacter.removeLast()
//                let firstCombinedCharacter = combinedJongsungCharacter.removeLast()
//                next = String(compose(choSung: chosung, jungSung: jungsung, jongSung: firstCombinedCharacter)!) + String(compose(choSung: secondCombinedCharacter, jungSung: char, jongSung: nil)!)
//            }
//        case .combinedJungsung:
//            var decomposed = decompose(char: last!)
//            _ = decomposed.removeLast()
//            let lastJungsung = decomposed.removeLast()
//            let jungsung = String([lastJungsung, char])
//            let chosung = decomposed.removeLast()
//            let combinedJungsung = combinedJungSungList[jungsung]!
//            return String(compose(choSung: chosung, jungSung: combinedJungsung, jongSung: nil)!)
//            // 새로 들어온 애가 종성이다.
//            // 가 / 개
//            // 각
//            // 각ㄱ
//            // 각ㄴ
//            // 갃
//        case .jongSung:
//            var decomposed = decompose(char: last!)
//            _ = decomposed.removeLast()
//            let jungsung = decomposed.removeLast()
//            let chosung = decomposed.removeLast()
//            next = String(compose(choSung: chosung, jungSung: jungsung, jongSung: char)!)
//        case .combinedJongsung:
//            var decomposed = decompose(char: last!)
//            let jongsung = decomposed.removeLast()
//            let jungsung = decomposed.removeLast()
//            let chosung = decomposed.removeLast()
//            let combinedJongsungCharacter = String([jongsung, char])
//            if let combinedJongsung = combinedJongSungList[combinedJongsungCharacter] {
//                next = String(compose(choSung: chosung, jungSung: jungsung, jongSung: combinedJongsung)!)
//            }
//        case .end:
//            break
//        }
//
//        return next
//    }
//
//    private func modify(status: Status, with char: Character, compare last : Character? = nil) -> Status {
//        switch status {
//        case .start:
//            if jungSungList.contains(char) {
//                if last != nil {
//                    // last에서 종성을 가져오는 기능 구현하여 넣기
//                    return Status.jungSung
//                }
//                return Status.end
//            } else if last == char {
//                return Status.doubleChosung
//            } else {
//                return Status.choSung
//            }
//
//        case .choSung:
//            if jungSungList.contains(char) {
//                return Status.jungSung
//            } else if let last = last,
//                      char == last,
//                      doubleChoSungList.keys.contains(char) {
//                return Status.doubleChosung
//            } else {
//                return Status.end
//            }
//
//        case .doubleChosung:
//            if jungSungList.contains(char) {
//                return Status.jungSung
//            }
//            return Status.end
//
//        case .jungSung:
//            if jungSungList.contains(last!) {
//                return Status.choSung
//            } else if jongSungList.contains(char) {
//                return Status.jongSung
//            } else if let last = last {
//                if jungSungList.contains(last) {
//                    return Status.jungSung
//                }
//                var decomposed = decompose(char: last)
//                decomposed.removeLast()
//                let lastJungsung = decomposed.last
//                if isCanBeCombinedJungSung(with: "\(lastJungsung!)\(char)") {
//                    return Status.combinedJungsung
//                }
//                return Status.end
//            } else {
//                return Status.end
//            }
//        case .combinedJungsung:
//            if jongSungList.contains(char) {
//                return Status.jongSung
//            } else if let last = last {
//                var decomposed = decompose(char: last)
//                _ = decomposed.removeLast()
//                let lastJungsung = decomposed.removeLast()
//                if isCanBeCombinedJungSung(with: "\(lastJungsung)\(char)") {
//                    return Status.combinedJungsung
//                }
//                return Status.end
//            } else {
//                return Status.end
//            }
//
//        case .jongSung:
//            var decomposed = decompose(char: last!)
//            let jongsung = decomposed.removeLast()
//            if jungSungList.contains(char) {
//                return Status.jungSung
//            } else if combinedJongsungPossibleList.contains(jongsung) {
//                let combinedJongsungCharacter = String(jongsung) + String(char)
//                if let combinedJongsung = combinedJongSungList[combinedJongsungCharacter] {
//                    return Status.combinedJongsung
//                }
//                if jongsung == char {
//                    return Status.choSung
//                }
//                return Status.choSung
//            } else {
//                return Status.end
//            }
//
//        case .combinedJongsung:
//            if jungSungList.contains(char) {
//                return Status.jungSung
//            }
//            return Status.end
//
//        case .end:
//            return Status.start
//        }
//    }
//
//    func insert(_ input: String) {
//        inputContents.append(input)
//    }
//
//    func reset() {
//        inputContents.removeAll()
//    }
//
//    private func isCanBeCombinedJungSung(with vowels: String) -> Bool {
//        return combinedJungSungList.keys.contains(vowels)
//    }
//
//    private func takeJongsung(to char: Character, from last : Character) -> Character {
//        //last를 분해해서, 종성을 떼어내고, toDisplayList에서 바꿔줌.
//        //떼어낸 종성을 초성으로 하여, char와 붙여 return
//        return "R"
//    }
//
//    // 받으면 합치는 메소드 실행.
//    // 합치는 메소드는 2단계
//    //1단계 : ㄱㄱ -> ㄲ 같은 조합 후
//    // 생겨난 것을 가지고, 글자 생성.
//    // but 이 때 , ㄱㅏㄴㅈㅏㅇ 이라고 할 때, 갅ㅏㅇ가 될 수도 있음. 이를 방지키 위해서는 모음을 기준으로 나누어야 함. 이 방법을 생각 해 볼 것.
//    // 아니야 틀렸음. 다음 index를 보고 평가하여 어디까지 집어넣을지 결정하면 됨.
//    // 중성을 넣었을 때, 다음 중성과의 사이의 자음들을 보고 평가를 해야 함.
//
//    /*
//    private func 입력을모음으로나누기(input: String) -> [String] {
//        var 나뉜애들 = [input]
//
//        let 모음들 = input.filter({
//            jung.contains($0)
//        }).compactMap { String($0) }
//
//        모음들.forEach { vowel in
//            let 기준 = 나뉜애들
//            var temp = [String]()
//            기준.forEach{
//                let 값 = $0.components(separatedBy: vowel)
//                temp.append(contentsOf: 값)
//            }
//            나뉜애들 = temp
//        }
//    }
//    */
//
//    private let combinedJungSungList: [String : Character] = [
//        "ㅗㅏ" : "ㅘ",
//        "ㅗㅐ" : "ㅙ",
//        "ㅗㅣ" : "ㅚ",
//        "ㅜㅓ" : "ㅝ",
//        "ㅜㅔ" : "ㅞ",
//        "ㅜㅣ" : "ㅟ",
//        "ㅡㅣ" : "ㅢ",
//        "ㅓㅣ" : "ㅔ",
//        "ㅏㅣ" : "ㅐ",
//        "ㅕㅣ" : "ㅖ",
//        "ㅑㅣ" : "ㅒ",
//        "ㅘㅣ" : "ㅙ",
//        "ㅝㅣ" : "ㅞ"
//    ]
//
//    private let doubleChoSungList: [Character: Character] = [
//        "ㄱ": "ㄲ",
//        "ㄷ": "ㄸ",
//        "ㅂ": "ㅃ",
//        "ㅅ": "ㅆ",
//        "ㅈ": "ㅉ"
//    ]
//
//    private let combinedJongSungList: [String : Character] = [
//        "ㄱㅅ" : "ㄳ",
//        "ㄴㅈ" : "ㄵ",
//        "ㄴㅎ" : "ㄶ",
//        "ㄹㄱ" : "ㄺ",
//        "ㄹㅁ" : "ㄻ",
//        "ㄹㅂ" : "ㄼ",
//        "ㄹㅅ" : "ㄽ",
//        "ㄹㅌ" : "ㄾ",
//        "ㄹㅍ" : "ㄿ",
//        "ㄹㅎ" : "ㅀ",
//        "ㅂㅅ" : "ㅄ"
//    ]
//
//    private let choSungList: [Character] = ["ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ"]
//
//    private let jungSungList: [Character] = ["ㅏ", "ㅐ", "ㅑ", "ㅒ", "ㅓ", "ㅔ", "ㅕ", "ㅖ", "ㅗ", "ㅘ", "ㅙ", "ㅚ", "ㅛ", "ㅜ", "ㅝ","ㅞ", "ㅟ", "ㅠ", "ㅡ", "ㅢ", "ㅣ"]
//
//    private let jongSungList: [Character] = [" ", "ㄱ", "ㄲ", "ㄳ", "ㄴ", "ㄵ", "ㄶ", "ㄷ", "ㄹ", "ㄺ", "ㄻ", "ㄼ", "ㄽ", "ㄾ", "ㄿ","ㅀ", "ㅁ", "ㅂ", "ㅄ", "ㅅ", "ㅆ", "ㅇ", "ㅈ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"]
//
//    private let combinedJongsungPossibleList: [Character] = ["ㄱ", "ㄴ", "ㄹ", "ㅂ"]
//
//    private let baseUnicodeValue = 0xAC00
//
//    private func compose(choSung: Character, jungSung: Character, jongSung: Character?) -> Character? {
//        var choSungIndex = 0
//        var jungSungIndex = 0
//        var jongSungIndex = 0
//
//        for i in 0..<choSungList.count {
//            if choSungList[i] == choSung { choSungIndex = i }
//        }
//
//        for i in 0..<jungSungList.count {
//            if jungSungList[i] == jungSung { jungSungIndex = i }
//        }
//
//        if let jongSung = jongSung {
//            for i in 0..<jongSungList.count {
//                if jongSungList[i] == jongSung { jongSungIndex = i }
//            }
//        }
//
//        let calculatedValue: Int = (choSungIndex * jungSungList.count * jongSungList.count)
//        + (jungSungIndex * jongSungList.count)
//        + (jongSungIndex)
//        + baseUnicodeValue
//
//        if let unicode = Unicode.Scalar(calculatedValue) {
//            return Character(unicode)
//        }
//
//        return nil
//    }
//
//    private func decompose(char: Character) -> String {
//        let unicode = char.unicodeScalarCodePoint()
//
//        let jongSung = (unicode - UInt32(baseUnicodeValue)) % UInt32(jongSungList.count)
//        let jungSung = (
//            (unicode - UInt32(baseUnicodeValue) - jongSung) /
//            UInt32(jongSungList.count) %
//            UInt32(jungSungList.count)
//        )
//        let choSung = (
//            (
//                (unicode - UInt32(baseUnicodeValue) - jongSung) /
//                UInt32(jongSungList.count) - jungSung
//            ) / UInt32(jungSungList.count)
//        )
//
//        return "\(choSungList[Int(choSung)])\(jungSungList[Int(jungSung)])\(jongSungList[Int(jongSung)])"
//    }
//
//}
//
//extension Character {
//
//    func unicodeScalarCodePoint() -> UInt32 {
//        let unicodeScalars = self.unicodeScalars
//
//        return unicodeScalars[unicodeScalars.startIndex].value
//    }
//
//}
