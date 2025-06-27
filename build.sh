#!/bin/sh

#git clone https://github.com/nxp-imx/imx-atf.git
#git clone https://github.com/nxp-imx/uboot-imx.git
#git clone https://github.com/nxp-imx/imx-mkimage.git

# DEFCONFIG = imx8mm_tsk8mm1_defconfig

rm -f ./flash.bin

cd ./imx-atf && make CROSS_COMPILE=aarch64-linux-gnu- -j8 PLAT=imx8mm && cd ../
cp ./src/tsk8mm1.dts ./uboot-imx/arch/arm/dts/tsk8mm1.dts || exit 1
cp ./src/imx8mm_tsk8mm1_defconfig ./uboot-imx/configs/imx8mm_tsk8mm1_defconfig || exit 1
cd ./uboot-imx && make imx8mm_tsk8mm1_defconfig && make CROSS_COMPILE=aarch64-linux-gnu- -j8 && cd ../
cp ./imx-atf/build/imx8mm/release/bl31.bin ./imx-mkimage/iMX8M/
cp ./uboot-imx/spl/u-boot-spl.bin ./imx-mkimage/iMX8M/
cp ./uboot-imx/u-boot-nodtb.bin ./imx-mkimage/iMX8M/
cp ./uboot-imx/tools/mkimage ./imx-mkimage/iMX8M/mkimage_uboot

# cp ./uboot-imx/arch/arm/dts/imx8mm-evk.dtb ./imx-mkimage/iMX8M/
# cp ./uboot-imx/arch/arm/dts/imx8mm-ddr4-evk.dtb ./imx-mkimage/iMX8M/
#cp ./uboot-imx/arch/arm/dts/imx8mm-ddr4-evk.dtb ./imx-mkimage/iMX8M/
#cp ./uboot-imx/arch/arm/dts/ok8mm-evk.dtb ./imx-mkimage/iMX8M/imx8mm-ddr4-evk.dtb
cp ./uboot-imx/arch/arm/dts/tsk8mm1.dtb ./imx-mkimage/iMX8M/

cp ./ddr_fw/*.bin ./imx-mkimage/iMX8M/

cd ./imx-mkimage && make -j8 SOC=iMX8MM HDMI=no dtbs=tsk8mm1.dtb TEE= flash_ddr4_evk && cd ../
cp ./imx-mkimage/iMX8M/flash.bin ./flash.bin

