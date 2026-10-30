//
//  ContentView.swift
//  test
//
//  Created by 松井秀明 on 2026/10/28.
//
import SwiftUI
struct ContentView: View {
    @State private var selectedLanguage = "C++"     //選ばれている言語の初期値
    @State private var searchText = ""              //検索欄の初期値
    @State private var selectedNotation = "すべて"     // 選択された表記の初期値
    @State private var selectedClass = "すべての分類"     // 選択された分類の初期値
    @State private var showFavoriteError = false        //ピンボタンの初期化
    @StateObject private var termStore = TermStore()
    //表記によるタイトルの分類
    private func matchesNotation(_ title: String) -> Bool {
        switch selectedNotation {
        case "英語":
            return title.range(
                of: "[A-Za-z]",
                options: .regularExpression
            ) != nil
        case "日本語":
            return title.range(
                of: #"[\p{Han}\p{Hiragana}]"#,
                options: .regularExpression
            ) != nil
        case "カタカナ":
            return title.range(
                of: #"\p{Katakana}"#,
                options: .regularExpression
            ) != nil
        default:
            return true // 「すべて」の場合
        }
    }
    //条件にあった際の検索結果に表示する用語
    private var filteredTerms: [Term] {
        let keyword = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        return termStore.terms.filter { term in
            // 言語の条件
            let matchesLanguage =
            term.language == selectedLanguage
            // タイトルの条件：検索欄が空ならすべて対象
            let matchesTitle =
            keyword.isEmpty
            || term.title.localizedCaseInsensitiveContains(keyword)
            // 分類の条件：「すべての分類」ならすべて対象
            let matchesCategory =
            selectedClass == "すべての分類"
            || term.category == selectedClass
            // 3つの条件をすべて満たす用語を表示
            return matchesLanguage
            && matchesTitle
            && matchesCategory
            && matchesNotation(term.title)
        }
        .sorted { first, second in
            // お気に入りを先頭にする
            if first.isFavorite != second.isFavorite {
                return first.isFavorite
            }
            // 同じグループ内では名前順
            let order = first.title.localizedStandardCompare(second.title)
            if order == .orderedSame {
                return first.id.uuidString < second.id.uuidString
            }
            return order == .orderedAscending
        }
    }
    var body: some View {
        
        NavigationStack {
            
            VStack(alignment: .leading, spacing: 10){
                HStack(alignment: .center) {
                    Text("用語を検索")       //タイトル
                        .font(.largeTitle)
                        .bold()

                    Spacer()

                    NavigationLink {
                        AddTermView(termStore: termStore)
                            .toolbar(.visible, for: .navigationBar)
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundStyle(.blue)
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("用語を追加")
                }
                .padding(.vertical, 15)
                //言語選択一覧
                HStack(spacing: 16) {
                    Text("言語")
                    let languages = ["C++", "C#", "Swift", "Python", "その他"]
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
                        .padding(.horizontal, 12)
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
                //検索欄
                HStack{
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                        TextField("用語を入力",text: $searchText)
                            .textInputAutocapitalization(.never)    //英字の先頭が自動で大文字になるのを防ぐ
                            .autocorrectionDisabled()               //自動修正を無効
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                //検索欄の表記による分類
                Text("表記")
                let notations = ["すべて", "英語", "日本語", "カタカナ"]
                Picker("表記",selection: $selectedNotation){
                    ForEach(notations, id: \.self) { notion in    //notionを新たに作成し保存
                        Text(notion)      // 画面に表示する文字
                            .tag(notion)  // 選択したときに使う値
                    }
                }
                .pickerStyle(.segmented)    //候補が横に並び、1つを選べる形式
                //分類選択一覧
                HStack(spacing: 16){
                    Text("分類")
                    let categories = [
                        "すべての分類",
                        "基本文法",
                        "データ型・コレクション",
                        "関数・メソッド",
                        "クラス・設計",
                        "アルゴリズム",
                        "エラー対処",
                        "豆知識",
                        "その他"
                    ]
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
                        .padding(.horizontal, 12)
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
                VStack(alignment: .leading,spacing: 10){
                    // 薄くて細い横線
                    Divider()
                    HStack{
                        // 検索結果の見出し
                        Text("検索結果")
                            .font(.title3)
                            .bold()
                        Spacer()
                        Text("\(filteredTerms.count)件")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(10)
                        Label(
                            "\(termStore.terms.count)語",
                            systemImage: "books.vertical"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            if filteredTerms.isEmpty {
                                Text("一致する用語が見つかりません。")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 30)
                            } else {
                                ForEach(filteredTerms) { term in
                                    HStack(spacing: 4) {
                                        NavigationLink {
                                            TermDetailView(
                                                termStore: termStore,
                                                term: term
                                            )
                                            .toolbar(.visible, for: .navigationBar)
                                        } label: {
                                            TermRowView(term: term)
                                        }
                                        .buttonStyle(.plain)
                                        Button {
                                            if !termStore.toggleFavorite(id: term.id) {
                                                showFavoriteError = true
                                            }
                                        } label: {
                                            Image(
                                                systemName: term.isFavorite ? "pin.fill" : "pin"
                                            )
                                            .foregroundStyle(
                                                term.isFavorite ? Color.blue : Color.gray
                                            )
                                            .frame(width: 44, height: 44)
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel(
                                            term.isFavorite
                                            ? "お気に入りを解除"
                                            : "お気に入りに登録"
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 8)
            .toolbar(.hidden, for: .navigationBar)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
        }
        .alert(
            "お気に入りを変更できませんでした",
            isPresented: $showFavoriteError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(termStore.errorMessage)
        }
    }
}
#Preview {
    ContentView()
}
