## To Create USB

Extract ISO

```
sudo mount Downloads/Fedora-Everything-netinst-x86_64-30-1.2.iso /run/media/Fedora-Everything-netinst-x86_64-30
mkdir -p /tmp/usb
cp -pRf /run/media/Fedora-Everything-netinst-x86_64-30 /tmp/usb
sudo mount /run/media/Fedora-Everything-netinst-x86_64-30
```

Copy kickstart file as ks.cfg to root of the USB

```
cp ~/git/dotfiles/kickstart.ks /tmp/usb/Fedora-Everything-netinst-x86_64-30/ks.cfg
```

Edit EFI/BOOT/BOOT.conf to:

```
linuxefi /images/pxeboot/vmlinuz inst.ks=hd:LABEL=Fedora-E-dvd-x86_64-30:ks.cfg  inst.stage2=hd:LABEL=Fedora-E-dvd-x86_64-30 quiet
```

```
genisoimage -U -r -v -T -J -joliet-long -V "Fedora-E-dvd-x86_64-30" -volset "Fedora-E-dvd-x86_64-30" -A"Fedora-E-dvd-x86_64-30" -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -o ../Fedora-E-dvd-x86_64-30.iso .
```