//
//  DocumentInformationForm.swift
//  PDFArchiver
//
//  Created by Julian Kahnert on 03.07.20.
//

import SwiftUI
import SwiftUIX

struct DocumentInformationForm: View {

    @Binding var date: Date
    @Binding var specification: String
    @Binding var tags: [String]

    @Binding var tagInput: String
    @Binding var suggestedTags: [String]

    var body: some View {
        Form {
            HStack {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                #if !os(macOS)
                Spacer()
                Button("Today" as LocalizedStringKey) {
                    date = Date()
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(Color.tertiarySystemFill)
                .cornerRadius(6)
                #endif
            }
            .labelsHidden()
            TextField("Description", text: $specification)
                .modifier(ClearButton(text: $specification))
            documentTagsView
            suggestedTagsView
        }
        .buttonStyle(BorderlessButtonStyle())
    }

    private func documentTagTapped(_ tag: String) {
        tags.removeAll { $0 == tag }
        // just remove the tapped tag
        // $suggestedTags.insertAndSort(tag)
    }

    private func saveCurrentTag() {
        let tag = tagInput
        tagInput = ""
        $tags.insertAndSort(tag)
    }

    private func suggestedTagTapped(_ tag: String) {
        suggestedTags.removeAll { $0 == tag }
        tagInput = ""
        $tags.insertAndSort(tag)
    }

    private var documentTagsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Document Tags")
                .font(.caption)
            TagListView(tags: $tags,
                        isEditable: true,
                        isMultiLine: true,
                        tapHandler: documentTagTapped(_:))
            TextField("Enter Tag",
                      text: $tagInput,
                      onCommit: saveCurrentTag)
                .disableAutocorrection(true)
                .frame(maxHeight: 22)
                .padding(EdgeInsets(top: 4.0, leading: 0.0, bottom: 4.0, trailing: 0.0))
        }
    }

    private var suggestedTagsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Suggested Tags")
                .font(.caption)
            TagListView(tags: $suggestedTags,
                        isEditable: false,
                        isMultiLine: true,
                        tapHandler: suggestedTagTapped(_:))
        }
    }
}

struct DocumentInformationForm_Previews: PreviewProvider {

    struct PreviewContentView: View {
        @State var tagInput: String = "test"
        @State var tags: [String] = ["bill", "clothes"]
        @State var suggestedTags: [String] = ["tag1", "tag2", "tag3"]

        var body: some View {
            DocumentInformationForm(date: .constant(Date()),
                                    specification: .constant("Blue Pullover"),
                                    tags: $tags,
                                    tagInput: $tagInput,
                                    suggestedTags: $suggestedTags)
                }
        }

    static var previews: some View {
        PreviewContentView()
            .previewLayout(.sizeThatFits)
    }
}
