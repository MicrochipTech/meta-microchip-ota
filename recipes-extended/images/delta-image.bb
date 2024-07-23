SUMMARY = "Create an ext4 image of just the delta update app data"
IMAGE_INSTALL = ""
IMAGE_LINGUAS = ""
PACKAGE_INSTALL = ""

inherit image

IMAGE_FSTYPES = " ext4"

# image size in KB
IMAGE_ROOTFS_SIZE = "512"

create_delta_data () {
        # create dummy delta update data with same pattern used in config board script
        rm -rf ${IMAGE_ROOTFS}/*
        dd if=/dev/urandom bs=1 count=1M > ${IMAGE_ROOTFS}/app_data.img
        dd if=/dev/zero bs=1 count=1M >> ${IMAGE_ROOTFS}/app_data.img
        dd if=/dev/urandom bs=1 count=1M >> ${IMAGE_ROOTFS}/app_data.img
}

IMAGE_PREPROCESS_COMMAND:append = "create_delta_data;"

# force regneration of data every time the image recipe is built for labs
do_image[nostamp] = "1"
