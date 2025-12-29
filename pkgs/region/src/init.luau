--!optimize 2
--!native

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local local_player = Players.LocalPlayer

local region = {}

local MINIMUM_DISTANCE = 0.1
local MINIMUM_FRAMES = 3

local last_position: Vector3?
local frame_counter = 0

local tracked_regions = {}
local render_connection

local function is_inside_region(created_region, root)
	local in_region = created_region.box.CFrame:PointToObjectSpace(root.Position)
	local half_size = created_region.box.Size / 2

	local is_inside = math.abs(in_region.X) <= half_size.X
		and math.abs(in_region.Y) <= half_size.Y
		and math.abs(in_region.Z) <= half_size.Z

	return is_inside
end

local function ensure_render_stepped()
	if render_connection then
		return
	end

	render_connection = RunService.RenderStepped:Connect(function()
		frame_counter += 1

		if frame_counter % MINIMUM_FRAMES ~= 0 then
			return
		end

		local character = local_player.Character

		if not character then
			return
		end

		local root = character:FindFirstChild("HumanoidRootPart")

		if not root then
			return
		end

		local current_position = root.Position

		if last_position == nil or (current_position - last_position).Magnitude < MINIMUM_DISTANCE then
			return
		end

		last_position = current_position

		for _, created_region in ipairs(tracked_regions) do
			local is_inside = is_inside_region(created_region, root)

			if is_inside and not created_region.player_inside then
				created_region.player_inside = true

				if created_region.callbacks.enter then
					task.spawn(created_region.callbacks.enter)
				end
			elseif not is_inside and created_region.player_inside then
				created_region.player_inside = false

				if created_region.callbacks.exit then
					task.spawn(created_region.callbacks.exit)
				end
			end
		end
	end)
end

function region.new(box: BasePart, callbacks: { enter: () -> (), exit: () -> () })
	assert(box and box:IsA("BasePart"), "box must be a valid BasePart")
	assert(typeof(callbacks) == "table", "callbacks must be a table")

	assert(callbacks.enter == nil or type(callbacks.enter) == "function", "callbacks.enter must be a function")
	assert(callbacks.exit == nil or type(callbacks.exit) == "function", "callbacks.exit must be a function")

	local created_region = {
		box = box,
		callbacks = callbacks,
		player_inside = false,
	}

	table.insert(tracked_regions, created_region)

	ensure_render_stepped()

	return created_region
end

function region.remove(region_object)
	for index, created_region in ipairs(tracked_regions) do
		if created_region == region_object then
			table.remove(tracked_regions, index)

			break
		end
	end

	if #tracked_regions == 0 and render_connection then
		render_connection:Disconnect()
		render_connection = nil
	end
end

return region
