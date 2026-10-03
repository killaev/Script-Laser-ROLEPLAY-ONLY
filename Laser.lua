--[==[
    Sistema Tactical Dual Beam + Lanterna Strobe
    Redcliff City RP

    DUAL BEAM:
    🟢 Verde = esquerda
    🟣 Roxo = direita

    Os dois lasers permanecem:
    - Paralelos
    - Retos
    - Separados
    - Dentro do quadrado/emissor

    LANTERNA:
    💡 Normal
    🚨 Strobe
]==]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--==================================================
-- CONFIGURAÇÕES DO LASER
--==================================================

local LaserRange = 150
local LaserWidth = 0.035

local GreenLaserColor = Color3.fromRGB(0, 255, 0)
local PurpleLaserColor = Color3.fromRGB(170, 0, 255)

local LaserDotSize = 0.10

-- DIREÇÃO DO LASER
-- MANTIDA EXATAMENTE IGUAL
local LaserRightAngle = 4.5
local LaserDownAngle = 20.0

--==================================================
-- DISTÂNCIA ENTRE OS DOIS LASERS
--==================================================

-- Cada laser fica um pouco para dentro do quadrado.
-- Verde = esquerda
-- Roxo = direita

local DualBeamSideOffset = 0.035

--==================================================
-- EMISSOR / QUADRADO
--==================================================

local EmitterColor = Color3.fromRGB(10, 10, 10)

local EmitterSize =
    Vector3.new(
        0.18,
        0.18,
        0.30
    )

local EmitterForwardOffset = 0.12

-- MANTIDO
local EmitterSideOffset = 0.17
local EmitterVerticalOffset = 0.26

local ShowEmitter = true

--==================================================
-- LANTERNA
--==================================================

local FlashBrightness = 5
local FlashRange = 35
local FlashAngle = 55

local FlashColor =
    Color3.fromRGB(
        255,
        255,
        255
    )

--==================================================
-- STROBE
--==================================================

local StrobeSpeed = 0.075

--==================================================
-- ESTADOS
--==================================================

local LaserEnabled = false
local FlashlightEnabled = false
local StrobeEnabled = false

--==================================================
-- OBJETOS ATUAIS
--==================================================

local CurrentTool = nil
local CurrentHandle = nil

local GreenBeam = nil
local PurpleBeam = nil

local CurrentFlashlight = nil

local CurrentDot = nil

local CurrentEmitter = nil
local CurrentEmitterAttachment = nil

local GreenBeamAttachment = nil
local PurpleBeamAttachment = nil

local GreenEndPart = nil
local PurpleEndPart = nil

local GreenEndAttachment = nil
local PurpleEndAttachment = nil

local RenderConnection = nil

--==================================================
-- STROBE
--==================================================

local StrobeTimer = 0
local StrobeState = false

--==================================================
-- GUI
--==================================================

local PlayerGui =
    Player:WaitForChild(
        "PlayerGui"
    )

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name =
    "TacticalAttachmentUI"

ScreenGui.ResetOnSpawn = false

ScreenGui.Parent =
    PlayerGui

--==================================================
-- PAINEL
--==================================================

local MainFrame =
    Instance.new("Frame")

MainFrame.Name =
    "MainFrame"

MainFrame.Size =
    UDim2.new(
        0,
        210,
        0,
        220
    )

MainFrame.Position =
    UDim2.new(
        0,
        15,
        0.5,
        -110
    )

MainFrame.BackgroundColor3 =
    Color3.fromRGB(
        20,
        20,
        20
    )

MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

MainFrame.Parent =
    ScreenGui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(
        0,
        10
    )

MainCorner.Parent =
    MainFrame

--==================================================
-- TÍTULO
--==================================================

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(
        1,
        -45,
        0,
        35
    )

Title.Position =
    UDim2.new(
        0,
        12,
        0,
        5
    )

Title.BackgroundTransparency = 1

Title.Text =
    "TACTICAL SYSTEM"

Title.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

Title.TextSize = 17

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    MainFrame

--==================================================
-- FECHAR
--==================================================

local CloseButton =
    Instance.new("TextButton")

CloseButton.Size =
    UDim2.new(
        0,
        30,
        0,
        30
    )

