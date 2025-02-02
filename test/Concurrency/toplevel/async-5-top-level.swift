// RUN: %target-swift-frontend -typecheck -disable-availability-checking -enable-experimental-async-top-level -swift-version 5 %s -verify

// enable-experimental-async-top-level is passed and an await is used in the
// top-level, so the top-level code is a concurrent context. Variables are
// declared with `@_predatesConcurrency @MainActor`, and the top-level is run on
// the main actor.

var a = 10 // expected-note {{mutation of this var is only permitted within the actor}}

func nonIsolatedSync() {
    // Okay because `a` is '@_predatesConcurrency'
    print(a)
    a = a + 10
}

@MainActor
func isolatedSync() {
    print(a)
    a = a + 10
}

func nonIsolatedAsync() async {
    await print(a)
    a = a + 10
    // expected-error@-1:5 {{var 'a' isolated to global actor 'MainActor' can not be mutated from this context}}
    // expected-error@-2:9 {{expression is 'async' but is not marked with 'await'}}{{9-9=await }}
    // expected-note@-3:9 {{property access is 'async'}}
}

@MainActor
func isolatedAsync() async {
    print(a)
    a = a + 10
}

nonIsolatedSync()
isolatedSync()
await nonIsolatedAsync()
await isolatedAsync()

print(a)

if a > 10 {
    nonIsolatedSync()
    isolatedSync()
    await nonIsolatedAsync()
    await isolatedAsync()

    print(a)
}
