script_name("FunHelper")
script_description('Helper for Arizona fun')
script_author("gullsssss")
script_version("beta test")

-- https://github.com/qrlk/moonloader-script-updater
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/gullsssss/asasasa/refs/heads/main/obnovachka/jopa.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/gullsssss/asasasa/"
        end
    end
end
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local new = imgui.new
local ffi = require 'ffi'
local new = imgui.new
local themeList = {}
local fa = require('fAwesome6_solid')
local iniFile = 'funhelpertheme.ini'
local inicfg = require 'inicfg'
local ini = inicfg.load({
    cfgtheme = {
        theme = 0
    }
}, iniFile)

local theme = new.int(ini.cfgtheme.theme)

if not doesDirectoryExist(getWorkingDirectory()..'\\config') then 
    print('Creating the config directory') createDirectory(getWorkingDirectory()..'\\config') 
end
if not doesFileExist('monetloader/config/'..iniFile) then 
    print('Creating/updating the .ini file') inicfg.save(ini, iniFile) 
end
function iniSave()
	ini.cfgtheme.theme = theme[0]
	inicfg.save(ini, iniFile)
    end
function main()
    while not isSampAvailable() do wait(100) end
    repeat
       wait(0)
    until sampIsLocalPlayerSpawned()
    sampAddChatMessage("{#C8C8C8}Скрипт успешно загружен, активация /fh", -1)
 end
 imgui.OnInitialize(function()
    fa.Init()
end)

local WinState = new.bool(false)
local Checkbox = new.bool(false)
local pravila = imgui.new.bool(false)
local check = new.bool(false)

local sliderBuf = new.int()
local function sendCommand(cmd)
    if isSampAvailable() then
        sampSendChat('/' .. cmd)
    end
end

local function teleportToCoordinates(x, y, z)
    local ped = PLAYER_PED
    if ped then
        setCharCoordinates(ped, x, y, z) 
        sampAddChatMessage("{C8C8C8}Вы были успешно телепортированы!", -1)
    else
        sampAddChatMessage("{C8C8C8}Ошибка: Не удалось телепортироваться по координатам!", -1)
    end
end

local tab = 1

