import SwiftUI
import UIKit

struct TermDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var termStore: TermStore

    let term: Term

    @State private var editingTerm: Term?
    @State private var showDeleteConfirmation = false
    @State private var showError = false
    @State private var showCopied = false

    // 保存管理から最新の内容を取得する
    private var currentTerm: Term {
        termStore.terms.first { $0.id == term.id } ?? term
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // タイトル
                Text(currentTerm.title)
                    .font(.largeTitle)
                    .bold()

                // 言語・分類
                HStack(spacing: 8) {
                    Text(currentTerm.language)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Capsule())

                    Text(currentTerm.category)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                }
                .font(.subheadline)

                Divider()

                // 説明
                VStack(alignment: .leading, spacing: 12) {
                    Text("説明（意味）")
                        .font(.title2)
                        .bold()

                    Text(currentTerm.explanation)
                        .textSelection(.enabled)
                }

                // 使用例
                if !currentTerm.example.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty {
                    exampleSection
                }

                Divider()

                Text("登録した内容は「編集」から変更できます。")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                // 削除ボタン
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("この用語を削除", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .navigationTitle("用語の詳細")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            // 左上：戻る
            ToolbarItem(placement: .topBarLeading) {
                Button{
                    dismiss()
                }label:{
                    Image(systemName: "chevron.left")
                    Text("戻る")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("編集") {
                    editingTerm = currentTerm
                }
            }
        }
        .sheet(item: $editingTerm) { selectedTerm in
            NavigationStack {
                EditTermView(
                    term: selectedTerm,
                    termStore: termStore
                )
            }
            .interactiveDismissDisabled()
        }
        .confirmationDialog(
            "この用語を削除しますか？",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("削除", role: .destructive) {
                if termStore.delete(id: term.id) {
                    dismiss()
                } else {
                    showError = true
                }
            }

            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("「\(currentTerm.title)」を削除します。この操作は取り消せません。")
        }
        .alert("削除できませんでした", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(termStore.errorMessage)
        }
        .alert("コピーしました", isPresented: $showCopied) {
            Button("OK", role: .cancel) {}
        }
        .tint(.blue)
    }

    // 使用例の表示を分けて、bodyを短くする
    private var exampleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("使用例")
                .font(.title2)
                .bold()

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Spacer()

                    Button {
                        UIPasteboard.general.string = currentTerm.example
                        showCopied = true
                    } label: {
                        Label("コピー", systemImage: "doc.on.doc")
                            .font(.subheadline)
                    }
                }

                Text(currentTerm.example)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color.gray.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}
#Preview {
    NavigationStack {
        TermDetailView(
            termStore: TermStore(),
            term: Term(
                title: "ソート",
                language: "C++",
                category: "アルゴリズム",
                explanation: "データを順番に並べ替える処理。",
                example: "std::sort(values.begin(), values.end());"
            )
        )
    }
}
