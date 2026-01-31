# framework

- this module is a simple module loader, used in [pillarworks](https://github.com/pillarworks-rbx).
- this is a **shared** module. this will work on the client *and* server.
- this is a pure luau module. for convenience, it is only published under the roblox target, but you can vendor it in. however, you must provide your own `task` implementation if you are using it outside of roblox.

## usage

```lua
local framework = require(path.to.framework)
local singletons = {}

framework.run({
  lifecycles = { "start", "stop" },
  singletons = singletons,
})

game:BindToClose(function()
	framework.utils.run_lifecycle(config, "stop", true)
end)
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
