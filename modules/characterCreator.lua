-- =====================================================
-- Karakteralkotó specifikus funkciók
-- =====================================================

local creator = {}

function creator:run(config, utils, bypass)
    print("[CREATOR] Indítás...")

    local Players = utils:getService("Players")
    local ReplicatedStorage = utils:getService("ReplicatedStorage")
    local Workspace = utils:getService("Workspace")
    local LocalPlayer = Players.LocalPlayer

    local creationGui = LocalPlayer.PlayerGui:FindFirstChild("CreationGUI")
    if not creationGui then
        print("[CREATOR] HIBA: CreationGUI nem található!")
        return
    end

    local appearanceModule = require(ReplicatedStorage:WaitForChild("appearanceModule"))

    -- 1. Nevek hozzáadása a modulhoz
    pcall(function()
        table.insert(appearanceModule.firstNames.boyNames, config.firstName)
        table.insert(appearanceModule.firstNames.girlNames, config.firstName)
        table.insert(appearanceModule.lastNames, config.lastName)
        print("[CREATOR] Nevek hozzáadva")
    end)

    -- 2. Legsötétebb bőr automatikus beállítása
    if config.features.autoSkinTone then
        local darkest = utils:getDarkestSkin(appearanceModule)
        config.skinTone = darkest
        print("[CREATOR] Legsötétebb bőr: " .. darkest)
    end

    -- 3. UI elemek keresése
    local appFrame = creationGui:FindFirstChild("appearanceFrame")
    local abilitiesFrame = creationGui:FindFirstChild("abilitiesFrame")
    local continueFrame = creationGui:FindFirstChild("continueFrame")

    -- 4. Bőrszín alkalmazása a dummy-ra
    local dummy = Workspace:FindFirstChild("DummyCharacter") or Workspace:WaitForChild("DummyCharacter", 5)
    if dummy and config.skinTone then
        local skinColor = appearanceModule.skintones[config.skinTone]
        if skinColor then
            for _, part in pairs(dummy:GetChildren()) do
                if part:IsA("MeshPart") or part:IsA("Part") then
                    part.Color = skinColor
                end
            end
            local ears = dummy:FindFirstChild("Ears")
            if ears and ears:FindFirstChild("Handle") then
                ears.Handle.Left.Color = skinColor
                ears.Handle.Right.Color = skinColor
            end
        end
    end

    -- 5. Cipő rendszer
    if config.features.unlockShoes then
        self:setupShoes(creationGui, appearanceModule, config, dummy)
    end

    -- 6. Attribútum hack
    if config.features.infinitePoints then
        self:hackAttributes(abilitiesFrame, config)
    end

    -- 7. Markings feloldása
    if config.features.unlockMarkings then
        self:unlockMarkings(appFrame)
    end

    -- 8. UI frissítés (nevek, bőrszín)
    self:updateUI(creationGui, config)

    -- 9. Remote hook
    self:setupRemoteHook(creationGui, config)

    -- 10. Continue gomb rögzítése
    if config.features.autoContinue and continueFrame then
        coroutine.wrap(function()
            while continueFrame do
                task.wait(0.5)
                continueFrame.Position = UDim2.new(0.34, 0, 0.9, 0)
            end
        end)()
        print("[CREATOR] Continue gomb rögzítve")
    end

    -- 11. Kick védelem
    if config.features.kickProtection then
        bypass:kickProtection()
    end

    print("[CREATOR] Minden kész! Nyomd meg a Play gombot!")
end

