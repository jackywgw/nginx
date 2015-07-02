include $(AEROS_ROOT)/build/ahcommonpre.mk
AH_NGINX_VERSION=1.8.0
AH_PCRE_VERSION=8.36
AH_ZLIB_VERSION=1.2.8
AH_NGINX_SUBDIR=nginx-$(AH_NGINX_VERSION)
AH_PCRE_SUBDIR=pcre-$(AH_PCRE_VERSION)
AH_PCRE_ZIP=$(AH_PCRE_SUBDIR).tar.gz
AH_ZLIB_SUBDIR=zlib-$(AH_ZLIB_VERSION)
AH_SRC_NGINX_DIR=$(CURDIR)/$(AH_NGINX_SUBDIR)
AH_BUILD_NGINX_DIR=$(AH_CURRENT_BUILD_PATH)/$(AH_NGINX_SUBDIR)
echo "AH_BUILD_NGINX_DIR=$AH_BUILD_NGINX_DIR"
AH_EXPORT_LDFLAGS += -lah_event -lah -lah_mpi -lah_sys -lpthread -lah_top -lah_tpa -lgdbm -lah_db -lah_rmc_db -lah_dcd -lah_cli
ifeq ($(AH_SUPPORT_SWITCH), yes)
AH_EXPORT_LDFLAGS += -lah_hw -lah_swd 
endif
DEPDIRS = $(AEROS_ROOT)/app/openssl 
ifeq ($(AH_SUPPORT_HOSTAPD_072), yes)
DEPDIRS += $(AEROS_ROOT)/app/auth2/libs/rmc_lib
else
DEPDIRS += $(AEROS_ROOT)/app/auth/rmc_lib
endif
define CfgNginx
		echo "AH_EXPORT_LDFLAGS=$(AH_EXPORT_LDFLAGS)"
        if [ ! -f $(AH_BUILD_NGINX_DIR)/Makefile ]; then \
                cd $(AH_BUILD_NGINX_DIR); \
                $(AH_SRC_NGINX_DIR)/configure --prefix=/usr/local/nginx \
						--sbin-path=/usr/local/nginx/nginx --conf-path=/usr/local/nginx/ \
						--pid-path=/usr/local/nginx/nginx.pid --with-http_ssl_module \
                        --with-pcre=$(AH_CURRENT_BUILD_PATH)/$(AH_PCRE_SUBDIR) --with-zlib=$(AH_CURRENT_BUILD_PATH)/$(AH_ZLIB_SUBDIR)\
                        --with-openssl=$(AH_BUILD_TREE_ROOT)/app/openssl/openssl --with-cc=powerpc-linux-gnu-gcc\
                        --with-cc-opt="-I$(AH_BUILD_TREE_ROOT)/app/openssl/openssl/include \
                                  -I$(AEROS_ROOT)/include/share \
                                  -I$(AEROS_ROOT)/include/user \
                                  -I$(AEROS_ROOT)/include/boot \
				  				  -I$(AH_BUILD_TREE_ROOT)/include/boot \
                                  -I$(AH_BUILD_TREE_ROOT)/include/share \
                                  -I$(AH_BUILD_TREE_ROOT)/include/user" ; \
        fi;
endef

header:
ifneq ($(DEPDIRS),)
	@$(MkDepDirs)
endif
	@$(InitAhInst)
	@$(AH_MKDIR) $(AH_BUILD_NGINX_DIR)
	$(AH_CP) -rf $(AH_NGINX_SUBDIR)/* $(AH_BUILD_NGINX_DIR)/
	$(AH_CP) -rpf $(AH_PCRE_SUBDIR)/ $(AH_CURRENT_BUILD_PATH)/$(AH_PCRE_SUBDIR)/
	$(AH_CP) -rf $(AH_ZLIB_SUBDIR)/ $(AH_CURRENT_BUILD_PATH)/$(AH_ZLIB_SUBDIR)/
	$(CfgNginx)
	$(AH_MAKE) -C $(AH_BUILD_NGINX_DIR)
	$(AH_MAKE) -C $(AH_BUILD_NGINX_DIR) DESTDIR=$(AH_ROOTFS_DIR)/nginx install
	$(AH_MKDIR) $(AH_ROOTFS_DIR)/opt/ah/bin
	$(AH_MV) $(AH_ROOTFS_DIR)/nginx/usr/local/nginx/nginx $(AH_ROOTFS_DIR)/opt/ah/bin/ah_nginx
	$(AH_TARGET_STRIP) $(AH_ROOTFS_DIR)/opt/ah/bin/ah_nginx
lib:

bin:

kmod: 

install:
	$(AH_MAKE) -C $(AH_BUILD_NGINX_DIR) DESTDIR=$(AH_ROOTFS_DIR)/nginx install
	$(AH_MKDIR) $(AH_ROOTFS_DIR)/opt/ah/bin
	$(AH_MV) $(AH_ROOTFS_DIR)/nginx/usr/local/nginx/nginx $(AH_ROOTFS_DIR)/opt/ah/bin/ah_nginx
	$(AH_TARGET_STRIP) $(AH_ROOTFS_DIR)/opt/ah/bin/ah_nginx

clean:
	if [ -f $(AH_BUILD_NGINX_DIR)/Makefile ]; then \
		$(AH_MAKE) -C $(AH_BUILD_NGINX_DIR) distclean; \
	fi;
instclean:
	@$(CleanAhInst)

.PHONY: header lib bin install clean instclean
