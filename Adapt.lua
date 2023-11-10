--[[ ADAPT: Almost-Default Animated PortraiTs

	This small mod animates the unit frames for (nearly) any UI.

	When a mod requests a portrait to be drawn, this mod intercepts
	the request and instead draws a model to the dimensions of the
	intended texture, dynamically creating the model if one didn't
	exist for that texture yet.	

	New in 1.9:
	- 4.0 (Cataclysm) support

  1.92, 8/28/12, fixed _ tainting
  1.91, 8/27/12, 5.0 (Mists of Pandaria) update
  1.9, 9/2/10, 4.0 (Cataclysm) support, TargetFrameToTPortrait defaulted DontUse
	1.82, 10/8/08, scroll fix, /adapt goes to options panel
	1.81, 8/8/08, updated for WotLK (toc, this->self)
	1.8, 4/12/08, moved options to new interface options, added full model option
	1.71, 1/12/07, fixed initialization
	1.7, 1/11/07, fixed taint issue with default ToT
	1.6, 10/4/06, edits for lua 5.1
	1.5, 8/21/06, changed DressUpModel to PlayerModel, moved SetCamera OnUpdate to OnShow
	1.4, 6/22/06, disabled mouse on portraits, added known frames to /adapt list
	1.3, 6/11/06, /adapt animate/unanimate options, visibility fix by Lafiell,
				  attempt at more flexibility with frameStrata 
]]

Adapt = {
	Version = 1.92, -- version
	Textures = {}, -- table of textures models are replacing
	xOffset = 0, -- x offset of model
	yOffset = -2, -- y offset of model
	StrataByIndex = { "BACKGROUND","LOW","MEDIUM","HIGH","TOOLTIP" }, -- for strata guessing
	StrataByName = { ["BACKGROUND"]=1, ["LOW"]=2, ["MEDIUM"]=3, ["HIGH"]=4, ["TOOLTIP"]=5 }
}

-- Adapt_Settings is the SavedVariable
function Adapt.CreateDefaults()
	Adapt_Settings = {
		Shape = "CIRCLE",	-- "CIRCLE" or "SQUARE" stretched to whole texture or shrunk within
		Back = "ON",		-- "ON" or "OFF" whether background shows
		ClassColor = "OFF",		-- "ON" or "OFF" whether class color background shows
		DontUse = { ["TargetFrameToTPortrait"]=1 }
	}
end
Adapt.CreateDefaults()

-- hooked SetPortraitTexture: display model if UnitIsVisible otherwise display old texture
function Adapt.newSetPortraitTexture(texture,unit)

	local swapHappened = nil -- whether a texture was swapped with a model

	if texture and texture.GetLeft then

		local textureName = texture:GetName()
		local xpos = texture:GetLeft()
		local ypos = texture:GetTop()
		local _

		if textureName and xpos and ypos and UnitExists(unit) and not Adapt_Settings.DontUse[textureName] then

			if(UnitIsVisible(unit)) then
				local width=texture:GetRight()-xpos
				local height=ypos-texture:GetBottom()
				if width>24 and height>24 then

					if not Adapt.Textures[textureName] then
						Adapt.CreateModel(texture)
					end
					local m = Adapt.Textures[textureName].modelLayer
					-- m = CharacterModelFrame
					m:SetUnit(unit)
					
					
					raceName, raceFile = UnitRace(unit)
					
					if raceFile=="Tauren" then
						name1 = UnitAura(unit, "Походный облик")
						name2 = UnitAura(unit, "Призрачный волк")
						name3 = UnitAura(unit, "Облик кошки")
						name4 = UnitAura(unit, "Облик медведя")
						
						if name1 or name2 or name3 or name4 then
							m:SetCamera(0)
						else
							m:SetCamera(1)
						end
						
					elseif raceFile=="Vulpera" then
						name1 = UnitAura(unit, "Походный облик")
						name2 = UnitAura(unit, "Призрачный волк")
						name3 = UnitAura(unit, "Облик кошки")
						name4 = UnitAura(unit, "Облик медведя")
						
						if name1 or name2 or name3 or name4 then
							m:SetCamera(0)
						else
							m:SetCamera(1)
						end
						
					elseif raceFile=="Scourge" then
						name1 = UnitAura(unit, "Походный облик")
						name2 = UnitAura(unit, "Призрачный волк")
						name3 = UnitAura(unit, "Облик кошки")
						name4 = UnitAura(unit, "Облик медведя")
						
						if name1 or name2 or name3 or name4 then
							m:SetCamera(0)
						else
							m:SetCamera(1)
						end
						
					elseif raceFile=="Dracthyr" then
						name1 = UnitAura(unit, "Походный облик")
						name2 = UnitAura(unit, "Призрачный волк")
						name3 = UnitAura(unit, "Облик кошки")
						name4 = UnitAura(unit, "Облик медведя")
						name5 = UnitAura(unit, "Драконий облик")
						
						if UnitSex(unit)==2 and name5 then
							m:SetCamera(1)
						elseif name1 or name2 or name3 or name4 or UnitSex(unit)==2 then
							m:SetCamera(0)
						else
							m:SetCamera(1)
						end
						
						
					else
						m:SetCamera(0)
					end
					
					_,Adapt.Textures[textureName].class = 
					Adapt.ColorBackground(textureName,Adapt.Textures[textureName].class)
					texture:Hide()

					Adapt.Textures[textureName]:Show()

					-- Show the Model for the case, it was show by the code below - By Lafiell
					m:Show()
					--print(raceFile)
					
					

					swapHappened = 1
				end

			else
				-- Unit not in Sight - By Lafiell
				if (textureName and Adapt.Textures[textureName]) then
					Adapt.Textures[textureName].modelLayer:Hide()
				end
			end

		end
	end

	if not swapHappened then
