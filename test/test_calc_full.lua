-- coding: utf-8
TestCP_CalcFull={}

--[[
 How to:
  -> Ingame: import equipment into cp  & run command "/cp s"
  -> logout
  -> open savevariables.lua and copy the "CP_FullCharInfo" block
  -> create a new function (named "TestCP_CalcFull:testXXXX")
  -> paste the CP_FullCharInfo variable into it
  -> at the end of the function add the test call: "TestCP_CalcFull:DoFullCharCheck(CP_FullCharInfo)"
]]
function TestCP_CalcFull:testLestatFull()
    local s = CP.Calc.STATS

	local CP_FullCharInfo = {
		["cards"] = {
			[2] = 34,
            [3] = 22,
			[4] = 25,
			[5] = 9,
			[6] = 36,
			[12] = 20,
			[13] = 37,
			[14] = 26,
			[15] = 24,
		},
		["item_links"] = {
			[1] = "|Hitem:374c3 0 77060c74 d41bd3b2 d56cd570 d492d574 7f1d9 0 0 0 2d50 9604|h|cffc805f8[Handschützer von Lekani]|r|h",
			[2] = "|Hitem:377ab 0 77050b51 d574d426 d48ed495 d56bd56c 7f084 7f1d8 0 0 1fa4 1876|h|cffc805f8[Grafus leichte Stiefel]|r|h",
			[3] = "|Hitem:36fd0 0 77080c6d d48ed41b d495d56c d574d496 7f19d 0 0 0 2a94 971|h|cffc805f8[Lederjacke der Gräueltat]|r|h",
			[4] = "|Hitem:374c5 0 77090b54 d38dd38b d38ed385 d3d9d3de 7f1d8 0 0 0 20d0 16c2|h|cffc805f8[Beinschützer von Lekani]|r|h",
			[5] = "|Hitem:37fff 2 77070b6a d5a1d56c d4c1d5a0 d4b6d599 0 0 0 0 2968 8404|h|cffc805f8[Herzloser Umhang der Vergeltung]|r|h",
			[6] = "|Hitem:374c4 0 77090b59 d38bd38e d38dd389 d3b2d385 7f1d9 0 0 0 22c4 e5d8|h|cffc805f8[Gurt von Lekani]|r|h",
			[7] = "|Hitem:377a9 2 77090b5d d56cd48e d573d495 d574d496 7f085 0 0 0 2454 2dde|h|cffc805f8[Grafus Schulterpanzer]|r|h",
			[8] = "|Hitem:375bd 0 770c0c6a d3dfd3b3 d3ded3e7 d3e6d3e8 7f175 7f1d8 7f19e 0 2968 e444|h|cffc805f8[Halskette des ruhigen Herzens]|r|h",
			[9] = "|Hitem:33e87 0 c106b c984c894 c9d4c9fc ca10c86c 7f263 7f201 0 0 29cc 10ee|h|cffc805f8[Zorn der Hüterin des Dschungels]|r|h",
			[10] = "|Hitem:36f39 0 770c0d6a d5a1d4c2 d5a0d4c1 d4b6d599 7f19d 7f176 0 0 2968 4814|h|cffc805f8[Dilan'y-Ring]|r|h",
			[11] = "|Hitem:36f39 0 77060b4a d3a7d2de d3a8d3a6 d3e9d3b2 7f19e 0 0 0 1ce8 6098|h|cffc805f8[Dilan'y-Ring]|r|h",
			[12] = "|Hitem:374c6 0 770a0b5f d38ed38b d3b3d3b7 d3dfd3a7 0 0 0 0 251c 9f59|h|cffc805f8[Ohrring von Lekani]|r|h",
			[13] = "|Hitem:374c6 0 77090c47 d3b3d3b2 d3a7d3a6 d3e1d3de 7f084 0 0 0 1bbc 826e|h|cffc805f8[Ohrring von Lekani]|r|h",
			[14] = "|Hitem:33e86 0 770c1075 c86cc844 c858ca38 c984ca10 7f23b 7f264 7f202 7f44e 2db4 b892|h|cffc805f8[Dorn von Yawaka]|r|h",
			[15] = "|Hitem:33f04 0 77060b6a d3b3d3a7 d3e6d3a6 d3ded3df 7f1d9 0 0 0 2968 bf4|h|cffc805f8[Flammenklinge]|r|h",
			[16] = "|Hitem:36691 0 77000d64 d3b5d389 d3a7d3a8 d3e1d3b2 0 0 0 0 2710 8b88|h|cffa864a8[Flügel des kleinen Teufels]|r|h",
			[17] = "|Hitem:377a8 0 770a0b58 d496d426 d56bd48e d573d56c 7f175 0 0 0 2260 bf3|h|cffc805f8[Grafus Helm]|r|h",
		},
		["title"] = 0,
		["skills"] = {
			[490313] = 60,
			[490329] = 0,
			[490346] = 0,
			[490504] = 50,
			[491528] = 0,
			[490347] = 0,
			[490505] = 50,
			[490332] = 65,
			[490506] = 0,
			[491530] = 0,
			[490507] = 0,
			[491531] = 62,
			[490350] = 56,
			[490146] = 0,
			[491533] = 0,
			[490337] = 60,
			[490306] = 64,
			[490448] = 0,
			[490338] = 22,
			[490354] = 0,
			[493019] = 55,
			[492922] = 0,
			[490355] = 50,
			[490434] = 61,
			[490333] = 50,
			[491159] = 62,
			[490317] = 0,
			[490309] = 0,
			[490451] = 0,
			[490341] = 50,
			[490420] = 0,
			[490310] = 0,
			[490326] = 50,
			[490143] = 50,
			[492626] = 0,
			[490311] = 61,
			[491532] = 0,
			[491292] = 52,
			[490316] = 50,
			[490312] = 50,
			[491525] = 60,
			[490344] = 0,
			[491534] = 66,
		},
		["bases"] = {
			[2] = 713,
			[3] = 670,
			[4] = 463,
			[5] = 431,
			[6] = 856,
			[404] = 10,
			[20] = 10,
			[403] = 0,
		},
		["result"] = {
        	-- INVALID: [s.MANA] = 100, -- PLZ FIX

			--[s.PACCMH] = 9884,
			[s.MATK] = 1147,
			[s.PDEF] = 29616,
			[s.MDEF] = 24072,
			[2] = 1686,
			[4] = 561,
			--[s.HP] = 55084,
			[s.EVADE] = 8532,
			[5] = 520,
			[404] = 2883,
			[20] = 593,
			[s.PCRITOH] = 2763,
			[22] = 0,
			[3] = 5424,
			[s.DEX] = 10534,
			[s.PATK] = 37074,
			[403] = 2753,
		},
		["class"] = "THIEF",
        level = 67, -- PLZ FIX
        sec_level = 67, -- PLZ FIX
	}
	TestCP_CalcFull:DoFullCharCheck(CP_FullCharInfo)
