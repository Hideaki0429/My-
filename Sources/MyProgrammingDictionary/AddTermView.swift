//
//  AddTermView.swift
//  test
//
//  Created by 松井秀明 on 2026/10/29.
//
import SwiftUI

struct AddTermView: View {
    @Environment(\.dismiss) private var dismiss     //戻るの初期値
    @State private var searchText = ""              //検索欄の初期値
    @State private var explainText = ""              //説明欄の初期値
    @State private var exampleText = ""              //使用例の初期値
    @State private var selectedLanguage = "C++"     //選ばれている言語の初期値
    @State private var selectedClass = "基本文法"     // 選択された分類の初期値
    private let languages = ["C++", "C#", "Swift", "Python", "その他"]
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
    //必須項目にテキストが入っているかを判別する処理
    private var canSave: Bool {
        let hasTitle = !searchText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        let hasExplanation = !explainText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty

        let hasLanguage = !selectedLanguage.isEmpty

        let hasCategory = !selectedClass.isEmpty
            && selectedClass != "すべての分類"

        return hasTitle
            && hasExplanation
            && hasLanguage
            && hasCategory
    }
    @ObservedObject var termStore: TermStore

    @State private var showSaveError = false
    var body: some View {
        
        
        VStack(alignment: .leading ,spacing: 20){
            
            //タイトル入力
            VStack(alignment: .leading,spacing: 0){
                HStack{
                    Text("タイトル")
                        .font(.title3)
                        .bold()
                    Text("必須")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                HStack{
                    TextField("用語を入力",text: $searchText)
                        .textInputAutocapitalization(.never)    //英字の先頭が自動で大文字になるのを防ぐ
                        .autocorrectionDisabled()               //自動修正を無効
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            //言語選択
            VStack(alignment: .leading,spacing: 0){
                HStack{
                    Text("言語")
                        .font(.title3)
                        .bold()
                    Text("必須")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                HStack(spacing: 16) {
                    
                    Menu {
                        ForEach(languages, id: \.self) { language in
                            Button(language) {
                                selectedLanguage = language
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedLanguage)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                        }
                        .foregroundStyle(.blue) // 文字と矢印を黒にする
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)     //選択肢を横幅の最大まで広げる
                        .background(Color.gray.opacity(0.1))    //背景を灰色にする
                        .clipShape(RoundedRectangle(cornerRadius: 10))  //選択肢の枠を指定の分丸くする
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5)       //灰色の枠線をつける
                        }
                    }
                }
            }
            
            //分類選択一覧
            VStack(alignment: .leading,spacing: 0){
                HStack{
                    Text("分類")
                        .font(.title3)
                        .bold()
                    Text("必須")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                HStack(spacing: 16){
                    Menu{
                        ForEach(categories, id: \.self) {category in    //languageを新たに作成し保存
                            Button(category) {
                                selectedClass = category
                            }
                        }
                        
                    }label: {
                        HStack {
                            Text(selectedClass)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                        }
                        .foregroundStyle(.blue) // 文字と矢印を黒にする
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)     //選択肢を横幅の最大まで広げる
                        .background(Color.gray.opacity(0.1))    //背景を灰色にする
                        .clipShape(RoundedRectangle(cornerRadius: 10))  //選択肢の枠を指定の分丸くする
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5)   //灰色の枠線をつける
                        }
                    }
                }
            }
            
            // 説明入力
            VStack(alignment: .leading, spacing: 5) {
                HStack{
                    Text("説明（意味）")
                        .font(.title3)
                        .bold()
                    Text("必須")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                }
                TextEditor(text: $explainText)
                    .scrollContentBackground(.hidden)   //標準の背景を隠し、指定した灰色を表示する
                    .padding(8)                         //入力欄の周囲に上下左右8ポイントの余白を付ける
                    .frame(height: 150)                 //余白を含む入力欄全体の高さを150ポイントにする
                    .background(Color.gray.opacity(0.1))    //背景を薄い灰色にする。0.1は不透明度10％
                    .clipShape(RoundedRectangle(cornerRadius: 12))  //表示を角丸の長方形に切り取る。12は角の丸みの大きさ
                    .textInputAutocapitalization(.never)       //英字の先頭を自動で大文字にしない
                    .autocorrectionDisabled()                   //入力した単語の自動修正を無効にする
            }
            
            // 使用例入力
            VStack(alignment: .leading, spacing: 5) {
                HStack{
                    Text("使用例")
                        .font(.title3)
                        .bold()
                    Text("任意")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                TextEditor(text: $exampleText)
                    .font(.system(.body, design: .monospaced))
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(height: 150)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            
            Text("入力した内容は端末内に保存されます")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            
        }
        .padding()
        .navigationTitle("用語を追加")
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

            // 右上：保存
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    let newTerm = Term(
                        title: searchText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ),
                        language: selectedLanguage,
                        category: selectedClass,
                        explanation: explainText.trimmingCharacters(
                            in: .whitespacesAndNewlines
                        ),
                        example: exampleText
                    )

                    if termStore.add(newTerm) {
                        dismiss() // 保存できたら検索画面に戻る
                    } else {
                        showSaveError = true
                    }
                }
                .disabled(!canSave)
            }
        }
        .tint(.blue)
        .alert("保存できませんでした", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(termStore.errorMessage)
        }
    }
}

#Preview {
    NavigationStack {
        AddTermView(termStore: TermStore())
    }
}

