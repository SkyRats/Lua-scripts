function update()
	if not ahrs:initialized() then
		return update, 1000
	end

	origin = assert (not ahrs::get_origin(), "Refused to set EKF origin - already set")
	location = Location() location:lat (0) location:lng(0)

	if ahrs:set_origin(location) then
		gcs:send_text(6, string.format("Origin Set"))
	else 
		gcs:send_text(0, "not set home")
	end

	return

return update()