--		Adapt.oldSetPortraitTexture(texture,unit)
		texture:Show()
		if textureName and Adapt.Textures[textureName] then
			Adapt.Textures[textureName]:Hide()
		end
	end

end

function Adapt.CreateModel(texture)
	local textureName = texture:GetName()
	local width = texture:GetWidth()
	local height = texture:GetHeight()
	if texture.GetParent and texture:GetParent().GetFrameStrata and texture:GetParent():GetFrameStrata()=="BACKGROUND" then
		texture:GetParent():SetFrameStrata("LOW")
	end
	local modelName = textureName.."Model"
	Adapt.Textures[textureName] = CreateFrame("Button",modelName,texture:GetParent())
	local frame = Adapt.Textures[textureName]
	frame:EnableMouse(false)
	frame:SetWidth(width)
	frame:SetHeight(height)
	frame.width = width
	frame.height = height
	frame:SetPoint("CENTER",texture,"CENTER",0,0)
	local strata
	if texture.GetParent then
		strata = Adapt.StrataByIndex[(Adapt.StrataByName[texture:GetParent():GetFrameStrata() or ""] or 1)-1]
	end
	frame:SetFrameStrata(strata or "BACKGROUND")
	frame.backLayer = frame:CreateTexture(modelName.."Back","BACKGROUND")
	frame.backLayer:SetTexture("Interface\\AddOns\\Adapt\\Adapt-ModelBack")
	frame.backLayer:SetWidth(width)
	frame.backLayer:SetHeight(height)
	frame.backLayer:SetPoint("CENTER",frame,"CENTER",0,0)
	if Adapt_Settings.Back=="OFF" then
		frame.backLayer:Hide()
	end
	
	frame.modelLayer = CreateFrame("PlayerModel",modelName.."Model",texture:GetParent())
	frame.modelLayer:SetPoint("CENTER",frame,"CENTER",0,0)
	frame.modelLayer:SetFrameLevel(1)
	frame.modelLayer:SetScript("OnShow",function(self) self:SetCamera(0) end)
	

	
	frame.maskLayer = texture:GetParent():CreateTexture()
	frame.maskLayer:SetDrawLayer("OVERLAY")
	--frame.modelLayer:SetFrameLevel(50)
	if Adapt_Settings.ClassColor=="OFF" then
		frame.maskLayer:SetWidth(width-2.5)
		frame.maskLayer:SetHeight(height)
		frame.maskLayer:SetPoint("CENTER",frame,"CENTER",-0.5,-1.5)
	else 
		frame.maskLayer:SetWidth(width-4)
		frame.maskLayer:SetHeight(height)
		frame.maskLayer:SetPoint("CENTER",frame,"CENTER",-0.5,-1.5)
	end

	frame.maskLayer:SetTexture("Interface\\AddOns\\Adapt\\Adapt-Mask")
	if Adapt_Settings.Shape=="SQUARE" then
		frame.maskLayer:Hide()
	end
	
	Adapt.Shape(textureName)
	frame.modelLayer.timer = 0
