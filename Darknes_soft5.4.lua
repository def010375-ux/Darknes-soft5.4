--[[
    DarknesSoft V5
    Roblox Studio UI
    Location: StarterPlayer > StarterPlayerScripts

    Features:
    - Dark interface
    - Code editor
    - Script manager
    - Settings and accent colors
    - Minimize and drag window
    - AI GPT placeholder (not connected)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("DarknesSoftV5")
if oldGui then
    oldGui:Destroy()
end

local ACCENT = Color3.fromRGB(145, 80, 255)
local BG = Color3.fromRGB(17, 17, 23)
local PANEL = Color3.fromRGB(25, 25, 34)
local CARD = Color3.fromRGB(32, 32, 43)
local TEXT = Color3.fromRGB(240, 240, 248)
local MUTED = Color3.fromRGB(155, 155, 175)

local animationsEnabled = true
local minimized = false
local savedSize = UDim2.fromOffset(780, 490)
local currentPage = "Editor"

local scripts = {
    {
        name = "Main",
        source = "-- Welcome to DarknesSoft V5!\nprint('Hello, Roblox!')"
    }
}

local selectedScript = 1

local function create(className, properties, parent)
    local object = Instance.new(className)

    for key, value in pairs(properties or {}) do
        object[key] = value
    end

    object.Parent = parent
    return object
end

local function round(object, radius)
    create("UICorner", {
        CornerRadius = UDim.new(0, radius or 10)
    }, object)
end

local function addStroke(object, color, transparency)
    return create("UIStroke", {
        Color = color or ACCENT,
        Transparency = transparency or 0.5,
        Thickness = 1
    }, object)
end

local function animate(object, properties, duration)
    if not animationsEnabled then
        for key, value in pairs(properties) do
            object[key] = value
        end
        return
    end

    TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.2,
            Enum.EasingStyle.Quad,
            Enum.EasingDirection.Out
        ),
        properties
    ):Play()
end

local gui = create("ScreenGui", {
    Name = "DarknesSoftV5",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling
}, playerGui)

local main = create("Frame", {
    Name = "Main",
    Size = savedSize,
    Position = UDim2.new(0.5, -390, 0.5, -245),
    BackgroundColor3 = BG,
    BorderSizePixel = 0,
    ClipsDescendants = true
}, gui)

round(main, 14)
local mainStroke = addStroke(main, ACCENT, 0.25)

-- TOP BAR

local topbar = create("Frame", {
    Name = "Topbar",
    Size = UDim2.new(1, 0, 0, 48),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
}, main)

round(topbar, 14)

create("Frame", {
    Position = UDim2.new(0, 0, 1, -14),
    Size = UDim2.new(1, 0, 0, 14),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
}, topbar)

