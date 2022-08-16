import Foundation
import Algorithms
import NaturalLanguage

public struct TextWrap {
    /// Return a String including breaklines that break up a given script up to given number. This is useful to
    /// determine the best distributed text that laid out on screenshots. The logic is to first list up the chunk of words
    /// and then work out standard deviation on each way of breaking and then choose the most distributed pattern.
    ///
    /// - Parameters:
    ///   - input: Input string to break lines
    ///   - separator: Character to separate words in scripts. Depending on languages, this can be blank string, like Japanese, Chinese, etc
    ///   - numberOfLines: number of lines to break up the input
    /// - Returns: A String including breaklines that break up a given script up to given number
    public static func wrapTextEqually(_ input: String, into numberOfLines: Int, using separator: String = " ") -> String {
        let words = splitByWord(input)
        let separatePatterns = words.indices.combinations(ofCount: numberOfLines - 1)
        var scores: [[String]: Double] = [:]
        var best: [String] = []
        var bestScore: Double = .infinity

        for separateIndexes in separatePatterns {
            var startIndex = words.startIndex
            var lines: [String] = []
            for separateIndex in separateIndexes {
                let subsequence = words[startIndex...separateIndex]
                lines.append(subsequence.joined(separator: separator))
                startIndex = separateIndex.advanced(by: 1)
            }
            lines.append(words[startIndex..<words.endIndex].joined(separator: separator))

            if lines.contains("") {
                continue
            }

            // Store score
            let score = evaluate(lines)
            scores[lines] = score

            // Update best pattern
            if score < bestScore {
                best = lines
                bestScore = score
            } else if score == bestScore {
                // if the score is same, choose the most centresied one.
                if numberOfLines.isMultiple(of: 2) {
                    let bestScore2 = best[numberOfLines/2].count + best[(numberOfLines/2) + 1].count
                    let score2 = lines[numberOfLines/2].count + lines[(numberOfLines/2) + 1].count
                    if bestScore2 < score2 {
                        best = lines
                        bestScore = score
                    }
                } else {
                    let bestScore2 = best[numberOfLines/2].count
                    let score2 = lines[numberOfLines/2].count
                    if bestScore2 < score2 {
                        best = lines
                        bestScore = score
                    }
                }
            }
        }

        return best.joined(separator: "\n")
    }

    // Use NSTagger to split a text into words.
    // This is not achivable for `String.split(separator:)` for Chinese or Japanese text
    private static func splitByWord(_ input: String) -> [Substring] {
        var words = [Substring]()
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = input
        tokenizer.enumerateTokens(in: input.startIndex..<input.endIndex) { (range, attribute) -> Bool in
            words.append(input[range])
            return true
        }
        return words
    }

    private static func evaluate(_ lines: [String]) -> Double {
        let charCounts = lines.map(\.count).map(Double.init)
        return stdev(of: charCounts)
    }

    private static func stdev(of values: [Double]) -> Double {
        // https://github.com/apple/swift-argument-parser/blob/898d1ae9dd7d9ff9af39e66bea744d52f69df2e3/Examples/math/Math.swift#L174-L180
        let sum: Double = values.reduce(0, +)
        let mean = sum / Double(values.count)
        let squaredErrors = values
            .map { $0 - mean }
            .map { $0 * $0 }
        let variance = squaredErrors.reduce(0, +) / Double(values.count)
        let result = variance.squareRoot()
        return result
    }
}
