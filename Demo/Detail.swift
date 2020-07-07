import ComposableArchitecture
import SwiftUI

struct DetailState: Equatable {}

enum DetailAction {}

let detailReducer = Reducer<DetailState, DetailAction, Void>.empty

struct DetailView: View {
    let store: Store<DetailState, DetailAction>

    var body: some View {
        VStack(spacing: 16) {
            Text("Detail").font(.title)
            Text("Hello, World!")
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
