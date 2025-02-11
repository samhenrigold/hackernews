//
//  CommentComposer.swift
//  HackerNews
//
//  Created by Rikin Marfatia on 1/16/25.
//
import SwiftUI
import Common

struct CommentComposer: View {
  @Binding var state: CommentComposerState
  @Environment(Theme.self) private var theme
  let goToLogin: () -> Void
  let sendComment: () -> Void

  var body: some View {
    VStack {
      HStack(alignment: .center) {
        Image(systemName: "message.fill")
          .font(.system(size: 12))
        Text("Add a comment")
              .font(theme.userSansFont(size: 12, weight: .medium))
      }
      TextField(
        "Words of wisdom",
        text: $state.text
      )
      .textFieldStyle(.roundedBorder)
      .disabled(AuthState.loggedOut == state.loggedIn)
      .submitLabel(.send)
      .onSubmit {
        sendComment()
      }
    }
    .padding(16)
    .background {
      Color
        .clear
        .background(.ultraThinMaterial)
        .containerShape(
          .rect(
            cornerRadii: RectangleCornerRadii(
              topLeading: 24,
              bottomLeading: 0,
              bottomTrailing: 0,
              topTrailing: 24
            ),
            style: .continuous
          )
        )
    }
    .onTapGesture {
      if AuthState.loggedOut == state.loggedIn {
        goToLogin()
      }
    }
  }
}

#Preview {
  CommentComposer(
    state: .constant(
      CommentComposerState(
        parentId: "",
        goToUrl: "",
        hmac: "",
        loggedIn: .loggedIn,
        text: ""
      )
    ),
    goToLogin: {},
    sendComment: {}
  )
}
