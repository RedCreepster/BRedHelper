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

AddOns = {};
AddOns.addonFrameHeight = 23;
AddOns.MAP_TYPES = {
    'World',
    'Instance',
};
AddOns.selectedMapType = AddOns.MAP_TYPES[1];
AddOns.addonsItemsToNames = {};

function AddOns:init()
    AddOnsFrame:SetScript('OnEvent', function(_, event)
        if event == 'PLAYER_LOGIN' then
            self:run();
            addPanel(AddOnsFrame, 'AddOns', 'RedHelper', function()
                if self:needReload() then
                    self:applyAddOns();
                end
            end);
        elseif event == 'PLAYER_ENTERING_WORLD' then
            if self:needReload() then
                AddOnsMapChangedChangedFrame:Show();
            else
                AddOnsMapChangedChangedFrame:Hide();
            end
        end
    end);
    AddOnsFrame:RegisterEvent('PLAYER_LOGIN');
    AddOnsFrame:RegisterEvent('PLAYER_ENTERING_WORLD');
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
    local addonsContainer = CreateFrame('Frame', 'addons-container', ScrollFrame1);
    addonsContainer:SetPoint('TOPLEFT', ScrollFrame1);
    ScrollFrame1:SetScrollChild(addonsContainer);

    local addons = getAddons();

    local addonsContainerHeight = (#addons) * self.addonFrameHeight;

    addonsContainer:SetHeight(addonsContainerHeight);
    addonsContainer:SetWidth(ScrollFrame1:GetWidth());

    for index, addon in ipairs(addons) do
        local addonName = addon.name;

        local addonItem, checkButton = self:createAddonItem(addon.title, addon.enabledForCharacter);

        self.addonsItemsToNames[addonItem] = addonName;

        local point = {
            'TOPLEFT',
            addonsContainer,
            0,
            (index - 1) * -self.addonFrameHeight
        };
        setParams(addonItem, point);
        addonItem:SetParent(addonsContainer);

        checkButton:SetScript('OnClick', function(checkButton)
            if not enabledAddOns[self.selectedMapType] then
                enabledAddOns[self.selectedMapType] = {};
            end

            local selectedEnabledAddons = enabledAddOns[self.selectedMapType];

            local contains = tContains(selectedEnabledAddons, addonName);

            if checkButton:GetChecked() and not contains then
                tinsert(selectedEnabledAddons, addonName);
            elseif contains then
                vtremove(selectedEnabledAddons, addonName);
            end
        end);
    end

    self:updateCheckboxes();

    createSimpleMenu(DropDownMenuTest, self.MAP_TYPES, 1, function(_, name)
        self.selectedMapType = name;
        self:updateCheckboxes();
    end);
end

function AddOns:updateCheckboxes()
    local _, addonsContainer = ScrollFrame1:GetChildren();

    local addonsItems = { addonsContainer:GetChildren() };

    local enabledAddOnsByMapType = enabledAddOns[self.selectedMapType];

    for _, addonItem in ipairs(addonsItems) do
        local children = addonItem:GetChildren();
        if children then
            local addonName = self.addonsItemsToNames[addonItem];
            children:SetChecked(enabledAddOnsByMapType and tContains(enabledAddOnsByMapType, addonName));
        end
    end
end

function AddOns:needReload()
    local type = self:getCurrentMapType();
    local enabledAddOnsByMapType = enabledAddOns[type];

    if not enabledAddOnsByMapType then
        return false;
    end

    local addons = getAddons();

    for _, addon in ipairs(addons) do
        local addonName = addon.name;
        local enabled = addon.enabled;

        if tContains(enabledAddOnsByMapType, addonName) then
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
    local type = self:getCurrentMapType();
    local enabledAddOnsByMapType = enabledAddOns[type];
    local addons = getAddons();

    for _, addon in ipairs(addons) do
        local addonName = addon.name;
        local enabled = addon.enabled;

        if (not enabledAddOnsByMapType or not tContains(enabledAddOnsByMapType, addonName)) and enabled then
            addon.disable(false);
            log('Disabled ' .. addonName);
        end

        if enabledAddOnsByMapType and tContains(enabledAddOnsByMapType, addonName) and not enabled then
            addon.enable(false);
            log('Enabled ' .. addonName);
        end
    end

    SaveAddOns();

    AddOnsMapChangedChangedFrame:Hide();

    ReloadUI();
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