end

function TestCP_CalcFull:testLestatNoWeapons()
    local s = CP.Calc.STATS

	local CP_FullCharInfo = {
		["cards"] = {
			[2] = 34,
			[3] = 22,
			[4] = 25,
			[5] = 9,
			[6] = 36,
			[12] = 20,
			[13] = 37,
			[14] = 26,
			[15] = 24,
		},
		["item_links"] = {
			[1] = "|Hitem:374c3 0 77060c74 d41bd3b2 d56cd570 d492d574 7f1d9 0 0 0 2d50 9604|h|cffc805f8[Handschützer von Lekani]|r|h",
			[2] = "|Hitem:377ab 0 77050b51 d574d426 d48ed495 d56bd56c 7f084 7f1d8 0 0 1fa4 1876|h|cffc805f8[Grafus leichte Stiefel]|r|h",
			[3] = "|Hitem:36fd0 0 77080c6d d48ed41b d495d56c d574d496 7f19d 0 0 0 2a94 971|h|cffc805f8[Lederjacke der Gräueltat]|r|h",
			[4] = "|Hitem:374c5 0 77090b54 d38dd38b d38ed385 d3d9d3de 7f1d8 0 0 0 20d0 16c2|h|cffc805f8[Beinschützer von Lekani]|r|h",
			[5] = "|Hitem:37fff 2 77070b6a d5a1d56c d4c1d5a0 d4b6d599 0 0 0 0 2968 8404|h|cffc805f8[Herzloser Umhang der Vergeltung]|r|h",
			[6] = "|Hitem:374c4 0 77090b59 d38bd38e d38dd389 d3b2d385 7f1d9 0 0 0 22c4 e5d8|h|cffc805f8[Gurt von Lekani]|r|h",
			[7] = "|Hitem:377a9 2 77090b5d d56cd48e d573d495 d574d496 7f085 0 0 0 2454 2dde|h|cffc805f8[Grafus Schulterpanzer]|r|h",
			[8] = "|Hitem:375bd 0 770c0c6a d3dfd3b3 d3ded3e7 d3e6d3e8 7f175 7f1d8 7f19e 0 2968 e444|h|cffc805f8[Halskette des ruhigen Herzens]|r|h",
			[9] = "|Hitem:36f39 0 770c0d6a d5a1d4c2 d5a0d4c1 d4b6d599 7f19d 7f176 0 0 2968 4814|h|cffc805f8[Dilan'y-Ring]|r|h",
			[10] = "|Hitem:36f39 0 77060b4a d3a7d2de d3a8d3a6 d3e9d3b2 7f19e 0 0 0 1ce8 6098|h|cffc805f8[Dilan'y-Ring]|r|h",
			[11] = "|Hitem:374c6 0 770a0b5f d38ed38b d3b3d3b7 d3dfd3a7 0 0 0 0 251c 9f59|h|cffc805f8[Ohrring von Lekani]|r|h",
			[12] = "|Hitem:374c6 0 77090c47 d3b3d3b2 d3a7d3a6 d3e1d3de 7f084 0 0 0 1bbc 826e|h|cffc805f8[Ohrring von Lekani]|r|h",
			[13] = "|Hitem:36691 0 77000d64 d3b5d389 d3a7d3a8 d3e1d3b2 0 0 0 0 2710 8b88|h|cffa864a8[Flügel des kleinen Teufels]|r|h",
			[14] = "|Hitem:377a8 0 770a0b58 d496d426 d56bd48e d573d56c 7f175 0 0 0 2260 bf3|h|cffc805f8[Grafus Helm]|r|h",
		},
		["title"] = 0,
		["skills"] = {
			[490313] = 60,
			[490329] = 0,
			[490346] = 0,
			[490504] = 50,
			[491528] = 0,
			[490347] = 0,
			[490505] = 50,
			[490332] = 65,
			[490506] = 0,
			[491530] = 0,
			[490507] = 0,
			[491531] = 62,
			[490350] = 56,
			[490146] = 0,
			[491533] = 0,
			[490337] = 60,
			[490306] = 64,
			[490448] = 0,
			[490338] = 22,
			[490354] = 0,
			[493019] = 55,
			[492922] = 0,
			[490355] = 50,
			[490434] = 61,
			[490333] = 50,
			[491159] = 62,
			[490317] = 0,
			[490309] = 0,
			[490451] = 0,
			[490341] = 50,
			[490420] = 0,
			[490310] = 0,
			[490326] = 50,
			[490143] = 50,
			[492626] = 0,
			[490311] = 61,
			[491532] = 0,
			[491292] = 52,
			[490316] = 50,
			[490312] = 50,
			[491525] = 60,
			[490344] = 0,
			[491534] = 66,
		},
		["bases"] = {
			[2] = 713,
			[3] = 670,
			[4] = 463,
			[5] = 431,
			[6] = 856,
			[404] = 10,
			[20] = 10,
			[403] = 0,
		},
		["result"] = {
        	-- INVALID: [s.MANA] = 100, -- PLZ FIX

			--[s.PACCMH] = 9489,
			[s.MATK] = 1115,
			[s.PDEF] = 28888,
			[s.MDEF] = 24009,
			[2] = 1499,
			[4] = 545,
			--[s.HP] = 52342,
			[s.EVADE] = 8190,
			[5] = 497,
			[404] = 2763,
			[20] = 593,
			[s.PCRITOH] = 2763,
			[22] = 0,
			[3] = 5020,
			[s.DEX] = 10096,
			[s.PATK] = 28910,
			[403] = 2753,
		},
		["class"] = "THIEF",
        level = 67, -- PLZ FIX
        sec_level = 67, -- PLZ FIX
	}

	TestCP_CalcFull:DoFullCharCheck(CP_FullCharInfo)
