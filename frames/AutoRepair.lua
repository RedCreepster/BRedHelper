enableAutoRepair = true;

AutoRepair = {};

function AutoRepair:init()
    AutoRepairFrame:SetScript('OnEvent', function(_, event)
        if event == 'PLAYER_LOGIN' then
            self:run();
            addPanel(AutoRepairFrame, 'AutoRepair', 'RedHelper');
        elseif event == 'MERCHANT_SHOW' then
            self:repair();
        end
    end);
    AutoRepairFrame:RegisterEvent('PLAYER_LOGIN');
    AutoRepairFrame:RegisterEvent('MERCHANT_SHOW');
    AutoRepairFrame:RegisterEvent('MERCHANT_UPDATE');
    AutoRepairFrame:RegisterEvent('MERCHANT_CLOSED');
end

function AutoRepair:run()
end

function AutoRepair:repair()
    if CanMerchantRepair() then
        local status = 'disabled';
        if enableAutoRepair then
            status = 'enabled';
            RepairAllItems();
        end
        log('Auto repair is ' .. status);
    end
end