imgui.OnFrame(function() return WinState[0] end, function(player)
    imgui.ShowStyleEditor()
    imgui.SetNextWindowPos(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(1000, 500), imgui.Cond.Always)

    if imgui.Begin('FunHelper', WinState, imgui.WindowFlags.NoResize) then
        if imgui.BeginTabBar('TB') then
            if imgui.BeginTabItem(fa.USER .. u8( ' Управление персонажем')) then
                tab = 1
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem(fa.EARTH_EUROPE .. u8(' Телепорты')) then
                tab = 2
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem(fa.CALENDAR_DAYS .. u8(' Мероприятие и челленджы')) then
                tab = 3
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem(fa.GEAR .. u8(' Настройки')) then
               tab = 4
               imgui.EndTabItem()
            end
            if imgui.BeginTabItem(fa.CIRCLE_INFO .. u8(' Прочее')) then
                tab = 5
                imgui.EndTabItem()
            end
        end


        if tab == 2 then
            if imgui.Button(fa.BAN .. u8('Телепорт в админ зону'), imgui.ImVec2(300, 40)) then
                sendCommand('az')
            end
            if imgui.Button(fa.HOUSE_USER .. u8(' Телепорт в свой дом'), imgui.ImVec2(300, 40)) then
                sendCommand('spawn')
            end
            if imgui.Button (fa.BUILDING_COLUMNS .. u8(' Телепорт в банк'), imgui.ImVec2(300 , 40)) then
                teleportToCoordinates(-2680.46, 800.20, 1501.03)
            end
            if imgui.Button(fa.SACK_DOLLAR .. u8(' БУ рынок'), imgui.ImVec2(300, 40)) then
                teleportToCoordinates(-2150.69, -752.39, 32.02)
            end
            if imgui.Button(fa.PLANE_DEPARTURE .. u8(' Аэропорт'), imgui.ImVec2(300, 40)) then
                teleportToCoordinates(-1589.67, -294.59, 14.15)
            end
             if imgui.Button(fa.SHOP .. u8(' Центральный рынок'), imgui.ImVec2(300, 40)) then
            teleportToCoordinates(1128.53, -1426.10, 15.80)
        end
            if imgui.Text(u8'Изпользовать только на улице') then
            end
        end

       
       if tab == 3 then
        if imgui.Button(fa.BRIDGE .. u8(' Дамба'), imgui.ImVec2(300, 40)) then
            teleportToCoordinates(-814.72, 1839.03, 22.92)
        end
        if imgui.Button(fa.BRIDGE .. u8(" Мост сф"), imgui.ImVec2(300,40)) then
            teleportToCoordinates(-1663.60, 526.54, 38.48)
        end
        if imgui.Button(fa.CITY .. u8(' Небоскёрб'), imgui.ImVec2(300, 40)) then
            teleportToCoordinates(1541.34, -1349.50, 329.48)
        end
        if imgui.Button(fa.SHIP .. u8(' Корабль'), imgui.ImVec2(300,40)) then
            teleportToCoordinates(-2415.18, 1544.74, 31.86)
        end
        if imgui.Button(fa.MOUNTAIN_CITY .. u8(' Чиллад'), imgui.ImVec2(300, 40)) then
            teleportToCoordinates(-2298.35, -1639.67, 483.71)
        end
        if imgui.Button(fa.TOWER_OBSERVATION .. u8(' Башеный кран'), imgui.ImVec2(300, 40)) then
            teleportToCoordinates(1239.14, -1257.58, 64.54)
        end
        if imgui.Text(u8'Изпользовать только на улице') then
        end
    end


        if tab == 1 then
            if imgui.Button(fa.CAR .. u8(' Выдать машину'), imgui.ImVec2(300, 40)) then
                sendCommand('plveh 15957')
            end
            if imgui.Button(fa.HEART_PULSE .. u8(' Установить здоровья'), imgui.ImVec2(300, 40)) then
                sendCommand('sethp 999')
            end
            if imgui.Button(fa.GUN .. u8(' Выдать Minigun'), imgui.ImVec2(300, 40)) then
                sendCommand('gg 38 9999')
            end
            if imgui.Button(fa.BRIEFCASE .. u8(' Получить полный доступ'), imgui.ImVec2(300,40)) then
                sendCommand('cb')
            end
            if imgui.Button(fa.CIRCLE_INFO .. u8(' Правила проекта'), imgui.ImVec2(300,40)) then
                pravila[0] = not pravila[0]
            end
        end

        if tab == 4 then
            if imgui.Combo(u8'Выбор темы', theme, new['const char*'][#themeList](themeList), #themeList) then 
                themes[theme[0]+1].func()
                iniSave()
            end
            if imgui.Checkbox(u8'Включить колизию', Checkbox) then
                if Checkbox[0] then
                sendCommand('collision')
            else
                sendCommand('collision')
                end
            end
            if imgui.Checkbox(u8'Стример режим', check) then
                if check[0] then
                sendCommand('tpoff')
             else
                sendCommand('tpon')
                end
            end
                if imgui.Button(fa.ROTATE_RIGHT .. u8(' Перезагрузить Скрипт'), imgui.ImVec2(300,40)) then
                    thisScript():reload()
                    imgui.ShowCursor = false
                end
                if imgui.Button(fa.FILE_ARROW_DOWN .. u8(' Выгрузить Скрипт'), imgui.ImVec2(300,40)) then
                    thisScript():unload()
                    imgui.ShowCursor = false
                end
             end

             if tab == 5 then
                imgui.Text(u8'Автор:gullsssss')
                imgui.Text(fa.PAPER_PLANE .. u8(" t.me/sborkiforrotyanka"))
                imgui.Text(u8'Баги? предложение по скрипту? @gullsssss')
            end
        end

        imgui.End()
end)


local otherFrame = imgui.OnFrame(
function() return pravila[0] end,
function(self)
    imgui.SetNextWindowPos(imgui.ImVec2(500, 695), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5)) -- отвечает за положение окна на экране
    imgui.SetNextWindowSize(imgui.ImVec2(350, 500), imgui.Cond.FirstUseEver)
    imgui.Begin(u8'Правила Arizona Fun', pravila, imgui.WindowFlags.AlwaysAutoResize)
    if imgui.CollapsingHeader(u8'Правила проекта') then
        imgui.Text(u8'1.0 Попытка ДМ//: /jail 15 минут')
        imgui.Text(u8'1.1 ДМ//: /jail 60 минут')
        imgui.Text(u8'1.2 Махинации//: /ban 2000 дней+обнуление')
        imgui.Text(u8'1.3 Массовый ДМ//: /ban 3 (при повторе /ban 10дней)')
        imgui.Text(u8'1.4 Обман/try, Обман//: /ban 2000 дней+обнуление')
        imgui.Text(u8'1.5 Оскорбление родных//: /ban 5 дней')
        imgui.Text(u8'1.6Упоминание родных//: /mute 150минут-/ban 5 дней')
        imgui.Text(u8'1.7Травля игроков в соц.сетях//: /ban 5 дней+бан ip')
        imgui.Text(u8'1.8 Стримснайп//: /jail 30 минут')
        imgui.Text(u8'1.9 Розжиг обсуждение политики//: /ban 10 дней')
        imgui.Text(u8'1.11 Ремклама промокода//: /mute 120 минут')
        imgui.Text(u8'1.12 Обман администрации и Спец.Администраторов//: /ban 15 дней')
        imgui.Text(u8'1.13 Продажа,Покупка ив//: /ban 2000+обнуление')
        imgui.Text(u8'1.14 Покупка/Передача/Взлом аккаунтов//: /ban 2000 дней+бан по ip+ обнуление')
        imgui.Text(u8'1.15 Обход бана//: /ban всех аккаунтов на 2000 дней')
    end
        if imgui.CollapsingHeader(u8'Правила ДМ зоны') then
        imgui.Text(u8'1.16 Изпользувать охраников в ДМ зоне /jail 60 минут')
        imgui.Text(u8'1.17 Запрещенное оружие в дм зоне(рпг,миниган,огнемет и тд) /jail 120 минут')
        imgui.Text(u8'1.18 Изпользувание бомбы /jail 120 минут')
        imgui.Text(u8'1.19 Изпользувание игрушки на П/У /jail 60 минут')
        imgui.Text(u8"1.20 Езда на транспорте в ДМ зоне /jail 60 минут")
        imgui.Text(u8'1.21 Изпользувание вред.ПО /ban 1 день')
        end
        if imgui.CollapsingHeader(u8'Правила Поведение в /az') then
        imgui.Text(u8'1.22 Стрельба/ДМ игрока /jail 75 минут')
        imgui.Text(u8'1.23 Попрошайничество в /az /mute 15 минут')
        imgui.Text(u8'1.24 Флуд (от 3-?х одинаковых сообщения за 18 секунд)')
        imgui.Text(u8'1.25 Прицеливание на игрока /jail 20 минут')
        imgui.Text(u8'1.26 Стрелять в стену или около игрока /jail 50 минут')
        imgui.Text(u8'1.27 Capslock в /az /mute 30 минут')
        end
        if imgui.CollapsingHeader(u8'Правила фам каптов') then
        imgui.Text(u8'1.28 Стрельба вне зоны /jail 60 минут')
        imgui.Text(u8'1.29 Изпользувать другие оружие со списка')
        imgui.Text(u8'1.30 Кроме м4(31id) deagle(24id) uzi(28id), обрезы(26id)')
        imgui.Text(u8'1.31 Покидать зону во время перестрелки. (Если человек случайным образом покинул фам капт, ему даётся 10 секунд чтобы вернуться) /jail 25 минут')
        imgui.Text(u8'1.32 Использовать игрушки на П/У')
        imgui.Text(u8'1.33 ДБ танки и тд /jail 60')
        imgui.Text(u8'1.34 Изпользувание вред.ПО /ban 3 дня')
        imgui.Text(u8'1.35 Запрещено делать через капты нецензурные вещи на карте удалание семьи + /ban')
        end
    end)


function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then
        return
    end
    while not isSampAvailable() do
        wait(100)
    end

    -- вырежи тут, если хочешь отключить проверку обновлений
    if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end
    sampRegisterChatCommand('fh', function()
        WinState[0] = not WinState[0]
    end)
end
imgui.OnInitialize(function()
    decor()
    for i, v in ipairs(themes) do
        table.insert(themeList, v.name)
    end
    themes[theme[0]+1].func()
end)

function autoupdate(json_url, prefix, url)
    local dlstatus = require('monetloader').download_status
    local json = getWorkingDirectory() .. '\\'..thisScript().name..'-version.json'
    if doesFileExist(json) then os.remove(json) end
    downloadUrlToFile(json_url, json,
      function(id, status, p1, p2)
        if status == dlstatus.STATUSEX_ENDDOWNLOAD then
          if doesFileExist(json) then
            local f = io.open(json, 'r')
            if f then
              local info = decodeJson(f:read('*a'))
              updatelink = info.updateurl
              updateversion = info.latest
              f:close()
              os.remove(json)
              if updateversion ~= thisScript().version then
                lua_thread.create(function(prefix)
                  local dlstatus = require('monetloader').download_status
                  local color = -1
                  sampAddChatMessage((prefix..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion), color)
                  wait(250)
                  downloadUrlToFile(updatelink, thisScript().path,
                    function(id3, status1, p13, p23)
                      if status1 == dlstatus.STATUS_DOWNLOADINGDATA then
                        print(string.format('Загружено %d из %d.', p13, p23))
                      elseif status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
                        print('Загрузка обновления завершена.')
                        sampAddChatMessage((prefix..'Обновление завершено!'), color)
                        goupdatestatus = true
                        lua_thread.create(function() wait(500) thisScript():reload() end)
                      end
                      if status1 == dlstatus.STATUSEX_ENDDOWNLOAD then
                        if goupdatestatus == nil then
                          sampAddChatMessage((prefix..'Обновление прошло неудачно. Запускаю устаревшую версию..'), color)
                          update = false
                        end
                      end
                    end
                  )
                  end, prefix
                )
              else
                update = false
                print('v'..thisScript().version..': Обновление не требуется.')
              end
            end
          else
            print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..url)
            update = false
          end
        end
      end
    )
    while update ~= false do wait(100) end
  end

