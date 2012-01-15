
local path = 'interface/addons/charplan/test/'

dofile(path..'luaunit.lua')
dofile(path..'test_pimp.lua')


LuaUnit:run()
