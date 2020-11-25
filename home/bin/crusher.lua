-- home/bin/crusher.lua --
--[[ EDIT HISTORY
  2020-11-24 = throwawAPI
             - v0.1
             - file created
--]]

local component = require("component")
local sides     = require("sides")
local term      = require("term")
local redstoneSide = sides.front
local crusher = component.ie_crusher

function getRedstoneSignal ()
  return component.redstone.getInput(redstoneSide)
end -- getRedstoneSignal ()

function setCrusherEnabled ()
  crusher.enableComputerControl(true)
  if getRedstoneSignal() > 0 then
    crusher.setEnabled(true)
  else
    crusher.setEnabled(false)
  end
end -- setCrusherEnabled ()

-- toIntStr should be moved into a /home/lib file for string helpers
function toIntStr (val)
  return string.format("%d", val)
end

--[[ crusher.getInputQueue() format:
{
  ipair []: -- we'll call this the "recipe", there can be several
  {
    float progress    -- current progress towards completion
    float maxProgress -- total needed for completion, usually 50?
    table input:
    {
      ipair []: -- I've never looked past the first index here
      {
        float damage -- might have to do with explosion resistance?
        bool? hasTag -- does this have nbt data
        str   label  -- good for human consumption
        float maxDamage -- ??? explosions resistance?
        float maxSize   -- max limit of item stack
        str   name      -- use "label" for non-technical needs
        str   nameUnlocalized -- use "label" for non-technical needs
        float size            -- size of item stack
      }
    }
    table output:
    {
      float damage -- might have to do with explosion resistance?
      bool? hasTag -- does this have nbt data
      str   label  -- good for human consumption
      float maxDamage -- ??? explosions resistance?
      float maxSize   -- max limit of item stack
      str   name      -- use "label" for non-technical needs
      str   nameUnlocalized -- use "label" for non-technical needs
      float size            -- size of item stack
    }
  }
}
--]]
--[[
we use a buffer to avoid flicker. many print() or io.write()
commands can cause a very unflattering flicker on the screen,
although I anticipate this is worse on Tier I than Tier II.
for the sake of avoiding the strobe, write to a buffer,
then clear the screen and immediently write the buffer out to io.
I'd prefer to have control over screen refresh/flush,
but I'm not sure that OpenOS supports this...
--]]
function printCrusherQueue (queue)
  local buffer = "Crusher Monitor v0.1\n===================="
  for idx, tbl in ipairs(queue) do
    if idx > 13 then -- this is hardcoded, check screen tier
      buffer = buffer .. "\n. . ."
      break -- screen would overflow and scroll, stop instead
    end
    local vin  = tbl.input[1]
    local vout = tbl.output
    buffer = buffer .. "\n" ..
      vin.label  .. " (x" .. toIntStr(vin.size)  .. ") => " ..
      vout.label .. " (x" .. toIntStr(vout.size) .. ") " ..
      toIntStr(tbl.progress) .. "/" .. toIntStr(tbl.maxProgress)
  end
  term.clear()
  io.write(buffer)
end -- printCrusherQueue()

--[[

--]]
while true do
  os.sleep(0.5)
  setCrusherEnabled()
  printCrusherQueue(crusher.getInputQueue())
end
