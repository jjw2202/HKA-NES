# HKA-NES
![HKA-NES](docs/pictures/PPUoutput_HKA.png)
![HKA-NES](docs/pictures/PPUoutput_NES.png)

This project was created as a project assignment in the Electrical Engineering programme at [Karlsruhe University of Applied Sciences](https://www.h-ka.de/). The goal was to implement the Picture Processing Unit (PPU) of the NES on a FPGA using the hardware description language VHDL. The PPU gets inputs from the CPU and is also connected to the character ROM. In this way, it generates output data that can be interpreted as an image on a screen. Please note that this project only covers the PPU. Below is a brief overview of the modules used and their purpose.

## Motivation

The motivation for this project was it to make VHDL more interesting and accessible for new learners, to create another source for understanding the NES and therefore helping to conserve it better. Also this project was intended as a foundation for a laboratory at our university and for that also as a source to show the coding standard of it and motivate our fellow students to learn more about the NES and VHDL.

We created our own new project for that because other implementations didn't fully suit our needs explained above. They were either too hard to understand, were in Verilog instead of VHDL, were too close or too far from the original PPU and didn't have the university background we needed.

## Goals

So therefore our goal was it to document the PPU as good as possible for students to understand, to implement the PPU following the university's coding standard, make small adjustments for it to work with modern hardware and in the end show at least one freeze frame of a game. It was not the goal to implement a fully functioning NES and also there will be no CPU attached to it. 

## Implementation

We first tried to understand the PPU as good as possible. For that we created the blockdiagram you can find below. Based on that we created blocks that would have one specific function following the principle of "divide et impera", for example a block that controls the background rendering or a block that decides which pixel to render. Those you can also find below in VHDL Entities. We then started to write these blocks beginning from the very end so it would always be clear what signal we want to be generated. Every block has its own simulation for verifying that it functions correctly. When implementing we tried to be as close to the original PPU as possible but made some decisions to leave out parts of it for now. Not implemented is the scrolling feature, the sprite 0 flag, the sprite overflow bug and parts of the PPU MASK register. The reason for that was mainly time so we focused on the features that are essential for generating one frame.

## Evaluation 

Did we fulfill our goals? We documented our work here with pictures, comments and texts. We also coded following the guidelines of our university. All the essential PPU features are implemented so that we have a functioning PPU. But as you read before the PPU is not exactly like the original one. We are also able to generate one still frame. For a moving picture we would also have to connect the CPU. We are satisfied with our result and count it as a success even though there is still room for further implementation.

## Outlook

In the future you could also implement the features mentioned above that are not implemented but are also not essential. Also for moving pictures a CPU has to be attached and for getting a picture on a TV a VGA or HDMI encoder has to be added. The overall goal could be to have a fully implemented NES with not only the PPU working but also the other parts like CPU, APU etc.


## Blockdiagram
[![Blockdiagram PPU](docs/blockdiagram/HKA-NES_Blockdiagram-PPU.png)](docs/blockdiagram/HKA-NES_Blockdiagram-PPU.png)

## VHDL Entities
[![VHDL Entities](docs/blockdiagram/HKA-NES_Blockdiagram-VHDL_Entities.png)](docs/blockdiagram/HKA-NES_Blockdiagram-VHDL_Entities.png)

## PPU
[![VHDL Entities PPU](docs/blockdiagram/HKA-NES_Blockdiagram-VHDL_Top_Level_PPU.png)](docs/blockdiagram/HKA-NES_Blockdiagram-VHDL_Top_Level_PPU.png)

### PPU Control Unit
Controls the PPU. Manages the MMIO registers through which the PPU communicates with the CPU.

### Sprite Control Unit:
This block is active while foreground rendering is enabled. Its purpose is to evaluate which sprites should be rendered in each scan line. For that it takes input from the OAM and compares the y-coordinate with the current scanline stored in the v-register. If a valid sprite is found, its data will be transferred to the OAM RAM (secondary OAM) and after that it will be loaded into the rendering shift registers.

### Background Control Unit:
This block is active while background rendering is enabled. Its purpose is to retrieve data from the name tables and load it into the rendering shift registers at the right time to ensure that the background is rendered correctly.

### Pixel Data Sort:
This block consists of the two subblocks `pixel_data_sort_background` and `pixel_data_sort_foreground`. Its purpose is to store the pixel data received from the background and foreground control units in shift registers, thereby converting the parallel data into serial data. These shift registers shift the data each cycle so that each cycle the data for one pixel drops out. The block is divided into those two subblocks because the background gets every 8 cycles newly fetched data input while the foreground is only evaluated once every scanline and the shifting starts depending on the sprite's x-coordinate. For that the subblock `countdown` is needed. `pixel_data_sort_foreground` consists of eight times the subblock `sprite_timer` because of readablity. The block used for the shift registers is called `shift_register_parallel_load`.

### Color Pixel Generator
Receives foreground and background data from `pixel_data_sort`. Decides whether foreground, background or backdrop is output. EXT functionality is fully supported. If it is the primary PPU (see EXT functionality of the PPU), the palette RAM is addressed and the colour pixel is output as an **HTML hex value**.

## Sources we used for development and which provide a good overview
- [NES dev reference guide](https://www.nesdev.org/wiki/NES_reference_guide)
- [NesHacker](https://www.youtube.com/@NesHacker)
- [An overview of NES rendering](https://austinmorlan.com/posts/nes_rendering_overview/)
- [fpgaNES from Feuerwerk](https://github.com/Feuerwerk/fpgaNES)
