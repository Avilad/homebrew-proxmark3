class Proxmark3Iceman < Formula
#  desc "Proxmark3 client, flasher, HID flasher and firmware bundle"
  desc "[icemanfork] Proxmark3 client, CDC flasher and firmware bundle"
  homepage "http://www.proxmark.org"
  url "https://github.com/iceman1001/proxmark3/archive/v1.7.1.tar.gz"
  sha256 "84c933426d43bd68f982b60218a87152fd5c0748e54ba7f1c7325177c4aa0e83"
  head "https://github.com/iceman1001/proxmark3.git"

  option "with-qt-gui", "Enables the QT GUI"
  option "without-iso14443a-standalone", "Disables ISO14443a standalone mode and enables LF standalone mode"

  depends_on "automake" => :build
  depends_on "readline"
  depends_on "p7zip" => :build
  depends_on "libusb"
  depends_on "libusb-compat"
  depends_on "pkg-config" => :build
  depends_on "wget"
  depends_on "qt5" if build.with? "qt-gui"
  depends_on "perl"
  depends_on "iceman1001/proxmark3/arm-none-eabi-gcc" => :build

  DISABLE_ISO14443A_STANDALONE_PATCH = <<-'END'
diff --git a/armsrc/Makefile b/armsrc/Makefile
index 054f20b6..38e5e26b 100644
--- a/armsrc/Makefile
+++ b/armsrc/Makefile
@@ -21,7 +21,6 @@ APP_CFLAGS = -DWITH_CRC \
 			 -DWITH_ISO14443a \
 			 -DWITH_ICLASS \
 			 -DWITH_HFSNOOP \
-			 -DWITH_ISO14443a_StandAlone \
 			 -fno-strict-aliasing -ffunction-sections -fdata-sections
 ### IMPORTANT -  move the commented variable below this line
 #			 -DWITH_LCD \
  END
  
  QT_GUI_PATCH = <<-'END'
diff --git a/client/Makefile b/client/Makefile
index 5f5df148..4ce7c08f 100644
--- a/client/Makefile
+++ b/client/Makefile
@@ -7,15 +7,13 @@ include ../common/Makefile.common
 
 CC = gcc
 CXX = g++
-COMMON_FLAGS += -std=c99 -O3 -g
 
 #VPATH = ../common ../zlib
 OBJDIR = obj
 
 LDLIBS = -L/opt/local/lib -L/usr/local/lib -lreadline -lpthread -lm
 LUALIB = ../liblua/liblua.a
-#LDFLAGS = $(COMMON_FLAGS)
-CFLAGS =  $(COMMON_FLAGS) -I. -I../include -I../common -I../zlib -I/opt/local/include -I../liblua -Wall
+CFLAGS = -std=c99 -I. -I../include -I../common -I../zlib -I/opt/local/include -I../liblua -Wall -O3
 LUAPLATFORM = generic
 
 ifneq (,$(findstring MINGW,$(platform))) 
@@ -44,12 +42,12 @@ ifneq (,$(findstring MINGW,$(platform)))
 else ifeq ($(platform),Darwin)
 
 	# OS X, QT5 detection needs this.
-	export PKG_CONFIG_PATH=/usr/local/Cellar/qt5/5.6.1-1/lib/pkgconfig/
+	PKG_CONFIG_PATH=/usr/local/opt/qt/lib/pkgconfig/
 
     CFLAGS +=  -march=native
-    CXXFLAGS = $(shell pkg-config --cflags QtCore QtGui 2>/dev/null) -Wall -O3
-    QTLDLIBS = $(shell pkg-config --libs QtCore QtGui 2>/dev/null)
-    MOC = $(shell pkg-config --variable=moc_location QtCore)
+    CXXFLAGS = -std=c++11 $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --cflags Qt5Core Qt5Gui Qt5Widgets 2>/dev/null) -Wall -O3
+    QTLDLIBS = $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --libs Qt5Core Qt5Gui Qt5Widgets 2>/dev/null)
+    MOC = $(shell PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --variable=host_bins Qt5Core)/moc
 
 	# QT version,  4 or 5
 	qtplatform = $(shell $(MOC) -v)
  END

  patch QT_GUI_PATCH if build.with? "qt-gui"

  patch DISABLE_ISO14443A_STANDALONE_PATCH if build.without? "iso14443a-standalone"

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
