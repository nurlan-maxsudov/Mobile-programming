# Lab 9: One Cart, Four Ways

## Scope and sample code

One Flutter app with four pages. The Product, catalog, CartLine, list extension,
fake checkout API and page wiring follow the lab samples. The shared UI receives
values and callbacks. All six required subtasks are implemented in each style.
No optional stretch goals are included. Git commits, tags and pushing are left
to the student, as requested.

`CartState` uses immutable lists and hand-written value equality. Empty strings
mean no coupon, coupon error, order id or checkout error; `copyWith` can clear
these by receiving `''`. No code generation or extra architecture is used.

## Part 1: shared code

1. Why immutable CartLine and copyWith? Each edit creates a new value without
   changing an earlier state. This makes equality checks and undo reliable.
   setState can rebuild after in-place mutation, but that would corrupt history.
   Riverpod/Cubit/Bloc can suppress notification when assigned the same value.
2. Why callbacks in CartBody? It can render all four versions without importing
   a provider or Bloc. Its TextEditingController only owns the unsubmitted draft.
   The applied coupon and the cart belong to the state holder.

## Part 2: setState

- T3: Total is derived from quantities, prices and the coupon. Storing it would
  require updating it after every add, quantity change, coupon change and undo.
  A missed update would show an incorrect total. Getters keep one source of truth.
- T4: Without `if (!mounted) return` after awaiting checkout, leaving the page
  could cause setState after dispose and using an invalid BuildContext.
- A second page cannot read this private State object directly. Lift the cart
  into a common ancestor and pass values/callbacks, or use a shared state holder.
- T5: `_history` lives in the State object. A normal hot reload preserves that
  object and history. Hot restart creates fresh state. Popping the page disposes
  it, so returning starts with an empty cart and empty history.
- T6: The widget test must pump a MaterialApp, find the product and field, tap,
  enter text and pump frames before reading the total. Most lines arrange UI
  interactions; the actual cart result needs one assertion.

## Part 3: Riverpod

- `ref.read` obtains the notifier to call methods, obtains the injected checkout
  API inside the notifier, and reads the current state in the status listener.
  The summary also reads the full state after its selected values trigger build.
- `ref.watch(cartProvider)` keeps the page current. `ref.watch(canUndoProvider)`
  keeps Undo current. The summary watches `select((s) => s.total)` and the other
  displayed summary values. The derived canUndo provider watches cart state.
- Value equality means applying SAVE10 twice produces no second notification.
  `ref.listen` prints actual state changes for inspection.
- The summary has its own ConsumerWidget. It rebuilds for displayed values, not
  for checkout status, coupon errors, or typing a draft. setState rebuilds the
  owning page when its cart changes. Typing is local to the shared TextField in
  all styles and does not itself mutate any cart.
- Auto-disposal destroys the provider state and private history once the page
  has no listeners. Returning starts a new cart. Unit tests keep a subscription
  open so auto-disposal does not destroy the provider in the middle of a test.
- Lifecycle correction to the PDF: before autoDispose, a provider owned by the
  root scope can outlive the page, so it needs no widget-mounted guard. Once
  autoDispose is enabled, Riverpod 3 requires `if (!ref.mounted) return` after
  the await. It is the provider lifecycle, not a widget's lifecycle, being tested.
  Source: https://riverpod.dev/docs/whats_new

## Part 4: Cubit

- The same coupon twice creates equal states. `emit` suppresses the second
  change, so `onChange` does not print again. The test verifies this sequence.
- The summary uses `BlocBuilder.buildWhen` (the alternative allowed in T3) to
  rebuild only when its displayed values differ. The same small generic widget
  is reused with CartBloc. Checking every displayed value avoids stale item
  counts in the unusual case where different carts have the same total.
- CheckoutApi is constructor-injected. After awaiting, `isClosed` prevents an
  emit on a Cubit that BlocProvider closed when the page was popped.
- `_history` remains private, but `canUndo` is part of CartState. A plain getter
  on the Cubit does not notify the Undo button; emitting state does.
- Putting BlocProvider inside CartBody would put the page's context above the
  provider. The page could not read it or use it to supply CartBody's arguments.
  It would also tie cart ownership to a UI component meant to be reusable.

| Cubit/Bloc | Riverpod equivalent |
| --- | --- |
| BlocProvider | ProviderScope/container plus a provider definition |
| BlocBuilder | ConsumerWidget and ref.watch |
| BlocListener | ref.listen |
| context.read | ref.read |
| buildWhen / BlocSelector | ref.watch(provider.select(...)) |

## Part 5: Bloc

- Every user intention has an event. The observer's transition log includes the
  event as well as the old and new states; Cubit's onChange has no event.
- Add, remove, change quantity and apply coupon are undoable when they actually
  change the state. Undo consumes history instead of adding another entry.
