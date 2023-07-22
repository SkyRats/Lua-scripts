-- Esse script faz o drone ir para frente e para trás a uma distância e número de vezes definidas
-- Seus estados são :
--  0) Muda para o Guided mode
--  1) Takeoff até a altura takeoff_alt 
--  2) Espera até atingir a altura de takeoff
--  3) Vai para frente até a distancia definida
--  4) Volta para a posição inicial
--  5) Muda para o land mode

local takeoff_alt = 3 -- Altura de takeoff
local copter_guided_mode_num = 4
local copter_land_mode_num = 9
local stage = 0
local count = 0               -- Número de vezes que o drone foi para frente
local max_count = 2           -- Número máximo de vezes que o drone deve ir para frente
local ping_pong_distance = 10 -- Distancia até a qual o drone deve ir para frente (m)
local vel = 1                 -- Velocidade do drone (m/s)


function update()
    -- Checando se o drone está armado
    if not arming:is_armed()then
         -- reset state when disarmed
        stage = 0
        gcs:send_text(6, "Arming")
    else
        if(stage == 0) then      -- Stage0 : Change to guided mode
              if(vehicle:set_mode(copter_guided_mode_num)) then -- change to Guided mode
                  stage = stage + 1
              end
        elseif (stage == 1) then -- Stage1 : takeoff
        gcs:send_text(6, "Taking off")
            if(vehicle:start_takeoff(takeoff_alt)) then
                stage = stage + 1
            end
        elseif (stage == 2) then --  Stage2 : check if vechile has reached target altitude
            local home = ahrs:get_home()
            local curr_loc = ahrs:get_position()
            if home and curr_loc then 
                local vec_from_home = home:get_distance_NED(curr_loc)
                gcs:send_text(6, "Altitude above home: " .. tostring(math.floor(-vec_from_home:z())))
                if(math.abs(takeoff_alt + vec_from_home:z()) < 1) then
                    stage = stage + 1
                end
            end
        elseif (stage == 3) then -- Stage3 : Moving Foward
        -- Se execedey o número de vezes muda para o stage5
            if (count >= max_count) then
                stage = stage + 2
            end

                -- calculate velocity vector
                local target_vel = Vector3f()
                target_vel:x(vel)
                target_vel:y(0)
                target_vel:z(0)

                -- send velocity request
                if not (vehicle:set_target_velocity_NED(target_vel)) then
                    gcs:send_text(6, "Failed to execute velocity command")
                end
                
                -- checking if reached stop point
                local home = ahrs:get_home()
                local curr_loc = ahrs:get_position()
                if home and curr_loc then 
                    local vec_from_home = home:get_distance_NED(curr_loc)
                    gcs:send_text(6, "Distance from home: " .. tostring(math.floor(vec_from_home:x())))
                    if(math.abs(ping_pong_distance - vec_from_home:x()) < 1) then
                        count = count + 1
                        stage = stage + 1
                    end
                end
            
        elseif (stage == 4) then --stage4 :  Moving Back
            -- calculate velocity vector
            local target_vel = Vector3f()
            target_vel:x(-vel);;
            target_vel:y(0)
            target_vel:z(0)

            -- send velocity request
            if not (vehicle:set_target_velocity_NED(target_vel)) then
                gcs:send_text(6, "Failed to execute velocity command")
            end
            
            -- checking if reached stop point
            local home = ahrs:get_home()
            local curr_loc = ahrs:get_position()
            if home and curr_loc then 
                local vec_from_home = home:get_distance_NED(curr_loc)
                gcs:send_text(6, "Distance from home: " .. tostring(math.floor(vec_from_home:x())))
                if(math.abs( vec_from_home:x()) < 1) then
                    stage = stage - 1
                end
            end
              
          elseif (stage == 5) then -- Stage5 :  change to land mode
              vehicle:set_mode(copter_land_mode_num)
              stage = stage + 1
              gcs:send_text(6, "Finished pingpong, switching to land")
          end
        end
    return update, 100
end

return update()

