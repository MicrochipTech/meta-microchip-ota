function preinst()
	local out = "Pre-install script, nothign to do"

	return true, out

end

function postinst()
	local out = "Halting system"

	swupdate.set_bootenv('upgrade_available', '0')
	os.execute("( sleep 5; halt ) &")

	return true, out
end

function postfailure()
	local out = "Update failed, rebooting to try again"

	os.execute("( sleep 5; reboot ) &")

	return true, out
end
