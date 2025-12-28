# framework

- this module is a simple module loader, used in [pillarworks](https://github.com/pillarworks-rbx).
- this is a **shared** module. this will work on the client _and_ server.

## usage

```lua
local framework = require(path.to.framework)
local singletons = {}

framework.run({
  lifecycles = { "start", "stop" },
  singletons = singletons,
})
```

## example singleton

```lua
local singleton = {}

singleton.identifier = "example_singleton"

export type self = typeof(singleton)

function singleton.start(self: self)
  print("singleton started")
end

function singleton.stop(self: self)
  print("singleton stopped")
end

return singleton
```
