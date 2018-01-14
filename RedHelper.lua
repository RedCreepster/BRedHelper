debug = true;

function log(...)
    if debug then
        print(...);
    end
end

local helloMessage = 'Hello! I\'m your helper.\n' ..
        'You can chose addons for enable or disable it in instances or in world.\n' ..
        'You can enable or disable auto repair function.'

local RedHelperMainFrame = CreateFrame('Frame', 'RedHelperMainFrame')
createText('$parentFontString', RedHelperMainFrame, helloMessage, { 'CENTER' })
RedHelperMainFrame:SetScript('OnEvent', function(_, event)
    if event == 'PLAYER_LOGIN' then
        addPanel(RedHelperMainFrame, 'RedHelper');
        print('RedHelper loaded! For open addons window use command /redhelper');
    end
end);
RedHelperMainFrame:RegisterEvent('PLAYER_LOGIN');

SLASH_REDHELPER1 = '/redhelper';
function SlashCmdList.REDHELPER()
    debug = not debug;
    if debug then
        print('Debug enabled')
    else
        print('Debug disabled')
    end
end
