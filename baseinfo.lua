-- ComputerCraft/OpenPeripherals Base Monitoring Program for MC 1.6.4
-- Thanks: Fogger, @EsperNet: #OpenMods, #computercraft @Freenode: #lua

-- The color palette. You can add more.
local palette = {["white"] = 1, ["orange"] = 2, ["magenta"] = 4, ["lightBlue"] = 8, ["yellow"] = 16,
["lime"] = 32, ["pink"] = 64, ["gray"] = 128, ["lightGray"] = 256, ["cyan"] = 512, ["purple"] = 1024,
["blue"] = 2048, ["brown"] = 4096, ["green"] = 8192, ["red"] = 16384, ["black"] = 32768}

-- LOAD APIs -------------------------------------------
print("Updating APIs...")
if fs.exists("marik") then shell.run("rm marik") end
	shell.run("pastebin get sZ13tEft marik")
	os.loadAPI("marik")
-------------------------------------------------------

-- *** CONFIG SECTION **
-- Will overwrite any changes if you auto-update the program
----------------------------------------------------------------------
-- MONITORS and TERMINAL GLASSES (the only required config change)
local left = "monitor_0" -- first main display monitor
local right = "monitor_4" -- second main display monitor
local aux_1 = "monitor_5" -- auxiliary monitor for total power/capacity reading
-- VARIOUS
local activeMsg, inactiveMsg, pendingMsg = "USING", "INACT", "PENDN"
local textSize = 1 -- increments of 0.5
local isGPS = true -- should we look for and display a nearby GPS?
-- MACHINE and PERIPHERAL NAMES --
-- Use the same # of characters for each so that formatting is aligned
name_comp = "CMPRESR" -- compressor
name_furnace = "FURNACE" -- electric furnace
name_ext = "EXTRCTR" -- extractor
name_mace = "MACERTR" -- macerator
name_washer = "ORWASHR" -- ore washer
name_centrifuge = "THR_CTR" -- thermal centrifuge
name_former = "MTL_FRM" -- metal former
name_recycler = "RECYCLR" -- recycler
name_canning = "CAN_MCN" -- canning machine
-- OTHER Machine Names
local name_mfsu = "MFSU"
-- COLORS
local hc = palette.lightBlue -- default heading color
local tc = palette.white -- default text color
local color_reading = palette.lime -- power readings for example
local color_inactive = palette.gray -- inactive reading for machines
local color_active = palette.red -- active reading for machines
local color_machines = palette.orange -- machine names
local color_ores = palette.pink -- ore name color
-- TEXT POSITIONS
local pos_PwrReading = 20 -- X pos to display power readings
local pos_MachineDisplay = 6 -- X pos to start displaying machines
local offsetPos = 2 -- left margin offset for text
local pos_mStatus = 11 -- machine status
local pos_Ore = 18 -- machine input item position
local pos_TankStart = 1 -- RC tank position start
local pos_Machines = 6
local GPS_x = 25
local GPS_y = 58
-- SPECIAL CHARACTERS
local separator = " | "
local spacer = " : "
-------------------------------------------------------------------------

local pversion = "1.3.5.1b"
local waitTime = {9,13}
local timer = {0,0,0,0,0,0,0,0,0,0,0}
local supported_Power = {"mfsu","cesu","mfe","batbox"}
local supported_Machines = {"macerator","furnace","orewashing","thermalcentrifuge", "extractor",
"compressor", "canning", "recycler", "metalformer"}
local sleepAmt = 0.2
local ic2ItemUsed = 7 -- input slot for most ic2 machines
local ic2ItemCreated = 2 -- output slot for most ic2 machines
local oreWashItemUsed = 9 -- input slot for orewasher
local thermCentrItemUsed = 9 -- input slot for thermal centrifuge

term.clear()
print("Base Monitoring Program v" .. pversion)
print("Starting...")

n,count = marik.numOfMachines()
print("Total peripherals detected: " .. count)
print("Power storage devices: " .. n)
print("Checking peripheral connections...")

marik.pLoad()

-- Monitors
local mon = peripheral.wrap(left)
local mon2 = peripheral.wrap(right)
mon.clear()
mon2.clear()
mon.setTextScale(textSize)
mon2.setTextScale(textSize)

-- MONITOR 1 - Write lines that won't be cleared
marik.cString(offsetPos, 1, hc, left, "-- Main Power --")
marik.cString(offsetPos, pos_Machines, hc, left, "-- Machines Info --")

-- MONITOR 2 - Write lines that won't be cleared
marik.cString(offsetPos, 1, hc, right, "-- RailCraft Tank Information --")

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

function dispAE()

	-- AE TERMINAL (not working yet)
	mon2.setTextColor(tc)
	mon2.setCursorPos(offsetPos,aeCraftCol)
	
	beingCrafted = aeController.getJobList()
	if beingCrafted.name ~= nil then
		timer[1] = os.clock()
		mon2.clearLine()
		mon2.write("Currently Crafting: " .. beingCrafted.name)
	elseif beingCrafted.name == nil then
			mon2.clearLine()
			mon2.write("Currently Crafting: Nothing")
	else
			mon2.clearLine()
			mon2.write("Currently Crafting: Unknown")
	end
