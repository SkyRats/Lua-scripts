# Lua-scripts

## Running in Simulation

To test Lua scripts in simulation using QGround and ArduPilot's SITL, follow these steps:

-  Run QGround:

        ./QGroundControl.AppImage

-  Run SITL 
        
        ardupilot/ArduCopter/sim_vehicle.py
            
-   Enable scripts in QGS :

    - Click on the icon with the letter "Q" in the top left corner;
    - Go to Vehicle Setup.;
    - Navigate to parameters;
    - Search for "SCR_ENABLE" and select it;
    - Change the value from None to Lua (or from 0 to 1);
    - Save (You might need to restart the simulation);



-  A folder named "scripts" will be created in the same directory where the simulation is running (ardupilot/ArduCopter)

-  Add the Lua scripts to this folder, and when you run SITL again, all the scripts in the folder will be executed.

## Running on the Real Drone

To run Lua scripts on the real drone, you need to send the Lua script files to the drone's SD card. Below are the steps to do this:


- Remove the SD card from the drone;
- Access the SD card content on your computer (you might need a micro SD adapter for this);
- The SD card should contain an "APM" folder, and within it, a "scripts" folder. If these folders don't exist, create them;
- Add or modify Lua scripts in the "APM/scripts" folder;
- Insert the SD card back into the drone (make sure it's properly inserted);

Now, to configure the scripts through QGround:

-  Run  QGround 
        ./QGroundControl.AppImage
-  Connect the drone to your computer (via USB directly or through telemetry).

- Enable scripts in QGS:

    - Click on the icon with the letter "Q" in the top left corner.
    - Go to Vehicle Setup.
    - Navigate to parameters.
    - Search for "SCR_ENABLE" and select it.
    - Change the value from None to Lua (or from 0 to 1).
    - Save (You might need to connect and disconnect the drone).
- If you encounter an "out of memory" error with scripts:

    - Click on the icon with the letter "Q" in the top left corner.
    - Go to Vehicle Setup.
    - Navigate to parameters.
    - Search for "SCR_DIR_DISABLE" and check the option "ROMFS" (this means it won't look for scripts in the ROMFS folder, but in the "APM/scripts" folder).
    - Save (You might need to connect and disconnect the drone).

Now, when you power on the drone, the scripts will be executed automatically.