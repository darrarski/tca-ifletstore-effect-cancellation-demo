# TCA: `IfLetStore`, `Effect` cancellation demo

Demo project. Reproduces the issue with `IfLetStore` and effect cancellation when using [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture).

## Issue

### Steps to reproduce

1. Clone the repository
2. Open `Demo.xcodeproj` in Xcode 11.5
3. Run the app in iPhone Simulator using `Demo` build scheme
4. Tap "Present Detail"
5. Observe timer on the screen
6. Tap "Dismiss Detail"

### Expected behavior

7. Detail view disappears
8. Timer effect is canceled

### Actual behavior

7. App crashes due to error:

```
Fatal error: "DetailAction.stopTimer" was received by an optional reducer when its state was "nil". This can happen for a few reasons:

* The optional reducer was combined with or run from another reducer that set "DetailState" to "nil" before the optional reducer ran. Combine or run optional reducers before reducers that can set their state to "nil". This ensures that optional reducers can handle their actions while their state is still non-"nil".

* An active effect emitted this action while state was "nil". Make sure that effects for this optional reducer are canceled when optional state is set to "nil".

* This action was sent to the store while state was "nil". Make sure that actions for this reducer can only be sent to a view store when state is non-"nil". In SwiftUI applications, use "IfLetStore".
```

## Details

I assume the issue is caused by the fact, that `DetailAction.stopTimer` action is sent to a store using `.onDisappear` modifier on a SwiftUI view that is already removed from the hierarchy by the `IfLetStore` view. 

I don't think it's a bug in The Composable Architecture, I think it's rather misuse of it. I am not sure if expected behavior can be achieved in the current implementation of the library.

The problem seems to be common, as it will be present whenever we send actions using `.onDisappear` view modifier, when the view is embedded in `IfLetStore` view. This concrete use case is probably a common one when implementing long-time-running effects that needs to be eventually canceled (when view disappears).

## Solution - Lifecycle Reducer

Solution proposed by [Brandon Williams on Swift Forums](https://forums.swift.org/t/ifletstore-and-effect-cancellation-on-view-disappear/38272/2?u=darrarski).

- `.lifecycle` function on a `Reducer<State, Action, E>` transforms it to `Reducer<State?, LifecycleAction<Action>, E>`.

```swift
extension Reducer {
    public func lifecycle(
        onAppear: @escaping (Environment) -> Effect<Action, Never>,
        onDisappear: @escaping (Environment) -> Effect<Never, Never>
    ) -> Reducer<State?, LifecycleAction<Action>, Environment>
}
```

- For `LifecycleAction<Action>.onAppear` action, `Effect<Action, Never>` is returned, where `Action` is a type of action in original reducer. In this place we can return a long-running effect, like a timer.

- For `LifecycleAction<Action>.onDisappear` action, `Effect<Never, Never>` is returned, as we assume the state is already `nil` and no actions should be sent to original reducer.

- Action `LifecycleAction<Action>.action(Action)` passes the `Action` to original reducer, if the state is not `nil`. Otherwise it triggers assertion failure (just like an optional reducer does in the same case) and returns `Effect.none`.

- [Check out all changes in the source code](https://github.com/darrarski/tca-ifletstore-effect-cancellation-demo/compare/c7e863b951569e1d1d96dd0930bf4f08ce926b94...solution-lifecycle)

## Links

- [IfLetStore and Effect cancellation on view disappear - Related Projects / Swift Composable Architecture - Swift Forums](https://forums.swift.org/t/ifletstore-and-effect-cancellation-on-view-disappear/38272)

## License

Copyright © 2020 [Dariusz Rybicki Darrarski](http://www.darrarski.pl)

License: [GNU GPLv3](LICENSE)
