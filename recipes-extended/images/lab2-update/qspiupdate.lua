require ("swupdate")

function cfgUpdateVer()
        local handle = io.popen('/opt/app/egt-swupdate -v')
        local ret = handle:read('*a')
        local appVersion = ret:gsub('[\n\r]', '')
        handle:close()

        appVersion = string.match(appVersion, " (.*)")

        local file = io.open('/etc/swupdate.cfg', 'r')
        local content = file:read '*a'
        file:close()

        local hawkbitReportAppVersion = string.format('{ name = \"App Version\"; value = \"%s\"; },', appVersion)
        local swupdateAppVersion = string.format('name = \"Application\";\n\t\tversion = \"%s\";\n\t}', appVersion)

        modified = string.gsub(content, '{ name = \"App Version\".-},', hawkbitReportAppVersion)
        modified = string.gsub(modified, 'name = \"Application\".-}', swupdateAppVersion)

        file = io.open('/etc/swupdate.cfg', 'w')
        file:write(modified)
        file:close()
end

function restartSWUpdate()
        local handle = io.popen('date -d "now + 5 seconds" +%s')
        local output = handle:read('*a')
        local restartTime = output:gsub('[\n\r]', '')
        handle:close()

        local cmd = string.format('systemd-run --on-calendar "@%s" --timer-property=AccuracySec=1us systemctl restart swupdate', restartTime)

        os.execute(cmd)
        return true
end

function preinst()
	local out = "Pre-install script: Stop app and umount data partition for update"

        local handle = io.popen('pidof egt-swupdate')
        local ret = handle:read('*a')
        local pid = ret:gsub('[\n\r]', '')
        handle:close()

        swupdate.trace('Stopping All Apps\r\n')
        os.execute([[systemctl stop egtdemo.service]])

        swupdate.trace('Unmounting QSPI for update\r\n')
        os.execute([[systemctl stop opt-app.mount]])

	return true, out
end

function postinst()
	local out = "Post-install: Remount updated mtd, start app, and restart swudpate service"

        os.execute([[systemctl start opt-app.mount]])

        cfgUpdateVer()
        restartSWUpdate()

        os.execute([[systemctl start egtdemo]])
	return true, out
end

function postfailure()
        local out = "Post-install failure script...something went wrong!"

        return true, out
end
