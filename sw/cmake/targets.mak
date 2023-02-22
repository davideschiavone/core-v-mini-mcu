# Copyright 2022 Jose Miranda
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.

# Author: Jose Miranda (jose.mirandacalero@epfl.ch)

build : build/Makefile
	@echo Build 
	${MAKE} -C build

setup : build/Makefile

build/Makefile : CMakeLists.txt ${CMAKE_DIR}/riscv.cmake
	if [ ! -d build ] ; then mkdir build ; fi
	cd build;  \
		cmake \
		    -G "Unix Makefiles" \
			-DCMAKE_TOOLCHAIN_FILE=../${CMAKE_DIR}/riscv.cmake \
			-DROOT_PROJECT=${ROOT_PROJECT} \
			-DPROJECT:STRING=${PROJECT} \
			-DMAINFILE:STRING=${MAINFILE} \
			-DRISCV:STRING=${RISCV} \
			-DLIB_CRT:STRING=${LIB_CRT} \
			-DLIB_CRT_FLASH_EXEC:STRING=${LIB_CRT_FLASH_EXEC} \
			-DLIB_CRT_FLASH_LOAD:STRING=${LIB_CRT_FLASH_LOAD} \
			-DLIB_BASE:STRING=${LIB_BASE} \
			-DLIB_BASE_FREESTD:STRING=${LIB_BASE_FREESTD} \
			-DLIB_RUNTIME:STRING=${LIB_RUNTIME} \
			-DLIB_DRIVERS:STRING=${LIB_DRIVERS} \
			-DINC_FOLDERS:STRING=${INC_FOLDERS} \
			-DLINK_FOLDER:STRING=${LINK_FOLDER} \
			-DLINKER:STRING=${LINKER} \
		    ../ 

clean:
	rm -rf build

.PHONY: setup build
.SUFFIXES:
