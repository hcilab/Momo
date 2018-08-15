# The Falling of Momo: EMG Streaming Tool

## Description

  This is a hacky modification to the Momo game that leverages Momo's built in calibration utility and allows the game to act as a web server server and stream EMG data from the Myo Armband.

  This tool was designed to work with the Hololen's Virtual Box and Blocks tool: https://github.com/hcilab/HoloLensBoxAndBlocks

## Using The Tool

  1. __Download Processing for Windows:__ https://processing.org/download/

  2. __Clone or Download the `calibrateAndStream` branch of this project.__  If you download the .zip version, make sure you rename the project root folder from `Momo-calibrateAndStream` to `Momo` as Processing will not be able to run the program otherwise.

  3. __Install the required Processing libraries.__ 
    1. Launch Processing, then navigate to the Add Tools Wizard (Tools >> Add Tool...). 
    2. Select the libraries tab.
    3. Install the following 3 libraries: `Box2D for Processing`, `Minim`, `Sprites`.

  4. __Launch the Tool.__ Open the Momo.pde file in Processing, then click the Play Button.

  5. __Connect Armband.__ Follow the instructions available in the `momo-armbandConnectionInstructions.pdf` to connect Myo armband.

  6. __Calibrate.__

  7. __Stream Data.__


## Tweaking Settings

  Server Address and Port can be modified using the following two variables in Momo.pde file: `emgServerHost`, `emgServerPort`.


## Known Issues

  Myoband will not connect if bluetooth usb dongle provided with the myo is not configured as the first available system COM port. See https://github.com/hcilab/Momo/issues/87 for details and workaround.