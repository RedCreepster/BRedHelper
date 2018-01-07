events = {
    'ADDON_LOADED',
    'BAG_UPDATE_DELAYED',
    'COMPACT_UNIT_FRAME_PROFILES_LOADED',
    'CURRENCY_DISPLAY_UPDATE',
    'MERCHANT_CLOSED',
    'MERCHANT_SHOW',
    'PLAYER_ALIVE',
    'PLAYER_TARGET_CHANGED',
    'PRODUCT_CHOICE_UPDATE',
    'PRODUCT_DISTRIBUTIONS_UPDATED',
    'STORE_PURCHASE_LIST_UPDATED',
    'STORE_STATUS_CHANGED',
    'TABARD_CANSAVE_CHANGED',
    'TOKEN_DISTRIBUTIONS_UPDATED',
    'TOKEN_STATUS_CHANGED',
    'UNIT_FACTION',
    'UNIT_MODEL_CHANGED',
    'UNIT_NAME_UPDATE',
    'UNIT_TARGET',
    'UNIT_THREAT_LIST_UPDATE',
    'UNIT_THREAT_SITUATION_UPDATE',
};

enabledAddOns = {
    ['World'] = { 'RedHelper' },
    ['Instance'] = { 'RedHelper' },
};

debug = true;

AddOns = {};
AddOns.__init = AddOns;

local MAP_TYPES = {
    'World',
    'Instance',
};
local selectedMapType = MAP_TYPES[1];

local addonsItemsToNames = {};

function log(...)
    if debug then
        print(...);
    end
end

function AddOns:init()
    Frame1:SetScript('OnEvent', function(_, event)
        if event == 'PLAYER_LOGIN' then
            AddOns:run();
            print('RedHelper loaded! For open addons window use command /redhelper')
        elseif event == 'PLAYER_ENTERING_WORLD' then
            if AddOns:needReload() then
                Frame2:Show();
            else
                Frame2:Hide();
            end
        end
    end);
    Frame1:RegisterEvent('PLAYER_LOGIN');
    Frame1:RegisterEvent('PLAYER_ENTERING_WORLD');
end

--- Создаёт контейнер с чекбоксом и текстом лля аддона
-- @param name
-- @param enable
--
function AddOns:createAddonItem(name, enable)
    local namePrefix = 'addon-' .. name;

    local addonContainer = CreateFrame('Frame', namePrefix .. '-container');

    local checkButton = createCheckButton(namePrefix .. '-checkbutton', addonContainer, nil, enable, { 'LEFT' });
    local textPoint = { 'LEFT', checkButton, checkButton:GetWidth(), 0 };
    local text = createText(namePrefix .. '-text', addonContainer, name, textPoint);

    addonContainer:SetWidth(checkButton:GetWidth() + text:GetWidth());
    addonContainer:SetHeight(max(checkButton:GetHeight(), text:GetHeight()));

    return addonContainer, checkButton, text;
end

function AddOns:run()
    local addonFrameHeight = 23;

    local addonsContainer = CreateFrame('Frame', 'addons-container', ScrollFrame1);
    addonsContainer:SetPoint('TOPLEFT', ScrollFrame1);
    ScrollFrame1:SetScrollChild(addonsContainer);

    local addons = getAddons();

    local addonsContainerHeight = ((#addons) + 1) * addonFrameHeight;

    addonsContainer:SetHeight(addonsContainerHeight);
    addonsContainer:SetWidth(ScrollFrame1:GetWidth());

    for index, addon in ipairs(addons) do
        local addonName = addon.name;

        local addonItem, checkButton = AddOns:createAddonItem(addon.title, addon.enabled);

        addonsItemsToNames[addonItem] = addonName;

        local point = {
            'TOPLEFT',
            addonsContainer,
            0,
            (index - 1) * -addonFrameHeight
        };
        setParams(addonItem, point);
        addonItem:SetParent(addonsContainer);

        checkButton:SetScript('OnClick', function(self)
            if not enabledAddOns[selectedMapType] then
                enabledAddOns[selectedMapType] = {};
            end

            local selectedEnabledAddons = enabledAddOns[selectedMapType];

            local contains = tContains(selectedEnabledAddons, addonName);

            if self:GetChecked() and not contains then
                tinsert(selectedEnabledAddons, addonName);
            elseif contains then
                vtremove(selectedEnabledAddons, addonName);
            end
        end);
    end

    AddOns:updateCheckboxes();

    createSimpleMenu(DropDownMenuTest, MAP_TYPES, 1, function(_, name)
        selectedMapType = name;
        AddOns:updateCheckboxes();
    end);
end

function AddOns:updateCheckboxes()
    local _, addonsContainer = ScrollFrame1:GetChildren();

    local addonsItems = { addonsContainer:GetChildren() };

    for _, addonItem in ipairs(addonsItems) do
        local children = addonItem:GetChildren();
        if children then
            local addonName = addonsItemsToNames[addonItem];
            children:SetChecked(enabledAddOns[selectedMapType] and tContains(enabledAddOns[selectedMapType], addonName));
        end
    end
end

function AddOns:needReload()
    local type = AddOns:getCurrentMapType();

    if not enabledAddOns[type] then
        return false;
    end

    local addons = getAddons();

    for _, addon in ipairs(addons) do
        local addonName = addon.name;
        local enabled = addon.enabled;

        if tContains(enabledAddOns[type], addonName) then
            if not enabled then
                log(addonName .. ' is disabled');
                return true;
            end
        else
            if enabled then
                log(addonName .. ' is enabled');
                return true;
            end
        end
    end

    return false;
end

function AddOns:applyAddOns()
    local type = AddOns:getCurrentMapType();
    local addons = getAddons();

    local needReload = false;

    for _, addon in ipairs(addons) do
        local addonName = addon.name;
        local enabled = addon.enabled;

        if (not enabledAddOns[type] or not tContains(enabledAddOns[type], addonName)) and enabled then
            DisableAddOn(addonName);
            printAddonInfo(addon);
            log('Disabled ' .. addonName);
            if IsAddOnLoaded(addonName) then
                needReload = true;
            end
        end
    end

    for _, addon in ipairs(addons) do
        local addonName = addon.name;
        local enabled = addon.enabled;
        local demand = addon.demand;

        if enabledAddOns[type] and tContains(enabledAddOns[type], addonName) and not enabled then
            EnableAddOn(addonName);
            log('Enabled ' .. addonName);

            if not needReload and not IsAddOnLoaded(addonName) and not demand then
                LoadAddOn(addonName);
                log('Loaded ' .. addonName);
            end
        end
    end

    SaveAddOns();

    Frame2:Hide();

    if needReload then
        ReloadUI();
    end
end

--- Возвращает тип текущей карты.
--
-- World - Мир, Instance - Подземелье, Рейд, Поле боя, Арена, etc...
--
function AddOns:getCurrentMapType()
    if IsInInstance() then
        return 'Instance';
    else
        return 'World';
    end
end

SLASH_REDHELPER1 = '/redhelper';
function SlashCmdList.REDHELPER()
    Frame1:Show();
end
