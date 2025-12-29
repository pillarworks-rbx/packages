# group

- this module is a simple memory management module, used in [pillarworks](https://github.com/pillarworks-rbx).
- this is a **shared** module. this will work on the client *and* server.
- all credits goes to [athar_adv](https://devforum.roblox.com/u/athar_adv) for the original module that you can find [here](https://devforum.roblox.com/t/110-itemgroup-type-safe-and-lightweight-cleanup-module/4151183).

## usage
```lua
local group = require(path.to.group)
local created_group = group.create()

created_group:add(function()
  print("this will be printed upon cleanup!")
end)

created_group:add(task.spawn(function()
  while task.wait(1) do
    print("this will be printed every second!")
  end
end))

task.wait(5)

created_group:clean()
```