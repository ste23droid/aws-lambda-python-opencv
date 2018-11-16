# Setting up build env
sudo yum update -y
sudo yum install -y git cmake gcc-c++ gcc python-devel chrpath
mkdir -p lambda-package/cv2 build/numpy

# Build numpy
pip install --install-option="--prefix=$PWD/build/numpy" numpy
cp -rf build/numpy/lib64/python2.7/site-packages/numpy lambda-package

# Build OpenCV 3.4.1
NUMPY=$PWD/lambda-package/numpy/core/include
cd build
git clone https://github.com/opencv/opencv.git
cd opencv
git checkout 3.4.1
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX="/usr" \
      -D BUILD_EXAMPLES=OFF \
      -D BUILD_opencv_python2=ON \
      -D INSTALL_C_EXAMPLES=OFF \
      -D INSTALL_PYTHON_EXAMPLES=ON \
      -D ENABLE_FAST_MATH=ON \
      -D WITH_TBB=ON \
      -D WITH_IPP=ON							\
      -D WITH_V4L=ON							\
      -D ENABLE_AVX=ON						\
      -D ENABLE_SSSE3=ON						\
      -D ENABLE_SSE41=ON						\
      -D ENABLE_SSE42=ON						\
      -D ENABLE_POPCNT=ON						\
      -D BUILD_TESTS=OFF						\
      -D BUILD_PERF_TESTS=OFF					\
      -D PYTHON2_NUMPY_INCLUDE_DIRS="$NUMPY"	\
      -D PYTHON2_EXECUTABLE="/usr/bin/python" \
      -D PYTHON2_INCLUDE_DIR="/usr/include/python2.7" \
      -D PYTHON2_LIBRARY="/usr/lib/python2.7/dist-packages" \
      ..
make -j`cat /proc/cpuinfo | grep MHz | wc -l`
cd ..
cd ..
cd ..
cp build/opencv/build/lib/cv2.so lambda-package/cv2/__init__.so
cp -L build/opencv/build/lib/*.so.3.4 lambda-package/cv2
strip --strip-all lambda-package/cv2/*
chrpath -r '$ORIGIN' lambda-package/cv2/__init__.so
touch lambda-package/cv2/__init__.py

# zip package
cd lambda-package
zip -r ../lambda-package.zip *
