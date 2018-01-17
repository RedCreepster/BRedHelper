enableAutoRepair = true;
enableAutoSellGray = true;

AutoRepair = {};

function AutoRepair:init()
    AutoRepairFrame:SetScript('OnEvent', function(_, event)
        if event == 'PLAYER_LOGIN' then
            self:run();
            addPanel(AutoRepairFrame, 'AutoRepair', 'RedHelper');
        elseif event == 'MERCHANT_SHOW' then
            self:open();
        end
    end);
    AutoRepairFrame:RegisterEvent('PLAYER_LOGIN');
    AutoRepairFrame:RegisterEvent('MERCHANT_SHOW');
    AutoRepairFrame:RegisterEvent('MERCHANT_UPDATE');
    AutoRepairFrame:RegisterEvent('MERCHANT_CLOSED');
end

function AutoRepair:run()
end

function AutoRepair:open()
    local autoRepairStatus = 'disabled';
    if enableAutoRepair then
        if CanMerchantRepair() then
            autoRepairStatus = 'enabled';
            RepairAllItems();
        end
    end
    log('Auto repair is ' .. autoRepairStatus);

    local autoSellStatus = 'disabled';
    if enableAutoSellGray then
        autoSellStatus = 'enabled';

        local soldItems = 0;
        local amount = 0;

        for container = 0, 4 do
            local slots = GetContainerNumSlots(container);
            local bagSpaces = GetContainerFreeSlots(container);
            for slot = 1, slots do
                if not tContains(bagSpaces, slot) then
                    local itemID = GetContainerItemID(container, slot);
                    local info = { GetItemInfo(itemID) };
                    local link = select(2, unpack(info));
                    local quality = select(3, unpack(info));
                    local vendorPrice = select(11, unpack(info));
                    local count = select(2, GetContainerItemInfo(container, slot))

                    if quality == 0 then
                        UseContainerItem(container, slot);
                        amount = amount + vendorPrice * count;
                        soldItems = soldItems + 1;

                        print('Sold ' .. link);
                    end
                end
            end
        end

        if soldItems > 0 then
            print('Number of items sold: ' .. soldItems);
            print('Amount: ' .. GetCoinTextureString(amount, ","));
        end
    end
    log('Auto sell is ' .. autoSellStatus);
end