CloseButton.Position =
    UDim2.new(
        1,
        -35,
        0,
        5
    )

CloseButton.BackgroundTransparency = 1

CloseButton.Text = "×"

CloseButton.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

CloseButton.TextSize = 25

CloseButton.Font =
    Enum.Font.GothamBold

CloseButton.Parent =
    MainFrame

--==================================================
-- CRIAR BOTÃO
--==================================================

local function CreateButton(
    Name,
    Text,
    Y
)

    local Button =
        Instance.new("TextButton")

    Button.Name =
        Name

    Button.Size =
        UDim2.new(
            1,
            -24,
            0,
            38
        )

    Button.Position =
        UDim2.new(
            0,
            12,
            0,
            Y
        )

    Button.BackgroundColor3 =
        Color3.fromRGB(
            35,
            35,
            35
        )

    Button.BorderSizePixel = 0

    Button.Text = Text

    Button.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    Button.TextSize = 14

    Button.Font =
        Enum.Font.GothamBold

    Button.AutoButtonColor = true

    Button.Parent =
        MainFrame

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            7
        )

    Corner.Parent =
        Button

    return Button
end

local DualBeamButton =
    CreateButton(
        "DualBeamButton",
        "DUAL BEAM: OFF",
        45
    )

local FlashButton =
    CreateButton(
        "FlashButton",
        "LANTERNA: OFF",
        88
    )

local StrobeButton =
    CreateButton(
        "StrobeButton",
        "STROBE: OFF",
        131
    )

local BothButton =
    CreateButton(
        "BothButton",
        "AMBOS: OFF",
        174
    )

--==================================================
-- BOTÃO REABRIR
--==================================================

local OpenButton =
    Instance.new("TextButton")

OpenButton.Name =
    "OpenButton"

OpenButton.Size =
    UDim2.new(
        0,
        55,
        0,
        55
    )

OpenButton.Position =
    UDim2.new(
        0,
        15,
        0.5,
        -27
    )

OpenButton.BackgroundColor3 =
    Color3.fromRGB(
        15,
        15,
        15
    )

OpenButton.BorderSizePixel = 0

OpenButton.Text = "⚙"

OpenButton.TextColor3 =
    Color3.fromRGB(
        255,
        255,
        255
    )

OpenButton.TextSize = 25

OpenButton.Font =
    Enum.Font.GothamBold

OpenButton.Visible = false

OpenButton.Parent =
    ScreenGui

local OpenCorner =
    Instance.new("UICorner")

OpenCorner.CornerRadius =
    UDim.new(
        1,
        0
    )

OpenCorner.Parent =
    OpenButton

CloseButton.MouseButton1Click:Connect(
    function()

        MainFrame.Visible = false
        OpenButton.Visible = true

    end
)

OpenButton.MouseButton1Click:Connect(
    function()

        MainFrame.Visible = true
        OpenButton.Visible = false

    end
)

--==================================================
-- DETECTAR PISTOLA
--==================================================

local function IsPistol(Tool)

    if not Tool
        or not Tool:IsA("Tool") then

        return false
    end

    if Tool:GetAttribute(
        "IsGun"
    ) == true then

        return true
    end

    if Tool:GetAttribute(
        "IsPistol"
    ) == true then

        return true
    end

    local Name =
        string.lower(
            Tool.Name
        )

    local Keywords = {
        "pistol",
        "gun",
        "glock",
        "revolver",
        "deagle",
        "desert",
        "beretta",
        "usp",
        "1911",
        "handgun"
    }

    for _, Word in ipairs(
        Keywords
    ) do

        if string.find(
            Name,
            Word
        ) then

            return true
        end

    end

    if Tool:FindFirstChild(
        "Handle"
    ) then

        return true
    end

    return false
end

--==================================================
-- HANDLE
--==================================================

local function FindHandle(Tool)

    if not Tool then
        return nil
    end

    local Handle =
        Tool:FindFirstChild(
            "Handle"
        )

    if Handle
        and Handle:IsA(
            "BasePart"
        ) then

        return Handle
    end

    for _, Object in ipairs(
        Tool:GetDescendants()
    ) do

        if Object:IsA(
            "BasePart"
        ) then

            return Object
        end

    end

    return nil
