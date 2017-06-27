class Proxmark3 < Formula
#  desc "Proxmark3 client, flasher, HID flasher and firmware bundle"
  desc "[icemanfork] Proxmark3 client, CDC flasher and firmware bundle"
  homepage "http://www.proxmark.org"
  url "https://github.com/iceman1001/proxmark3/archive/v1.7.1.tar.gz"
  sha256 "84c933426d43bd68f982b60218a87152fd5c0748e54ba7f1c7325177c4aa0e83"
  head "https://github.com/iceman1001/proxmark3.git"

  option "without-iso14443a-standalone", "Disables ISO14443a standalone mode and enables LF standalone mode"

  depends_on "automake" => :build
  depends_on "readline"
  depends_on "p7zip" => :build
  depends_on "libusb"
  depends_on "libusb-compat"
  depends_on "pkg-config" => :build
  depends_on "wget"
  depends_on "qt5"
  depends_on "perl"
  depends_on "iceman1001/proxmark3/arm-none-eabi-gcc" => :build

  patch :DATA if build.without? "iso14443a-standalone"

  def install
    ENV.deparallelize

#    system "make", "-C", "client/hid-flasher/"
    system "make", "clean"
    system "make", "all"
    bin.mkpath
    bin.install "client/flasher" => "proxmark3-flasher"
#    bin.install "client/hid-flasher/flasher" => "proxmark3-hid-flasher"
    bin.install "client/proxmark3" => "proxmark3"
    bin.install "client/fpga_compress" => "fpga_compress"
    share.mkpath
    (share/"firmware").mkpath
    (share/"firmware").install "armsrc/obj/fullimage.elf" => "fullimage.elf"
    (share/"firmware").install "bootrom/obj/bootrom.elf" => "bootrom.elf"
#    ohai "Install success! Upgrade devices on HID firmware with proxmark3-hid-flasher, or devices on more modern firmware with proxmark3-flasher."
	ohai "Install success!  Only proxmark3-flasher (modern firmware) is available."
    ohai "The latest bootloader and firmware binaries are ready and waiting in the current homebrew Cellar within share/firmware."
  end

  test do
    system "proxmark3", "-h"
  end
end

__END__
diff --git a/armsrc/Makefile b/armsrc/Makefile
index 054f20b6..ea12dd30 100644
--- a/armsrc/Makefile
+++ b/armsrc/Makefile
@@ -21,10 +21,10 @@ APP_CFLAGS = -DWITH_CRC \
 			 -DWITH_ISO14443a \
 			 -DWITH_ICLASS \
 			 -DWITH_HFSNOOP \
-			 -DWITH_ISO14443a_StandAlone \
 			 -fno-strict-aliasing -ffunction-sections -fdata-sections
 ### IMPORTANT -  move the commented variable below this line
 #			 -DWITH_LCD \
+#			 -DWITH_ISO14443a_StandAlone \
 
 SRC_LCD = fonts.c LCD.c
 SRC_LF = lfops.c hitag2.c hitagS.c lfsampling.c pcf7931.c lfdemod.c