-- Cipő rendszer (részletesen)
function creator:setupShoes(creationGui, appearanceModule, config, dummy)
    local appFrame = creationGui:FindFirstChild("appearanceFrame")
    if not appFrame then return end

    local shoesFrame = appFrame:FindFirstChild("shoes")
    if not shoesFrame then
        shoesFrame = Instance.new("Frame")
        shoesFrame.Name = "shoes"
        shoesFrame.Size = UDim2.new(0, 300, 0, 50)
        shoesFrame.Position = UDim2.new(0, 0, 0, 200)
        shoesFrame.BackgroundTransparency = 1
        shoesFrame.Parent = appFrame
    end

    -- Lockolt gombok eltávolítása
    for _, child in pairs(shoesFrame:GetChildren()) do
        if child:IsA("TextButton") and (child.Name:lower():find("locked") or child.Name:lower():find("lock")) then
            child:Destroy()
        end
    end

    -- SelectionLabel
    local selectionLabel = shoesFrame:FindFirstChild("selectionLabel")
    if not selectionLabel then
        selectionLabel = Instance.new("TextLabel")
        selectionLabel.Name = "selectionLabel"
        selectionLabel.Size = UDim2.new(0, 150, 0, 30)
        selectionLabel.Position = UDim2.new(0, 140, 0, 10)
        selectionLabel.Text = (config.shoe or "whiteNavy1s"):upper()
        selectionLabel.BackgroundTransparency = 1
        selectionLabel.TextColor3 = Color3.new(1,1,1)
        selectionLabel.TextStrokeTransparency = 0
        selectionLabel.Parent = shoesFrame
    end

    -- Gombok létrehozása
    local whiteBtn = shoesFrame:FindFirstChild("whiteOption") or Instance.new("TextButton")
    whiteBtn.Name = "whiteOption"
    whiteBtn.Text = "WHITE"
    whiteBtn.Size = UDim2.new(0, 60, 0, 30)
    whiteBtn.Position = UDim2.new(0, 10, 0, 10)
    whiteBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    whiteBtn.TextColor3 = Color3.new(1,1,1)
    whiteBtn.Parent = shoesFrame

    local blackBtn = shoesFrame:FindFirstChild("blackOption") or Instance.new("TextButton")
    blackBtn.Name = "blackOption"
    blackBtn.Text = "BLACK"
    blackBtn.Size = UDim2.new(0, 60, 0, 30)
    blackBtn.Position = UDim2.new(0, 80, 0, 10)
    blackBtn.BackgroundColor3 = Color3.new(0.2,0.2,0.2)
    blackBtn.TextColor3 = Color3.new(1,1,1)
    blackBtn.Parent = shoesFrame

    -- Cipő alkalmazó függvény
    local function applyShoe(shoeName)
        if not dummy then return end
        local shoeData = appearanceModule.clothes.shoes[shoeName]
        if not shoeData then return end

        for _, child in pairs(dummy:GetChildren()) do
            if child:IsA("Accessory") and (child.Name == "LeftShoe" or child.Name == "RightShoe") then
                child:Destroy()
            end
        end

        local left = shoeData.leftShoeClone:Clone()
        local right = shoeData.rightShoeClone:Clone()
        left.Name = "LeftShoe"
        right.Name = "RightShoe"
        left.Parent = dummy:FindFirstChild("LeftFoot") or dummy
        right.Parent = dummy:FindFirstChild("RightFoot") or dummy

        local function weld(part0, part1, cframe)
            local weld = Instance.new("Weld")
            weld.Part0 = part0
            weld.Part1 = part1
            weld.C0 = cframe
            weld.Parent = part0
        end
        weld(left.Handle, left.Parent, shoeData.leftAttachment)
        weld(right.Handle, right.Parent, shoeData.rightAttachment)

        selectionLabel.Text = shoeData.name:upper()
        config.shoe = shoeName
    end

    pcall(function() applyShoe(config.shoe or "whiteNavy1s") end)

    whiteBtn.MouseButton1Down:Connect(function()
        pcall(function() applyShoe("whiteNavy1s") end)
    end)
    blackBtn.MouseButton1Down:Connect(function()
        pcall(function() applyShoe("blackNavy1s") end)
    end)

    print("[CREATOR] Cipő rendszer aktív")
end

