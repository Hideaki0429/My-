//
//  TermStore.swift
//  test
//
//  Created by 松井秀明 on 2026/10/29.
//
import Foundation
import Combine

@MainActor
final class TermStore: ObservableObject {
    @Published private(set) var terms: [Term] = []
    @Published var errorMessage = ""

    private var loadFailed = false

    // 保存先
    private var fileURL: URL {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("terms.json")
    }

    // 作成時に保存済みデータを読み込む
    init() {
        load()
    }

    private func load() {
        guard FileManager.default.fileExists(
            atPath: fileURL.path
        ) else {
            return // 初回はファイルがなくても正常
        }

        do {
            let data = try Data(contentsOf: fileURL)

            terms = try JSONDecoder().decode(
                [Term].self,
                from: data
            )
        } catch {
            loadFailed = true
            errorMessage = "用語を読み込めませんでした：\(error.localizedDescription)"
        }
    }

    // 用語を追加して保存する
    func add(_ term: Term) -> Bool {
        // 読み込み失敗時に既存データを上書きしない
        guard !loadFailed else {
            errorMessage = "保存済みデータを読み込めなかったため、追加できません。"
            return false
        }

        var updatedTerms = terms
        updatedTerms.append(term)

        do {
            let data = try JSONEncoder().encode(updatedTerms)

            try data.write(to: fileURL, options: .atomic)

            // ファイル保存に成功したら画面にも反映する
            terms = updatedTerms
            return true
        } catch {
            errorMessage = "保存できませんでした：\(error.localizedDescription)"
            return false
        }
    }
    
    // 編集
    func update(_ term: Term) -> Bool {
        guard let index = terms.firstIndex(
            where: { $0.id == term.id }
        ) else {
            errorMessage = "編集する用語が見つかりません。"
            return false
        }

        var updatedTerms = terms
        updatedTerms[index] = term

        return saveChanges(updatedTerms)
    }
    
    // 削除
    func delete(id: UUID) -> Bool {
        let updatedTerms = terms.filter { $0.id != id }

        return saveChanges(updatedTerms)
    }
    
    // 変更後の一覧を端末内に保存
    private func saveChanges(_ updatedTerms: [Term]) -> Bool {
        guard !loadFailed else {
            errorMessage = "保存済みデータを読み込めなかったため、変更できません。"
            return false
        }

        do {
            let data = try JSONEncoder().encode(updatedTerms)
            try data.write(to: fileURL, options: .atomic)

            terms = updatedTerms
            return true
        } catch {
            errorMessage = "保存できませんでした：\(error.localizedDescription)"
            return false
        }
    }
    //お気に入りピンの状態の切り替え処理
    func toggleFavorite(id: UUID) -> Bool {
        guard var term = terms.first(where: { $0.id == id }) else {
            errorMessage = "用語が見つかりません。"
            return false
        }

        term.isFavorite.toggle()

        return update(term)
    }
    
}