end

--==================================================
-- MUZZLE
--==================================================

local function FindMuzzle(Tool)

    if not Tool then
        return nil
    end

    local Names = {
        "muzzle",
        "muzzleattachment",
        "laserpoint",
        "laserattachment"
    }

    for _, Object in ipairs(
        Tool:GetDescendants()
    ) do

        if Object:IsA(
            "Attachment"
        ) then

            local LowerName =
                string.lower(
                    Object.Name
                )

            for _, Name in ipairs(
                Names
            ) do

                if LowerName == Name then
                    return Object
                end

            end

        end

    end

    return nil
end

--==================================================
-- DIREÇÃO DA ARMA
--==================================================

local function CalculateWeaponDirection(
    Tool,
    Handle
)

    if not Handle then

        return Vector3.new(
            0,
            0,
            -1
        )

    end

    local Muzzle =
        FindMuzzle(Tool)

    if Muzzle then

        local Difference =
            Muzzle.WorldPosition
            - Handle.Position

        if Difference.Magnitude
            > 0.01 then

            return Difference.Unit
        end

    end

    local FurthestPart = nil
    local FurthestDistance = 0

    for _, Object in ipairs(
        Tool:GetDescendants()
    ) do

        if Object:IsA(
            "BasePart"
        )
        and Object ~= Handle then

            local LowerName =
                string.lower(
                    Object.Name
                )

            local Ignore =
                string.find(
                    LowerName,
                    "grip"
                )
                or string.find(
                    LowerName,
                    "handle"
                )
                or string.find(
                    LowerName,
                    "mag"
                )
                or string.find(
                    LowerName,
                    "trigger"
                )

            if not Ignore then

                local Distance =
                    (
                        Object.Position
                        - Handle.Position
                    ).Magnitude

                if Distance
                    > FurthestDistance then

                    FurthestDistance =
                        Distance

                    FurthestPart =
                        Object

                end

            end

        end

    end

    if FurthestPart then

        local Difference =
            FurthestPart.Position
            - Handle.Position

        if Difference.Magnitude
            > 0.01 then

            return Difference.Unit
        end

    end

    return Handle.CFrame.LookVector
end

--==================================================
-- AJUSTE DO LASER
--==================================================

local function ApplyLaserAdjustment(
    Direction,
    Handle
)

    if not Handle then
        return Direction
    end

    local RightAngle =
        math.rad(
            LaserRightAngle
        )

    Direction =
        (
            Direction
            * math.cos(
                RightAngle
            )
            +
            Handle.CFrame.RightVector
            * math.sin(
                RightAngle
            )
        ).Unit

    local DownAngle =
        math.rad(
            LaserDownAngle
        )

    Direction =
        (
            Direction
            * math.cos(
                DownAngle
            )
            -
            Handle.CFrame.UpVector
            * math.sin(
                DownAngle
            )
        ).Unit

    return Direction
end

--==================================================
-- POSIÇÃO DO QUADRADO
--==================================================

local function CalculateEmitterPosition(
    Tool,
    Handle,
    Direction
)

    if not Handle then
        return Vector3.zero
    end

    local Muzzle =
        FindMuzzle(Tool)

    local Position

    if Muzzle then

        Position =
            Muzzle.WorldPosition

    else

        Position =
            Handle.Position
            +
            Direction
            *
            (
                Handle.Size.Z / 2
                +
                EmitterForwardOffset
            )

    end

    Position =
        Position
        +
        Direction
        *
        EmitterForwardOffset

    -- DIREITA DO QUADRADO
    Position =
        Position
        +
        Handle.CFrame.RightVector
        *
        EmitterSideOffset

    -- CIMA DO QUADRADO
    Position =
        Position
        +
        Handle.CFrame.UpVector
        *
        EmitterVerticalOffset

    return Position
end

--==================================================
-- CRIAR EMISSOR
--==================================================