-- Attribútum hack (pontok és gombok letiltása)
function creator:hackAttributes(abilitiesFrame, config)
    if not abilitiesFrame then return end

    -- Gombok letiltása
    local attrNames = {"strength", "stamina", "smarts", "stress"}
    for _, name in pairs(attrNames) do
        local container = abilitiesFrame:FindFirstChild(name)
        if container then
            for _, btn in pairs(container:GetChildren()) do
                if btn:IsA("TextButton") and (btn.Name == "raiseOption" or btn.Name == "lowerOption") then
                    local cons = getconnections and getconnections(btn.MouseButton1Down)
                    if cons then
                        for _, con in pairs(cons) do con:Disable() end
                    else
                        btn.MouseButton1Down:Connect(function() end)
                    end
                end
            end
        end
    end

    -- Reset gomb
    local attributes = abilitiesFrame:FindFirstChild("attributes")
    if attributes then
        local resetBtn = attributes:FindFirstChild("resetOption")
        if resetBtn then
            local cons = getconnections and getconnections(resetBtn.MouseButton1Down)
            if cons then
                for _, con in pairs(cons) do con:Disable() end
            end
        end
        local pointsLabel = attributes:FindFirstChild("pointsLabel")
        if pointsLabel then pointsLabel.Text = "POINTS • ∞" end
    end

    -- Szintek beállítása (csak UI)
    for _, name in pairs(attrNames) do
        local container = abilitiesFrame:FindFirstChild(name)
        if container and container:FindFirstChild("levelLabel") then
            container.levelLabel.Text = "LEVEL • 100"
        end
    end
    print("[CREATOR] Attribútum hack aktiválva")
end

-- Markings feloldása
function creator:unlockMarkings(appFrame)
    local markingsFrame = appFrame and appFrame:FindFirstChild("markings")
    if markingsFrame then
        for _, child in pairs(markingsFrame:GetChildren()) do
            if child:IsA("TextButton") and (child.Name:lower():find("locked") or child.Name:lower():find("lock")) then
                child:Destroy()
            end
        end
        if not markingsFrame:FindFirstChild("selectionLabel") then
            local lbl = Instance.new("TextLabel")
            lbl.Name = "selectionLabel"
            lbl.Text = "NONE"
            lbl.Size = UDim2.new(0, 100, 0, 30)
            lbl.BackgroundTransparency = 1
            lbl.TextColor3 = Color3.new(1,1,1)
            lbl.Parent = markingsFrame
        else
            markingsFrame.selectionLabel.Text = "NONE"
        end
        print("[CREATOR] Markings feloldva")
    end
end

-- UI frissítés
function creator:updateUI(creationGui, config)
    local appFrame = creationGui:FindFirstChild("appearanceFrame")
    if appFrame then
        local firstName = appFrame:FindFirstChild("firstname", true)
        if firstName and firstName:FindFirstChild("selectionLabel") then
            firstName.selectionLabel.Text = config.firstName:upper()
        end
        local lastName = appFrame:FindFirstChild("lastname", true)
        if lastName and lastName:FindFirstChild("selectionLabel") then
            lastName.selectionLabel.Text = config.lastName:upper()
        end
        local skinTone = appFrame:FindFirstChild("skintone", true)
        if skinTone and skinTone:FindFirstChild("selectionLabel") then
            skinTone.selectionLabel.Text = config.skinTone:upper()
        end
    end
end

-- Remote hook (sendData)
function creator:setupRemoteHook(creationGui, config)
    local remote = creationGui:FindFirstChild("sendData")
    if not remote then return end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        if self == remote and method == "FireServer" then
            local data = args[1]
            if type(data) == "table" then
                if data.appearanceData then
                    data.appearanceData.FirstName = config.firstName
                    data.appearanceData.LastName = config.lastName
                    data.appearanceData.SkinTone = config.skinTone
                end
                if data.abilitiesData then
                    data.abilitiesData.Strength = 100
                    data.abilitiesData.Stamina = 100
                    data.abilitiesData.Smarts = 100
                    data.abilitiesData.Stress = 100
                end
                if data.clothingData then
                    data.clothingData.Shoes = config.shoe or "whiteNavy1s"
                end
            end
            return oldNamecall(self, unpack(args))
        end
        return oldNamecall(self, ...)
    end)
    print("[CREATOR] Remote hook telepítve")
end

return creator
