//
//  Story.swift
//  Hacker News
//
//  Created by Ryan Brooks on 6/21/23.
//

import Foundation
import SwiftUI
import Common

struct StoryRow: View {
  @Binding var model: AppViewModel
  @Environment(Theme.self) private var theme
  let state: StoryState

  var body: some View {
    switch state {
    case .loading:
      StoryRowLoadingState()
    case .nextPage:
      StoryRowLoadingState()
        .onAppear {
          Task {
            await model.fetchNextPage()
          }
        }
    case .loaded(let content):
      Button {
        if case .loaded(let content) = state {
          let destination: AppViewModel.AppNavigation =
            if let url = content.makeUrl() {
              .webLink(url: url, title: content.title)
            } else {
              .storyComments(story: content.toStory())
            }
          print("Navigating to \(destination)")
          model.navigationPath.append(destination)
        }
      } label: {
        VStack(alignment: .leading, spacing: 8) {
          let author = content.author!
          HStack {
            Text("@\(author)")
              .font(theme.userMonoFont(size: 12, weight: .bold))
              .foregroundStyle(.hnOrange)
            Spacer()
            if content.bookmarked {
              Image(systemName: "book.fill")
                .font(.system(size: 12))
                .foregroundStyle(.hnOrange)
            }
          }
          Text(content.title)
            .font(theme.titleFont)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
          HStack(spacing: 16) {
            HStack(spacing: 4) {
              Image(systemName: "arrow.up")
                .font(.system(size: 12))
                .foregroundStyle(.green)
              Text("\(content.score)")
                .font(theme.userSansFont(size: 12, weight: .medium))
            }
            HStack(spacing: 4) {
              Image(systemName: "clock")
                .font(.system(size: 12))
                .foregroundStyle(.purple)
              Text(content.relativeDate())
                .font(theme.userSansFont(size: 12, weight: .medium))
            }
            Spacer()
            // Comment Button
            Button(action: {
              print("Pressed comment button for: \(content.id)")
              model.navigationPath.append(
                AppViewModel.AppNavigation.storyComments(
                  story: content.toStory())
              )
            }) {
              HStack(spacing: 4) {
                Image(systemName: "message.fill")
                  .font(.system(size: 12))
                Text("\(content.commentCount)")
                  .font(theme.userSansFont(size: 12, weight: .medium))
              }
              .foregroundStyle(.blue)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(ButtonBorderShape.capsule)
          }
        }
        .padding(.all, 8)
      }
      .buttonStyle(StoryRowButtonStyle())
    }
  }
}

struct StoryRowLoadingState: View {
  @Environment(Theme.self) private var theme
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("@humdinger")
        .font(theme.userMonoFont(size: 12, weight: .bold))
        .foregroundStyle(.hnOrange)
        .redacted(reason: .placeholder)
      Text("Some Short Title")
        .font(theme.userMonoFont(size: 16, weight: .bold))
        .redacted(reason: .placeholder)
      HStack(spacing: 16) {
        HStack(spacing: 4) {
          Image(systemName: "arrow.up")
            .font(.system(size: 12))
            .foregroundStyle(.green)
            .redacted(reason: .placeholder)
          Text("99")
            .font(
              theme.userSansFont(size: 12, weight: .medium)
            )
            .redacted(reason: .placeholder)
        }
        HStack(spacing: 4) {
          Image(systemName: "clock")
            .font(.system(size: 12))
            .foregroundStyle(.purple)
            .redacted(reason: .placeholder)
          Text("2h ago")
            .font(theme.userSansFont(size: 12, weight: .medium))
            .redacted(reason: .placeholder)
        }
        Spacer()
        // Comment Button
        Button(action: {}) {
          HStack(spacing: 4) {
            Image(systemName: "message.fill")
              .font(.system(size: 12))
            Text("45")
              .font(theme.userSansFont(size: 12, weight: .medium))
          }
          .foregroundStyle(.blue)
        }
        .disabled(true)
        .buttonStyle(.bordered)
        .buttonBorderShape(ButtonBorderShape.capsule)
        .redacted(reason: .placeholder)
      }
    }
    .padding(.all, 8)
  }
}

private struct StoryRowButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .contentShape(Rectangle())
      .background(Color.gray.opacity(configuration.isPressed ? 0.1 : 0))
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
      .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
  }
}

struct StoryRow_Preview: PreviewProvider {
  static var previews: some View {
    let fakeStory = PreviewHelpers.makeFakeStory(
      index: 0, descendants: 3, kids: [1, 2, 3])
    @State var model = AppViewModel(
      bookmarkStore: FakeBookmarkDataStore(),
      shouldFetchPosts: false
    )
    PreviewVariants {
      StoryRow(
        model: $model, state: .loaded(content: fakeStory.toStoryContent())
      )
      .environment(Theme())
    }
  }
}

struct StoryRowLoadingState_Preview: PreviewProvider {
  static var previews: some View {
    PreviewVariants {
      StoryRowLoadingState()
        .environment(Theme())
    }
  }
}
