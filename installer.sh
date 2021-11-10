#!/usr/bin/bash
backtitle="StreamerOS_VM-Installer"
vendor_id=$(lscpu | grep 'Vendor ID' | awk '{print $3}')
cpu_model=$(lscpu | grep "Model name" | awk '{print substr ($0,34)}')
gpu_vendor=$(lspci | grep "VGA" | awk '{print $9}')
gpu_model=$(lspci | grep "VGA" | awk '{print $9,$11,$12,$13}')
total_mem=$(free -m | grep Mem | awk '{print $2}')"MB"
[ -d /sys/firmware/efi ] && boot_mode="UEFI" || boot_mode="BIOS"
bios_version=$(cat /sys/class/dmi/id/bios_version)
mb_model=$(cat /sys/devices/virtual/dmi/id/board_{vendor,name})

#Detecting Cpu and model
if [[ $vendor_id = "AuthenticAMD" ]];
then
  echo $cpu_model
  ucode="amd-ucode"
elif [[ $vendor_id = "GenuineIntel" ]];
then
  echo $cpu_model
  ucode="intel-ucode"
else
  ucode=""
fi

#Detecting Gpu and Model.
if [[ $gpu_vendor = "[AMD/ATI]" ]];
then
  echo $gpu_model
  gpu_driver="xf86-video-amdgpu"
elif [[ $gpu_vendor = "NVIDIA" ]];
then
  echo $gpu_model
  [[ -z "$gpu_driver" ]] && gpu_driver="xf86-video-nouveau" || gpu_driver="${gpu_driver} xf86-video-nouveau"
  gpu_driver=""
elif [[ $gpu_vendor = "Intel" ]];
then
  echo $gpu_model
  [[ -z "$gpu_driver" ]] && gpu_driver="xf86-video-intel" || gpu_driver="${gpu_driver} xf86-video-intel"
  gpu_driver=""
fi
#--TURKISH-----------------------------------------------------------------------------------------------------#
turkish(){
  backtitle="StreamerOS_VM-Yükleyici"
  hardwareshow="Donanimlar ve Destekler"
  CPU="Islemci"
  GPU="Ekran Karti"
  totram="Toplam RAM"
  mb="Anakart"
  version="Versiyon"
  bootmode="Acilis Modu"
  disksel="Disk Secimi"
  partingdisk="Disk Bolunuyor"
  plswait="Lutfen Bekleyin"
}
#--ENGLISH-----------------------------------------------------------------------------------------------------#
english(){
  backtitle="StreamerOS_VM-Installer"
  hardwareshow="Hardware and Support"
  CPU="CPU"
  GPU="GPU"
  totram="Total RAM"
  mb="Motherboard"
  version="Version"
  bootmode="Boot Mode"
  disksel="Disk Select"
  partingdisk="Parting Disk"
  plswait="Please Wait"
}
#--------------------------------------------------------------------------------------------------------------#
hardwaredetect(){
  whiptail --backtitle "${backtitle}" --title "${hardwareshow}" --msgbox "$CPU: $cpu_model \n$GPU: $gpu_model \n$totram: $total_mem \n$mb: $mb_model $version $bios_version \n$bootmode: $boot_mode"  0 0 0
  diskselect
}
#--------------------------------------------------------------------------------------------------------------#
diskselect(){
    disks=$(lsblk -d -p -n -l -o NAME,SIZE -e 7,11)
    options=()
    IFS_ORIG=$IFS
    IFS=$'\n'
    for seldisk in ${disks}
    do
        options+=("${seldisk}" "")
    done
    IFS=$IFS_ORIG
    showdisk=$(whiptail --backtitle "${backtitle}" --title "${disksel}" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
    if [ "$?" != "0" ]
    then
      return 1
    fi
      echo ${showdisk%%\ *}
      formatdisk
      return 0
}
#--------------------------------------------------------------------------------------------------------------#
formatdisk(){
  {
  sleep 0.5
  echo -e "XXX\n0\n${partingdisk} \nXXX"
  sleep 2
  echo -e "XXX\n25\n${partingdisk}. \nXXX"
  sleep 0.5

  echo -e "XXX\n25\n${partingdisk}.. \nXXX"
  sleep 2
  echo -e "XXX\n50\n${partingdisk}... \nXXX"
  sleep 0.5

  echo -e "XXX\n50\n${partingdisk} \nXXX"
  sleep 2
  echo -e "XXX\n75\n${partingdisk}. \nXXX"
  sleep 0.5

  echo -e "XXX\n75\n${partingdisk}.. \nXXX"
  sleep 2
  echo -e "XXX\n100\n${partingdisk}... \nXXX"
  sleep 1
} |whiptail --title "${plswait}" --gauge "Please wait while installing" 6 60 0
}
#--------------------------------------------------------------------------------------------------------------#

if [ "${1}" = "" ]; then
	nextitem="."
else
	nextitem=${1}
fi
options=()
options+=("English" "")
options+=("Turkish" "")
lang=$(whiptail --backtitle "${backtitle}" --title "Select Language" --menu "" --cancel-button "exit" --default-item "${nextitem}" 0 0 0 \
	"${options[@]}" \
	3>&1 1>&2 2>&3)
if [ "$?" = "0" ]; then
  case ${lang} in
    "English")
      english
      hardwaredetect
      nextitem="turkish"
      ;;
    "Turkish")
      turkish
      hardwaredetect
      nextitem="turkish"
      ;;
    esac
else
  clear
fi