local function CreateEmitter(
    Tool,
    Handle,
    Direction
)

    local Position =
        CalculateEmitterPosition(
            Tool,
            Handle,
            Direction
        )

    local Emitter =
        Instance.new("Part")

    Emitter.Name =
        "TacticalEmitter"

    Emitter.Size =
        EmitterSize

    Emitter.Color =
        EmitterColor

    Emitter.Material =
        Enum.Material.SmoothPlastic

    Emitter.Transparency =
        ShowEmitter and 0 or 1

    Emitter.CanCollide = false
    Emitter.CanTouch = false
    Emitter.CanQuery = false
    Emitter.Massless = true
    Emitter.CastShadow = false

    Emitter.CFrame =
        CFrame.lookAt(
            Position,
            Position + Direction
        )

    Emitter.Parent =
        Tool

    local Weld =
        Instance.new("WeldConstraint")

    Weld.Part0 =
        Handle

    Weld.Part1 =
        Emitter

    Weld.Parent =
        Emitter

    --==================================================
    -- ATTACHMENT CENTRAL
    --==================================================

    local Attachment =
        Instance.new("Attachment")

    Attachment.Name =
        "EmitterFront"

    Attachment.Position =
        Vector3.new(
            0,
            0,
            -EmitterSize.Z / 2
        )

    Attachment.Parent =
        Emitter

    --==================================================
    -- ATTACHMENT VERDE
    -- ESQUERDA
    --==================================================

    local GreenAttachment =
        Instance.new("Attachment")

    GreenAttachment.Name =
        "GreenBeamAttachment"

    GreenAttachment.Position =
        Vector3.new(
            -DualBeamSideOffset,
            0,
            -EmitterSize.Z / 2
        )

    GreenAttachment.Parent =
        Emitter

    --==================================================
    -- ATTACHMENT ROXO
    -- DIREITA
    --==================================================

    local PurpleAttachment =
        Instance.new("Attachment")

    PurpleAttachment.Name =
        "PurpleBeamAttachment"

    PurpleAttachment.Position =
        Vector3.new(
            DualBeamSideOffset,
            0,
            -EmitterSize.Z / 2
        )

    PurpleAttachment.Parent =
        Emitter

    return
        Emitter,
        Attachment,
        GreenAttachment,
        PurpleAttachment
end

--==================================================
-- CRIAR FINAL DE UM BEAM
--==================================================

local function CreateBeamEnd(Name)

    local EndPart =
        Instance.new("Part")

    EndPart.Name =
        Name

    EndPart.Size =
        Vector3.new(
            0.1,
            0.1,
            0.1
        )

    EndPart.Transparency = 1
    EndPart.Anchored = true
    EndPart.CanCollide = false
    EndPart.CanTouch = false
    EndPart.CanQuery = false

    EndPart.Parent =
        Workspace

    local Attachment =
        Instance.new("Attachment")

    Attachment.Name =
        "BeamEndAttachment"

    Attachment.Parent =
        EndPart

    return
        EndPart,
        Attachment
end

--==================================================
-- DOT
--==================================================

local function CreateLaserDot()

    local Dot =
        Instance.new("Part")

    Dot.Name =
        "TacticalLaserDot"

    Dot.Shape =
        Enum.PartType.Ball

    Dot.Size =
        Vector3.new(
            LaserDotSize,
            LaserDotSize,
            LaserDotSize
        )

    Dot.Material =
        Enum.Material.Neon

    Dot.Color =
        Color3.fromRGB(
            255,
            255,
            255
        )

    Dot.Anchored = true
    Dot.CanCollide = false
    Dot.CanTouch = false
    Dot.CanQuery = false
    Dot.CastShadow = false
    Dot.Transparency = 1

    Dot.Parent =
        Workspace

    return Dot
end

--==================================================
-- LIMPAR
--==================================================

local function Cleanup()

    if RenderConnection then

        RenderConnection:Disconnect()
        RenderConnection = nil

    end

    if CurrentDot then

        CurrentDot:Destroy()
        CurrentDot = nil

    end

    if CurrentEmitter then

        CurrentEmitter:Destroy()
        CurrentEmitter = nil

    end

    if GreenEndPart then

        GreenEndPart:Destroy()
        GreenEndPart = nil

    end

    if PurpleEndPart then

        PurpleEndPart:Destroy()
        PurpleEndPart = nil

    end

    GreenBeam = nil
    PurpleBeam = nil

    CurrentFlashlight = nil

    CurrentEmitterAttachment = nil

    GreenBeamAttachment = nil
    PurpleBeamAttachment = nil

    GreenEndAttachment = nil
    PurpleEndAttachment = nil

    CurrentTool = nil
    CurrentHandle = nil

    StrobeTimer = 0
    StrobeState = false