end

function TestCP_CalcFull:testLestatInclusiveTitle()
    local s = CP.Calc.STATS

	local CP_FullCharInfo = {
		["cards"] = {
			[2] = 34,
			[3] = 22,
			[4] = 25,
			[5] = 9,
			[6] = 36,
			[12] = 20,
			[13] = 37,
			[14] = 26,
			[15] = 24,
		},
		["item_links"] = {
			[1] = "|Hitem:374c3 0 77060c74 d41bd3b2 d56cd570 d492d574 7f1d9 0 0 0 2d50 9604|h|cffc805f8[Handschützer von Lekani]|r|h",
			[2] = "|Hitem:377ab 0 77050b51 d574d426 d48ed495 d56bd56c 7f084 7f1d8 0 0 1fa4 1876|h|cffc805f8[Grafus leichte Stiefel]|r|h",
			[3] = "|Hitem:36fd0 0 77080c6d d48ed41b d495d56c d574d496 7f19d 0 0 0 2a94 971|h|cffc805f8[Lederjacke der Gräueltat]|r|h",
			[4] = "|Hitem:374c5 0 77090b54 d38dd38b d38ed385 d3d9d3de 7f1d8 0 0 0 20d0 16c2|h|cffc805f8[Beinschützer von Lekani]|r|h",
			[5] = "|Hitem:37fff 2 77070b6a d5a1d56c d4c1d5a0 d4b6d599 0 0 0 0 2968 8404|h|cffc805f8[Herzloser Umhang der Vergeltung]|r|h",
			[6] = "|Hitem:374c4 0 77090b59 d38bd38e d38dd389 d3b2d385 7f1d9 0 0 0 22c4 e5d8|h|cffc805f8[Gurt von Lekani]|r|h",
			[7] = "|Hitem:377a9 2 77090b5d d56cd48e d573d495 d574d496 7f085 0 0 0 2454 2dde|h|cffc805f8[Grafus Schulterpanzer]|r|h",
			[8] = "|Hitem:375bd 0 770c0c6a d3dfd3b3 d3ded3e7 d3e6d3e8 7f175 7f1d8 7f19e 0 2968 e444|h|cffc805f8[Halskette des ruhigen Herzens]|r|h",
			[9] = "|Hitem:33e87 0 770c106b c984c894 c9d4c9fc ca10c86c 7f263 7f201 0 0 29cc 8f9d|h|cffc805f8[Zorn der Hüterin des Dschungels]|r|h",
			[10] = "|Hitem:36f39 0 770c0d6a d5a1d4c2 d5a0d4c1 d4b6d599 7f19d 7f176 0 0 2968 4814|h|cffc805f8[Dilan'y-Ring]|r|h",
			[11] = "|Hitem:36f39 0 77060b4a d3a7d2de d3a8d3a6 d3e9d3b2 7f19e 0 0 0 1ce8 6098|h|cffc805f8[Dilan'y-Ring]|r|h",
			[12] = "|Hitem:374c6 0 770a0b5f d38ed38b d3b3d3b7 d3dfd3a7 0 0 0 0 251c 9f59|h|cffc805f8[Ohrring von Lekani]|r|h",
			[13] = "|Hitem:374c6 0 77090c47 d3b3d3b2 d3a7d3a6 d3e1d3de 7f084 0 0 0 1bbc 826e|h|cffc805f8[Ohrring von Lekani]|r|h",
			[14] = "|Hitem:33e86 0 770c1075 c86cc844 c858ca38 c984ca10 7f23b 7f264 7f202 7f44e 2db4 b892|h|cffc805f8[Dorn von Yawaka]|r|h",
			[15] = "|Hitem:33f04 0 77060b6a d3b3d3a7 d3e6d3a6 d3ded3df 7f1d9 0 0 0 2968 bf4|h|cffc805f8[Flammenklinge]|r|h",
			[16] = "|Hitem:36691 0 77000d64 d3b5d389 d3a7d3a8 d3e1d3b2 0 0 0 0 2710 8b88|h|cffa864a8[Flügel des kleinen Teufels]|r|h",
			[17] = "|Hitem:377a8 0 770a0b58 d496d426 d56bd48e d573d56c 7f175 0 0 0 2260 bf3|h|cffc805f8[Grafus Helm]|r|h",
		},
		["title"] = 530724,
		["skills"] = {
			[490313] = 60,
			[490329] = 0,
			[490346] = 0,
			[490504] = 50,
			[491528] = 0,
			[490347] = 0,
			[490505] = 50,
			[490332] = 65,
			[490506] = 0,
			[491530] = 0,
			[490507] = 0,
			[491531] = 62,
			[490350] = 56,
			[490146] = 0,
			[491533] = 0,
			[490337] = 60,
			[490306] = 64,
			[490448] = 0,
			[490338] = 22,
			[490354] = 0,
			[493019] = 55,
			[492922] = 0,
			[490355] = 50,
			[490434] = 61,
			[490333] = 50,
			[491159] = 62,
			[490317] = 0,
			[490309] = 0,
			[490451] = 0,
			[490341] = 50,
			[490420] = 0,
			[490310] = 0,
			[490326] = 50,
			[490143] = 50,
			[492626] = 0,
			[490311] = 61,
			[491532] = 0,
			[491292] = 52,
			[490316] = 50,
			[490312] = 50,
			[491525] = 60,
			[490344] = 0,
			[491534] = 66,
		},
		["bases"] = {
			[2] = 713,
			[3] = 670,
			[4] = 463,
			[5] = 431,
			[6] = 856,
			[404] = 10,
			[20] = 10,
			[403] = 0,
		},
		["result"] = {
        	-- INVALID: [s.MANA] = 100,

			--[s.PACCMH] = 9884,
			[s.MATK] = 1147,
			[s.PDEF] = 29986,
			[s.MDEF] = 24072,
			[2] = 1686,
			[4] = 561,
			--[s.HP] = 56113,
			[s.EVADE] = 8532,
			[5] = 520,
			[404] = 2883,
			[20] = 593,
			[s.PCRITOH] = 2763,
			[22] = 0,
			[3] = 5630,
			[s.DEX] = 10534,
			[s.PATK] = 38121,
			[403] = 2753,
		},
		["class"] = "THIEF",
        level = 67, -- PLZ FIX
        sec_level = 67, -- PLZ FIX
	}
	TestCP_CalcFull:DoFullCharCheck(CP_FullCharInfo)