function decor()
    -- == Декор часть == --
    local gs = imgui.GetStyle()
    gs.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    gs.WindowRounding = 10.0
    gs.ChildRounding = 6.0
    gs.FrameRounding = 8
    gs.PopupRounding = 8
    gs.ScrollbarRounding = 8
    gs.ScrollbarSize = 13.0
    gs.GrabRounding = 8.0
end

themes = {
	     {
            name = u8'Черная',
            func = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
            imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
            imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
            imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
            imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
            imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
        end
    },
    {
        name = u8'Зелёная',
        func = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(0.85, 0.93, 0.85, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.55, 0.65, 0.55, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.13, 0.22, 0.13, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.17, 0.27, 0.17, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.15, 0.24, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.18, 0.28, 0.18, 1.00)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.15, 0.25, 0.15, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.35, 0.45, 0.35, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(0.50, 0.70, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.50, 0.70, 0.50, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.55, 0.75, 0.55, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.28, 0.38, 0.28, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.30, 0.40, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.35, 0.45, 0.35, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.60, 0.70, 0.60, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(0.65, 0.75, 0.65, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.60, 0.70, 0.60, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(0.65, 0.75, 0.65, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.15, 0.25, 0.15, 0.80)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.19, 0.29, 0.19, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.23, 0.33, 0.23, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.25, 0.35, 0.25, 1.00)
        end
	},
    {
        name = u8'Белый',
        func = function()
            local ImVec4 = imgui.ImVec4
            imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
            imgui.GetStyle().Colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00);
            imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.94, 0.94, 0.94, 1.00);
            imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
            imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.94, 0.94, 0.94, 0.78);
            imgui.GetStyle().Colors[imgui.Col.Border] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
            imgui.GetStyle().Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
            imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.94, 0.94, 0.94, 1.00);
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.88, 1.00, 1.00, 1.00);
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.80, 0.89, 0.97, 1.00);
            imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.94, 0.94, 0.94, 1.00);
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.94, 0.94, 0.94, 1.00);
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 0.51);
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.94, 0.94, 0.94, 1.00);
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.02, 0.02, 0.02, 0.00);
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.31, 0.31, 0.31, 1.00);
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
            imgui.GetStyle().Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.20, 0.20, 0.20, 1.00);
            imgui.GetStyle().Colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.00, 0.48, 0.85, 1.00);
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.80, 0.80, 0.80, 1.00);
            imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.88, 0.88, 0.88, 1.00);
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.88, 1.00, 1.00, 1.00);
            imgui.GetStyle().Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.80, 0.89, 0.97, 1.00);
            imgui.GetStyle().Colors[imgui.Col.Header] = imgui.ImVec4(0.88, 0.88, 0.88, 1.00);
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.88, 1.00, 1.00, 1.00);
            imgui.GetStyle().Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.80, 0.89, 0.97, 1.00);
            imgui.GetStyle().Colors[imgui.Col.Separator] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.10, 0.40, 0.75, 0.78);
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.10, 0.40, 0.75, 1.00);
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.00, 0.00, 0.00, 0.25);
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 0.67);
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.00, 0.00, 0.00, 0.95);
            imgui.GetStyle().Colors[imgui.Col.Tab] = imgui.ImVec4(0.88, 0.88, 0.88, 1.00);
            imgui.GetStyle().Colors[imgui.Col.TabHovered] = imgui.ImVec4(0.88, 1.00, 1.00, 1.00);
            imgui.GetStyle().Colors[imgui.Col.TabActive] = imgui.ImVec4(0.80, 0.89, 0.97, 1.00);
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97);
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00);
            imgui.GetStyle().Colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.00, 0.47, 0.84, 1.00);
            imgui.GetStyle().Colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
            imgui.GetStyle().Colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
            imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
            imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
            imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
        end
    },
    {
        name = u8'Хакерский',
        func = function()
    local ImVec4 = imgui.ImVec4
    imgui.SwitchContext()
    imgui.GetStyle().Colors[imgui.Col.Text] = imgui.ImVec4(0.00, 1.00, 0.14, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TextDisabled] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.Border] = imgui.ImVec4(0.31, 0.64, 0.26, 0.38);
    imgui.GetStyle().Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
    imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.CheckMark] = imgui.ImVec4( 1.00, 1.00, 1.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.18, 0.49, 0.196, 1);
    imgui.GetStyle().Colors[imgui.Col.Header] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.180, 0.490, 0.196, 1);
    imgui.GetStyle().Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.180, 0.490, 0.196, 1);
    imgui.GetStyle().Colors[imgui.Col.Separator] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotLines] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.Tab] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TabHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
    imgui.GetStyle().Colors[imgui.Col.TabActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00);
