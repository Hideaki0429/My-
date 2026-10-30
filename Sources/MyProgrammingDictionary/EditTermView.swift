//
//  EditTermView.swift
//  test
//
//  Created by 松井秀明 on 2026/10/30.
//
import SwiftUI

struct EditTermView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var termStore: TermStore

    // 編集中のデータ
    @State private var draft: Term
    @State private var showError = false

    private let languages = [
        "C++", "C#", "Swift", "Python", "その他"
    ]

    private let categories = [
        "基本文法",
        "データ型・コレクション",
        "関数・メソッド",
        "クラス・設計",
        "アルゴリズム",
        "エラー対処",
        "豆知識",
        "その他"
    ]

    // 元の用語を編集用データへコピー
    init(term: Term, termStore: TermStore) {
        self.termStore = termStore
        _draft = State(initialValue: term)
    }

    private var canSave: Bool {
        !draft.title.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        && !draft.explanation.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
        && !draft.language.isEmpty
        && !draft.category.isEmpty
        && draft.category != "すべての分類"
    }

    var body: some View {
        Form {
            Section("タイトル（必須）") {
                TextField("用語を入力", text: $draft.title)
            }

            Section("カテゴリ") {
                Picker("言語", selection: $draft.language) {
                    ForEach(
                        Array(Set(languages + [draft.language])).sorted(),
                        id: \.self
                    ) { language in
                        Text(language).tag(language)
                    }
                }

                Picker("分類", selection: $draft.category) {
                    ForEach(
                        Array(Set(categories + [draft.category])).sorted(),
                        id: \.self
                    ) { category in
                        Text(category).tag(category)
                    }
                }
            }

            Section("説明（意味）・必須") {
                TextEditor(text: $draft.explanation)
                    .frame(minHeight: 150)
            }

            Section("使用例・任意") {
                TextEditor(text: $draft.example)
                    .font(.system(.body, design: .monospaced))
                    .frame(minHeight: 150)
            }
        }
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .navigationTitle("用語を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("キャンセル") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    var updatedTerm = draft

                    updatedTerm.title = draft.title
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    updatedTerm.explanation = draft.explanation
                        .trimmingCharacters(in: .whitespacesAndNewlines)

                    if termStore.update(updatedTerm) {
                        dismiss()
                    } else {
                        showError = true
                    }
                }
                .disabled(!canSave)
            }
        }
        .alert("保存できませんでした", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(termStore.errorMessage)
        }
    }
}
//#Preview {
//    EditTermView(
//        
//    )
//}
