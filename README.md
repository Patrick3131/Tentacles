# 🐙Tentacles

# Welcome to Tentacles

Tentacles are body parts that an animal uses to hold, grab or even feel things. That is what Tentacles are used for in terms of data collection in your application. It helps you to abstract analytics from specific providers, to structure your analytic events in a type-safe way and to collect meaningful domain-driven data with ``DomainActivity``.

For further information, why abstracting a third party library make sense [Benoit Pasquier wrote an article](https://benoitpasquier.com/abstract-ios-third-party-libraries/).

## ✨Features
- Analytics layer abstraction
    - Analytics event reporting
    - Error reporting
    - Adding user attributes
- Type-safety for events and no manual data converting between event layers
- Domain-driven analytics with ``DomainActivity``
- ``Middleware`` to transform/ignore events for reporters


## Analytics setup
Tentacles registers and manages ``AnalyticsReporter`` in a central entity. If we want to use a service like Firebase we need to create an implementation that conforms to ``AnalyticsReporting``:

```swift
class FirebaseReporter: AnalyticsReporting {
    func setup() {
        FirebaseApp.configure()
    }
    func report(event: RawAnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.attributes)
    }
    func addUserAttributes(_ attributes: AttributesValue) {
        attributes.forEach { (key, value) in
            Analytics.setUserProperty(value as? String, forName: key)
        }
    }
    func identify(with id: String) {
        Analytics.setUserID(id)
    }
    func logout() {
        Analytics.resetAnalyticsData()
    }
    func report(_ error: Error, filename: String, line: Int) {
    }
}
```
Registering reporters to Tentacles is easy:
```swift
let firebaseReporter = FirebaseReporter()
let tentacles = Tentacles()
tentacles.register(analyticsReporter: firebaseReporter)
```
In the case where we want to register a ``Middleware`` to affect events going to all of our reporters:
```swift
tentacles.register(.capitalisedAttributeKeys)
```
Or if we want to add a ``Middleware`` only affecting events for a specific reporter:
```swift
tentacles.register(analyticsReporter: firebaseReporter, middlewares: [.ignoreLifecycleEvents])
```

## Defining Events & Using Analytics
Creating analytic events and attributes is easy and type safe.
Defining Attributes:
```swift
struct UserContentSharingAttributes: TentaclesAttributes {
        enum Content: Encodable {
            case video
            case picture
            case story
        } 
        let content: Content
        let likedContent: Bool
        let commentedOnContent: Bool
    }
}
```
Adding your own ``AnalyticsEventCategory`` (Adding ``AnalyticsEventTrigger`` works the same way) :
```swift
enum MyAppAnalyticsEventCategory: String, AnalyticsEventCategory {
    case social
    var name: String {
        self.rawValue
    }
}
``` 

Defining ``AnalyticsEvent``:
```swift
typealias UserContentSharing = AnalyticsEvent<UserContentSharingAttributes>
extension UserContentSharing {
    init(name: String = "userContentSharing",
         category: AnalyticsEventCategory = MyAppAnalyticsEventCategory.social,
         trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
         otherAttributes: UserContentSharingAttributes) {
         self.init(category: category, trigger: trigger,
                   name: name, otherAttributes: otherAttributes)
    }
}
let userContentSharingAttributes = UserContentSharingAttributes(
content: .video, didUserLikeContent: true, didUserComment: false)
let userSharedContentEvent = UserContentSharing(otherAttributes: userContentSharingAttributes)
tentacles.track(userSharedContentEvent)
```
Defining and tracking a screen event:
```swift
typealias  AnalyticsScreenEvent = AnalyticsEvent<EmptyAttributes>
extension AnalyticsScreenEvent {
    init(name: String) {
        self.init(category: TentaclesEventCategory.screen,
                  trigger: TentaclesEventTrigger.screenDidAppear,
                  name: name,
                  otherAttributes: EmptyAttributes())
    }
}
let screenEvent = AnalyticsScreenEvent(name: "Home Screen")
tentacles.track(screenEvent)
```
Tracking an error is also possible:
```swift
tentacles.report(error)
```
Our Firebase analytics implementation does not support reporting errors, therefore this would not report anything. We would need to add a ``AnalyticsReporting`` implementation for a service like Crashlytics, it is the same process as described above for Firebase analytics.

In a case where no attributes need to be reported, ``EmptyAttributes`` must be used.
## Domain driven analytics

When developing an app, it is important to understand its domain. Yes, we want to track if a user logs in or clicks on a specific button, but what we are particular interested is how are users interacting with ``DomainActivity``s. ``DomainActivity``s are the core functionalities that should bring the most value to your users and are specific to your app and its domain. 

Tentacles offers a way to connect events that are related to the same ``DomainActivity``. 
A session (identified by UUID) is a period devoted to a particular ``DomainActivity``. The UUID identifying the session is automatically added and managed. This brings the advantage of further possibilities to analyse the data, as connections between the events can be derived. For example, as Tentacles tracks every status change of a ``DomainActivity`` with a timestamp it is easily possible to calculate the duration between when the ``DomainActivity`` started and completed. 
 
Let's use Youtube as an example, one of their ``DomainActivity``s a user can do on their platform is watching videos. The user experience of watching a video usually involves these steps:
```mermaid
graph LR
A(Open Video Page) --> B(Start Video)
B --> C(Pause Video)
B --> D(Complete Video)
B --> E(Cancel Video)
C --> B
```
These steps are the possible status of a session related to a ``DomainActivity``. When a ``DomainActivity`` is tracked with an ``DomainActivityAction``, the status of the session is updated and an event forwarded. Status changes that are allowed:

```mermaid
graph LR
A(Open) --> B(Start)
A --> E
B --> C(Pause)
C --> B
B --> D(Complete)
C --> E
B --> E(Cancel)
```
By reaching completed or canceled the session ends, and it gets deallocated. 
If a prohibited status update occurs, a non fatal error event is forwarded and the status is **not** updated. In cases where attributes are specific to a ``DomainActivity`` status, they can be added to  ``DomainActivityAction``. I.e. if a pause event needs the pausing point of the video, these attributes are then mapped to the derived analytics events. 

Multiple sessions with different ``DomainActivity``s can be managed. However, only one session for one particular ``DomainActivity``. A ``DomainActivity`` is equal if name and attributes match, not considering additional attributes that can be added by ``DomainActivityAction``. 

### Background & Foreground Applifecycle
When the app **will resign**, all active ``DomainActivity`` sessions are canceled and cached in memory in case the app enters foreground again. After app **did become active** again, all previous active sessions are reset and updated with a new identifier. For all previous active sessions, an open event is sent and then reset to the previous status that also triggers an event.

### Defining & Tracking ``DomainActivity``s 

```swift
struct VideoWatchingAttributes: TentaclesAttributes {
    videoName: String
    language: String
    duration: Double  // in seconds
}

typealias VideoWatching = DomainActivity<VideoWatchingAttributes>

let attributes = VideoWatchingAttributes.Attributes(
    videoName: "Learning Swift", language: "English", duration: 3240)
let videoWatching = VideoWatching(name: "videoWatching", attributes: attributes)
let action = DomainActivityAction(status: .open, trigger: .clicked)
tracker.track(for: videoWatching, with: action)
```

There are convenient static functions to build an action, e.g.:

```swift
tracker.track(for: watchingVideo, with: .start())
```

Adding action specific attributes:

```swift
struct WatchingVideoCompletionAttributes: TentaclesAttributes {
    let secondsSkipped: Double
    let userCommented: Bool
}

let completionAttributes = WatchingVideoCompletionAttributes(
    secondsSkipped: 300, userCommented: false)
tracker.track(for: videoWatching, with: .complete(trigger: .automatically, attributes: completionAttributes))
```

## Default attributes
CustomAttributes added via ``TentacleAttributes`` that share the same key as default attributes will overwrite default ones.

Attributes added to every event by default:

- sessionId - A generated random uuid, to let you search events from the same session.

Attributes added to events derived from ``DomainActivity``:

- trigger, activity triggering the event, specified by the app
- category - value: **domainActivity**
- status - status of the ``DomainActivity`` session, possible values: 
    - **opened, started, paused, canceled, completed**
- domainActivitySessionId - A generated random uuid, to let you group events from the same ``DomainActivity`` session.
- with every session status update a timestamp of the update is logged:
    -  i.e. opened: 123456.00, started: 1234567.00, completed: 1234354.00,
    -  if an update occurs more than once a count is added as suffix to the key:
        -  i.e. started_1, started_2

## Middleware
``Middleware``s are used to transform events and can be registered to a specific reporter or as a general ``Middleware`` to the ``AnalyticsRegister``. If added to a specific reporter, only events reported to this reporter will be transformed. 
Use Cases:

- Transforming Events
    - Editing existing attribute keys or values, i.e. capitalising the key or converting it in a different format.
    - Adding new attributes, i.e. calculate the active duration a user spent with a particular domain proposition.
- Skipping events, i.e. skip all events for a category for a specific reporter.

### Middlewares predefined:
- calculateDomainActivityDuration - calculates the duration between two status changes for a ``DomainActivity``. 
- skipEvent - skips events for a specific category or names
- capitalisedAttributeKeys - capitalises keys of attributes