end

--==================================================
-- CONFIGURAR ARMA
--==================================================

local function SetupTool(Tool)

    if not IsPistol(Tool) then
        return
    end

    Cleanup()

    local Handle =
        FindHandle(Tool)

    if not Handle then
        return
    end

    CurrentTool =
        Tool

    CurrentHandle =
        Handle

    local Direction =
        CalculateWeaponDirection(
            Tool,
            Handle
        )

    Direction =
        ApplyLaserAdjustment(
            Direction,
            Handle
        )

    --==================================================
    -- EMISSOR
    --==================================================

    local Emitter,
        EmitterAttachment,
        GreenAttachment,
        PurpleAttachment =
        CreateEmitter(
            Tool,
            Handle,
            Direction
        )

    CurrentEmitter =
        Emitter

    CurrentEmitterAttachment =
        EmitterAttachment

    GreenBeamAttachment =
        GreenAttachment

    PurpleBeamAttachment =
        PurpleAttachment

    --==================================================
    -- DOT
    --==================================================

    CurrentDot =
        CreateLaserDot()

    --==================================================
    -- FINAIS SEPARADOS
    --==================================================

    local GreenEnd,
        GreenAttachmentEnd =
        CreateBeamEnd(
            "TacticalGreenEnd"
        )

    local PurpleEnd,
        PurpleAttachmentEnd =
        CreateBeamEnd(
            "TacticalPurpleEnd"
        )

    GreenEndPart =
        GreenEnd

    GreenEndAttachment =
        GreenAttachmentEnd

    PurpleEndPart =
        PurpleEnd

    PurpleEndAttachment =
        PurpleAttachmentEnd

    --==================================================
    -- BEAM VERDE
    --==================================================

    local BeamGreen =
        Instance.new("Beam")

    BeamGreen.Name =
        "TacticalGreenBeam"

    BeamGreen.Attachment0 =
        GreenAttachment

    BeamGreen.Attachment1 =
        GreenAttachmentEnd

    BeamGreen.Width0 =
        LaserWidth

    BeamGreen.Width1 =
        LaserWidth

    BeamGreen.Color =
        ColorSequence.new(
            GreenLaserColor
        )

    BeamGreen.FaceCamera = true
    BeamGreen.LightEmission = 1
    BeamGreen.LightInfluence = 0

    BeamGreen.Transparency =
        NumberSequence.new(0)

    BeamGreen.Enabled = false

    BeamGreen.Parent =
        Emitter

    GreenBeam =
        BeamGreen

    --==================================================
    -- BEAM ROXO
    --==================================================

    local BeamPurple =
        Instance.new("Beam")

    BeamPurple.Name =
        "TacticalPurpleBeam"

    BeamPurple.Attachment0 =
        PurpleAttachment

    BeamPurple.Attachment1 =
        PurpleAttachmentEnd

    BeamPurple.Width0 =
        LaserWidth

    BeamPurple.Width1 =
        LaserWidth

    BeamPurple.Color =
        ColorSequence.new(
            PurpleLaserColor
        )

    BeamPurple.FaceCamera = true
    BeamPurple.LightEmission = 1
    BeamPurple.LightInfluence = 0

    BeamPurple.Transparency =
        NumberSequence.new(0)

    BeamPurple.Enabled = false

    BeamPurple.Parent =
        Emitter

    PurpleBeam =
        BeamPurple

    --==================================================
    -- LANTERNA
    --==================================================

    local Flashlight =
        Instance.new("SpotLight")

    Flashlight.Name =
        "TacticalFlashlight"

    Flashlight.Brightness =
        FlashBrightness

    Flashlight.Range =
        FlashRange

    Flashlight.Angle =
        FlashAngle

    Flashlight.Color =
        FlashColor

    Flashlight.Face =
        Enum.NormalId.Front

    Flashlight.Enabled = false

    Flashlight.Parent =
        EmitterAttachment

    CurrentFlashlight =
        Flashlight

    --==================================================
    -- RENDER
    --==================================================

    RenderConnection =
        RunService.RenderStepped:Connect(
            function(DeltaTime)

                if not CurrentTool
                    or not CurrentHandle
                    or not CurrentTool.Parent then

                    Cleanup()
                    return
                end

                --==========================================
                -- DIREÇÃO PRINCIPAL
                --==========================================

                local WeaponDirection =
                    CalculateWeaponDirection(
                        CurrentTool,
                        CurrentHandle
                    )

                WeaponDirection =
                    ApplyLaserAdjustment(
                        WeaponDirection,
                        CurrentHandle
                    )

                --==========================================
                -- ORIGENS DOS DOIS LASERS
                --==========================================

                local GreenOrigin =
                    GreenBeamAttachment.WorldPosition

                local PurpleOrigin =
                    PurpleBeamAttachment.WorldPosition

                --==========================================
                -- RAYCAST VERDE
                --==========================================

                local ParamsGreen =
                    RaycastParams.new()

                ParamsGreen.FilterType =
                    Enum.RaycastFilterType.Exclude

                local IgnoreList = {
                    CurrentTool,
                    GreenEndPart,
                    PurpleEndPart
                }

                local Character =
                    Player.Character

                if Character then

                    table.insert(
                        IgnoreList,
                        Character
                    )

                end

                ParamsGreen.FilterDescendantsInstances =
                    IgnoreList

                ParamsGreen.IgnoreWater = true

                local GreenResult =
                    Workspace:Raycast(
                        GreenOrigin,
                        WeaponDirection
                        * LaserRange,
                        ParamsGreen
                    )

                --==========================================
                -- RAYCAST ROXO
                --==========================================

                local ParamsPurple =
                    RaycastParams.new()

                ParamsPurple.FilterType =
                    Enum.RaycastFilterType.Exclude

                ParamsPurple.FilterDescendantsInstances =
                    IgnoreList

                ParamsPurple.IgnoreWater = true

                local PurpleResult =
                    Workspace:Raycast(
                        PurpleOrigin,
                        WeaponDirection
                        * LaserRange,
                        ParamsPurple
                    )

                --==========================================
                -- POSIÇÃO FINAL VERDE
                --==========================================

                local GreenEndPosition

                if GreenResult then

                    GreenEndPosition =
                        GreenResult.Position

                else

                    GreenEndPosition =
                        GreenOrigin
                        +
                        WeaponDirection
                        * LaserRange

                end

                --==========================================
                -- POSIÇÃO FINAL ROXA
                --==========================================

                local PurpleEndPosition

                if PurpleResult then

                    PurpleEndPosition =
                        PurpleResult.Position

                else

                    PurpleEndPosition =
                        PurpleOrigin
                        +
                        WeaponDirection
                        * LaserRange

                end

                --==========================================
                -- MANTER SEPARAÇÃO ATÉ O FINAL
                --==========================================

                local RightVector =
                    CurrentHandle.CFrame.RightVector

                -- Verde fica à esquerda
                GreenEndPosition =
                    GreenEndPosition
                    - RightVector
                    * DualBeamSideOffset

                -- Roxo fica à direita
                PurpleEndPosition =
                    PurpleEndPosition
                    + RightVector
                    * DualBeamSideOffset

                GreenEndPart.Position =
                    GreenEndPosition

                PurpleEndPart.Position =
                    PurpleEndPosition

                --==========================================
                -- DOT
                --==========================================

                if LaserEnabled then

                    if GreenResult then

                        CurrentDot.Position =
                            GreenResult.Position

                        CurrentDot.Transparency = 0

                    elseif PurpleResult then

                        CurrentDot.Position =
                            PurpleResult.Position

                        CurrentDot.Transparency = 0

                    else

                        CurrentDot.Transparency = 1

                    end

                else

                    CurrentDot.Transparency = 1

                end

                --==========================================
                -- DUAL BEAM
                --==========================================

                if GreenBeam then

                    GreenBeam.Enabled =
                        LaserEnabled

                end

                if PurpleBeam then

                    PurpleBeam.Enabled =
                        LaserEnabled

                end

                --==========================================
                -- STROBE
                --==========================================

                if StrobeEnabled
                    and FlashlightEnabled then

                    StrobeTimer =
                        StrobeTimer
                        + DeltaTime

                    if StrobeTimer
                        >= StrobeSpeed then

                        StrobeTimer = 0

                        StrobeState =
                            not StrobeState

                    end

                    CurrentFlashlight.Enabled =
                        StrobeState

                elseif FlashlightEnabled then

                    StrobeTimer = 0
                    StrobeState = true

                    CurrentFlashlight.Enabled =
                        true

                else

                    StrobeTimer = 0
                    StrobeState = false

                    CurrentFlashlight.Enabled =
                        false

                end

            end
        )
