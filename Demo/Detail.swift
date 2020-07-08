import ComposableArchitecture
import SwiftUI

struct DetailState: Equatable {
    var time: Int = 0
}

enum DetailAction: Equatable {
    case timerTicked
}

struct TimerId: Hashable {}

let detailReducer = Reducer<DetailState, DetailAction, Void> { state, action, _ in
    switch action {
    case .timerTicked:
        state.time += 1
        return .none
    }
}
.lifecycle(onAppear: {
    CustomTimerPublisher()
        .map { _ in DetailAction.timerTicked }
        .eraseToEffect()
        .cancellable(id: TimerId(), cancelInFlight: true)

}, onDisappear: {
    .cancel(id: TimerId())
})

struct DetailView: View {
    let store: Store<DetailState, LifecycleAction<DetailAction>>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 16) {
                Text("Detail").font(.title)
                Text("\(viewStore.time)")
            }.onAppear {
                viewStore.send(.onAppear)
            }.onDisappear {
                viewStore.send(.onDisappear)
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
