# HKA-NES

This project was created as a project assignment in the Electrical Engineering programme at Karlsruhe University of Applied Sciences. The Goal was to implement the Picture processing unit (PPU) of the NES on the FPGA using VHDL. The PPU gets inputs from the CPU and is also connected to the Character ROM and by this creates output data that can be interpreted to be a picture on a screen. Please note that this project only covers the PPU. In the following you will find a short breakdown of the used modules and their purpose.

## Sprite Control Unit:

This block is active while foreground rendering is enabled. Its purpose is it to evaluate in each scanline which sprites will be rendered there. For that it takes input from the OAM and compares the y-coordinate with the current scanline stored in the v-register. If a valid sprite is found, its data will be transferred to the OAM RAM (secondary OAM) and after that it will be loaded into the rendering shift registers.

## Background Control Unit:

This block is active while background rendering is enabled. Its purpose is it to fetch data from the nametables and load it into the rendering shift registers at the correct time therefore ensuring that the background is rendered correctly.

## Pixel Data Sort:

This block consists of the two subblocks pixel_data_sort_background and pixel_data_sort_foreground. Its purpose is it to store the pixel data received from Background and Foreground Control Unit in shift registers and thus changing the parallel data to serial data. These shift registers shift the data each cycle so that each cycle the data for one pixel drops out. The block is divided into those two subblocks because the background gets every 8 cycles newly fetched data input while the foreground is only evaluated once every scanline and the shifting starts depending on the sprite's x-coordinate. For that the subblock Countdown is needed. Pixel_data_sort_foreground consists of eight times the subblock sprite_timer because of readablity. The block used for the shift registers is called shift_register_parallel_load.
