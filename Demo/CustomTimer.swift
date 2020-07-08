import Combine
import CoreData

private var CustomTimerPublisher_instanceCounter = 0
private var CustomTimerSubscription_instanceCounter = 0

final class CustomTimerPublisher: Publisher {

    init() {
        CustomTimerPublisher_instanceCounter += 1
        Swift.print("^^^ CustomTimerPublisher.init (\(CustomTimerPublisher_instanceCounter))")
    }

    deinit {
        CustomTimerPublisher_instanceCounter -= 1
        Swift.print("^^^ CustomTimerPublisher.deinit (\(CustomTimerPublisher_instanceCounter))")
    }

    // MARK: - Publisher

    typealias Output = Void
    typealias Failure = Never

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        subscriber.receive(subscription: CustomTimerSubscription(subscriber: subscriber))
    }

}

final class CustomTimerSubscription<SubscriberType>
    : NSObject, Subscription, NSFetchedResultsControllerDelegate
    where
    SubscriberType: Subscriber,
    SubscriberType.Input == Void,
    SubscriberType.Failure == Never
{
    init(subscriber: SubscriberType) {
        self.subscriber = subscriber
        CustomTimerSubscription_instanceCounter += 1
        Swift.print("^^^ CustomTimerSubscription.init (\(CustomTimerSubscription_instanceCounter))")
    }

    deinit {
        CustomTimerSubscription_instanceCounter -= 1
        Swift.print("^^^ CustomTimerSubscription.deinit (\(CustomTimerSubscription_instanceCounter))")
    }

    private let subscriber: SubscriberType
    private var timer: Timer?

    // MARK: - Subscription

    func request(_ demand: Subscribers.Demand) {
        guard demand > 0, timer == nil  else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] timer in
            _ = self?.subscriber.receive(())
        })
    }

    // MARK: - Cancellable

    func cancel() {
        Swift.print("^^^ CustomTimerSubscription.cancel")
        timer?.invalidate()
        timer = nil
    }

}
