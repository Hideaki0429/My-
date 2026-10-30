//
//  Term.swift
//  test
//
//  Created by 松井秀明 on 2026/10/29.
//
import Foundation

struct Term: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var language: String
    var category: String
    var explanation: String
    var example: String

    var isFavorite: Bool = false

    enum CodingKeys: String, CodingKey {
        case id, title, language, category
        case explanation, example, isFavorite
    }

    // 以前の保存データにisFavoriteがなくても読み込めるようにする
    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        language = try container.decode(String.self, forKey: .language)
        category = try container.decode(String.self, forKey: .category)
        explanation = try container.decode(
            String.self, forKey: .explanation
        )
        example = try container.decode(String.self, forKey: .example)

        isFavorite = try container.decodeIfPresent(
            Bool.self, forKey: .isFavorite
        ) ?? false
    }

    // 新しい用語を作るときに使う
    init(
        id: UUID = UUID(),
        title: String,
        language: String,
        category: String,
        explanation: String,
        example: String,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.language = language
        self.category = category
        self.explanation = explanation
        self.example = example
        self.isFavorite = isFavorite
    }
}
