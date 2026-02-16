import Foundation

struct CurrencyConversion: Sendable {
    let originalText: String
    let euroAmount: Double
    let jpyAmount: Double
    let range: Range<String.Index>
}

struct CurrencyDetector: Sendable {
    // €15.50, €15, € 15.50
    nonisolated(unsafe) private static let prefixEuroSymbol = /€\s?(\d{1,6}(?:[.,]\d{1,2})?)/

    // 15,50 €, 15 €, 15.50€
    nonisolated(unsafe) private static let suffixEuroSymbol = /(\d{1,6}(?:[.,]\d{1,2})?)\s?€/

    // EUR 20, EUR20, 20 EUR
    nonisolated(unsafe) private static let eurCode = /(?:EUR\s?(\d{1,6}(?:[.,]\d{1,2})?))|(?:(\d{1,6}(?:[.,]\d{1,2})?)\s?EUR)/

    // 15 euros, 15 euro, 15euros (case-insensitive)
    nonisolated(unsafe) private static let euroWord = /(\d{1,6}(?:[.,]\d{1,2})?)\s?[Ee]uros?/

    // 15ユーロ
    nonisolated(unsafe) private static let euroJP = /(\d{1,6}(?:[.,]\d{1,2})?)\s?ユーロ/

    func detect(in text: String, rate: Double) -> [CurrencyConversion] {
        var conversions: [CurrencyConversion] = []
        var coveredRanges: [Range<String.Index>] = []

        func addMatch(amount: Double, range: Range<String.Index>, original: String) {
            for existing in coveredRanges {
                if range.overlaps(existing) { return }
            }
            let jpy = amount * rate
            conversions.append(CurrencyConversion(
                originalText: original,
                euroAmount: amount,
                jpyAmount: jpy,
                range: range
            ))
            coveredRanges.append(range)
        }

        // €15.50
        for match in text.matches(of: Self.prefixEuroSymbol) {
            if let amount = parseEuroAmount(String(match.1)) {
                addMatch(amount: amount, range: match.range, original: String(text[match.range]))
            }
        }

        // 15,50 €
        for match in text.matches(of: Self.suffixEuroSymbol) {
            if let amount = parseEuroAmount(String(match.1)) {
                addMatch(amount: amount, range: match.range, original: String(text[match.range]))
            }
        }

        // EUR 20
        for match in text.matches(of: Self.eurCode) {
            let amountStr = match.1 ?? match.2
            if let amountStr, let amount = parseEuroAmount(String(amountStr)) {
                addMatch(amount: amount, range: match.range, original: String(text[match.range]))
            }
        }

        // 15 euros
        for match in text.matches(of: Self.euroWord) {
            if let amount = parseEuroAmount(String(match.1)) {
                addMatch(amount: amount, range: match.range, original: String(text[match.range]))
            }
        }

        // 15ユーロ
        for match in text.matches(of: Self.euroJP) {
            if let amount = parseEuroAmount(String(match.1)) {
                addMatch(amount: amount, range: match.range, original: String(text[match.range]))
            }
        }

        return conversions.sorted { $0.range.lowerBound < $1.range.lowerBound }
    }

    func annotate(text: String, rate: Double) -> String {
        let conversions = detect(in: text, rate: rate)
        guard !conversions.isEmpty else { return text }

        var result = text
        // Process from end to preserve indices
        for conversion in conversions.reversed() {
            let jpyFormatted = formatJPY(conversion.jpyAmount)
            let annotation = " (\(jpyFormatted))"
            result.insert(contentsOf: annotation, at: conversion.range.upperBound)
        }
        return result
    }

    private func parseEuroAmount(_ text: String) -> Double? {
        let normalized = text.replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    private func formatJPY(_ amount: Double) -> String {
        let rounded = Int(amount.rounded())
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: rounded)) ?? "\(rounded)"
        return "¥\(formatted)"
    }
}
