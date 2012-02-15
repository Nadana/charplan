
local path = 'interface/addons/charplan/test/'

dofile(path..'test_db.lua')
dofile(path..'test_pimp.lua')
dofile(path..'test_calc.lua')
dofile(path..'test_calc_items.lua')
dofile(path..'test_utils.lua')

LuaUnit:run()