end

--==================================================
-- BOTÃO DUAL BEAM
--==================================================

DualBeamButton.MouseButton1Click:Connect(
    function()

        LaserEnabled =
            not LaserEnabled

        if LaserEnabled then

            DualBeamButton.Text =
                "DUAL BEAM: ON"

        else

            DualBeamButton.Text =
                "DUAL BEAM: OFF"

        end

    end
)

--==================================================
-- BOTÃO LANTERNA
--==================================================

FlashButton.MouseButton1Click:Connect(
    function()

        FlashlightEnabled =
            not FlashlightEnabled

        if FlashlightEnabled then

            FlashButton.Text =
                "LANTERNA: ON"

        else

            FlashButton.Text =
                "LANTERNA: OFF"

        end

    end
)

--==================================================
-- BOTÃO STROBE
--==================================================

StrobeButton.MouseButton1Click:Connect(
    function()

        StrobeEnabled =
            not StrobeEnabled

        if StrobeEnabled then

            StrobeButton.Text =
                "STROBE: ON"

            FlashlightEnabled =
                true

            FlashButton.Text =
                "LANTERNA: ON"

        else

            StrobeButton.Text =
                "STROBE: OFF"

        end

    end
)

--==================================================
-- BOTÃO AMBOS
--==================================================

BothButton.MouseButton1Click:Connect(
    function()

        local NewState =
            not (
                LaserEnabled
                and FlashlightEnabled
            )

        LaserEnabled =
            NewState

        FlashlightEnabled =
            NewState

        if NewState then

            BothButton.Text =
                "AMBOS: ON"

            DualBeamButton.Text =
                "DUAL BEAM: ON"

            FlashButton.Text =
                "LANTERNA: ON"

        else

            BothButton.Text =
                "AMBOS: OFF"

            DualBeamButton.Text =
                "DUAL BEAM: OFF"

            FlashButton.Text =
                "LANTERNA: OFF"

        end

    end
)

