# OpenROAD support with SkyWater 130 PDK

## Install OpenROAD

First, clone clone `OpenROAD-flow-scripts`

```bash
cd flow
git clone --recursive https://github.com/The-OpenROAD-Project/OpenROAD-flow-scripts
cd OpenROAD-flow-scripts
```

Install `OpenRoad` [locally](https://openroad.readthedocs.io/en/latest/user/BuildLocally.html) as,


```bash
sudo ./tools/OpenROAD/etc/DependencyInstaller.sh
sudo ./build_openroad.sh --local
```

Finally, you need to install `KLayout` v0.27.1


Installing OpenRoad and KLayout may not be as straight and forwards, so you may need to install several missing packages
(e.g. Qt for KLayout or libreadline-dev for Yosys, tcl-dev for OpenSTA, etc)

```bash
git clone --depth=1 --branch v0.27.1 https://github.com/KLayout/klayout.git
cd klayout
./build.sh -noruby
```

## Edalize

`x-heep` uses a verion of `edalize` + `fusesoc` that supports `sv2v` to convert SystemVerilog to Verilog so that
`OpenRoad` (`yosys`) can compile it.

You need to install `sv2v` as:

```bash
git clone https://github.com/zachjs/sv2v.git
git checkout 36cff4ab0ff3fc64dddb66ef6f3ff4ed80cbd581
cd sv2v
make
```

Follow the instructions at [sv2v](https://github.com/zachjs/sv2v#installation)
and add `sv2v` to the `PATH` variable.

## Run command

```
make openroad-sky130
```
OPENROAD RUN

Tool takes an input configuration file config.mk which contains the information over:
	- technology (platform to be used)
	- design file (system verilog file)
	- sdc file (information over clock)
	- area parameters

SYNTHESIS
First step of the flow is synthesis which is done with yosys. Tool takes the information over design and technology to synthesize the system. 
This step generates 2 results 1_synth.v which is the netlist file and 1_synth.sdc which contains the same clock information to be used in the next step. 

FLOORPLAN
Second step is the floorplan. It starts by initializing the floorplan according to the parameters defined in config.mk file. There are two different methods. 
User should either define list of sites, die area and core area or utilization percent, aspect ratio and core margin. 
First method directly takes die area and core area values from the user but in the second method it is calculated from the design area and utilization.
After the initializing the floorplan it removes the buffers inserted by yosys and restructure for timing. Results are writen in 2_1_floorplan.odb and 2_floorplan.sdc files.

Since the initial floorplan finished tool goes over the other steps as pin placement, tdms, macro placement, tapcell insertion and pdn generation. Output files after every step is
stored in the results directory. 

PLACE
Global placement first starts without the pin placement, than it implements a non-random pin placement and does the global placement again. Afterwards tool resizes the cells and add buffers 
according to timing requirements, it also takes into account the wire RC and layer RC values in order to analyze the delays. Finally it runs a detailed placement with the final parameters. 
End of the placing step is written in 3_place.odb. 

CTS
For the clock tree sytnhesis openroad uses TritonCTS 2.0. It configures to clock tree according to the technology and sytnhesis it.

ROUTE
For the routing stage, first the tool runs the fastroute as global route and than runs the TritonRoute for detailed route. While creating the routes it takes the 
output of the cts stage and sets the max and min layers according to the technology. At the end, wire lengths are reported for each stage. 

FINISH
In order to finalize the design first it uses metal fillers to meet the density requirement. After that it creates the final def file with parametric extractions according to the given RC corner.
As a final step in klayout it generates gds files using the def files created by the openroad. 



How to use it better? 
You can run tcl scripts for every stage seperately, this way you can analyze the effects of the each of them. Also you can skip some middle steps which might not be necessary at every design.
When you check the tcl scripts you can see possible checkpoints, with this functionality you can exract the def files and analyze the layout. 
A lot of parameters are defined under the platform directory according to the technology so they shouldn't be changed much, however if the user wants to define a limitation some changes can 
be applied as long as they are implementable with the selected technology. 
















