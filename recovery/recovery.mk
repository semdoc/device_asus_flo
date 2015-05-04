LZMA := /usr/bin/lzma


$(recovery_uncompressed_ramdisk): $(MINIGZIP) \
	$(TARGET_RECOVERY_ROOT_TIMESTAMP)
	@echo -e ${PRT_IMG}"----- Making uncompressed recovery ramdisk ------"${CL_RST}
	$(MKBOOTFS) $(TARGET_RECOVERY_ROOT_OUT) > $@

$(recovery_ramdisk): $(MKBOOTFS) \
	$(recovery_uncompressed_ramdisk)
	@echo -e ${CL_CYN}"----- Making recovery ramdisk ------"${CL_RST}
ifndef BOARD_LZMA_RECOVERY_RD
	$(MINIGZIP) < $(recovery_uncompressed_ramdisk) > $@
else
	$(LZMA) < $(recovery_uncompressed_ramdisk) > $@
endif

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_FILES)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}
	
$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) \
		$(recovery_ramdisk) \
		$(recovery_kernel)
	@echo -e ${CL_CYN}"----- Making recovery image ------"${CL_RST}
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}
