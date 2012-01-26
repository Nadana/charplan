

TestPimpMe ={}


function TestPimpMe:testLinks()

    local i = TestPimpMe:ExtractLink("|Hitem:377a0 3 358e0c74 d41fd41a d56bd56d d48fd56c 0 0 0 0 2d50 82a0|h|cffc805f8[Ardmonds Helm]|r|h")
    assertEquals(i.id,0x377a0)
end

function TestPimpMe:ExtractLink(itemlink)

    local item_data = CP.Pimp.ExtractLink(itemlink)
    local test = CP.Pimp.GenerateLink(item_data)

    assertEquals(test,itemlink)

    return item_data
end