- Submitting and failure status changes do not add history. Successful checkout
  saves the pre-checkout cart because clearing the cart is a data mutation.
  Undo restores the local cart snapshot; this fake API has no real payment to reverse.
- Bloc keeps history in CartState. Each snapshot has its own history stripped,
  avoiding nested histories. `canUndo` changes together with that list.
- `droppable()` ignores further checkout events until the running checkout
  handler finishes. The test dispatches two events and verifies one API call
  and one submitting state. The UI also disables Checkout while submitting.
- A naive Cubit method can be called again during its await. Here setState,
  Riverpod and Cubit explicitly guard against submitting a second time.
- `emit.isDone` prevents emitting from a handler cancelled by Bloc closure.
- Event objects are useful for named transitions and declarative concurrency
  policies such as duplicate-checkout suppression. For a simple quantity
  increment, they are extra boilerplate compared with a Cubit method.
- Of these implementations, Bloc supports declarative duplicate dropping with
  its event transformer. The others use an explicit submitting check.
- Correction to the PDF: Bloc handlers are concurrent by default, not
  sequential. The synchronous cart edits complete immediately; checkout uses
  an explicit droppable transformer. Sources:
  https://github.com/felangel/bloc/blob/master/packages/bloc/lib/src/bloc.dart
  and https://pub.dev/packages/bloc_concurrency

## Five checkpoint answers

1. **State lifetime:** setState lives in the page State and dies on dispose;
   Riverpod lives in the provider container but this autoDispose provider dies
   after losing listeners; Cubit and Bloc live in page-scoped BlocProviders and
   are closed when the page is disposed.
2. **Mutation API:** Notifier exposes methods that assign `state`; Cubit exposes
   methods that call `emit`; Bloc exposes `add(event)`. setState has no separate
   state-holder public API: page callbacks mutate its fields inside setState.
3. **Subscriptions:** watch maps to BlocBuilder, read to context.read, and listen
   to BlocListener. setState schedules a rebuild of its owning widget, which
   passes updated values down through constructors.
4. **Equality:** suppressing equal states avoids needless notifications and
   rebuilds. Keep state immutable (including its lists), and implement matching
   value-based `==` and `hashCode` for the state and nested values.
5. **Async guards:** setState uses mounted; Riverpod originally needed no widget
   guard while its provider stayed alive, but our autoDispose Riverpod 3 version
   uses ref.mounted; Cubit checks isClosed; Bloc checks emit.isDone. These match
   the different objects that can be disposed or cancelled while awaiting.

## Undo and interaction choices

- Invalid coupons clear the discount and display a red error. Undo restores the
  earlier applied coupon. Coupon text is a draft and is not an undo snapshot.
- While checkout is pending, cart edits, Undo and Checkout are disabled. This
  keeps the submitted total and displayed cart consistent.
- Quantity zero removes the line. A no-op does not consume an undo step.
- The fake checkout uses the final discounted total: values over 500 fail with
  Card declined after 1.5 seconds; success returns an order id and clears the cart.

## Validation and demonstration

- `flutter analyze`: clean.
- `flutter test`: 21 passing tests, including the eight required tests.
- Extra checks cover matching flows across all four pages, invalid coupons,
  successful checkout, undo, duplicate coupon equality and async disposal.
- Run `flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8080`
  and open http://127.0.0.1:8080, or use a configured mobile/desktop device.
- Native macOS execution requires Xcode, which is not installed on this machine.
- For a recording under 45 seconds, repeat in setState and Bloc: add Monitor,
  press its + button twice, apply SAVE10 (537.30), checkout (Card declined),
  then Undo (597.00, since the coupon was the last mutation).
- Commits, tags p1-shared through p5-bloc, and pushing are left to the student.

## Comparison table

Counts below are physical lines after dart format, including imports, comments
and blank lines. T1-T5 counts include each style's page/state-holder/event files.
Shared model, service, UI and main are counted separately instead of charged four
times. Test counts refer to the named style-specific test file. The common
cart_pages_test.dart supplies eight additional cross-style UI/lifecycle tests.

| Style | T1-T5 lines | Test lines | Source + test files | Strength | Weakness |
| --- | ---: | ---: | ---: | --- | --- |
| setState | 99 | 20 | 1 + 1 | Few concepts; direct Flutter code | Page-bound state; UI-dependent testing |
| Riverpod | 125 | 84 | 2 + 1 | Selective subscriptions and easy dependency overrides | Provider lifecycle needs attention |
| Cubit | 133 | 79 | 2 + 1 | Simple methods and emitted-state tests | Duplicate async work needs an explicit guard |
| Bloc | 199 | 97 | 3 + 1 | Named events and declarative checkout concurrency | More event and handler boilerplate |

Shared source: 432 lines in 4 files. Common UI tests: 94 lines in one file.
The reusable BlocCartSummary widget is included in the Cubit page count and imported by the Bloc page.
