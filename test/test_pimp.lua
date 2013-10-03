

TestCP_PimpMe ={}


function TestCP_PimpMe:testLinks()

    local i = TestCP_PimpMe:ExtractLink("|Hitem:377a0 3 358e0c74 d41fd41a d56bd56d d48fd56c 0 0 0 0 2d50 82a0|h|cffc805f8["..TEXT("Sys227232_name").."]|r|h")
    assertEquals(i.id,0x377a0)

    i = TestCP_PimpMe:ExtractLink("|Hitem:33e87 3 80b56 d2fed2ec d36cd305 d36fd36a 7eff9 0 0 0 4330 d408|h|cffc805f8["..TEXT("Sys212615_name").."]|r|h")
    i = TestCP_PimpMe:ExtractLink("|Hitem:36e08 3 200a75 c989 0 0 0 0 0 0 2db4 c125|h|cffc805f8["..TEXT("Sys224776_name").."]|r|h")
    i = TestCP_PimpMe:ExtractLink("|Hitem:3736c 3 a55 d206 0 0 0 0 0 0 2134 19d4|h|cff00ff00["..TEXT("Sys226156_name").."]|r|h")
    i = TestCP_PimpMe:ExtractLink("|Hitem:36df1 1 60b72 d241c9a1 d205c875 c876c9a2 7f034 7f084 7f1d8 0 2c68 94dd|h|cffffffff["..TEXT("Sys224753_name").."]|r|h")
    i = TestCP_PimpMe:ExtractLink("|Hitem:33b07 3 40a6c c8adcc31 0 0 0 0 0 0 2a30 4299|h|cfff68e56["..TEXT("Sys211719_name").."]|r|h")
    i = TestCP_PimpMe:ExtractLink("|Hitem:377b1 2 77500d64 d5a5d577 d5a4d4d6 d4c7d4c8 7f1b6 7f18e 0 0 3536 a47c|h|cffc805f8["..TEXT("Sys227249_name").."]|r|h")
end

function TestCP_PimpMe:ExtractLink(itemlink)

    local item_data = Charplan.Pimp.ExtractLink(itemlink)
    local test = Charplan.Pimp.GenerateLink(item_data)

    assertEquals(test,itemlink)

    return item_data
end



function TestCP_PimpMe:classSetUp()
    Charplan.DB.Load()
end

function TestCP_PimpMe:classTearDown()
    Charplan.DB.Release()
end