end
function TestCP_CalcFull:testThoros()
    local s = CP.Calc.STATS

    local CP_FullCharInfo = {
        ["class"]= "WARDEN",
        ["cards"] = {
            [2] = 6, [3] = 7, [4] = 8, [6] = 14, [13] = 18,[15] = 4,
        },
        ["item_links"] = {
            [1] = "|Hitem:36da4 0 77010a64 c9b5 0 0 0 0 0 0 1f40 2ded|h|cff00ff00[Bablis' geschmiedete Handschuhe]|r|h",
            [2] = "|Hitem:36dae 0 77010a64 c9b5 0 0 0 0 0 0 1f40 cbcf|h|cff00ff00[Abgefahrene Stiefel]|r|h",
            [3] = "|Hitem:36d65 0 77010a64 c9b5 0 0 0 0 0 0 1f40 ca47|h|cff00ff00[Flammenbrustpanzer der Bodos]|r|h",
            [4] = "|Hitem:36d98 0 77010a64 c9b5 0 0 0 0 0 0 1f40 d961|h|cff00ff00[Beinpanzer der Schuld]|r|h",
            [5] = "|Hitem:36c06 0 77010a64 c9a0c9b5 0 0 0 0 0 0 1f40 13d3|h|cff0072bc[Schlangenabwehr-Umhang des Mutes]|r|h",
            [6] = "|Hitem:36d5e 0 77010a64 c9b5 0 0 0 0 0 0 1f40 4fd1|h|cff00ff00[Grüner Dornkettengürtel]|r|h",
            [7] = "|Hitem:36d55 0 77010a64 c9b5 0 0 0 0 0 0 1f40 d818|h|cff00ff00[Kampfschulterschützer]|r|h",
            [8] = "|Hitem:36141 0 77010a64 c960c9c4 0 0 0 0 0 0 1f40 88a0|h|cff0072bc[Kette aus Carfcamois Beute]|r|h",
            [9] = "|Hitem:33c0f 0 77000a64 c9b4c875 0 0 0 0 0 0 1f40 94d4|h|cff0072bc[Norzens Windläufer-Langbogen]|r|h",
            [10] = "|Hitem:363ce 1 77010a55 c99ac9af 0 0 0 0 0 0 2134 9fd8|h|cff0072bc[Ring des heldenhaften Aufruhrs]|r|h",
            [11] = "|Hitem:36bf9 0 77010a64 c89d 0 0 0 0 0 0 1f40 737f|h|cff00ff00[Mysteriöser Ring]|r|h",
            [12] = "|Hitem:36fee 0 77010a64 c9b5 0 0 0 0 0 0 1f40 4f9a|h|cff00ff00[Heldengedenken-Ohrring]|r|h",
            [13] = "|Hitem:363d2 1 77010a54 c99cc871 0 0 0 0 0 0 20d0 9438|h|cff0072bc[Ohrring des heldenhaften Zorns]|r|h",
            [14] = "|Hitem:33c0e 0 77010a64 c9a0c9b5 0 0 0 0 0 0 1f36 87b1|h|cff0072bc[Schwert der Wut des Feuergeistes]|r|h",
            [15] = "|Hitem:369b3 0 77000a64 c9a0c9b5 0 0 0 0 0 0 1f40 86|h|cff0072bc[Heldenhelm des Schwertkämpfers]|r|h",
        },
        ["title"] = 0,
        ["bases"] = {
            [2] = 543,[3] = 460,[4] = 417,[5] = 434,[6] = 399, [20] = 10,
            [403] = 0, [404] = 10, [405] = 10, [409] = 359,
        },
        ["result"] = {
            [2] = 956,
            [3] = 596,
            [4] = 430,
            [5] = 439,
            [s.DEX] = 482,
            --[s.HP] = 4443, -- HP 3761.2
            --[9] = 2892, -- MP 2625
            --[12] = 1757, -- PATK 1758
            --[13] = 2899, -- PDEF 2898
            [14] = 2612, -- MDEF
            --[15] = 880, -- MATK 879
            [17] = 375, -- EVADE
            [20] = 20,
            [22] = 0,
            --[404] = 20, -- PCRITMH 10
            --[405] = 20, -- PCRITOH 10
            --[409] = 433, -- PACCMH 359
            [403] = 10,
        },
        level = 54,
    }

    TestCP_CalcFull:DoFullCharCheck(CP_FullCharInfo)
