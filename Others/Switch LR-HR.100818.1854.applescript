on run
	set disk_target_name to "Phototheque"
	set srv_phototheque_lr to "LAYOUT-MACDATA"
	set srv_phototheque_hr to "layout.server"
	set list_volumes to list folder (path to startup disk as string) & "Volumes:"
	set disk_phototheque_mounted to 0
	
	repeat with i in (list_volumes)
		if i contains disk_target_name then
			set disk_phototheque_mounted to disk_phototheque_mounted + 1
			-- log disk_phototheque_mounted
		end if
	end repeat
	
	if disk_phototheque_mounted > 1 then
		-- log disk_phototheque_mounted
		display dialog "There's multiple phototheque mounted on your computer" & return & return & Â
			"Which Resolution Phototheque do you want use ?" with icon caution buttons {"High Resolution", "Low Resolution", "Cancel"} default button 3
		if the button returned of the result is "High Resolution" then
			connect_to_high_res_phototheque()
		else
			connect_to_low_res_phototheque()
		end if
		
	else
		if disk_phototheque_mounted = 1 then
			-- log disk_phototheque_mounted
			set which_server to get_the_server_phototheque(disk_target_name)
			if which_server is srv_phototheque_hr then
				display dialog "You are connected to the High-Resolution Server." & return & return & Â
					"Do you want to connect to the Low-Resolution Phototheque ?" with icon caution buttons {"Go to the Low Resolution", "Cancel"} default button 1
				if the button returned of the result is "Go to the Low Resolution" then
					connect_to_low_res_phototheque()
				end if
			else
				display dialog "You are connected to the Low-Resolution Server." & return & return & Â
					"Do you want to connect to the High-Resolution Phototheque ?" with icon caution buttons {"Go to the High Resolution", "Cancel"} default button 1
				if the button returned of the result is "Go to the High Resolution" then
					connect_to_high_res_phototheque()
				end if
			end if
		else
			-- log disk_phototheque_mounted
			display dialog "There's no phototheque mounted on your computer." & return & return & Â
				"Which phototeque do you want to connect to ?" with icon caution buttons {"Go to the High Resolution", "Go to the Low Resolution", "Cancel"} default button 3
			if the button returned of the result is "Go to the High Resolution" then
				connect_to_high_res_phototheque()
			else
				connect_to_low_res_phototheque()
			end if
		end if
	end if
end run

on connect_to_high_res_phototheque()
	-- display dialog "Fn to connect to the HR"
	tell application "Finder"
		try
			repeat while ("Phototheque" is in (list disks))
				eject "Phototheque"
			end repeat
			mount volume "afp://10.1.0.2/Phototheque"
		end try
	end tell
end connect_to_high_res_phototheque

on connect_to_low_res_phototheque()
	-- display dialog "Fn to connect to the LR"
	tell application "Finder"
		try
			repeat while ("Phototheque" is in (list disks))
				eject "Phototheque"
			end repeat
			mount volume "smb://layout-macdata/Phototheque" as user name "Layout" with password "layout"
		end try
	end tell
	
end connect_to_low_res_phototheque

on get_the_server_phototheque(volume_mounted)
	tell application "System Events"
		return (get server of disk volume_mounted)
	end tell
end get_the_server_phototheque