create("TextLabel", {
    Position = UDim2.fromOffset(16, 0),
    Size = UDim2.new(0, 300, 1, 0),
    BackgroundTransparency = 1,
    Text = "✦  DarknesSoft V5",
    TextColor3 = TEXT,
    TextSize = 19,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, topbar)

local minimizeButton = create("TextButton", {
    Position = UDim2.new(1, -86, 0, 9),
    Size = UDim2.fromOffset(32, 30),
    BackgroundColor3 = CARD,
    Text = "—",
    TextColor3 = TEXT,
    TextSize = 18,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, topbar)

round(minimizeButton, 8)

local closeButton = create("TextButton", {
    Position = UDim2.new(1, -46, 0, 9),
    Size = UDim2.fromOffset(32, 30),
    BackgroundColor3 = Color3.fromRGB(115, 43, 57),
    Text = "×",
    TextColor3 = TEXT,
    TextSize = 22,
    Font = Enum.Font.GothamBold,
    AutoButtonColor = false
}, topbar)

round(closeButton, 8)

-- SIDEBAR

local sidebar = create("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(12, 60),
    Size = UDim2.new(0, 172, 1, -72),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
}, main)

round(sidebar, 12)

create("TextLabel", {
    Position = UDim2.fromOffset(14, 12),
    Size = UDim2.new(1, -28, 0, 24),
    BackgroundTransparency = 1,
    Text = "WORKSPACE",
    TextColor3 = MUTED,
    TextSize = 11,
    Font = Enum.Font.GothamBold,
    TextXAlignment = Enum.TextXAlignment.Left
}, sidebar)

local pageArea = create("Frame", {
    Name = "PageArea",
    Position = UDim2.fromOffset(196, 60),
    Size = UDim2.new(1, -208, 1, -72),
    BackgroundTransparency = 1
}, main)

local pages = {}
local navButtons = {}

local function makePage(name)
    local page = create("Frame", {
        Name = name:gsub("%s+", ""),
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false
    }, pageArea)

    pages[name] = page
    return page
end

local editorPage = makePage("Editor")
local scriptsPage = makePage("Scripts")
local settingsPage = makePage("Settings")
local aiPage = makePage("AI GPT")

local function label(parent, text, position, size, textSize, color)
    return create("TextLabel", {
        Position = position,
        Size = size,
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or TEXT,
        TextSize = textSize or 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center
    }, parent)
end

local function button(parent, text, position, size, callback, highlighted)
    local b = create("TextButton", {
        Position = position,
        Size = size,
        BackgroundColor3 = highlighted and ACCENT or CARD,
        Text = text,
        TextColor3 = TEXT,
        TextSize = 13,
        Font = Enum.Font.GothamSemibold,
        AutoButtonColor = false
    }, parent)

    round(b, 8)

    b.MouseEnter:Connect(function()
        if b.Parent then
            animate(b, {
                BackgroundColor3 = highlighted
                    and ACCENT:Lerp(Color3.new(1, 1, 1), 0.1)
                    or Color3.fromRGB(48, 48, 62)
            }, 0.12)
        end
    end)

    b.MouseLeave:Connect(function()
        if b.Parent then
            animate(b, {
                BackgroundColor3 = highlighted and ACCENT or CARD
            }, 0.12)
        end
    end)

    b.Activated:Connect(callback)
    return b
end

local function showPage(name)
    currentPage = name

    for pageName, page in pairs(pages) do
        page.Visible = pageName == name
    end

    for pageName, nav in pairs(navButtons) do
        nav.BackgroundColor3 =
            pageName == name and ACCENT or PANEL
    end
end

local navItems = {
    {"Editor", "⌨  Editor"},
    {"Scripts", "▤  Scripts"},
    {"Settings", "⚙  Settings"},
    {"AI GPT", "✦  AI GPT"}
}

for index, item in ipairs(navItems) do
    local name = item[1]
    local text = item[2]

    local nav = button(
        sidebar,
        text,
        UDim2.fromOffset(8, 48 + (index - 1) * 43),
        UDim2.new(1, -16, 0, 36),
        function()
            showPage(name)
        end,
        false
    )

    nav.TextXAlignment = Enum.TextXAlignment.Left
    nav.TextSize = 12
    navButtons[name] = nav
end

label(
    sidebar,
    "DARKNESSOFT  •  V5",
    UDim2.new(0, 12, 1, -32),
    UDim2.new(1, -24, 0, 20),
    10,
    MUTED
)

-- EDITOR PAGE

label(
    editorPage,
    "Code Editor",
    UDim2.fromOffset(4, 0),
    UDim2.new(1, -8, 0, 32),
    22
)

label(
    editorPage,
    "Write and manage your Lua snippets",
    UDim2.fromOffset(4, 32),
    UDim2.new(1, -8, 0, 22),
    12,
    MUTED
)

local editor = create("TextBox", {
    Name = "CodeEditor",
    Position = UDim2.fromOffset(4, 64),
    Size = UDim2.new(1, -8, 1, -126),
    BackgroundColor3 = Color3.fromRGB(12, 12, 17),
    TextColor3 = Color3.fromRGB(220, 220, 235),
    PlaceholderColor3 = MUTED,
    PlaceholderText = "-- Write Lua code here...",
    Text = scripts[1].source,
    TextSize = 14,
    Font = Enum.Font.Code,
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    TextWrapped = false,
    ClearTextOnFocus = false,
    MultiLine = true
}, editorPage)

round(editor, 10)
addStroke(editor, Color3.fromRGB(65, 65, 85), 0.4)

local status = label(
    editorPage,
    "Ready  •  1 script",
    UDim2.new(0, 4, 1, -54),
    UDim2.new(1, -8, 0, 22),
    12,
    MUTED
)

button(
    editorPage,
    "Save",
    UDim2.new(0, 4, 1, -30),
    UDim2.fromOffset(105, 30),
    function()
        scripts[selectedScript].source = editor.Text
        status.Text = "Saved in session"
    end,
    true
)

button(
    editorPage,
    "Clear",
    UDim2.new(0, 118, 1, -30),
    UDim2.fromOffset(105, 30),
    function()
        editor.Text = ""
        status.Text = "Editor cleared"
    end,
    false
)

-- SCRIPT MANAGER

label(
    scriptsPage,
    "Script Manager",
    UDim2.fromOffset(4, 0),
    UDim2.new(1, -8, 0, 32),
    22
)

label(
    scriptsPage,
    "Create and select scripts stored in this session.",
    UDim2.fromOffset(4, 32),
    UDim2.new(1, -8, 0, 24),
    12,
    MUTED
)

local scriptList = create("ScrollingFrame", {
    Name = "ScriptList",
    Position = UDim2.fromOffset(4, 64),
    Size = UDim2.new(1, -8, 1, -112),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0,
    ScrollBarThickness = 4,
    CanvasSize = UDim2.new()
}, scriptsPage)

round(scriptList, 10)

create("UIListLayout", {
    Padding = UDim.new(0, 6),
    SortOrder = Enum.SortOrder.LayoutOrder
}, scriptList)

create("UIPadding", {
    PaddingTop = UDim.new(0, 8),
    PaddingLeft = UDim.new(0, 8),
    PaddingRight = UDim.new(0, 8),
    PaddingBottom = UDim.new(0, 8)
}, scriptList)

local function refreshScripts()
    for _, child in ipairs(scriptList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    for index, item in ipairs(scripts) do
        local row = button(
            scriptList,
            "▤   " .. item.name,
            UDim2.new(),
            UDim2.new(1, -8, 0, 38),
            function()
                scripts[selectedScript].source = editor.Text
                selectedScript = index
                editor.Text = scripts[index].source
                status.Text = "Selected: " .. scripts[index].name
                showPage("Editor")
            end,
            index == selectedScript
        )

        row.LayoutOrder = index
        row.TextXAlignment = Enum.TextXAlignment.Left
    end

    scriptList.CanvasSize = UDim2.fromOffset(0, #scripts * 44 + 16)
end

button(
    scriptsPage,
    "+ New Script",
    UDim2.new(0, 4, 1, -38),
    UDim2.fromOffset(130, 32),
    function()
        scripts[selectedScript].source = editor.Text

        table.insert(scripts, {
            name = "Script" .. (#scripts + 1),
            source = "-- New script\n"
        })

        selectedScript = #scripts
        editor.Text = scripts[selectedScript].source
        refreshScripts()
        status.Text = "New script created"
    end,
    true
)

button(
    scriptsPage,
    "Rename",
    UDim2.new(0, 144, 1, -38),
    UDim2.fromOffset(90, 32),
    function()
        scripts[selectedScript].name = "Script" .. selectedScript
        refreshScripts()
    end,
    false
)

button(
    scriptsPage,
    "Delete",
    UDim2.new(0, 244, 1, -38),
    UDim2.fromOffset(90, 32),
    function()
        if #scripts <= 1 then
            status.Text = "Keep at least one script"
            return
        end

        table.remove(scripts, selectedScript)
        selectedScript = math.clamp(selectedScript, 1, #scripts)
        editor.Text = scripts[selectedScript].source

        refreshScripts()
        status.Text = "Script deleted"
    end,
    false
)

-- SETTINGS

label(
    settingsPage,
    "Settings",
    UDim2.fromOffset(4, 0),
    UDim2.new(1, -8, 0, 32),
    22
)

label(
    settingsPage,
    "Customize the interface",
    UDim2.fromOffset(4, 32),
    UDim2.new(1, -8, 0, 24),
    12,
    MUTED
)

local animationLabel = label(
    settingsPage,
    "Interface animations: ON",
    UDim2.fromOffset(8, 78),
    UDim2.new(1, -150, 0, 35),
    14
)

button(
    settingsPage,
    "Toggle",
    UDim2.new(1, -116, 0, 78),
    UDim2.fromOffset(108, 35),
    function()
        animationsEnabled = not animationsEnabled
        animationLabel.Text =
            "Interface animations: " ..
            (animationsEnabled and "ON" or "OFF")
    end,
    true
)

label(
    settingsPage,
    "Accent color",
    UDim2.fromOffset(8, 132),
    UDim2.new(1, -16, 0, 24),
    14
)

local colors = {
    {"Purple", Color3.fromRGB(145, 80, 255)},
    {"Blue", Color3.fromRGB(55, 125, 255)},
    {"Red", Color3.fromRGB(235, 70, 95)},
    {"Green", Color3.fromRGB(50, 190, 130)}
}

for index, entry in ipairs(colors) do
    local colorName = entry[1]
    local colorValue = entry[2]

    button(
        settingsPage,
        colorName,
        UDim2.fromOffset(8 + (index - 1) * 105, 164),
        UDim2.fromOffset(96, 34),
        function()
            ACCENT = colorValue
            mainStroke.Color = ACCENT

            for pageName, nav in pairs(navButtons) do
                nav.BackgroundColor3 =
                    pageName == currentPage and ACCENT or PANEL
            end
        end,
        false
    )
end

label(
    settingsPage,
    "Scripts and settings are not saved between sessions.",
    UDim2.fromOffset(8, 224),
    UDim2.new(1, -16, 0, 42),
    12,
    MUTED
)

-- AI GPT PLACEHOLDER

label(
    aiPage,
    "AI GPT",
    UDim2.fromOffset(4, 0),
    UDim2.new(1, -8, 0, 38),
    24
)

local badge = create("TextLabel", {
    Position = UDim2.fromOffset(4, 48),
    Size = UDim2.fromOffset(142, 30),
    BackgroundColor3 = Color3.fromRGB(75, 55, 105),
    Text = "✦  IN DEVELOPMENT",
    TextColor3 = Color3.fromRGB(220, 200, 255),
    TextSize = 11,
    Font = Enum.Font.GothamBold
}, aiPage)

round(badge, 8)

local aiCard = create("Frame", {
    Position = UDim2.fromOffset(4, 92),
    Size = UDim2.new(1, -8, 0, 190),
    BackgroundColor3 = PANEL,
    BorderSizePixel = 0
}, aiPage)

round(aiCard, 12)
addStroke(aiCard, ACCENT, 0.6)

label(
    aiCard,
    "AI assistant",
    UDim2.fromOffset(16, 14),
    UDim2.new(1, -32, 0, 28),
    18
)

label(
    aiCard,
    "GPT connection is not configured yet.\n\n" ..
    "This page is a placeholder for the future assistant.\n" ..
    "No API requests are sent and no AI responses are generated.",
    UDim2.fromOffset(16, 52),
    UDim2.new(1, -32, 0, 110),
    13,
    MUTED
)

local aiInput = create("TextBox", {
    Position = UDim2.fromOffset(4, 300),
    Size = UDim2.new(1, -120, 0, 42),
    BackgroundColor3 = PANEL,
    TextColor3 = TEXT,
    PlaceholderColor3 = MUTED,
    PlaceholderText = "AI GPT is not available yet...",
    Text = "",
    TextSize = 13,
    Font = Enum.Font.Gotham,
    ClearTextOnFocus = false
}, aiPage)

round(aiInput, 9)

button(
    aiPage,
    "Unavailable",
    UDim2.new(1, -108, 0, 300),
    UDim2.fromOffset(104, 42),
    function()
        aiInput.Text = ""
    end,
    false
)

-- DRAG WINDOW

local dragging = false
local dragStart
local startPosition

topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- MINIMIZE / RESTORE

minimizeButton.Activated:Connect(function()
    minimized = not minimized

    if minimized then
        savedSize = main.Size
        sidebar.Visible = false
        pageArea.Visible = false

        animate(main, {
            Size = UDim2.fromOffset(300, 48)
        }, 0.2)

        minimizeButton.Text = "□"
    else
        main.Size = savedSize
        sidebar.Visible = true
        pageArea.Visible = true
        minimizeButton.Text = "—"
    end
end)

closeButton.Activated:Connect(function()
    gui:Destroy()
end)

-- INITIALIZE

showPage("Editor")
refreshScripts()

print("DarknesSoft V5 loaded successfully")
</CodeBlock>

## Как загрузить на GitHub

1. Открой свой репозиторий.
2. Нажми **Add file → Create new file**.
3. Назови файл `DarknesSoft_V5.lua`.
4. Вставь код из блока целиком.
5. Нажми **Commit changes**.

**Важно:** этот код создаёт интерфейс, но не выполняет текст из редактора как Lua-программу. AI GPT пока не подключён, а скрипты хранятся только в памяти текущей сессии.
