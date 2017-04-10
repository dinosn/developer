set -ex
cd /tmp
curl -O https://capnproto.org/capnproto-c++-0.5.3.tar.gz
rm -rf capnproto-c++-0.5.3
tar zxf capnproto-c++-0.5.3.tar.gz
cd capnproto-c++-0.5.3
sed -i /'define KJ_HAS_BACKTRACE'/d src/kj/exception.c++
./configure
make -j6 check
sudo make install
cd ..
rm -rf capnproto-c++-0.5.3
rm -f capnproto-c++-*
