######a* ZPU/history *
# MODIFICATION HISTORY
# DATE     WHO   DESCRIPTION
# -------- ----- --------------------------------------------------------------
# 07.05.08 JK    initial version
#                verilog verion of the ZPU
#                - basic tool chain for linux
#                  * binutils
#                  * gcc
#                - supported simulators:
#                  * cver     : http://www.pragmatic-c.com/gpl-cver/
#                  * veriwell : http://sourceforge.net/projects/veriwell
#                  * modelsim : http://www.model.com/resources/resources_demos.asp
#
# -----------------------------------------------------------------------------
# AUTHOR
# jurij kostasenko
#
# SEE ALSO
# - orig. file:
#   href:../readme.txt
#
# - eCosForge: sitefor the development of software for the eCos (R)
#              open source real-time operating system.
#   http://www.ecosforge.net/pmwiki/
#
# - ZPU - the worlds smallest 32 bit CPU with GCC toolchain: Overview
#   http://www.opencores.org/projects.cgi/web/zpu/overview
#
# - ROBODOC: a convenient documentation tool
#   http://www.xs4all.nl/~rfsber/Robo/robodoc.html
#
# - CVER: GNU General Public License Verilog standard HDL simulator
#   http://www.pragmatic-c.com/gpl-cver
#
# - v2html: a free perl script that converts verilog designs into webpages.
#   http://www.burbleland.com/v2html/v2html.html
#
# - Veripool: Free Verilog and SystemC Software
#   http://www.veripool.org
#
# TODO
# build gdb
######

######z* ZPU/Zylin documentation *
# SYNOPSIS
# all refered documents could be found in the CVS repository
#
#  Download
#
# the simplest way to get the ZPU HDL source and tools is to check it out from CVS:
#
# cvs -d :pserver:anonymous@cvs.opencores.org:/cvsroot/anonymous co zpu/zpu
#
# - Introduction to the stack based CPU (ZPU)
#   href:../zpu_arch.html
#
# - presentations for the zylin CPU (open office )
#   href:../zpudemo.odp
#   href:../zpu.odp
#
######

######z* ZPU/overview *
# SYNOPSIS
# ZPU is the worlds smallest 32 bit CPU with GCC tool-chain.
# the original ZPU source is written in VHDL and provided by Øyvind Harboe on the
# opencores web page.
#
#
# this document is a brief compilation for the verilog version of the ZPU.
# this version will enter to the CVS repository managed by Øyvind Harboe.
#
# tools provided with this development tree are build for x86 Linux architecture.
# the tool-chain tested on a intel i686 machine running on Scientific Linux 
# ( 2.6.9-67 GNU/Linux , RED HAT compatible):
# http://www.scientificlinux.org/
#
######

######z* ZPU/development tree *
# SYNOPSIS
#
# Directory Structure
# -------------------
# [ZPU_CORE]                     : ZPU_CORE directory tree
#   +- /doc                      : documentation for the ZPU
#      +- /hdl_html              : verilog source HTML browser
#      +- /html                  : HTML docu
#      +- /sources               :
#   +- /local_bin                : local tools for simulation and compilation
#   +- /local_etc                : local config files
#   +- /src                      : verilog HDL sources for the verilog ZPU
#   +- /tb                       : TESTBENCH directory tree
#      +- /bin                   : scripts to run the demo simulation
#      +- /hdl                   : verilog HDL testbench sources
#      +- /soft                  : software directory tree
#         +- /include            : C includes
#         +- /src                : C sources
#
######

######z* ZPU/verilog source browser *
# SYNOPSIS
# to browse thru the verilog implementation refer:
# href:../hdl_html/hierarchy.html
######

######z* ZPU/data base *
# SYNOPSIS
# this is a brief to important files
#
# |html <b><u>
# HDL design of the ZPU 
# |html </b></u>
# - main verilog source
#   href:../../src/zpu_core.v
#
# - configuration for the ZPU
#   href:../../src/incl/zpu_config.v
#
# - simple testbench for the ZPU (simulation only)
#   href:../../tb/hdl/tb_zpu_core.v
#
# - simple dual port memmory model (simulation only)
#   href:../../tb/hdl/dualport_ram.v
#
#
# |html <b><u>
# C software for a demo application
# |html </b></u>
#
# - simple main programm
#   href:../../tb/soft/src/main.c
#
#
# |html <b><u>
# scripts to build and run a simulation
# |html </b></u>
#
# - main run script for CVER based simulation
#   href:../../tb/bin/run_csim.sh
#
# - main run script for VERIWELL based simulation
#   href:../../tb/bin/run_vwsim.sh
#
# - main run script for modelsim based simulation
#   href:../../tb/bin/run_msim.sh
#
# - ZPU software compile script
#   href:../../tb/bin/gen_soft.sh
#
# - HDL generation/preperation script (in this version simple copy taks)
#   href:../../tb/bin/gen_hdl.sh
#
# - HDL source compilation with modelsim
#   href:../../tb/bin/compile_msim.sh
#
# - simple monitor to see the printf output from the simulation
#   href:../../tb/bin/tty_monitor.sh
#
######

######z* data base/run demos *
# SYNOPSIS
#
# to start a CVER demo simulation
# do as follow::
# |html <pre class=source>
# cd ZPU_CORE
# tb/bin/run_csim.sh
# |html </pre>
#
# to start a VERIWELL demo simulation
# do as follow::
# |html <pre class=source>
# cd ZPU_CORE
# tb/bin/run_vwsim.sh
# |html </pre>
#
# to start a MODELSIM demo simulation (modelsim should in your PATH variable!)
# do as follow::
# |html <pre class=source>
# cd ZPU_CORE
# tb/bin/run_msim.sh
# |html </pre>
#
# 
# file generated
# |html <table cellspacing=0 border=1><tr><td>
# |html <b><u>
# important files generated                                          
# |html </b></u>
#  MODELSIM
#  msim/tty_zpu.txt     : printf output file from the MODELSIM simulation
#  msim/transcript      : MODELSIM run log file 
#
#  CVER
#  csim/tty_zpu.txt     : printf output file from the CVER simulation (unfortunately not work properly)
#  csim/verilog.log     : CVER run log file
#
#  VERIWELL
#  vwsim/tty_zpu.txt    : printf output file from the VERIWELL simulation (unfortunately not work properly)
#  vwsim/veriwell.log   : VERIWELL run log file
#
#  SOFTWARE FLOW
#  wk/soft/img/main.dis : disassemble file
#  wk/mem/dpram.mem     : hex dump of the simulation memory
# |html </td></tr></table>
#
#######
