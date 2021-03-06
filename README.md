Q2PRO
=====

Q2PRO is an enhanced, multiplayer oriented Quake 2 client and server.

Features include:

* rewritten OpenGL renderer optimized for stable FPS
* enhanced client console with persistent history
* ZIP packfiles (.pkz), JPEG and PNG textures, MD3 models
* fast HTTP downloads
* multichannel sound using OpenAL
* recording from demos, forward and backward seeking
* server side multiview demos and GTV capabilities

For building Q2PRO, consult the INSTALL file.

For information on using and configuring Q2PRO, refer to client and server
manuals available in doc/ subdirectory.

Q2PRO Speed
===========

Q2PRO Speed extends Q2PRO with speedrun functionality, including:

* Proper ingame timer for speedruns
* Support for Ground Zero (rogue) and The Reckoning (xatrix) mission packs, implemented by Jonathan Richman, aka Qualx
* Co-Op bugfixes

Follow these steps, alongside Q2PRO Speed source directory, to check out
and build Q2PRO Speed for Windows using MinGW-w64:

    curl -s https://api.github.com/repos/skullernet/q2pro-mgw-sdk/releases/latest \
    | grep "browser_download_url.*q2pro-mgw-sdk*\.tar\.gz" \
    | cut -d ":" -f 2,3 \
    | tr -d \" \
    | wget -qi -
    tarball="$(find . -name "*q2pro-mgw-sdk*.tar.gz")"
    tar -xzf $tarball
    git clone --recurse-submodules -j8 https://github.com/kugelrund/q2pro-speed.git q2pro-speed.git
    cd q2pro-speed.git
    cp ../q2pro-mgw-sdk*/config .config
    # review .config
    make strip

Before typing ‘make’ you may need to adjust the build time configuration file (‘.config’), especially if your compiler name does not have ‘i686-w64-mingw32-’ prefix. For more information consult the Q2PRO INSTALL file.