end

function Adapt.OnLoad(self)
	hooksecurefunc("SetPortraitTexture",Adapt.newSetPortraitTexture)
	SlashCmdList["ADAPT"] = Adapt.SlashHandler
	SLASH_ADAPT1 = "/adapt"
	self:RegisterEvent("PLAYER_LOGIN")
end

function Adapt.OnEvent(self,event)
	if not Adapt_Settings.DontUse then
		-- default ToT has the perl epillepsy problem of constantly going back to first frame
		Adapt_Settings.DontUse = { ["TargetFrameToTPortrait"]=1 }
	elseif Adapt_Settings.DontUse["TargetofTargetPortrait"] then
		-- users of older versions have old ToT frame marked DontUse, switch them to new frame
		Adapt_Settings.DontUse["TargetofTargetPortrait"] = nil
		Adapt_Settings.DontUse["TargetFrameToTPortrait"] = 1
	end
end

function Adapt.SlashHandler()
	InterfaceOptionsFrame_OpenToCategory(AdaptOptions)
end

-- color background by raid class color
function Adapt.ColorBackground(textureName,class)
	local back = Adapt.Textures[textureName].backLayer
	local mask = Adapt.Textures[textureName].maskLayer
	local color = RAID_CLASS_COLORS[class or ""]
	if Adapt_Settings.ClassColor=="OFF" then
		back:SetVertexColor(.1,.1,.1,1)
		mask:SetVertexColor(0,0,0,1)
	elseif color then
		back:SetVertexColor(.1,.1,.1,1)
		mask:SetVertexColor(0,0,0,1)
	else
		back:SetVertexColor(.1,.1,.1,1)
		mask:SetVertexColor(0,0,0,1)
	end

	if Adapt_Settings.Back=="OFF" then
		back:Hide()
	end
end

function Adapt.Refresh()
	Adapt.Reshape()
	Adapt.Reback()
	Adapt.Remodel()
	AdaptOptionsCheckButtonBackColor:SetChecked((Adapt_Settings.ClassColor=="ON") and 1 or nil)

end

function Adapt.Remodel()
	--local camera = 0
	--for i in pairs(Adapt.Textures) do
	--	Adapt.Textures[i].modelLayer:SetCamera(camera)
	--end
	AdaptOptionsCheckButtonFullModel:SetChecked(Adapt_Settings.FullModel)
end

function Adapt.Reback()
	for i in pairs(Adapt.Textures) do
		if Adapt_Settings.Back=="ON" then
			Adapt.Textures[i].backLayer:Show()
			Adapt.Textures[i].maskLayer:Show()
		else
			Adapt.Textures[i].backLayer:Hide()
			Adapt.Textures[i].maskLayer:Hide()
		end
	end
	AdaptOptionsCheckButtonTransparent:SetChecked((Adapt_Settings.Back=="OFF") and 1 or nil)
end

function Adapt.Recolor()
	Adapt.needReload = 1

	if Adapt_Settings.Back=="OFF" then
		back:Hide()
		mask:Hide()
	end
	
	AdaptOptionsCheckButtonBackColor:SetChecked((Adapt_Settings.ClassColor=="ON") and 1 or nil)
	
end

-- sets texcoords and width/height of all known backgrounds and models
function Adapt.Reshape()
	for i in pairs(Adapt.Textures) do
		Adapt.Shape(i)
	end
	AdaptOptionsPortraitBorder:SetTexture((Adapt_Settings.Shape=="CIRCLE") and "Interface\\Addons\\Adapt\\CircleBorder" or "Interface\\Addons\\Adapt\\SquareBorder")
	AdaptOptionsCheckButtonSquare:SetChecked((Adapt_Settings.Shape=="SQUARE") and 1 or nil)
end

