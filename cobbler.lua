-- Constants
local ENDPOINT = "http://episode17.com/mc/cobbler/update.php"
local ME_SIDE = "bottom"
local UPDATE_INTERVAL = 10
local AVERAGE_STACK_SIZE = 10

local storage = peripheral.wrap(ME_SIDE)

-- Setup
term.clear()
term.setCursorPos(1, 1)


-- Gets cobblestone count from ME storage
local function getCount()
  local items = storage.getAvailableItems()
  
  for slot, item in pairs(storage.getAvailableItems()) do
    if item['fingerprint']['id'] == 'minecraft:cobblestone' then
      return item['size']
    end
  end
end


-- Data
local prevCount = getCount()
local last = os.clock()
local speedStack = {}

-- Welcome
print("=== Cobbler MC Client         ===")
write("=== Race to ")
term.setTextColor(colors.yellow)
write("1,000,000,000,000")
term.setTextColor(colors.white)
print(" ===")

sleep(2)

-- Main loop
while true do
  local count = getCount()
  local diff = count - prevCount
  prevCount = count
  
  local now = os.clock()
  local dt = now - last
  last = now
  
  local speed = diff / dt
  
  
  -- Average speed
  table.insert(speedStack, speed)
  
  if #speedStack > 10 then
    table.remove(speedStack, 1)
  end
  
  local sum = 0
  for i, v in pairs(speedStack) do
    sum = sum + v
  end
  
  local avgSpeed = sum / #speedStack
  
  
  -- Info
  term.setTextColor(colors.yellow)
  print("---")
  term.setTextColor(colors.white)
  print("Count: " .. count)
  print("Speed: " .. speed .. " / " .. avgSpeed)
  
  
  -- Contact endpoint
  pcall(function() 
    local h = http.get(ENDPOINT .. "?c=" .. count .. "&s=" .. avgSpeed)
    print("Resp:  " .. h.readAll())
    h.close()
  end)
  
  sleep(UPDATE_INTERVAL)
end

