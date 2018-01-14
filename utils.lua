function getAddOn(nameOrIndex)
    local name, title, notes, loadable, reason, security = GetAddOnInfo(nameOrIndex);

    local addon = {};

    local playerName = UnitName("player");

    local enabled = GetAddOnEnableState(playerName, nameOrIndex);

    addon.name = name;
    addon.title = title;
    addon.notes = notes;
    addon.enabled = enabled > 0;
    addon.enabledForCharacter = enabled == 1;
    addon.enabledForRealm = enabled == 2;
    addon.loaded = IsAddOnLoaded(nameOrIndex);
    addon.loadable = loadable;
    addon.demand = IsAddOnLoadOnDemand(nameOrIndex);
    addon.reason = reason;
    addon.security = security;
    addon.enable = function(all)
        if all then
            EnableAddOn(nameOrIndex, nil);
        else
            EnableAddOn(nameOrIndex, playerName);
        end
    end
    addon.disable = function(all)
        if all then
            DisableAddOn(nameOrIndex, nil);
        else
            DisableAddOn(nameOrIndex, playerName);
        end
    end

    return addon;
end

function printAddonInfo(addon)
    print('name: ' .. addon.name);
    print('title: ' .. addon.title);
    print('notes: ' .. toString(addon.notes));
    print('enabledForCharacter: ' .. toString(addon.enabledForCharacter));
    print('enabledForRealm: ' .. toString(addon.enabledForRealm));
    print('loaded: ' .. toString(addon.loaded));
    print('loadable: ' .. toString(addon.loadable));
    print('demand: ' .. toString(addon.demand));
    print('reason: ' .. toString(addon.reason));
    print('security: ' .. toString(addon.security));
end

--- Получение списка аддонов
--
function getAddons()
    local count = GetNumAddOns();

    local addons = {};

    for index = 1, count, 1 do
        addons[index] = getAddOn(index);
    end

    return addons;
end

function setParams(frame, point, width, height)
    if point then
        frame:SetPoint(unpack(point));
    end
    if width then
        frame:SetWidth(width);
    end
    if height then
        frame:SetHeight(height);
    end
end

function createButton(name, parent, text, point, width, height)
    local button = CreateFrame("Button", name, parent, "UIPanelButtonTemplate");

    setParams(button, point, width, height);

    button:SetText(text);

    return button;
end

function createCheckButton(name, parent, tooltip, checked, point, width, height)
    local button = CreateFrame("CheckButton", name, parent, "ChatConfigCheckButtonTemplate");

    setParams(button, point, width, height);

    button.tooltip = tooltip;
    button:SetChecked(checked);

    return button;
end

function createText(name, parent, text, point, width, height)
    local fontString = parent:CreateFontString(name, "BACKGROUND");

    setParams(fontString, point, width, height);

    fontString:SetFontObject("GameFontNormal");

    fontString:SetText(text);

    return fontString;
end

function setScrollFrameChilds(scrollFrame, containerName, childs)
    local container = CreateFrame('Frame', containerName, scrollFrame);

    container:SetWidth(scrollFrame:GetWidth());
    container:SetPoint('TOPLEFT', scrollFrame);
    scrollFrame:SetScrollChild(container);

    for _, child in ipairs(childs) do
        child:SetParent(container);
    end

    return container;
end

--- Создание простого меню
-- @param menuButton Элеммент для открытия меню
-- @param items Тектовый массив/таблица
-- @param selectedID Первоначальное выбранное значение
-- @param onChange
-- @param width
-- @param buttonWidth
--
function createSimpleMenu(menuButton, items, selectedID, onChange, width, buttonWidth)
    UIDropDownMenu_Initialize(menuButton, function(_, level)
        local info = UIDropDownMenu_CreateInfo();
        for _, v in ipairs(items) do
            info = UIDropDownMenu_CreateInfo();
            info.text = v
            info.value = v
            info.func = function(self)
                local id = self:GetID();
                UIDropDownMenu_SetSelectedID(menuButton, id);
                if onChange then
                    onChange(id, items[id]);
                end
            end
            UIDropDownMenu_AddButton(info, level);
        end
    end)
    UIDropDownMenu_SetWidth(menuButton, width or 100);
    UIDropDownMenu_SetButtonWidth(menuButton, buttonWidth or 125);
    UIDropDownMenu_SetSelectedID(menuButton, selectedID);
    UIDropDownMenu_JustifyText(menuButton, "LEFT");
end

function indexOf(table, item)
    local index;

    for i, currentItem in ipairs(table) do
        if currentItem == item then
            index = i;
            break;
        end
    end

    return index;
end

function vtremove(table, value)
    local index = indexOf(table, value);
    while (index) do
        tremove(table, index);
        index = indexOf(table, value);
    end
end

function bool2String(value)
    if value then
        return 'true';
    else
        return 'false';
    end
end

function toString(value)
    if type(value) == 'boolean' then
        return bool2String(value);
    end

    if value == nil then
        return 'nil';
    end

    return value;
end

function addPanel(frame, name, parent, okay, cancel, default, refresh)
    local panel = frame;
    panel.name = name;
    if parent then
        panel.parent = parent;
    end
    if okay then
        panel.okay = okay
    end
    if cancel then
        panel.cancel = cancel
    end
    if default then
        panel.default = default
    end
    if refresh then
        panel.refresh = refresh
    end
    InterfaceOptions_AddCategory(panel);
end