-- shapes an individual texture (named as a string) to square or circle.
-- square is anchored to two corners of the texture
-- circle is anchored to the center and shrunk slightly
function Adapt.Shape(i)
	if not i or type(i)~="string" or not Adapt.Textures[i] then
		return
	end

	local back = Adapt.Textures[i].backLayer
	local model = Adapt.Textures[i].modelLayer
	local mask = Adapt.Textures[i].maskLayer
	local texture = getglobal(i)
	if texture then
		width = texture:GetWidth()
		height = texture:GetHeight()
	else
		width = Adapt.Textures[i].width
		height = Adapt.Textures[i].height
	end
	if Adapt_Settings.Shape=="SQUARE" then
		back:SetTexCoord(.2,.8,.2,.8)
		back:ClearAllPoints()
		back:SetPoint("TOPLEFT",i,"TOPLEFT")
		back:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",Adapt.xOffset,Adapt.yOffset)
		model:ClearAllPoints()
		model:SetPoint("TOPLEFT",i,"TOPLEFT")
		model:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",Adapt.xOffset,Adapt.yOffset)
		mask:Hide()
	else
		back:SetTexCoord(0,1,0,1)
		back:ClearAllPoints()
		back:SetPoint("CENTER",i,"CENTER",Adapt.xOffset,Adapt.yOffset)
		back:SetWidth(width)
		back:SetHeight(height)
		model:ClearAllPoints()
		model:SetPoint("CENTER",i,"CENTER",Adapt.xOffset,Adapt.yOffset)
		model:SetWidth(width*.75)
		model:SetHeight(height*.75)
		mask:Show()

	end
end


--[[ Options ]]

Adapt.OptionsControls = {
	["AdaptOptionsCheckButtonSquare"] = { AdaptLocal.SQUAREOPTLABEL, AdaptLocal.SQUAREOPTTOOLTIP },
	["AdaptOptionsCheckButtonTransparent"] = { AdaptLocal.BACKOPTLABEL, AdaptLocal.BACKOPTTOOLTIP },
	["AdaptOptionsCheckButtonFullModel"] = { AdaptLocal.MODELOPTLABEL, AdaptLocal.MODELOPTTOOLTIP },
	["AdaptOptionsCheckButtonBackColor"] = { AdaptLocal.BACKCOLORLABEL, AdaptLocal.BACKCOLORTOOLTIP },
}

function Adapt.OptionsOnLoad(panel)
	panel.name = "Adapt"
	panel.okay = Adapt.OptionsOk
	panel.cancel = Adapt.OptionsCancel
	panel.default = Adapt.OptionsDefault
	InterfaceOptions_AddCategory(panel)
	getglobal(panel:GetName().."Version"):SetText(AdaptLocal.VERSION.." "..Adapt.Version)
	getglobal(panel:GetName().."SubText"):SetText(AdaptLocal.OPTSUBTEXT)
	getglobal(panel:GetName().."ListDescription"):SetText(AdaptLocal.OPTLISTDESC)
	getglobal(panel:GetName().."ListHeader"):SetText(AdaptLocal.OPTLISTHEADER)

	for i in pairs(Adapt.OptionsControls) do
		getglobal(i.."Text"):SetText(Adapt.OptionsControls[i][1])
		getglobal(i).tooltipText = Adapt.OptionsControls[i][2]
	end
end 

-- the OnShow runs every time the "Adapt" category is clicked, even if already showing
function Adapt.OptionsOnShow(panel)
	SetPortraitTexture(AdaptOptionsPortrait,"player")
	Adapt.Refresh()
	Adapt.OptionsCreateList()
	Adapt.OptionsStoreOldSettings()
end

-- the checkbutton (shape, back, fullmodel) OnClick
function Adapt.OptionsOnClick(button)
	if button:GetChecked() then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	if button==AdaptOptionsCheckButtonSquare then
		Adapt_Settings.Shape = AdaptOptionsCheckButtonSquare:GetChecked() and "SQUARE" or "CIRCLE"
		Adapt.Reshape()
	elseif button==AdaptOptionsCheckButtonTransparent then
		Adapt_Settings.Back = AdaptOptionsCheckButtonTransparent:GetChecked() and "OFF" or "ON"
		Adapt.Reback()
	elseif button==AdaptOptionsCheckButtonFullModel then
		Adapt_Settings.FullModel = AdaptOptionsCheckButtonFullModel:GetChecked()
		Adapt.Remodel()
	elseif button==AdaptOptionsCheckButtonBackColor then
		Adapt_Settings.ClassColor = AdaptOptionsCheckButtonBackColor:GetChecked() and "ON" or "OFF"
		Adapt.Recolor()
		
	end
