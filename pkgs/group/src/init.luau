--!optimize 2
--!native

local types = {
	"Instance",
	"function",
	"thread",
	"RBXScriptConnection",
}

export type disconnect = () -> ()
export type item = Instance | (() -> ()) | thread | RBXScriptConnection

local create

export type item_group = {
	add: (item_group, item: item) -> disconnect,
	clean: (item_group) -> (),
	extend: (item_group) -> item_group,

	items: { item },
	cleanup_handler: (item) -> (),
	children: { item_group },

	_cleaned: boolean,
}

function add(self: item_group, item: item): disconnect
	local items = self.items
	local alive = true

	table.insert(items, item)

	return function()
		if not alive then
			return
		end

		alive = false

		local index = table.find(items, item)

		if index then
			table.remove(items, index)
		end
	end
end

function clean(self: item_group)
	if self._cleaned then
		return
	end

	self._cleaned = true

	local items = self.items
	local handler = self.cleanup_handler
	local children = self.children

	for _, child: item_group in ipairs(children) do
		child:clean()
	end

	table.clear(children)

	for _, item: item in ipairs(items) do
		local ok, err = pcall(handler, item)

		if not ok then
			warn("error cleaning item:", err)
		end
	end

	table.clear(items)
end

function extend(self: item_group)
	local new = create()

	table.insert(self.children, new)

	return new
end

function cleanup_handler(item: item)
	if typeof(item) == "Instance" then
		item:Destroy()
	elseif typeof(item) == "function" then
		item()
	elseif typeof(item) == "thread" then
		task.cancel(item)
	elseif typeof(item) == "RBXScriptConnection" then
		item:Disconnect()
	else
		warn(`error trying to clean item: expected one of {table.concat(types, ", ")}. got {typeof(item)}`)
	end
end

function create(): item_group
	return {
		items = {},
		children = {},

		cleanup_handler = cleanup_handler,

		clean = clean,
		cleanup = clean,
		
		add = add,
		extend = extend,

		_cleaned = false,
	} :: item_group
end

return {
	create = create,
}
