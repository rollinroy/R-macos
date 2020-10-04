#!/bin/bash
# This script installs R on Mac with accelerate framework (similar to MKL).
# It builds R (4.0+) using xcode clang.
# The input args are:
#   1   R version (e.g., 4.0.2)
#   2   Install location (R's prefix) (def: /usr/local/R/R-$(R_VERSION)-accelerate)
#   3   Link dir to R and Rscript (def: /usr/local/bin)
#   4   Source root location (def: /usr/local/src/R/)
#   5   Build dir name (def:build_accelerate)
f () {
    errcode=$? # save the exit code as the first thing done in the trap function
    echo ">>>Error in $0 $errorcode"
    echo "     the command executing at the time of the error was"
    echo "     $BASH_COMMAND"
    echo "     on line ${BASH_LINENO[0]}"
    if [[ "$BASH_COMMAND" == *"tar "* ]]; then
      echo "   tar command error might be due to /usr/loc permissions"
      echo "   continuing ..."
    else
      exit $errcode  # or use some other value or do return instead
    fi
}
trap f ERR
# input args
R_VERSION=${1:-4.0.2}
R_INSTALL=${2:-/usr/local/R/$R_VERSION-accelerate}
R_LINK_DIR=${3:-/usr/local/bin}
R_SRC_ROOT=${4:-/usr/local/src/R}
R_BUILD_NAME=${5:-build-accelerate}
# download R
R_TAR=
RV=`echo $R_VERSION | cut -f1 -d "."`
mkdir -p $R_SRC_ROOT
chown $USER $R_SRC_ROOT

cd $R_SRC_ROOT
R_SRC=$R_SRC_ROOT/R-$R_VERSION
# check if R tar file exists
R_TAR=R-$R_VERSION.tar.gz
if [[ ! -f $R_TAR ]]; then
  echo ">>> wget R-$RV/$R_TAR"
  wget --no-check-certificate https://cran.r-project.org/src/base/R-$RV/$R_TAR
  tar -xvzf $R_TAR
fi
# check for pcre2
R_OTHER=pcre2
R_OTHER_TAR=$R_OTHER-10.34-darwin.17-x86_64.tar.gz
if [[ ! -e /usr/local/src/$R_OTHER ]]; then
  mkdir -p /usr/local/src/$R_OTHER
  cd /usr/local/src/$R_OTHER
  echo ">>> wget //mac.R-project.org/libs-$RV/$R_OTHER_TAR"
  curl -OL http://mac.R-project.org/libs-$RV/$R_OTHER_TAR
  sudo tar -xvzf $R_OTHER_TAR -C /
fi
# check for xz (liblzma)
R_OTHER=xz
R_OTHER_TAR=$R_OTHER-5.2.4-darwin.17-x86_64.tar.gz
if [[ ! -e /usr/local/src/$R_OTHER ]]; then
  mkdir -p /usr/local/src/$R_OTHER
  cd /usr/local/src/$R_OTHER
  echo ">>> wget //mac.R-project.org/libs-$RV/$R_OTHER_TAR"
  curl -OL http://mac.R-project.org/libs-$RV/$R_OTHER_TAR
  sudo tar -xvzf $R_OTHER_TAR -C /
fi
# check for texinfo
R_OTHER=texinfo
R_OTHER_TAR=$R_OTHER-6.7-darwin.17-x86_64.tar.gz
if [[ ! -e /usr/local/src/$R_OTHER ]]; then
  mkdir -p /usr/local/src/$R_OTHER
  cd /usr/local/src/$R_OTHER
  echo ">>> wget //mac.R-project.org/libs-$RV/$R_OTHER_TAR"
  curl -OL http://mac.R-project.org/libs-$RV/$R_OTHER_TAR
  sudo tar -xvzf $R_OTHER_TAR -C /
fi
# check for cairo
R_OTHER=cairo
R_OTHER_TAR=$R_OTHER-1.14.12-darwin.17-x86_64.tar.gz
if [[ ! -e /usr/local/src/$R_OTHER ]]; then
  mkdir -p /usr/local/src/$R_OTHER
  cd /usr/local/src/$R_OTHER
  echo ">>> wget //mac.R-project.org/libs-$RV/$R_OTHER_TAR"
  curl -OL http://mac.R-project.org/libs-$RV/$R_OTHER_TAR
  sudo tar -xvzf $R_OTHER_TAR -C /
fi
# check for libpng
R_OTHER=libpng
R_OTHER_TAR=$R_OTHER-1.6.37-darwin.17-x86_64.tar.gz
if [[ ! -e /usr/local/src/$R_OTHER ]]; then
  mkdir -p /usr/local/src/$R_OTHER
  cd /usr/local/src/$R_OTHER
  echo ">>> wget //mac.R-project.org/libs-$RV/$R_OTHER_TAR"
  curl -OL http://mac.R-project.org/libs-$RV/$R_OTHER_TAR
  sudo tar -xvzf $R_OTHER_TAR -C /
fi
# check for jpeg jpeg-9-darwin.17-x86_64.tar.gz
R_OTHER=jpeg
R_OTHER_TAR=$R_OTHER-9-darwin.17-x86_64.tar.gz
if [[ ! -e /usr/local/src/$R_OTHER ]]; then
  mkdir -p /usr/local/src/$R_OTHER
  cd /usr/local/src/$R_OTHER
  echo ">>> wget //mac.R-project.org/libs-$RV/$R_OTHER_TAR"
  curl -OL http://mac.R-project.org/libs-$RV/$R_OTHER_TAR
  sudo tar -xvzf $R_OTHER_TAR -C /
fi

R_BUILD_DIR=$R_SRC_ROOT/$R_BUILD_NAME
mkdir -p $R_BUILD_DIR
# goto  build dir
echo ">>> cd to $R_BUILD_DIR and execute $R_SRC/configure ..."
cd $R_BUILD_DIR
#: <<'END'
$R_SRC/configure --prefix=$R_INSTALL \
  --disable-R-framework  \
  CC="clang"   \
  CXX="clang++"   \
  F77="/usr/local/bin/gfortran" \
  FC="/usr/local/bin/gfortran"   \
  OBJC="clang"   \
  CFLAGS="-Wall -Wno-implicit-function-declaration -g -O2"   \
  CXXFLAGS="-Wall  -g -O2" \
  OBJCFLAGS="-Wall -g -O2 -fobjc-exceptions"   \
  F77FLAGS="-Wall -g -O2"  \
  FCFLAGS="$F77FLAGS"   \
  PKG_CONFIG_PATH="/opt/X11/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig" \
  --enable-memory-profiling  \
  --enable-R-shlib   \
  --x-includes=/opt/X11/include \
  --x-libraries=/opt/X11/lib  \
  --with-blas="-framework Accelerate"
#END
echo ">>> make R ..."
make
echo ">>> installing R to $R_INSTALL ..."
sudo make install
R_BIN=$R_INSTALL/bin/R
RS_BIN=$R_INSTALL/bin/RScript
R_LINK=$R_LINK_DIR/R
RS_LINK=$R_LINK_DIR/Rscript
echo ">>> creating link from $R_BIN TO $R_LINK ..."
if [[ -e "$R_LINK" ]]; then
  sudo rm "$R_LINK"
fi
sudo ln -s $R_BIN $R_LINK

echo ">>> creating link from $RS_BIN TO $RS_LINK ..."
if [[ -e "$RS_LINK" ]]; then
  sudo rm "$RS_LINK"
fi
sudo ln -s $RS_BIN $RS_LINK
