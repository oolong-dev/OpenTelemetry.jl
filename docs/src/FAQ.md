# FAQ

## Method overwritten warning

When building `OpenTelemetrySDK` for the first time, you'll see the following warning message:

```
WARNING: Method definition schedule(Task) in module Base at task.jl:639 overwritten in module OpenTelemetrySDK at /home/tj/workspace/git/OpenTelemetry.jl/src/sdk/src/patch.jl:6.
** incremental compilation may be fatally broken for this module **
```

Unfortunately, this is unavoidable and shouldn't be a problem in most cases (unless you also overwritten the `schedule(Task)` method...). See more discussions in [#32](https://github.com/oolong-dev/OpenTelemetry.jl/issues/32).