end

local function ApplyBonus(stats, effect)
    for i=1,#effect,2 do
        stats[effect[i]] = stats[effect[i]] + effect[i+1]
    end
end

function  TestCP_CalcFull:DoFullCharCheck(info)

    -- data prepase
    TestCP_CalcFull.cur_data = info

    CP.Items={}
    for _,item in pairs(info.item_links) do
        CP.ApplyLinkItem(item,nil,true)
    end

    CP.Calc.Init()

    -- !Same as in calculate
    local values = CP.Calc.NewStats()
    values = values + info.bases
    values = values + CP.Calc.GetBasesCalced()
    values = values + CP.Calc.GetSkillBonus()
    values = values + info.cards
    values = values + CP.Calc.GetArchievementBonus()
    values = values + CP.Calc.GetAllItemsBonus()
    CP.Calc.DependingStats(values)
    -- !end

    TestCP_Calc:CompareStats(values, info.result,nil,0.9) -- TODO: tolerance (last value) should be 0
end

function TestCP_CalcFull.HOOKED_GetCurrentTitle()
    return TestCP_CalcFull.cur_data.title
end

function TestCP_CalcFull.HOOKED_UnitClassToken(unit)
    return TestCP_CalcFull.cur_data.class
end

function TestCP_CalcFull.HOOKED_UnitLevel(unit)
    return  TestCP_CalcFull.cur_data.level,
            TestCP_CalcFull.cur_data.sec_level