end
    },
{
    name = u8"Голубой с черным",
    func = function()
        local ImVec4 = imgui.ImVec4
        imgui.SwitchContext()
            imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(0.00, 0.98, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.00, 0.85, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.00, 0.86, 0.96, 1.00)
            imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
            imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
            imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
            imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
            imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
            imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
            imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
            imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
            imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
            imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
            imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
        end
},
{
    name = u8"Красный",
    func = function()
        local ImVec4 = imgui.ImVec4
        imgui.SwitchContext()
        imgui.GetStyle().Colors[imgui.Col.Text] = imgui.ImVec4(0.95, 0.96, 0.98, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.60, 0.60, 0.60, 1.00)
        imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.15, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.20, 0.15, 0.15, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.15, 0.10, 0.10, 0.95)
        imgui.GetStyle().Colors[imgui.Col.Border] = imgui.ImVec4(0.70, 0.30, 0.30, 0.50)
        imgui.GetStyle().Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.25, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.40, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.60, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.15, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.25, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.15, 0.10, 0.10, 0.75)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.15, 0.10, 0.10, 0.60)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.80, 0.20, 0.20, 0.80)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.90, 0.30, 0.30, 0.80)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.95, 0.40, 0.40, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.20, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.30, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.40, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Header] = imgui.ImVec4(0.20, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.40, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.60, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Tab] = imgui.ImVec4(0.20, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TabHovered] = imgui.ImVec4(0.40, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TabActive] = imgui.ImVec4(0.60, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotLines] = imgui.ImVec4(0.80, 0.20, 0.20, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(0.90, 0.30, 0.30, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.80, 0.20, 0.20, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(0.90, 0.30, 0.30, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(0.30, 0.60, 0.85, 0.35)
        imgui.GetStyle().Colors[imgui.Col.DragDropTarget] = imgui.ImVec4(0.85, 0.60, 0.40, 0.90)
        imgui.GetStyle().Colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.80, 0.30, 0.30, 1.00)
        imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(0.90, 0.50, 0.50, 0.70)
        imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.20, 0.20, 0.25, 0.20)
        imgui.GetStyle().Colors[imgui.Col.CheckMark] = imgui.ImVec4(0.90, 0.10, 0.10, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.20, 0.20, 0.25, 0.35)
    end
},
{
    Name = u8"Черно-оранджевый",
    fung = function()
    local ImVec4 = imgui.ImVec4
    imgui.SwitchContext()
    imgui.GetStyle().Colors[imgui.Col.Text] = imgui.ImVec4(1.00, 0.69, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
    imgui.GetStyle().Colors[imgui.Col.WindowBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PopupBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Border] = imgui.ImVec4(1.00, 0.69, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.FrameBgActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(1.00, 0.69, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(1.00, 0.69, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(1.00, 0.69, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.CheckMark] = imgui.ImVec4(1.00, 0.69, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrab] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(0.13, 0.13, 0.13, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ButtonActive] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Header] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.HeaderActive] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.Separator] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.SeparatorActive] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGrip] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLines] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.69, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
    imgui.GetStyle().Colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(1.00, 0.69, 0.00, 0.43)
    imgui.GetStyle().Colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
    imgui.GetStyle().Colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.67, 0.39, 0.09, 1.00)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
    imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
    imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35)


    end
}
}


