-- Separating Axis Theorem (SAT) collision detection for Roblox
-- by @mattmarcin
-- Pass in 2 Models to ModelsCollide to test if they intersect. Supports rotation.

local SATUtil = {}

-- Test if two bounding boxes intersect. Return true if they do.

function SATUtil.ModelsCollide(object1: Model, object2: Model)
	local box1CFrame, box1Size = object1:GetBoundingBox()
	local box2CFrame, box2Size = object2:GetBoundingBox()

	local axes = {}
	local eps = 1e-5 -- Small epsilon to deal with numerical precision issues

	-- Get the box axes
	axes[1], axes[2], axes[3] = box1CFrame.RightVector, box1CFrame.UpVector, box1CFrame.LookVector
	axes[4], axes[5], axes[6] = box2CFrame.RightVector, box2CFrame.UpVector, box2CFrame.LookVector

	-- Compute the cross product of the edge directions
	for i = 1, 3 do
		for j = 4, 6 do
			axes[#axes + 1] = axes[i]:Cross(axes[j])
			-- If the cross product is very small, it means the edges are almost parallel, so we don't need this axis
			if axes[#axes].Magnitude < eps then
				axes[#axes] = nil
			end
		end
	end

	-- Now we need to project both boxes onto these axes and see if the projections overlap
	for _, axis in pairs(axes) do
		if axis then -- Ensure the axis is not nil (in case of almost parallel edges)
			local min1, max1 = math.huge, -math.huge
			local min2, max2 = math.huge, -math.huge
			-- Compute the projection of the first box onto the current axis
			for _, corner in pairs(SATUtil.getBoxCorners(box1CFrame, box1Size)) do
				local projection = corner:Dot(axis)
				min1 = math.min(min1, projection)
				max1 = math.max(max1, projection)
			end
			-- Compute the projection of the second box onto the current axis
			for _, corner in pairs(SATUtil.getBoxCorners(box2CFrame, box2Size)) do
				local projection = corner:Dot(axis)
				min2 = math.min(min2, projection)
				max2 = math.max(max2, projection)
			end
			-- If the projections do not overlap, then we have found a separating axis and the boxes do not intersect
			if max1 < min2 or max2 < min1 then
				return false
			end
		end
	end
	-- If we haven't found a separating axis, then the boxes intersect
	return true
end

-- Helper function to get the corners of a box given its CFrame and size
function SATUtil.getBoxCorners(cframe, size)
	local halfSize = size / 2
	return {
		cframe * Vector3.new(halfSize.X, halfSize.Y, halfSize.Z),
		cframe * Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z),
		cframe * Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z),
		cframe * Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z),
		cframe * Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z),
		cframe * Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z),
		cframe * Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z),
		cframe * Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z),
	}
end

return SATUtil
