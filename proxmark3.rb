class Proxmark3 < Formula
  desc "Proxmark3 client, CDC flasher, HID flasher and firmware bundle"
  homepage "http://www.proxmark.org"
  url "https://github.com/proxmark/proxmark3/archive/v3.0.1.tar.gz"
  sha256 "bace0dd34e35923bfd926cf0943e615a00b2588bb958a13afde3fd46cd34a821"
  head "https://github.com/proxmark/proxmark3.git"

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
  depends_on "proxmark/proxmark3/arm-none-eabi-gcc" => :build

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
index 73c2290..04b3e22 100644
--- a/armsrc/Makefile
+++ b/armsrc/Makefile
@@ -10,7 +10,7 @@ APP_INCLUDES = apps.h
 
 #remove one of the following defines and comment out the relevant line
 #in the next section to remove that particular feature from compilation
-APP_CFLAGS	= -DWITH_ISO14443a_StandAlone -DWITH_LF -DWITH_ISO15693 -DWITH_ISO14443a -DWITH_ISO14443b -DWITH_ICLASS -DWITH_LEGICRF -DWITH_HITAG  -DWITH_CRC -DON_DEVICE -DWITH_HFSNOOP \
+APP_CFLAGS	= -DWITH_LF -DWITH_ISO15693 -DWITH_ISO14443a -DWITH_ISO14443b -DWITH_ICLASS -DWITH_LEGICRF -DWITH_HITAG  -DWITH_CRC -DON_DEVICE -DWITH_HFSNOOP \
 				-fno-strict-aliasing -ffunction-sections -fdata-sections
 #-DWITH_LCD
 
