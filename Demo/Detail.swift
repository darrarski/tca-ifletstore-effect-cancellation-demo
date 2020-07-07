import ComposableArchitecture
import SwiftUI

struct DetailState: Equatable {
    var time: Int = 0
}

enum DetailAction {
    case startTimer
    case stopTimer
    case timerTicked
}

let detailReducer = Reducer<DetailState, DetailAction, Void> { state, action, _ in
    struct TimerId: Hashable {}

    switch action {
    case .startTimer:
        return Effect.timer(id: TimerId(), every: 1, tolerance: .zero, on: DispatchQueue.main)
            .map { _ in DetailAction.timerTicked }

    case .stopTimer:
        return .cancel(id: TimerId())

    case .timerTicked:
        state.time += 1
        return .none
    }

}

struct DetailView: View {
    let store: Store<DetailState, DetailAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                Text("Detail").font(.title)
                Text("\(viewStore.time)")
            }.onAppear {
                viewStore.send(.startTimer)
            }.onDisappear {
                viewStore.send(.stopTimer)
            }
        }
    }
}

#if DEBUG
struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(store: Store(
            initialState: .init(),
            reducer: .empty,
            environment: ()
        ))
    }
}
#endif
