require ("swupdate")

function getUpdatePartition(part)
        local mountUnitFilePath = string.format('/run/media/mmcblk0p%s/usr/lib/systemd/system/opt-data.mount', part)
        local mountUnitFile = io.open(mountUnitFilePath, 'r')
        local content = mountUnitFile:read '*a'
        mountUnitFile:close()

        local activeMount = string.match(content, 'What=(.-)\n')

        if activeMount == "/dev/mmcblk0p5" then
                return "mmcblk0p6"
        else
                return "mmcblk0p5"
        end
end

function updateAppPartition(part)
        local mountUnitFilePath = string.format('/run/media/mmcblk0p%s/usr/lib/systemd/system/opt-data.mount', part)
        local mountUnitFile = io.open(mountUnitFilePath, 'r')
        local content = mountUnitFile:read '*a'
        mountUnitFile:close()

        local newMount = nil
        local activeMount = string.match(content, 'What=(.-)\n')

        if activeMount == "/dev/mmcblk0p5" then
                newMount = "/dev/mmcblk0p6"
        else
                newMount = "/dev/mmcblk0p5"
        end

        local mountPoint = string.format('What=%s\n', newMount)

        swupdate.trace("Current app mount point is " .. activeMount .. ", new mount point is " .. newMount)

        modified = string.gsub(content, 'What=.-\n', mountPoint)

        swupdate.trace(modified)

        mountUnitFile = io.open(mountUnitFilePath, 'w')
        mountUnitFile:write(modified)
        mountUnitFile:close()
end

function preinst()
	local out = "Pre-install script: Unmount destination partition if mounted"

        local rootpart
        
        rootpart = swupdate.get_bootenv("rootpart")

        if rootpart == nil then
                rootpart = 2
        end

        local updatePartition = getUpdatePartition(rootpart)

        swupdate.trace("update partition is " .. updatePartition)

        if swupdate.umount("/run/media/" .. updatePartition) ~= true then
                swupdate.trace("Note: Update partition " .. updatePartition .. " not mounted...")
        end

	return true, out
end

function postinst()
	local out = "Post-install: Update app data mount point and reboot"

        local rootpart
        
        rootpart = swupdate.get_bootenv("rootpart")

        if rootpart == nil then
                rootpart = 2
        end

        updateAppPartition(rootpart)

        swupdate.set_bootenv('upgrade_available', '0')
        os.execute("( sleep 5; reboot ) &")
        
	return true, out
end

function postfailure()
        local out = "Post-install failure, rebooting to try again..."

        swupdate.set_bootenv('upgrade_available', '0')
        os.execute("( sleep 5; reboot ) &")

        return true, out
end
