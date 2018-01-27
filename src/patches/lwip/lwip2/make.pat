diff --git a/Makefile.open.orig b/Makefile.open
old mode 100644
new mode 100755
index 6614788..62fa692
--- a/Makefile.open.orig
+++ b/Makefile.open
@@ -1,19 +1,40 @@
-
+PREFIX=/esp-new-sdk/xtensa-lx106-elf
 $(shell makefiles/patch-non-local-includes \
-	$(PREFIX)/xtensa-lx106-elf/sysroot/usr/include/user_interface.h \
-	$(PREFIX)/xtensa-lx106-elf/sysroot/usr/include/sntp.h \
+	$(PREFIX)/xtensa-lx106-elf/include/user_interface.h \
+	$(PREFIX)/xtensa-lx106-elf/include/sntp.h \
 )
 
-SDK=$(PREFIX)/xtensa-lx106-elf/sysroot/usr
-LWIP_LIB_RELEASE=$(SDK)/lib/liblwip2.a
-LWIP_INCLUDES_RELEASE=$(SDK)/include/lwip2
+SDK=$(PREFIX)/xtensa-lx106-elf
+## where to install the lib and the includes
+#LWIP_LIB_RELEASE=$(SDK)/lib/liblwip2.a
+#LWIP_INCLUDES_RELEASE=$(SDK)/include/lwip2
+LWIP_LIB_RELEASE=release/lib
+LWIP_INCLUDES_RELEASE=release/include/lwip2
+## some includes needed
+LWIP_ESP=/esp-new-sdk/sdk/esp_iot_sdk_v2.1.x/include
+LWIP_ESP=/Arduino/tools/sdk/lwip/include
+LWIP_ESP=./glue-lwip
+LWIP_ESP=/esp-new-sdk/sdk/esp_iot_sdk_v2.1.x/include
+LWIP_ESP=./glue-lwip
+LWIP_ESP=lwip2-src/src
+## where to find lwipopts.h
+Target=open
+
+##all: install
+install:
 
 %:
+	@echo "- PREFIX:   $(PREFIX)"
+	@echo "- SDK:      $(SDK)"
+	@echo "- LWIP_ESP: $(LWIP_ESP)"
+	mkdir -p $(LWIP_LIB_RELEASE)
 	make -f makefiles/Makefile.build-lwip2 \
-			target=esp-open-sdk \
-			SDK=$(SDK) \
-			LWIP_LIB=liblwip2.a \
-			LWIP_LIB_RELEASE=$(LWIP_LIB_RELEASE) \
-			LWIP_INCLUDES_RELEASE=$(LWIP_INCLUDES_RELEASE) \
-			TOOLS=$(PREFIX)/bin/xtensa-lx106-elf- \
-			$@
+		target=$(Target) \
+		SDK=$(SDK) \
+		LWIP_ESP=$(LWIP_ESP) \
+		LWIP_LIB=liblwip2.a \
+		LWIP_LIB_RELEASE=$(LWIP_LIB_RELEASE)/liblwip2.a \
+		LWIP_INCLUDES_RELEASE=$(LWIP_INCLUDES_RELEASE) \
+		TOOLS=$(PREFIX)/bin/xtensa-lx106-elf- \
+		TCP_MSS=536 BUILD=build-536 \
+		$@
