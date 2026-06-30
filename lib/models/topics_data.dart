// Curated by ChatGPT for John Colani's Senior Flutter interview prep.
class ConceptPoint {
  final String question;
  final String explanation;
  final String code;
  const ConceptPoint({required this.question, required this.explanation, required this.code});
}
class LevelSection {
  final String level;
  final String title;
  final List<ConceptPoint> points;
  const LevelSection({required this.level, required this.title, required this.points});
}
class Topic {
  final String id;
  final String label;
  final String icon;
  final int colorValue;
  final List<LevelSection> sections;
  const Topic({required this.id, required this.label, required this.icon, required this.colorValue, required this.sections});
}
final List<Topic> kTopics = [
  Topic(
    id: r"""dart""",
    label: r"""Dart Core""",
    icon: r"""🎯""",
    colorValue: 0xFF4F6AF0,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""Why Dart for Flutter?""",
            explanation: r"""Dart was chosen because Flutter needs a language that supports fast development and high-performance production builds. Dart gives Flutter JIT for Hot Reload during development and AOT compilation for optimized native release builds. It also has a modern type system, sound null safety, async programming, and a syntax that is easy to learn for developers coming from Java, Kotlin, Swift, or JavaScript.""",
            code: r"""Development: Dart VM + JIT → Hot Reload
Release: AOT → native machine code
Result: fast iteration + production performance""",
          ),
          ConceptPoint(
            question: r"""final vs const""",
            explanation: r"""final means the variable can be assigned only once, but the value can be created at runtime. const means compile-time constant. In Flutter, const widgets can help because Flutter can reuse the same immutable instance instead of creating a new one when nothing changes.""",
            code: r"""final now = DateTime.now(); // runtime
const padding = EdgeInsets.all(16); // compile time""",
          ),
          ConceptPoint(
            question: r"""Class vs Object""",
            explanation: r"""A class is a blueprint. An object is a runtime instance created from that blueprint. The class defines properties and methods; the object holds actual state in memory.""",
            code: r"""class Line {
  final Point start;
  final Point end;
  const Line(this.start, this.end);
}

final line = Line(Point(0, 0), Point(100, 0));""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Why Dart supports both JIT and AOT""",
            explanation: r"""Flutter has two different needs: during development, developers need fast feedback and Hot Reload, so Dart uses JIT. In production, users need fast startup and predictable performance, so Dart uses AOT. This dual compilation model is one of the reasons Dart fits Flutter better than many general-purpose languages.""",
            code: r"""Debug/Profile: JIT + VM services
Release: AOT snapshot → optimized native code""",
          ),
          ConceptPoint(
            question: r"""Reference vs Object""",
            explanation: r"""Variables that refer to objects usually hold references, not the entire object. The object lives on the heap, and the variable points to it. This avoids copying large objects and allows multiple variables to refer to the same object.""",
            code: r"""final a = Circle();
final b = a;
// a and b point to the same object""",
          ),
          ConceptPoint(
            question: r"""Equality vs identity""",
            explanation: r"""Identity asks whether two references point to the exact same object. Equality asks whether two objects should be considered equal by value. In Dart, == can be overridden, but identical(a, b) checks identity.""",
            code: r"""identical(a, b); // same object?
a == b;          // equal by value?""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""async""",
    label: r"""Async""",
    icon: r"""⏳""",
    colorValue: 0xFF3182CE,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""What is Future?""",
            explanation: r"""A Future represents a value or error that will be available later. It is used for one-time asynchronous work such as API calls, file reading, login, upload, or database queries. A Future is not automatically a new thread.""",
            code: r"""Future<User> loadUser() async {
  return api.fetchUser();
}""",
          ),
          ConceptPoint(
            question: r"""What does await do?""",
            explanation: r"""await pauses only the current async function until the Future completes. It does not freeze the whole app. While that function is waiting, Flutter can still handle gestures, animations, rendering, and other events.""",
            code: r"""final user = await loadUser();
// This line runs after loadUser completes.""",
          ),
          ConceptPoint(
            question: r"""Future vs Stream""",
            explanation: r"""Future returns one result once. Stream returns multiple values over time. Use Future for one-time operations and Stream for continuous updates such as chat messages, Firestore snapshots, WebSocket events, GPS, or sensors.""",
            code: r"""Future: API request → one response
Stream: chat → message after message""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Does Future create a thread?""",
            explanation: r"""No. Future is an abstraction for asynchronous completion. Many Futures are completed through the event loop on the main isolate. For CPU-heavy work, use an Isolate because heavy synchronous computation on the main isolate blocks the UI.""",
            code: r"""Future != Thread
CPU-heavy work → Isolate / compute""",
          ),
          ConceptPoint(
            question: r"""Event Loop""",
            explanation: r"""The Event Loop processes asynchronous events and completed Futures. It lets Dart continue running other work while waiting for I/O. This is why await does not freeze the entire Flutter app.""",
            code: r"""Event Queue → Event Loop → callback continues execution""",
          ),
          ConceptPoint(
            question: r"""Microtask Queue vs Event Queue""",
            explanation: r"""Microtasks run before the next event. They are useful for scheduling small work that must happen before control returns to the event queue. Overusing microtasks can starve normal events and hurt responsiveness.""",
            code: r"""scheduleMicrotask(() { /* runs before next event */ });""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""memory""",
    label: r"""Memory""",
    icon: r"""🧠""",
    colorValue: 0xFF805AD5,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""Stack vs Heap""",
            explanation: r"""The stack stores function frames, local variables, and references. The heap stores objects. When a function returns, its stack frame is removed, but heap objects remain as long as they are reachable.""",
            code: r"""Stack: local refs
Heap: actual objects""",
          ),
          ConceptPoint(
            question: r"""Garbage Collection""",
            explanation: r"""Dart automatically removes objects that are no longer reachable from the running program. Garbage collection manages memory, but it does not replace lifecycle cleanup such as dispose().""",
            code: r"""object has no reachable reference → eligible for GC""",
          ),
          ConceptPoint(
            question: r"""What is a memory leak?""",
            explanation: r"""A memory leak happens when something is no longer needed but is still referenced, so the garbage collector cannot reclaim it. Common Flutter leaks come from forgotten controllers, subscriptions, timers, or listeners.""",
            code: r"""late final StreamSubscription sub;
@override void dispose() {
  sub.cancel();
  super.dispose();
}""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Why dispose() matters""",
            explanation: r"""Garbage collection frees unreachable memory. dispose() releases active framework or native resources such as AnimationController, TextEditingController, FocusNode, ScrollController, StreamSubscription, and Timer. They solve different problems.""",
            code: r"""GC → memory
dispose() → active resources/listeners/native handles""",
          ),
          ConceptPoint(
            question: r"""Why retaining BuildContext can be dangerous""",
            explanation: r"""BuildContext is tied to an Element. If you store it and use it after the widget is removed, that context may no longer be valid. After async gaps, check mounted before using context or calling setState.""",
            code: r"""await save();
if (!context.mounted) return;
Navigator.pop(context);""",
          ),
          ConceptPoint(
            question: r"""4iCAD memory angle""",
            explanation: r"""In a CAD app, memory matters because drawings can contain thousands of entities and cached geometry. Keep drawing models lightweight, avoid unnecessary object churn during pointer movement, dispose controllers, and use DevTools to inspect memory growth.""",
            code: r"""Large drawing → many entities → watch allocation + GC pressure""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""flutter_arch""",
    label: r"""Flutter Architecture""",
    icon: r"""🏗️""",
    colorValue: 0xFF2B6CB0,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""Flutter layers""",
            explanation: r"""Flutter has three main layers: Framework, Engine, and Platform Embedder. The Framework is the Dart layer developers use. The Engine handles low-level rendering, text, images, accessibility, and runtime services. The Embedder connects Flutter to the operating system window, input, and platform lifecycle.""",
            code: r"""App Dart code
↓
Framework
↓
Engine
↓
Embedder
↓
OS / GPU""",
          ),
          ConceptPoint(
            question: r"""Framework vs Engine""",
            explanation: r"""The Framework describes and manages the UI through widgets, elements, render objects, gestures, animations, and painting instructions. The Engine rasterizes the scene and talks to the graphics backend. The Framework does not directly draw pixels to the screen.""",
            code: r"""Framework: build/layout/paint recording
Engine: rasterization + platform services""",
          ),
          ConceptPoint(
            question: r"""Is Flutter native?""",
            explanation: r"""Flutter produces native apps and native binaries, but it usually does not use native UI controls. Flutter draws its own UI inside a native app shell.""",
            code: r"""Native app shell + Flutter-rendered UI""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Why separate Framework and Engine?""",
            explanation: r"""They have different responsibilities and different portability needs. The Framework stays mostly platform-independent Dart code, while the Engine and Embedder handle lower-level rendering and platform integration. This lets Flutter support many platforms without rewriting the UI framework for each one.""",
            code: r"""Portable Framework + platform-aware Engine/Embedder""",
          ),
          ConceptPoint(
            question: r"""Why Platform Channels exist if Flutter has an Engine""",
            explanation: r"""The Engine renders UI, but operating systems own APIs such as Bluetooth, camera SDKs, NFC, printer APIs, battery, file system, or proprietary hardware. Platform Channels provide controlled communication from Dart to native code when platform-specific functionality is needed.""",
            code: r"""Dart → MethodChannel → Kotlin/Swift → OS SDK → result""",
          ),
          ConceptPoint(
            question: r"""Flutter vs React Native""",
            explanation: r"""Flutter renders its own widgets, while React Native maps UI to native components through a different architecture. Flutter can have more predictable pixel output and animation behavior because it owns the rendering pipeline. The trade-off is that native look and behavior must be intentionally implemented using Material, Cupertino, or adaptive design.""",
            code: r"""Flutter: own rendering
React Native: native component mapping""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""wer""",
    label: r"""Widget / Element / RenderObject""",
    icon: r"""🧩""",
    colorValue: 0xFF4F6AF0,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""What is a Widget?""",
            explanation: r"""A Widget is an immutable configuration object. It describes what part of the UI should look like, but it does not store mutable state, calculate layout, or draw pixels.""",
            code: r"""const Text("Hello") // configuration, not pixels""",
          ),
          ConceptPoint(
            question: r"""What is an Element?""",
            explanation: r"""An Element is the mutable runtime object that manages a Widget in the tree. It connects the Widget configuration to the live tree and helps Flutter decide what can be reused during rebuilds.""",
            code: r"""Widget creates/inflates → Element""",
          ),
          ConceptPoint(
            question: r"""What is a RenderObject?""",
            explanation: r"""A RenderObject performs layout, painting, and hit testing. It is the lower-level object that knows size, position, and how to record drawing commands.""",
            code: r"""RenderObject → layout + paint + hit test""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Why three objects instead of one?""",
            explanation: r"""Flutter separates Widget, Element, and RenderObject because they have different responsibilities and lifecycles. Widgets are cheap and recreated often. Elements are mutable and persist across rebuilds. RenderObjects are expensive and reused when possible. This separation keeps rebuilds fast.""",
            code: r"""Widget: cheap config
Element: live manager
RenderObject: expensive rendering""",
          ),
          ConceptPoint(
            question: r"""Why are Widgets immutable?""",
            explanation: r"""Flutter creates a new Widget configuration when UI changes instead of mutating the old one. This makes comparison predictable and allows existing Elements and RenderObjects to be reused when runtimeType and key match.""",
            code: r"""New Widget config → Element compares → reuse when possible""",
          ),
          ConceptPoint(
            question: r"""What happens after setState?""",
            explanation: r"""setState does not repaint the screen directly. It marks the related Element as dirty. In the next frame, Flutter rebuilds that subtree and then performs layout or paint only if needed.""",
            code: r"""setState → markNeedsBuild → build → layout? → paint?""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""lifecycle""",
    label: r"""Lifecycle""",
    icon: r"""🔁""",
    colorValue: 0xFFD69E2E,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""Why StatefulWidget?""",
            explanation: r"""StatefulWidget exists because some UI must change over time due to user actions, network responses, animations, timers, or streams. The Widget remains immutable, while mutable data lives inside the State object.""",
            code: r"""StatefulWidget → createState() → State""",
          ),
          ConceptPoint(
            question: r"""initState""",
            explanation: r"""initState runs once when the State object is created. Use it for one-time setup such as controllers, subscriptions, timers, and initial requests.""",
            code: r"""@override
void initState() {
  super.initState();
  controller = AnimationController(vsync: this);
}""",
          ),
          ConceptPoint(
            question: r"""dispose""",
            explanation: r"""dispose runs when the State is permanently removed. Use it to release controllers, focus nodes, subscriptions, timers, and listeners.""",
            code: r"""@override
void dispose() {
  controller.dispose();
  super.dispose();
}""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Why State is separate from StatefulWidget""",
            explanation: r"""Widgets are immutable and recreated frequently. If mutable state lived inside the Widget, it would be lost on rebuild. The State object survives rebuilds and is managed by the Element.""",
            code: r"""Widget changes often
State persists while Element is kept""",
          ),
          ConceptPoint(
            question: r"""didChangeDependencies vs initState""",
            explanation: r"""initState runs once before dependency registration is fully complete. didChangeDependencies runs after initState and whenever an inherited dependency changes. Use it when setup depends on Theme, Localizations, MediaQuery, or inherited/provider data.""",
            code: r"""initState: one-time setup
didChangeDependencies: inherited dependencies""",
          ),
          ConceptPoint(
            question: r"""mounted""",
            explanation: r"""mounted tells whether the State is still attached to the tree. After an async gap, check mounted before calling setState or using context, because the widget may have been disposed.""",
            code: r"""await load();
if (!mounted) return;
setState(() {});""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""context""",
    label: r"""BuildContext""",
    icon: r"""📍""",
    colorValue: 0xFF38A169,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""What is BuildContext?""",
            explanation: r"""BuildContext represents a widget location in the tree. More precisely, it is an interface implemented by Element. It gives safe access to tree-related operations such as Theme, Navigator, MediaQuery, and inherited data.""",
            code: r"""BuildContext ≈ safe view of Element""",
          ),
          ConceptPoint(
            question: r"""How Theme.of(context) works""",
            explanation: r"""Flutter starts from the current Element and searches upward through ancestors until it finds the nearest Theme inherited data.""",
            code: r"""Current Element ↑ Parent ↑ Theme""",
          ),
          ConceptPoint(
            question: r"""Wrong context errors""",
            explanation: r"""Errors like “No Navigator found” happen when the context belongs to a place in the tree where the required ancestor does not exist above it.""",
            code: r"""Navigator.of(context) needs Navigator above this context""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Why not expose Element directly?""",
            explanation: r"""Element is an internal implementation detail. BuildContext is a stable, safe public interface. It prevents accidental mutation of the tree and lets Flutter evolve Element internals without breaking app code.""",
            code: r"""Encapsulation: expose what developers need, hide internals""",
          ),
          ConceptPoint(
            question: r"""InheritedWidget""",
            explanation: r"""InheritedWidget shares immutable data with descendants and lets Flutter track which Elements depend on it. When it changes, Flutter rebuilds only registered dependents.""",
            code: r"""InheritedWidget → InheritedElement → dependents""",
          ),
          ConceptPoint(
            question: r"""Provider vs Riverpod context""",
            explanation: r"""Provider is built on InheritedWidget and depends on BuildContext lookup. Riverpod separates provider lookup from the widget tree, improving testability and making state available outside BuildContext while still integrating with widget rebuilds.""",
            code: r"""Provider.of(context) vs ref.watch(provider)""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""rendering""",
    label: r"""Rendering Pipeline""",
    icon: r"""🎨""",
    colorValue: 0xFFE53E3E,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""Rendering Pipeline""",
            explanation: r"""The rendering pipeline is the path from state change to pixels on screen: build, layout, paint, compositing, engine, GPU.""",
            code: r"""State → Build → Layout → Paint → Layers → Engine → GPU""",
          ),
          ConceptPoint(
            question: r"""Layout Phase""",
            explanation: r"""During layout, constraints flow from parent to child. Each RenderObject chooses a size within those constraints and reports it back to the parent.""",
            code: r"""Parent constraints ↓ Child size ↑""",
          ),
          ConceptPoint(
            question: r"""Paint Phase""",
            explanation: r"""During paint, RenderObjects record drawing commands such as text, paths, images, rectangles, and shadows. Paint does not directly draw pixels to the screen.""",
            code: r"""Canvas commands → layer/scene""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Layer Tree and Compositing""",
            explanation: r"""Layers organize painted content for efficient compositing, transforms, clipping, opacity, and partial repainting. SceneBuilder turns the layer tree into a scene that the Engine can render.""",
            code: r"""RenderObjects → Layers → SceneBuilder → Scene""",
          ),
          ConceptPoint(
            question: r"""Skia vs Impeller""",
            explanation: r"""Skia is Flutter’s long-used graphics library. Impeller is Flutter’s newer rendering backend designed for more predictable performance and reduced shader compilation jank, especially on platforms where it is enabled.""",
            code: r"""Framework records scene → Engine rasterizes using Skia or Impeller""",
          ),
          ConceptPoint(
            question: r"""RepaintBoundary""",
            explanation: r"""RepaintBoundary isolates repaint work into a separate layer. It can reduce unnecessary repainting, but it does not stop widget rebuilds and can hurt performance if overused.""",
            code: r"""RepaintBoundary: repaint isolation, not rebuild isolation""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""state""",
    label: r"""State Management""",
    icon: r"""🧭""",
    colorValue: 0xFFDD6B20,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""What is State?""",
            explanation: r"""State is data that can change over time and affect what the UI displays. If changing data should update UI, it is state.""",
            code: r"""counter, auth user, selected tool, drawing entities""",
          ),
          ConceptPoint(
            question: r"""Why State Management exists""",
            explanation: r"""As apps grow, passing state manually through constructors becomes hard. State management provides a predictable way to store, update, and expose state to the UI.""",
            code: r"""State holder → UI watches → rebuild affected parts""",
          ),
          ConceptPoint(
            question: r"""ChangeNotifier""",
            explanation: r"""ChangeNotifier is a simple observable object. It stores mutable state and calls notifyListeners() when listeners should rebuild.""",
            code: r"""class Counter extends ChangeNotifier {
  int value = 0;
  void inc() { value++; notifyListeners(); }
}""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Provider""",
            explanation: r"""Provider is built on InheritedWidget and gives a cleaner way to expose objects down the tree. It is simple and effective, but still tied to BuildContext lookup.""",
            code: r"""Provider → InheritedWidget + listen/read helpers""",
          ),
          ConceptPoint(
            question: r"""Riverpod""",
            explanation: r"""Riverpod moves dependency management outside the widget tree. Providers are declared as independent units, read through ref, and are easier to test, override, compose, and use outside UI code.""",
            code: r"""final userProvider = FutureProvider((ref) => repo.getUser());""",
          ),
          ConceptPoint(
            question: r"""BLoC trade-off""",
            explanation: r"""BLoC separates events, business logic, and states clearly. It is strong for complex flows and teams, but can be verbose compared with Riverpod or simpler notifiers.""",
            code: r"""Event → Bloc → State → UI""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""app_arch""",
    label: r"""Clean Architecture""",
    icon: r"""🏛️""",
    colorValue: 0xFF667EEA,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""Clean Architecture""",
            explanation: r"""Clean Architecture separates business rules from UI and external systems. The goal is maintainability, testability, and lower coupling.""",
            code: r"""Presentation → Application/UseCases → Domain → Data""",
          ),
          ConceptPoint(
            question: r"""Repository Pattern""",
            explanation: r"""A repository hides where data comes from. The UI asks for data through an interface instead of depending directly on Firebase, REST, local database, or cache.""",
            code: r"""UI → Repository interface → Firebase/REST/local implementation""",
          ),
          ConceptPoint(
            question: r"""DTO vs Entity""",
            explanation: r"""DTO is shaped for transport or storage. Entity is shaped for business meaning. Keeping them separate prevents backend or database details from leaking into domain logic.""",
            code: r"""UserDto.fromJson(json) → User entity""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Dependency Inversion""",
            explanation: r"""High-level business logic should depend on abstractions, not concrete Firebase/HTTP classes. This makes code easier to test and replace.""",
            code: r"""Domain depends on abstract repository
Data implements repository""",
          ),
          ConceptPoint(
            question: r"""Feature-first architecture""",
            explanation: r"""Feature-first groups code by product capability instead of technical layer only. In large Flutter apps, this reduces cross-feature coupling and makes ownership clearer.""",
            code: r"""features/auth, features/cad_workspace, features/chat""",
          ),
          ConceptPoint(
            question: r"""Trade-offs""",
            explanation: r"""Clean Architecture improves maintainability but adds ceremony. For small apps it may be overkill; for complex apps like multi-role workflow platforms or CAD tools, the separation pays off.""",
            code: r"""Small app: keep simple
Large app: separate concerns""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""firebase""",
    label: r"""Firebase""",
    icon: r"""🔥""",
    colorValue: 0xFFE53E3E,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""Firebase Authentication""",
            explanation: r"""Firebase Auth manages user identity through email/password, phone, OAuth, and custom tokens. In Flutter, auth state is often exposed as a Stream so the UI can react when users sign in or out.""",
            code: r"""FirebaseAuth.instance.authStateChanges()""",
          ),
          ConceptPoint(
            question: r"""Firestore""",
            explanation: r"""Firestore is a NoSQL document database. It supports real-time listeners, offline cache, security rules, indexes, and scalable document/collection structures.""",
            code: r"""collection("contracts").doc(id).snapshots()""",
          ),
          ConceptPoint(
            question: r"""FCM""",
            explanation: r"""Firebase Cloud Messaging sends push notifications. A common pattern is Firestore write → Cloud Function → FCM notification to target users.""",
            code: r"""New message → Cloud Function → FCM""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Security Rules""",
            explanation: r"""Security Rules are not optional. Client code is untrusted. Rules must enforce tenant, role, ownership, and document-level permissions on the server side.""",
            code: r"""allow read: if request.auth.uid == resource.data.ownerId;""",
          ),
          ConceptPoint(
            question: r"""Offline Cache""",
            explanation: r"""Firestore can cache data locally and sync changes when the network returns. This improves UX but requires careful conflict handling, pending write indicators, and security-aware design.""",
            code: r"""Offline write → local view updates → server sync later""",
          ),
          ConceptPoint(
            question: r"""Cloud Functions""",
            explanation: r"""Cloud Functions are useful for trusted server-side work: notifications, denormalization, validation, payment webhooks, and workflows that should not live in the client.""",
            code: r"""Client writes request → Function validates → writes result""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""realtime""",
    label: r"""Realtime""",
    icon: r"""📡""",
    colorValue: 0xFF00A3C4,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""WebSocket""",
            explanation: r"""WebSocket is a persistent full-duplex connection between client and server. Unlike REST, the server can push messages to the client without the client polling repeatedly.""",
            code: r"""Client ⇄ persistent connection ⇄ Server""",
          ),
          ConceptPoint(
            question: r"""Why not REST?""",
            explanation: r"""REST is great for request/response. WebSocket is better when updates are frequent, low-latency, and server-driven, such as chat, live tracking, multiplayer state, or device telemetry.""",
            code: r"""REST: ask each time
WebSocket: server pushes""",
          ),
          ConceptPoint(
            question: r"""Stream in Flutter""",
            explanation: r"""WebSocket messages are naturally represented as a Stream in Dart because values arrive over time.""",
            code: r"""webSocket.stream.listen((message) { ... });""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Handshake and Upgrade""",
            explanation: r"""WebSocket starts as an HTTP request and upgrades the connection to the WebSocket protocol. After that, client and server exchange frames over a persistent connection.""",
            code: r"""HTTP Upgrade → WebSocket frames""",
          ),
          ConceptPoint(
            question: r"""Heartbeat and Reconnection""",
            explanation: r"""Production WebSocket systems need ping/pong or heartbeat, reconnection strategy, exponential backoff, auth refresh, and duplicate-message handling.""",
            code: r"""disconnect → backoff → reconnect → resync""",
          ),
          ConceptPoint(
            question: r"""WebRTC""",
            explanation: r"""WebRTC is for peer-to-peer audio/video/data use cases and involves signaling, ICE candidates, STUN/TURN, and media tracks. WebSocket is often used only for signaling in WebRTC.""",
            code: r"""WebSocket signaling + WebRTC media/data path""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""native""",
    label: r"""Native Integration""",
    icon: r"""🔌""",
    colorValue: 0xFF9F7AEA,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""MethodChannel""",
            explanation: r"""MethodChannel is used for one-time request/response calls from Flutter to native code. Flutter sends a method name and arguments; native code performs platform-specific work and returns a result.""",
            code: r"""Dart invokeMethod → Kotlin/Swift handler → result""",
          ),
          ConceptPoint(
            question: r"""EventChannel""",
            explanation: r"""EventChannel is used when native code must send continuous events to Flutter, such as sensor updates, location changes, or hardware status.""",
            code: r"""Native stream → EventChannel → Dart Stream""",
          ),
          ConceptPoint(
            question: r"""Plugin Architecture""",
            explanation: r"""A Flutter plugin wraps platform-specific code behind a Dart API so the app can call native features while keeping most business logic in Flutter.""",
            code: r"""Dart API + Android implementation + iOS implementation""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""MethodChannel internals""",
            explanation: r"""MethodChannel uses BinaryMessenger and a codec, commonly StandardMethodCodec, to serialize method calls and results between Dart and the platform side.""",
            code: r"""MethodChannel → BinaryMessenger → Codec → platform handler""",
          ),
          ConceptPoint(
            question: r"""MethodChannel vs FFI""",
            explanation: r"""Use MethodChannel for platform SDK APIs in Kotlin/Swift. Use FFI when calling C-compatible native libraries directly. FFI is better for performance-critical native libraries but not for normal Android/iOS SDK calls.""",
            code: r"""Platform SDK → MethodChannel
C library → FFI""",
          ),
          ConceptPoint(
            question: r"""Phillips-style answer""",
            explanation: r"""If an off-the-shelf camera plugin no longer supports custom hardware, a custom plugin can expose the required native SDK calls to Flutter while keeping UI and business flow in Dart.""",
            code: r"""Flutter UI → custom plugin → native camera SDK → hardware""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""performance""",
    label: r"""Performance""",
    icon: r"""⚡""",
    colorValue: 0xFFF6AD55,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""Frame budget""",
            explanation: r"""For 60 FPS, Flutter should complete build, layout, paint, compositing, and rasterization within about 16.67ms. For 120 FPS, the budget is about 8.33ms.""",
            code: r"""60 FPS → 16.67ms per frame""",
          ),
          ConceptPoint(
            question: r"""Jank""",
            explanation: r"""Jank happens when a frame takes too long and the app drops frames. Causes include heavy build methods, expensive layout, too much repainting, large image decoding, shader compilation, or CPU work on the main isolate.""",
            code: r"""Long frame → dropped frame → visible stutter""",
          ),
          ConceptPoint(
            question: r"""DevTools""",
            explanation: r"""Flutter DevTools helps inspect performance, memory, rebuilds, frame timings, CPU profile, and widget tree behavior.""",
            code: r"""Use Performance + Memory tabs""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Build vs Layout vs Paint optimization""",
            explanation: r"""Do not treat rebuild, layout, and repaint as the same. Optimize the actual bottleneck. A rebuild may be cheap; layout or paint may be expensive depending on the UI.""",
            code: r"""Measure first → optimize correct phase""",
          ),
          ConceptPoint(
            question: r"""CustomPainter""",
            explanation: r"""CustomPainter is powerful for canvas-heavy UI like CAD, charts, diagrams, and drawing apps. Keep shouldRepaint accurate, cache expensive calculations, and avoid redrawing static content unnecessarily.""",
            code: r"""bool shouldRepaint(old) => old.modelVersion != modelVersion;""",
          ),
          ConceptPoint(
            question: r"""Spatial Index""",
            explanation: r"""For a CAD canvas, scanning every entity for hit testing or snapping does not scale. A spatial index helps query nearby entities instead of checking the entire drawing.""",
            code: r"""Pointer location → spatial query → nearby candidates only""",
          ),
        ],
      ),
    ],
  ),

  Topic(
    id: r"""plugin""",
    label: r"""Desktop Plugin""",
    icon: r"""🪟""",
    colorValue: 0xFFECC94B,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""How Sticker Transparency Works""",
        points: [
          ConceptPoint(
            question: r"""Did this feature use a plugin?""",
            explanation: r"""Yes. The desktop sticker transparency feature uses the window_manager plugin. Flutter can draw the app UI, but changing the native desktop window itself requires platform-level window APIs. The plugin gives Flutter safe access to native window behavior on macOS, Windows, and Linux.""",
            code: r"""pubspec.yaml
window_manager: ^0.4.3""",
          ),
          ConceptPoint(
            question: r"""Why is a plugin needed for transparency?""",
            explanation: r"""Opacity of the entire app window is not a normal Flutter widget property. Flutter can make widgets transparent inside the app, but the real desktop window belongs to the operating system. To make the whole window behave like a floating sticker, we need a plugin that talks to the native window manager.""",
            code: r"""Flutter UI opacity ≠ native window opacity
Native desktop window opacity → window_manager""",
          ),
          ConceptPoint(
            question: r"""What does the sticker button do?""",
            explanation: r"""The sticker button toggles desktop sticker mode. When enabled, the app sets the native window opacity to the selected slider value and keeps the window always on top. When disabled, the app restores full opacity and turns off always-on-top behavior.""",
            code: r"""Sticker ON  → setOpacity(value) + setAlwaysOnTop(true)
Sticker OFF → setOpacity(1.0) + setAlwaysOnTop(false)""",
          ),
          ConceptPoint(
            question: r"""Why is it desktop-only?""",
            explanation: r"""macOS, Windows, and Linux allow desktop apps to control native window behavior. Mobile and web platforms do not expose the same type of desktop window APIs, so the app hides the sticker controls on unsupported platforms.""",
            code: r"""Supported: macOS, Windows, Linux
Hidden fallback: iOS, Android, Web""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Implementation Details""",
        points: [
          ConceptPoint(
            question: r"""How is the plugin isolated from mobile and web?""",
            explanation: r"""The project uses conditional imports. The public WindowTransparencyService has the same API everywhere, but desktop builds import the real implementation and mobile/web builds import a stub. This prevents unsupported desktop code from breaking iOS, Android, or web compilation.""",
            code: r"""window_transparency.dart
  if (dart.library.io) window_transparency_desktop.dart
  otherwise window_transparency_stub.dart""",
          ),
          ConceptPoint(
            question: r"""What does initialize() do?""",
            explanation: r"""On desktop, initialize() prepares the native window system before the app starts. It calls windowManager.ensureInitialized() and sets the initial WindowOptions, including a transparent background. This must happen before runApp so the desktop window is ready when Flutter renders the UI.""",
            code: r"""await WindowTransparencyService.initialize();
runApp(const FlutterInterviewPrepApp());""",
          ),
          ConceptPoint(
            question: r"""How does the opacity slider work?""",
            explanation: r"""The slider stores a value between 0.35 and 1.0. When sticker mode is active, every slider change calls windowManager.setOpacity(value). The slider changes the real native window opacity, not just a Flutter widget's opacity.""",
            code: r"""onChanged: (value) {
  windowOpacity = value;
  if (stickerMode) setOpacity(value);
}""",
          ),
          ConceptPoint(
            question: r"""What is the interview explanation for this feature?""",
            explanation: r"""A senior-level answer is: I kept the feature platform-safe by isolating native desktop behavior behind a small service. The Flutter UI owns the button and slider state, while window_manager handles OS-level window opacity and always-on-top behavior. Unsupported platforms use a stub implementation, so the same project can still compile across all six platforms.""",
            code: r"""UI state → WindowTransparencyService → window_manager → native window APIs""",
          ),
        ],
      ),
    ],
  ),
  Topic(
    id: r"""4icad""",
    label: r"""4iCAD Story""",
    icon: r"""📐""",
    colorValue: 0xFF48BB78,
    sections: [
      LevelSection(
        level: r"""mid""",
        title: r"""Interview Core""",
        points: [
          ConceptPoint(
            question: r"""How to present 4iCAD""",
            explanation: r"""Present 4iCAD as a cross-platform CAD application where the hard part is not only UI but geometry, commands, drawing performance, selection, DXF workflows, and mobile-friendly interaction design.""",
            code: r"""Problem → architecture → performance → trade-offs""",
          ),
          ConceptPoint(
            question: r"""Why Flutter for 4iCAD?""",
            explanation: r"""Flutter gives one shared codebase for iOS, Android, web, Windows, macOS, and Linux. The CAD domain logic, geometry, command system, and most UI can be shared, while platform-specific file/device behavior can be isolated.""",
            code: r"""Shared CAD logic + adaptive UI + platform-specific integrations""",
          ),
          ConceptPoint(
            question: r"""Why CustomPainter?""",
            explanation: r"""CAD drawing requires precise vector rendering, zoom, pan, selection overlays, and custom geometry. CustomPainter gives low-level canvas control beyond normal widgets.""",
            code: r"""CustomPainter → lines, arcs, dimensions, selection""",
          ),
        ],
      ),
      LevelSection(
        level: r"""senior""",
        title: r"""Senior Depth""",
        points: [
          ConceptPoint(
            question: r"""Performance risk in CAD""",
            explanation: r"""A normal CRUD app may rebuild a few widgets. A CAD app may render thousands of entities and respond to pointer movement continuously. That requires careful repaint control, cached geometry, spatial queries, and separation between static drawing layers and interactive overlays.""",
            code: r"""Static drawing cache + interactive overlay + spatial index""",
          ),
          ConceptPoint(
            question: r"""How to be honest about AI-assisted coding""",
            explanation: r"""A strong answer is: I drove the product and architecture decisions, defined the problems, reviewed and tested AI-assisted implementations, debugged issues, and I am deepening my understanding of the lower-level details. Do not claim you hand-wrote every line if asked directly.""",
            code: r"""Own the decisions. Be honest about implementation assistance.""",
          ),
          ConceptPoint(
            question: r"""CEO-ready 4iCAD summary""",
            explanation: r"""4iCAD is my strongest project because it combines product design, CAD domain knowledge, Flutter rendering, performance optimization, and cross-platform architecture. It shows that I can think beyond screens and solve complex workflow problems.""",
            code: r"""Lead story: domain + product + engineering""",
          ),
        ],
      ),
    ],
  ),
];
