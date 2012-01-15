--[[
		luaunit.lua

Description: A unit testing framework
Homepage: http://phil.freehackers.org/luaunit/
Initial author: Ryu, Gwang (http://www.gpgstudy.com/gpgiki/LuaUnit)
Lot of improvements by Philippe Fremy <phil@freehackers.org>
Version: 1.3
License: X11 License, see LICENSE.txt

Modifications for Runes Of Magic and addtions by McBen (viertelvor12@gmx.net)

]]--

argv = arg


local function print(msg)
    if type(msg)=="string" then
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end
end


function assertError(f, ...)
	-- assert that calling f with the arguments will raise an error
	-- example: assertError( f, 1, 2 ) => f(1,2) should generate an error
	local has_error, error_msg = not pcall( f, ... )
	if has_error then return end
	error( "No error generated", 2 )
end

function assertEquals(actual, expected)
	-- assert that two values are equal and calls error else
	if  actual ~= expected  then
		local function wrapValue( v )
			if type(v) == 'string' then return "'"..v.."'" end
			return tostring(v)
		end

		local errorMsg
		if type(expected) == 'string' then
			errorMsg = "\nexpected: "..wrapValue(expected).."\n"..
                             "actual  : "..wrapValue(actual).."\n"
		else
			errorMsg = "expected: "..wrapValue(expected)..", actual: "..wrapValue(actual)
		end
		print (errorMsg)
		error( errorMsg, 2 )
	end
end

function assertArrayEquals(actual, expected)
    -- assert if a value differs in both arrays
    if type(actual)~="table" or type(expected)~="table" then
        local errorMsg = "parmeter have invalid type: actual="..type(actual).." expected: "..type(expected)
    	print (errorMsg)
		error( errorMsg, 2 )
        return
    end

    for id,data in pairs(actual) do
        if data~=expected[id] then
            local errorMsg = "at "..tostring(id).." expected: "..tostring(expected[id])..", actual: "..tostring(data)
            print (errorMsg)
            error( errorMsg, 2 )
        end
    end

    for id,data in pairs(expected) do
        if not actual[id] then
            local errorMsg = "at "..tostring(id).." expected: "..tostring(data)..", actual: nil"
            print (errorMsg)
            error( errorMsg, 2 )
        end
    end
end

function assertType(obj,extype)
	-- assert if value is not nil
	if type(obj)~=extype then
		local errorMsg = "expected type: "..tostring(extype)..", actual type: "..type(obj)
		print (errorMsg)
		error( errorMsg, 2 )
	end
end

function assertNil(actual)
	-- assert if value is not nil
	if actual~=nil then
		local errorMsg = "expected: nil, actual: "..tostring(actual)
		print (errorMsg)
		error( errorMsg, 2 )
	end
end

function assertNotNil(actual)
	-- assert if value is nil
	if actual==nil then
		local errorMsg = "expected non-nil value"
		print (errorMsg)
		error( errorMsg, 2 )
	end
end

function assertTrue(actual)
	-- assert if value is not true
	if not actual then
		local errorMsg = "expected: true, actual: "..tostring(actual)
		print (errorMsg)
		error( errorMsg, 2 )
	end
end

function assertFalse(actual)
	-- assert if value is not true
	if actual then
		local errorMsg = "expected: false, actual: "..tostring(actual)
		print (errorMsg)
		error( errorMsg, 2 )
	end
end

assert_equals = assertEquals
assert_error = assertError

function wrapFunctions(...)
	-- Use me to wrap a set of functions into a Runnable test class:
	-- TestToto = wrapFunctions( f1, f2, f3, f3, f5 )
	-- Now, TestToto will be picked up by LuaUnit:run()
	local testClass, testFunction
	testClass = {}
	local function storeAsMethod(idx, testName)
		testFunction = _G[testName]
		testClass[testName] = testFunction
	end
	table.foreachi( {...}, storeAsMethod )
	return testClass
end

function __genOrderedIndex( t )
    local orderedIndex = {}
    for key,_ in pairs(t) do
        table.insert( orderedIndex, key )
    end
    table.sort( orderedIndex )
    return orderedIndex
end

function orderedNext(t, state)
	-- Equivalent of the next() function of table iteration, but returns the
	-- keys in the alphabetic order. We use a temporary ordered key table that
	-- is stored in the table being iterated.

    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex( t )
        key = t.__orderedIndex[1]
        return key, t[key]
    end
    -- fetch the next value
    key = nil
    for i = 1,table.getn(t.__orderedIndex) do
        if t.__orderedIndex[i] == state then
            key = t.__orderedIndex[i+1]
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

function orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return orderedNext, t, nil
end

-------------------------------------------------------------------------------
UnitResult = { -- class
	failureCount = 0,
	testCount = 0,
	errorList = {},
	currentClassName = "",
	currentTestName = "",
	testHasFailure = false,
	verbosity = 0
}
	function UnitResult:displayClassName()
        if self.verbosity > 0 then
		    print( '>>>>>>>>> '.. self.currentClassName )
        end
	end

	function UnitResult:displayTestName()
		if self.verbosity > 1 then
			print( ">>> ".. self.currentTestName )
		end
	end

	function UnitResult:displayFailure( errorMsg )
		if self.verbosity > 0 then
			print( errorMsg )
			print( 'Failed' )
		end
	end

	function UnitResult:displaySuccess()
		if self.verbosity > 2 then
			print( 'Ok' )
		end
	end

	function UnitResult:displayOneFailedTest( failure )
		testName, errorMsg = unpack( failure )
		print(">>> "..testName.." failed")
		print( errorMsg )
	end

	function UnitResult:displayFailedTests()
		if table.getn( self.errorList ) == 0 then return end
		print("Failed tests:")
		print("-------------")
		table.foreachi( self.errorList, self.displayOneFailedTest )
		print()
	end

	function UnitResult:displayFinalResult()
        if self.verbosity > 0 or self.failureCount>0 then
            print("=========================================================")
            self:displayFailedTests()
            local failurePercent, successCount
            if self.testCount == 0 then
                failurePercent = 0
            else
                failurePercent = 100 * self.failureCount / self.testCount
            end
            successCount = self.testCount - self.failureCount
            print( string.format("Success : %d%% - %d / %d",
                100-math.ceil(failurePercent), successCount, self.testCount) )
        end
    end

	function UnitResult:startClass(className)
		self.currentClassName = className
		self:displayClassName()
	end

	function UnitResult:startTest(testName)
		self.currentTestName = testName
		self:displayTestName()
        self.testCount = self.testCount + 1
		self.testHasFailure = false
	end

	function UnitResult:addFailure( errorMsg )
		self.failureCount = self.failureCount + 1
		self.testHasFailure = true
		table.insert( self.errorList, { self.currentTestName, errorMsg } )
		self:displayFailure( errorMsg )
	end

	function UnitResult:endTest()
		if not self.testHasFailure then
			self:displaySuccess()
		end
	end

-- class UnitResult end


LuaUnit = {
	result = UnitResult
}
	-- Split text into a list consisting of the strings in text,
	-- separated by strings matching delimiter (which may be a pattern).
	-- example: strsplit(",%s*", "Anna, Bob, Charlie,Dolores")
	function LuaUnit.strsplit(delimiter, text)
		local list = {}
		local pos = 1
		if string.find("", delimiter, 1) then -- this would result in endless loops
			error("delimiter matches empty string!")
		end
		while 1 do
			local first, last = string.find(text, delimiter, pos)
			if first then -- found?
				table.insert(list, string.sub(text, pos, first-1))
				pos = last+1
			else
				table.insert(list, string.sub(text, pos))
				break
			end
		end
		return list
	end

	function LuaUnit.isFunction(aObject)
		return 'function' == type(aObject)
	end

	function LuaUnit.strip_luaunit_stack(stack_trace)
		stack_list = LuaUnit.strsplit( "\n", stack_trace )
		strip_end = nil
		for i = table.getn(stack_list),1,-1 do
			-- a bit rude but it works !
			if string.find(stack_list[i],"[C]: in function `xpcall'",0,true)
				then
				strip_end = i - 2
			end
		end
		if strip_end then
			table.setn( stack_list, strip_end )
		end
		stack_trace = table.concat( stack_list, "\n" )
		return stack_trace
	end

    function LuaUnit:runTestMethod(aName, aClassInstance, aMethod)
		local ok, errorMsg
		-- example: runTestMethod( 'TestToto:test1', TestToto, TestToto.testToto(self) )
		LuaUnit.result:startTest(aName)

		-- run setUp first(if any)
		if self.isFunction( aClassInstance.setUp) then
				aClassInstance:setUp()
		end

		local function err_handler(e)
			return e -- ..'\n'..debug.traceback()
		end

		-- run testMethod()
        ok, errorMsg = xpcall( aMethod, err_handler )
		if not ok then
			errorMsg  = self.strip_luaunit_stack(errorMsg)
			LuaUnit.result:addFailure( errorMsg )
        end

		-- lastly, run tearDown(if any)
		if self.isFunction(aClassInstance.tearDown) then
			 aClassInstance:tearDown()
		end

		self.result:endTest()
    end

	function LuaUnit:runTestMethodName( methodName, classInstance )
		-- example: runTestMethodName( 'TestToto:testToto', TestToto )
		local methodInstance = loadstring(methodName .. '()')
		LuaUnit:runTestMethod(methodName, classInstance, methodInstance)
	end

    function LuaUnit:runTestClassByName( aClassName )
		-- example: runTestMethodName( 'TestToto' )
		local hasMethod, methodName, classInstance
		hasMethod = string.find(aClassName, ':' )
		if hasMethod then
			methodName = string.sub(aClassName, hasMethod+1)
			aClassName = string.sub(aClassName,1,hasMethod-1)
		end
        classInstance = _G[aClassName]
		if not classInstance then
			error( "No such class: "..aClassName )
		end

		LuaUnit.result:startClass( aClassName )

		if hasMethod then
            print("no methodes")
			if not classInstance[ methodName ] then
				error( "No such method: "..methodName )
			end
			LuaUnit:runTestMethodName( aClassName..':'.. methodName, classInstance )
		else
			-- run all test methods of the class
			for methodName, method in orderedPairs(classInstance) do
			--for methodName, method in classInstance do
				if LuaUnit.isFunction(method) and string.sub(methodName, 1, 4) == "test" then
					LuaUnit:runTestMethodName( aClassName..':'.. methodName, classInstance )
				end
			end
		end
		print()
	end

	function LuaUnit:run(...)
		-- Run some specific test classes.
		-- If no arguments are passed, run the class names specified on the
		-- command line. If no class name is specified on the command line
		-- run all classes whose name starts with 'Test'
		--
		-- If arguments are passed, they must be strings of the class names
		-- that you want to run
                args={...};
		if #args > 0 then
			table.foreachi( args, LuaUnit.runTestClassByName )
		else
            -- create the list before. If you do not do it now, you
            -- get undefined result because you modify _G while iterating
            -- over it.
            testClassList = {}
            for key, val in pairs(_G) do
                if string.sub(key,1,4) == 'Test' and type(_G[key])=="table" then
                    table.insert( testClassList, key )
                end
            end
            for i, val in orderedPairs(testClassList) do
                    LuaUnit:runTestClassByName(val)
            end
		end

        LuaUnit.result:displayFinalResult()
		return LuaUnit.result.failureCount
	end
-- class LuaUnit

