#!/bin/sh

# Клонирование репозиториев (если еще не сделано)
[ ! -d "imx-atf" ] && git clone https://github.com/nxp-imx/imx-atf.git
[ ! -d "uboot-imx" ] && git clone https://github.com/nxp-imx/uboot-imx.git
[ ! -d "imx-mkimage" ] && git clone https://github.com/nxp-imx/imx-mkimage.git

# Удаление старого flash.bin
rm -f ./flash.bin

# Сборка ATF
cd ./imx-atf && make CROSS_COMPILE=aarch64-linux-gnu- -j8 PLAT=imx8mm || exit 1
cd ../

# Копирование конфигурации и DTS
cp ./src/tsk8mm1.dts ./uboot-imx/arch/arm/dts/tsk8mm1.dts || exit 1
cp ./src/imx8mm_tsk8mm1_defconfig ./uboot-imx/configs/imx8mm_tsk8mm1_defconfig || exit 1

# Сборка U-Boot с автоматической конфигурацией
cd ./uboot-imx
make clean
make distclean
make imx8mm_tsk8mm1_defconfig
make olddefconfig
make CROSS_COMPILE=aarch64-linux-gnu- -j8 V=1 || exit 1
cd ../

# Копирование файлов для imx-mkimage
cp ./imx-atf/build/imx8mm/release/bl31.bin ./imx-mkimage/iMX8M/ || exit 1
cp ./uboot-imx/spl/u-boot-spl.bin ./imx-mkimage/iMX8M/ || exit 1
cp ./uboot-imx/u-boot-nodtb.bin ./imx-mkimage/iMX8M/ || exit 1
cp ./uboot-imx/tools/mkimage ./imx-mkimage/iMX8M/mkimage_uboot || exit 1
cp ./uboot-imx/arch/arm/dts/tsk8mm1.dtb ./imx-mkimage/iMX8M/ || exit 1
cp ./ddr_fw/*.bin ./imx-mkimage/iMX8M/ || exit 1

# Сборка финального образа
cd ./imx-mkimage && make -j8 SOC=iMX8MM HDMI=no dtbs=tsk8mm1.dtb TEE= flash_ddr4_evk || exit 1
cd ../

# Копирование финального образа
cp ./imx-mkimage/iMX8M/flash.bin ./flash.bin || exit 1