end

Adapt.OptionsList = {} -- numerically indexed list of portrait texture names to list in options

function Adapt.OptionsCreateList()
	local list = Adapt.OptionsList
	for i in pairs(list) do
		list[i] = nil -- wipe old list
	end
	for i in pairs(Adapt_Settings.DontUse) do
		table.insert(list,i)
	end
	for i in pairs(Adapt.Textures) do
		if not Adapt_Settings.DontUse[i] then
			table.insert(list,i)
		end
	end
	table.sort(list)
	Adapt.OptionsListScrollFrameUpdate()
end

function Adapt.OptionsListScrollFrameUpdate()
	local idx
	local offset = FauxScrollFrame_GetOffset(AdaptOptionsListScrollFrame)
	FauxScrollFrame_Update(AdaptOptionsListScrollFrame, #(Adapt.OptionsList),7,22)
	for i=1,7 do
		idx = offset + i
		if idx<=#(Adapt.OptionsList) then
			getglobal("AdaptOptionsList"..i.."CheckButton"):SetChecked(Adapt_Settings.DontUse[Adapt.OptionsList[idx]])
			getglobal("AdaptOptionsList"..i.."Text"):SetText(Adapt.OptionsList[idx])
			getglobal("AdaptOptionsList"..i):Show()
		else
			getglobal("AdaptOptionsList"..i):Hide()
		end
	end
end

-- this is the X checkbox on the list in options
function Adapt.OptionsListOnClick(button)
	local id = button:GetParent():GetID()
	local idx = id + FauxScrollFrame_GetOffset(AdaptOptionsListScrollFrame)
	Adapt_Settings.DontUse[Adapt.OptionsList[idx]] = button:GetChecked()
	Adapt.needReload = 1 -- prompt for reload if changes made to this list
end

-- in case user cancels option changes, save old settings in a temporary table
function Adapt.OptionsStoreOldSettings()
	if not Adapt.OldSettings then
		Adapt.OldSettings = { DontUse={} }
		Adapt.OldSettings.Shape = Adapt_Settings.Shape
		Adapt.OldSettings.Back = Adapt_Settings.Back
		Adapt.OldSettings.FullModel = Adapt_Settings.FullModel
		Adapt.OldSettings.ClassColor = Adapt_Settings.ClassColor
		for i in pairs(Adapt_Settings.DontUse) do
			Adapt.OldSettings.DontUse[i] = 1
		end
	end
end

-- Ok button hit in options panel
function Adapt.OptionsOk()
	if Adapt.OldSettings and Adapt.needReload then
		Adapt.Reload()
	end
	Adapt.OldSettings = nil
end

-- Cancel button hit in options panel
function Adapt.OptionsCancel()
	if Adapt.OldSettings then
		-- change current settings to those saved in Adapt.OldSettings
		Adapt_Settings.Shape = Adapt.OldSettings.Shape
		Adapt_Settings.Back = Adapt.OldSettings.Back
		Adapt_Settings.FullModel = Adapt.OldSettings.FullModel
		for i in pairs(Adapt_Settings.DontUse) do
			Adapt_Settings.DontUse[i] = nil
		end
		for i in pairs(Adapt.OldSettings.DontUse) do
			Adapt_Settings.DontUse[i] = 1
		end
		Adapt.OldSettings = nil
	end
	Adapt.Refresh()
end

-- Default button hit in options panel
function Adapt.OptionsDefault()
	Adapt.CreateDefaults()
	Adapt.Refresh()
	Adapt.needReload = 1
end

-- prompts for reload.  No change REQUIRES a reload, but it's recommended for expected behavior.
function Adapt.Reload()
	StaticPopupDialogs["AdaptReloadNeeded"] = {
		text = AdaptLocal.RELOAD,
		button1 = YES,
		button2 = NO,
		timeout = 0,
		hideOnEscape = 1,
		whileDead = 1,
		OnAccept = ReloadUI
	}
	StaticPopup_Show("AdaptReloadNeeded")
end