--==================================================
-- CHARACTER
--==================================================

local function SetupCharacter(
    Character
)

    Cleanup()

    for _, Tool in ipairs(
        Character:GetChildren()
    ) do

        if Tool:IsA("Tool")
            and IsPistol(Tool) then

            Tool.Equipped:Connect(
                function()

                    SetupTool(Tool)

                end
            )

            Tool.Unequipped:Connect(
                function()

                    if CurrentTool == Tool then

                        Cleanup()

                    end

                end
            )

        end

    end

    Character.ChildAdded:Connect(
        function(Child)

            if Child:IsA("Tool")
                and IsPistol(Child) then

                Child.Equipped:Connect(
                    function()

                        SetupTool(Child)

                    end
                )

                Child.Unequipped:Connect(
                    function()

                        if CurrentTool == Child then

                            Cleanup()

                        end

                    end
                )

            end

        end
    )

    local Humanoid =
        Character:FindFirstChildOfClass(
            "Humanoid"
        )

    if Humanoid then

        Humanoid.Died:Connect(
            function()

                Cleanup()

            end
        )

    end

end

--==================================================
-- INICIALIZAÇÃO
--==================================================

if Player.Character then

    SetupCharacter(
        Player.Character
    )

end

Player.CharacterAdded:Connect(
    function(Character)

        Character:WaitForChild(
            "Humanoid"
        )

        SetupCharacter(
            Character
        )

    end
)

Player.CharacterRemoving:Connect(
    function()

        Cleanup()

    end
)
