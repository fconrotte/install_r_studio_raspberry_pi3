sudo su
service dphys-swapfile stop
sed -i 's/^CONF_SWAPSIZE=[0-9]*$/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile
service dphys-swapfile start
dpkg-reconfigure dash

apt-get update
apt-get upgrade -y
apt-get install -y git r-recommended python-dev cmake
cd /home/pi/Downloads/
git clone https://github.com/rstudio/rstudio.git
cd /home/pi/Downloads/rstudio/dependencies/common/
./install-common
cd /home/pi/Downloads/rstudio/dependencies/linux/
./install-dependencies-debian

#saw java 6 was not installed. installed v8
apt-get install -y openjdk-8-jdk

#tried to make install, got an error about dictionaries not installed and rerun install-dependencies
cd /home/pi/Downloads/rstudio/dependencies/common/
./install-common

#tried to make install, hangs at "ext:" so I tried manually installing pandoc, which should have been installed earlier, but apparently was not
apt-get install -y pandoc

#tried to make install, hangs at "ext:" so I tried installing the latest GWT compiler
cd /home/pi/Downloads
wget http://dl.google.com/closure-compiler/compiler-latest.zip
unzip compiler-latest.zip
rm COPYING README.md compiler-latest.zip
mv closure-compiler-v20170218.jar /home/pi/Downloads/rstudio/src/gwt/tools/compiler/compiler.jar

#build
cd /home/pi/Downloads/rstudio/
#remove build if exists
rm -r ./build
mkdir build
cd build

apt-get install -y qt5-default libqt5svg5-dev libqt5sensors5-dev libqt5webkit5-dev libqt5xmlpatterns5-dev qtpositioning5-dev
mv /root/Qt5.4.0/5.4/gcc/bin /root/Qt5.4.0/5.4/gcc/bin_orig
mv /root/Qt5.4.0/5.4/gcc/lib /root/Qt5.4.0/5.4/gcc/lib_orig
ln -s /usr/lib/arm-linux-gnueabihf/qt5/bin /root/Qt5.4.0/5.4/gcc/bin
ln -s /usr/lib/arm-linux-gnueabihf /root/Qt5.4.0/5.4/gcc/lib
sed -i -e s/COPY_ONLY/COPYONLY/g /root/Qt5.4.0/5.4/gcc/lib/cmake/Qt5Core/Qt5CoreMacros.cmake
sed -i -e s/CMP0020/CMP0043/g /home/pi/Downloads/rstudio/src/cpp/desktop/CMakeLists.txt

cd /home/pi/Downloads/rstudio/build
cmake .. -DRSTUDIO_TARGET=Desktop -DCMAKE_BUILD_TYPE=Release
make -j3 install &> install_output

#According to [5]
sudo apt-get install pandoc-citeproc
sudo rm /usr/local/lib/rstudio/bin/pandoc/pandoc
sudo rm /usr/local/lib/rstudio/bin/pandoc/pandoc-citeproc

#When trying to run, saw : libEGL warning: DRI2: failed to authenticate
#According to [6], make the following symbolic links.
#(See  Addendum below.)

#sudo apt-get install chromium-browser
LIBEGL=`sudo find /usr/lib/chromium-browser -name libEGL.so`
LIBGLES=`sudo find /usr/lib/chromium-browser -name libGLESv2.so`
sudo ln -sf $LIBEGL /usr/lib/arm-linux-gnueabihf/libEGL.so
sudo ln -sf $LIBEGL /usr/lib/arm-linux-gnueabihf/libEGL.so.1
sudo ln -sf $LIBGLES /usr/lib/arm-linux-gnueabihf/libGLESv2.so
sudo ln -sf $LIBGLES /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2
