#!/bin/bash

. /etc/os-release

VERSION_MAJOR=$VERSION_ID
case "${VERSION_MAJOR}" in
    22.03*)
        VERSION_MAJOR=22.03
        ;;
    24.03*)
        VERSION_MAJOR=24.03
        ;;
    *)
        echo "Unsupported version: $VERSION_MAJOR"
        ;;
esac

# packages
PKGS=$(cat pkglist/openEuler/*.txt pkglist/openEuler/${VERSION_MAJOR}/*.txt | grep -v "^#" | sort | uniq)

CACHEDIR=cache/cache-rpms
mkdir -p $CACHEDIR

# if [ "$VERSION_MAJOR" = "22.03" ]; then
#     RT="sudo dnf download --resolve --alldeps --downloaddir $CACHEDIR"
# fi

RT="sudo dnf download --resolve --alldeps --downloaddir $CACHEDIR"

echo "==> Downloading: " $PKGS
$RT $PKGS || {
    echo "Download error"
    exit 1
}

# create rpms dir
RPMDIR=outputs/rpms/local
if [ -e $RPMDIR ]; then
    /bin/rm -rf $RPMDIR || exit 1
fi
mkdir -p $RPMDIR
/bin/cp $CACHEDIR/*.rpm $RPMDIR/
/bin/rm $RPMDIR/*.i686.rpm

echo "==> createrepo"
createrepo -d $RPMDIR || exit 1

echo "create-repo done."