end

function TestCP_CalcFull.HOOKED_GetListOfSkills()
    if TestCP_CalcFull.cur_data and TestCP_CalcFull.cur_data.skills then
        return TestCP_CalcFull.cur_data.skills
    end
    return {}
end

function TestCP_CalcFull:classSetUp()
    self.old_data = CP.Utils.TableCopy(CP.Items)

    self.old_GetCurrentTitle = GetCurrentTitle
    GetCurrentTitle = TestCP_CalcFull.HOOKED_GetCurrentTitle

    self.old_UnitClassToken = UnitClassToken
    UnitClassToken = TestCP_CalcFull.HOOKED_UnitClassToken

    self.old_UnitLevel = UnitLevel
    UnitLevel = TestCP_CalcFull.HOOKED_UnitLevel

    self.old_GetListOfSkills = CP.Calc.GetListOfSkills
    CP.Calc.GetListOfSkills = TestCP_CalcFull.HOOKED_GetListOfSkills

    CP.DB.Load()
end

function TestCP_CalcFull:classTearDown()
    GetCurrentTitle = self.old_GetCurrentTitle
    UnitClassToken = self.old_UnitClassToken
    UnitLevel = self.old_UnitLevel
    CP.Calc.GetListOfSkills = self.old_GetListOfSkills
    CP.Items = self.old_data
    CP.Calc.Init()
    CP.DB.Release()
end


------------------------------------------
-- SnapShot Tests
------------------------------------------
local fct,err = loadfile('interface/addons/charplan/test/test_calc_full_data.lua')
local snapshots = fct()
for nid,data in pairs(snapshots) do
    local name=string.format("testSnap%s_%s",(data.name or ""),nid)
    TestCP_CalcFull[name]=function()
        TestCP_CalcFull:DoFullCharCheck(data)
    end
end




