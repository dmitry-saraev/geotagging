name: QMake Build Matrix

on: [push]

env:
  QT_VERSION: 5.14.0

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [windows-2019]
        version: ['5.15.2']
    steps:
    - uses: actions/checkout@v1

    - name: Install Qt
      uses: jurplel/install-qt-action@v2
      with:
        version: ${{ matrix.version }}
        host: 'windows'
        taget: 'desktop'
        arch: 'win64_msvc2019_64'
        modules: 'qtwebengine'
        tools: 'tools_openssl_x64,1.1.1-10,qt.tools.openssl.win_x64'

    - name: Download exiv2
      if: startsWith(matrix.os, 'windows')
      run: |
        wget https://www.exiv2.org/builds/exiv2-0.27.3-2019msvc64.zip
        7z x exiv2-0.27.3-2019msvc64.zip -oc:/

      shell: cmd


    - name: Configure test project on windows
      if: startsWith(matrix.os, 'windows')
      run: |
        call "%programfiles(x86)%\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
        mkdir build
        cd build
        cmake -DCMAKE_PREFIX_PATH="C:\Qt\5.15.2\msvc2019_64" -Dexiv2_DIR="C:\exiv2-0.27.3-2019msvc64\lib\cmake\exiv2" -DCMAKE_GENERATOR_PLATFORM=x64 -DCMAKE_BUILD_TYPE=RELEASE -DDEPLOY_QT_LIBRARIES=ON -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ..
        cmake --build . --config Release
        ctest -C Release .
        cp *.qm ./Release
#        find /c/Qt/Tools/OpenSSL -type f -name '*.dll' -print -exec cp {} ./Release \;
#        find /c/exiv2-0.27.3-2019msvc64 -type f -name '*.dll' -print -exec cp {} ./Release \;
#        7z a -tzip com.github.jmlich.geotagging.zip -r *
      shell: cmd
