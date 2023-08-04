-- Changes to RTL mode when the vehicle is 40m away from its takeoff point
function update () -- periodic function that will be called
    local current_pos = ahrs:get_position() -- fetch the current position of the vehicle
    local home = ahrs:get_home()            -- fetch the home position of the vehicle
    if current_pos and home then            -- check that both a vehicle location, and home location are available
      local distance = current_pos:get_distance(home) -- calculate the distance from home in meters
      gcs:send_text(6, "Distância de home:  " .. distance)
  
      if distance > 40 then
        vehicle:set_mode(6)
        gcs:send_text(6, "Returning to Launch...")
      
      end
    end
  
    return update, 1000 -- request "update" to be rerun again 1000 milliseconds (1 second) from now
  end
  
  return update, 1000   -- request "update" to be the first time 1000 milliseconds (1 second) after script is loaded
