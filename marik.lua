-- Marik's CC/OpenPeripherals API

function pFormat(pName)
-- Renames peripherals for formatting purposes

	if string.find(pName, "compressor") then
		pName = name_comp
	elseif string.find(pName, "electric_furnace") then
		pName = name_furnace
	elseif string.find(pName, "extractor") then
		pName = name_ext
	elseif string.find(pName, "macerator") then
		pName = name_mace
	elseif string.find(pName, "orewashing") then
		pName = name_washer
	elseif string.find(pName, "thermalcentrifuge") then
		pName = name_centrifuge
	elseif string.find(pName, "canning") then
		pName = name_canning
	elseif string.find(pName, "recycler") then
		pName = name_recycler
	elseif string.find(pName, "former") then
		pName = name_former
	elseif string.find(pName, "mfsu") then
		pName = name_mfsu
	end

return pName
end

function pLoad()

	machines = peripheral.getNames() -- load a list of peripherals into a table
	table.sort(machines) -- so it displays in non-random manner

return machines
end

function findBridge()
-- Find terminal glasses bridge and wrap it if it exists
	for i=1, #machines do
		if string.find(machines[i], "glassesbridge") then
			bridge = peripheral.wrap(machines[i])
			print("FOUND and added TERMINAL GLASSES bridge.")
			return true, bridge
		else
			return false
		end
	end
end


function dispGlasses()
-- addBox(x,y,width,height,hexcolor,opacity)
-- opacity 0 to 1
-- addText(x,y,text,color)
-- .clear()

	if bridge ~= nil then
		bridge.addBox(5,5,70,10,0xFFFFFF,0.5)
		glasses = bridge.addText(6,6,"Power: ",0x123456)
		-- glasses.setText(("Power: " .. totalStorage))
	end

end

function clearPos(x, y, side)
-- clears a specific line @ x, y and side

	m = peripheral.wrap(side)

	m.setCursorPos(x,y)
	m.clearLine()

end

function appendString(side, color, text, clear, x, y)
-- side: check program config (ie: left, right, aux_1)
-- color: computercraft color codes
-- text: the text to append
-- clear: true or false (clear the line when you append the string?)
-- x or y: if either is zero it uses the getCursorPos() x or y

	local m = peripheral.wrap(side)
	local a,b = m.getCursorPos()
	
	if x == 0 and y ~= 0 then
		m.setCursorPos(a,y)
	elseif x ~= 0 and y == 0 then
		-- set x position
		m.setCursorPos(x,b)
	elseif x ~= 0 and y ~= 0 then
		m.setCursorPos(x,y)
	elseif x == 0 and y == 0 then
		m.setCursorPos(a,b)
	end
	
	m.setTextColor(color)
	
	if clear == true then
		m.clearLine()
	end

	m.write(text)

end

function cString(x, y, color, side, text)
-- x, y: position coords
-- color: computercraft color codes
-- side: check program config (ie: left, right, aux_1)
-- text: any string

local m = peripheral.wrap(side)

	m.setCursorPos(x,y)
	m.setTextColor(color)
	m.write(text)
	
end

function getTank(tankPeriph)

local tableInfo = tankPeriph.getTankInfo("unknown")[1]

local fluidRaw, fluidName, fluidAmount, fluidCapacity, fluidID

    fluidRaw = tableInfo.rawName
    fluidName = tableInfo.name
    fluidAmount = tableInfo.amount
    fluidCapacity = tableInfo.capacity
    fluidID = tableInfo.id
 
return fluidRaw, fluidName, fluidAmount, fluidCapacity, fluidID
end

function getBuckets(fluidAmount)
-- Convert millibuckets to buckets

	fluidBuckets = fluidAmount / 1000

return fluidBuckets
end

function numOfMachines()

	local machines = peripheral.getNames()
	count = #machines
	table.sort(machines)
	n = 0
	
	for i=1, #machines do
		if string.find(machines[i], "mfsu")
		or string.find(machines[i], "mfe")
		or string.find(machines[i], "cesu")  
		or string.find(machines[i], "batbox") then
			n = n + 1
		end
	end
	
return n, count
end

function comma(number)
-- Formats long numbers with commas
	
	if string.len(number) < 6 then
		-- leave as is
	elseif string.len(number) == 6 then
		number = string.gsub(number, "^(-?%d+)(%d%d%d)", '%1,%2')
	elseif string.len(number) >= 7 and string.len(number) <= 9 then
		number = string.gsub(number, "^(-?%d+)(%d%d%d)(%d%d%d)", '%1,%2,%3')
	elseif string.len(number) == 10 then -- need to fix
		number = string.gsub(number, "^(-?%d+)(%d%d%d)(%d%d%d)(%d%d%d)", '%1,%2,%3,%4')
	else
		-- nothing
	end

return number
end

function itemRename(itemName)
-- Shortens some long IC2/MFR/AE names to a more readable format
-- This could be done with a lot less lines, but I'm still working on it.

	if (string.find(itemName, "ic2.item",1) == 1) then
		itemName = string.sub(itemName, 9)
		itemName = removeDots(itemName)

			if string.find(itemName, "%s") then
				-- If there's a space in the itemName like "Iron Ore" don't do anything to it!
				-- It's "probably" correct.
			else
				-- It's probably "CrushedIronOre" or something similar.
				-- Fix it.
				itemName = spaceAtSecondUpper(itemName)
			end			

	elseif (string.find(itemName, "ic2.",1) == 1) then
		itemName = string.sub(itemName, 5)
		itemName = removeDots(itemName)

			if string.find(itemName, "%s") then
				-- end
			else
				itemName = spaceAtSecondUpper(itemName)
			end		

	elseif (string.find(itemName, "tile.mfr.",1) == 1) then
		itemName = string.sub(itemName, 10)
	elseif (string.find(itemName, "appeng.materials.",1) == 1) 
		or (string.find(itemName, "AppEng.Materials.",1) == 1) then
		itemName = string.sub(itemName, 18)
		itemName = removeDots(itemName)
		itemName = spaceAtSecondUpper(itemName)
	elseif (string.find(itemName, "item.mfr.",1) == 1) then
		itemName = string.sub(itemName, 10)
		itemName = removeDots(itemName)
	elseif (string.find(itemName, "rubberwood.log.name",1) == 1) then
		itemName = removeDots(itemName)
	elseif (string.find(itemName, "item.openperipheral",1) == 1) then
		itemName = string.sub(itemName, 21)
		itemName = removeDots(itemName)
		itemName = spaceAtSecondUpper(itemName)
	end


return itemName
end

function removeDots(itemName)
-- remove any "." in itemName and replaces with spaces
-- also remove any occurence of "name" in the ore

	itemName = string.gsub(itemName, "%.", " ") -- change rubber.raw.name to "rubber raw name"
	itemName = string.gsub(itemName, "%name", "") -- change "rubber raw name" to "rubber raw"
	itemName = string.gsub(itemName, "block", "") -- remove "block" from the name

return itemName
end

function spaceAtSecondUpper(itemName)
-- Insert a space before each occurence of a capital letter
-- Remove the leading space
-- This is to change ore names like "PurifiedCrushedCopperOre" to "Purified Crushed Copper Ore"

	itemName = itemName:gsub("(%S)(%u)", "%1 %2")
	itemName = itemName:gsub("^%s*(.-)%s*$", "%1")

return itemName
end

function GPSinfo()

local x,y,z = gps.locate(5)
	if x == nil then
		return false
	else
		return true
	end
end



