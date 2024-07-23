require ("swupdate")

function preinst()
	local out = "Pre-install script, nothing to do..."

	return true, out
end

function postinst()
	local out = "Post-install: Reset upgrade_available variable and reboot in 10 sec"

        swupdate.set_bootenv('upgrade_available', '0')
        os.execute("( sleep 10; reboot ) &")

	return true, out
end

function postfailure()
        local out = "Post-install failure script...something went wrong!"

        return true, out
end
