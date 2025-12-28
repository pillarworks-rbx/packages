# stack

- this module is the implementation of a "stack" data structure, used in [pillarworks](https://github.com/pillarworks-rbx).
- this is a **shared** module. this will work on the client *and* server.

## usage
```lua
local stack = require(path.to.stack)

local new_stack = stack.new()

new_stack:push(1)
new_stack:push(2)
new_stack:push(3)

print(new_stack:pop()) -- prints 3
print(new_stack:pop()) -- prints 2
print(new_stack:pop()) -- prints 1

new_stack:push(4)

print(new_stack:peek()) -- prints 4
print(new_stack:is_empty()) -- prints false

new_stack:clear()

print(new_stack:is_empty()) -- prints true
```