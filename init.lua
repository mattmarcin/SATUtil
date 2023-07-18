-- Separating Axis Theorem (SAT) collision detection for Roblox
-- by @mattmarcin
-- Pass in 2 Models to ModelsCollide to test if they intersect. Supports rotation.

local SATUtil = {}

-- Test if two bounding boxes intersect. Return true if they do.
function SATUtil.ModelsCollide(box1: Model, box2: Model)
	local box1CFrame, box1Size = box1:GetBoundingBox()
	local box2CFrame, box2Size = box2:GetBoundingBox()

	local box1Corners = SATUtil.getCorners(box1CFrame, box1Size)
	local box2Corners = SATUtil.getCorners(box2CFrame, box2Size)

	local axes = {
		(box1Corners[2] - box1Corners[1]).unit,
		(box1Corners[3] - box1Corners[1]).unit,
		(box1Corners[5] - box1Corners[1]).unit,
		(box2Corners[2] - box2Corners[1]).unit,
		(box2Corners[3] - box2Corners[1]).unit,
		(box2Corners[5] - box2Corners[1]).unit,
	}

	for _, axis in ipairs(axes) do
		local box1Min = math.huge
		local box1Max = -math.huge
		for _, corner in ipairs(box1Corners) do
			local projection = axis:Dot(corner - box1CFrame.p)
			box1Min = math.min(box1Min, projection)
			box1Max = math.max(box1Max, projection)
		end

		local box2Min = math.huge
		local box2Max = -math.huge
		for _, corner in ipairs(box2Corners) do
			local projection = axis:Dot(axis, corner - box2CFrame.p)
			box2Min = math.min(box2Min, projection)
			box2Max = math.max(box2Max, projection)
		end

		if box1Max < box2Min or box1Min > box2Max then
			return false
		end
	end

	return true
end

-- Get the corners of a bounding box
function SATUtil.getCorners(inCFrame, inSize)
	local sizeDiv2 = inSize / 2
	local corners = {}
	for i = -1, 1, 2 do
		for j = -1, 1, 2 do
			for k = -1, 1, 2 do
				local newPos = inCFrame:PointToWorldSpace(Vector3.new(i * sizeDiv2.X, j * sizeDiv2.Y, k * sizeDiv2.Z))
				table.insert(corners, newPos)
			end
		end
	end
	return corners
end

return SATUtil
