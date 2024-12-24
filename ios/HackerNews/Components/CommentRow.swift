//
//  CommentRow.swift
//  Hacker News
//
//  Created by Trevor Elkins on 9/5/23.
//

import Foundation
import SwiftUI

struct CommentRow: View {
  let comment: Comment
  let level: Int
  let maxIndentationLevel: Int = 5
  
  var body: some View {
    VStack(alignment: .leading) {
      // first row
      HStack {
        // author
        let author = comment.by != nil ? comment.by! : ""
        Text("@\(author)")
          .font(.caption)
          .fontWeight(.bold)
        // time
        HStack(alignment: .center, spacing: 4.0) {
          Image(systemName: "clock")
          Text(comment.displayableDate)
        }
        .font(.caption)
        // collapse/expand
        Image(systemName: "chevron.up.chevron.down")
          .font(.caption)
        // space between
        Spacer()
        // upvote
        Button(action: {}) {
          Image(systemName: "arrow.up")
            .font(.caption2)
        }
        .padding(
          EdgeInsets(
            top: 4.0,
            leading: 8.0,
            bottom: 4.0,
            trailing: 8.0
          )
        )
        .background(HNColors.background)
        .foregroundStyle(.black)
        .clipShape(Capsule())
      }
      
      // Comment Body
      let commentText = comment.text != nil ? comment.text! : ""
      Text(commentText.strippingHTML())
        .font(.caption)
    }
    .padding(8.0)
    .background(HNColors.commentBackground)
    .clipShape(RoundedRectangle(cornerRadius: 16.0))
    .padding(
      EdgeInsets(
        top: 0,
        leading: min(CGFloat(level * 20), CGFloat(maxIndentationLevel * 20)),
        bottom: 0,
        trailing: 0)
    )
  }
}

struct CommentView_Preview: PreviewProvider {
  static var previews: some View {
    PreviewVariants {
        CommentRow(comment: PreviewHelpers.makeFakeComment(), level: 0)
    }
  }
}

struct CommentViewIndentation_Preview: PreviewProvider {
  static var previews: some View {
    Group {
      ForEach(0..<6) { index in
        CommentRow(comment: PreviewHelpers.makeFakeComment(), level: index)
          .previewLayout(.sizeThatFits)
          .previewDisplayName("Indentation \(index)")
      }
    }
  }
}