end

function dispTanks()
mon.setCursorPos(offsetPos, 1)
mon2.setCursorPos(offsetPos,1)

	for i=1, #machines do
	-- RC Tanks --------------------------------------------
		if string.find(machines[i], "rcirontankvalvetile") 
			or string.find(machines[i], "rcsteeltankvalvetile") then						
			
			if peripheral.isPresent(machines[i]) then
				periph = peripheral.wrap(machines[i])
			
				fluidRaw, fluidName, fluidAmount, fluidCapacity, fluidID = marik.getTank(periph)				        	
			
				if fluidName == nil then
				-- does not display empty tanks
				elseif fluidName ~= nil then
					mon2.setTextColor(tc)
					x,y = mon2.getCursorPos()
					mon2.setCursorPos(offsetPos, (y+1))
					mon2.clearLine()
   	  		-- marik.cString(offsetPos,(y+1), tc, right, " ")
   	  		mon2.write("Tank (" .. marik.comma(fluidName) .. ") : " .. marik.comma(fluidAmount) .. " / " .. marik.comma(fluidCapacity) .. " mb (" .. marik.getBuckets(fluidAmount) .. " buckets)") 
   	  	end
   		end
  	end
	end
end

function dispPower()

 	for i=1, #machines do
  -- IC2 Power -------------------------------------------
    for s=1, #supported_Power do
	   	if string.find(machines[i], supported_Power[s]) then 

     		periph = peripheral.wrap(machines[i])        		
     		local storedEU = periph.getEUStored()
     		local capacity = periph.getEUCapacity()

				-- modify these later for multiple storage peripherals
				local totalStorage = storedEU
				local totalCapacity = capacity

				marik.appendString(left, tc, "Total EU       " .. separator, true, offsetPos, 2)
				marik.appendString(left, color_reading, (marik.comma(totalStorage)), false, pos_PwrReading, 2)
				
				marik.appendString(left, tc, "Total Capacity " .. separator, true, offsetPos, 3)
				marik.appendString(left, color_reading, (marik.comma(totalCapacity)), false, pos_PwrReading, 3)

				marik.appendString(left, tc, pFormat(machines[i]) .. " Storage   " .. separator, true, offsetPos, 4)
				marik.appendString(left, color_reading, (marik.comma(storedEU)), false, pos_PwrReading, 4)

			end
		end
	end
end


function dispIC2()

machineDispStart = pos_MachineDisplay -- screen start positon
	
	for i=1, #machines do
	-- IC2 Machines -----------------------------------------
		local m
		for m=1, #supported_Machines do 
			-- check if the machine is a supported machine
			if string.find(machines[i], supported_Machines[m]) then
			
				-- check if the peripheral is connected
				-- if peripheral.isPresent(machines[i]) then
					periph = peripheral.wrap(machines[i])

						-- determine what slot to use for the machines' input								
						if string.find(machines[i], "thermalcentrifuge") then itemStackUsed = periph.getStackInSlot(thermCentrItemUsed)
						elseif string.find(machines[i], "orewashing") then itemStackUsed = periph.getStackInSlot(oreWashItemUsed)
						else itemStackUsed = periph.getStackInSlot(ic2ItemUsed)
						end
						
						machineDispStart = machineDispStart + 1 -- move this down?

						-- if there's something in the input slot
						if itemStackUsed ~= nil then 
							itemName = marik.itemRename(itemStackUsed.name)
							timer[2] = os.clock()
						
							-- display machine, active message and itemName
							marik.appendString(left, color_ores, itemName, true, pos_Ore, machineDispStart) -- append the itemName
							str = (pFormat(peripheral.getType(machines[i]))) 
							marik.appendString(left, tc, str, false, offsetPos, machineDispStart) -- append the [      ] that contains the itemName
							marik.appendString(left, color_active, activeMsg, false, 11, machineDispStart) -- append the activeMsg							

						-- if there is nothing in the input slot
						elseif itemStackUsed == nil then 		
							if os.clock() - timer[2] > waitTime[1] then -- clear the message only if it has been waitTime[1] seconds
								
								--display machine and inactive message
								marik.appendString(left, color_inactive, inactiveMsg, true, pos_mStatus, machineDispStart) -- append INACTIVE
								str = (pFormat(peripheral.getType(machines[i]))) 
								marik.appendString(left, tc, str, false, offsetPos, machineDispStart) -- append the [      ] that contains the itemName
								
							end
			
									
					end
				-- end
			end	
		end	
	end
end

-- Loop Start
while true do

mon.setTextColor(tc)
if marik.GPSinfo() then
	mon.setCursorPos(GPS_y, GPS_x)
	mon.write("GPS: Online")
else
	mon.setCursorPos(GPS_y, GPS_x)
	mon.write("GPS: Offline")
end

marik.pLoad()

dispTanks()
dispPower()
dispIC2()

sleep(sleepAmt)

end