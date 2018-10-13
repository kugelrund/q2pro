### Q2PRO Makefile ###

ifneq ($(CONFIG_FILE),)
    include $(CONFIG_FILE)
else
    -include .config
endif

ifdef CONFIG_WINDOWS
    CPU ?= x86
    SYS ?= Win32
else
    ifndef CPU
        CPU := $(shell uname -m | sed -e s/i.86/i386/ -e s/amd64/x86_64/ -e s/sun4u/sparc64/ -e s/arm.*/arm/ -e s/sa110/arm/ -e s/alpha/axp/)
    endif
    ifndef SYS
        SYS := $(shell uname -s)
    endif
endif

ifndef REV
    REV := $(shell ./version.sh --revision)
endif
ifndef VER
    VER := $(shell ./version.sh --version)
endif

CC ?= gcc
WINDRES ?= windres
STRIP ?= strip
RM ?= rm -f
RMDIR ?= rm -rf
MKDIR ?= mkdir -p

CFLAGS ?= -O2 -Wall -g -MMD $(INCLUDES)
RCFLAGS ?=
LDFLAGS ?=
LIBS ?=

CFLAGS_s := -iquote./inc
CFLAGS_c := -iquote./inc
CFLAGS_g := -iquote./inc
CFLAGS_r := -iquote./inc
CFLAGS_x := -iquote./inc

RCFLAGS_s :=
RCFLAGS_c :=
RCFLAGS_g :=
RCFLAGS_r :=
RCFLAGS_x :=

LDFLAGS_s :=
LDFLAGS_c :=
LDFLAGS_g := -shared
LDFLAGS_r := -shared
LDFLAGS_x := -shared

ifdef CONFIG_WINDOWS
    # Force i?86-netware calling convention on x86 Windows
    ifeq ($(CPU),x86)
        CONFIG_X86_GAME_ABI_HACK := y
    else
        CONFIG_X86_GAME_ABI_HACK :=
    endif

    LDFLAGS_s += -mconsole
    LDFLAGS_c += -mwindows
    LDFLAGS_g += -mconsole
    LDFLAGS_r += -mconsole
    LDFLAGS_x += -mconsole

    # Mark images as DEP and ASLR compatible
    LDFLAGS_s += -Wl,--nxcompat,--dynamicbase
    LDFLAGS_c += -Wl,--nxcompat,--dynamicbase
    LDFLAGS_g += -Wl,--nxcompat,--dynamicbase
    LDFLAGS_r += -Wl,--nxcompat,--dynamicbase
    LDFLAGS_x += -Wl,--nxcompat,--dynamicbase

    # Force relocations to be generated for 32-bit .exe files and work around
    # binutils bug that causes invalid image entry point to be set when
    # relocations are enabled.
    ifeq ($(CPU),x86)
        LDFLAGS_s += -Wl,--pic-executable,--entry,_mainCRTStartup
        LDFLAGS_c += -Wl,--pic-executable,--entry,_WinMainCRTStartup
    endif
else
    # Disable x86 features on other arches
    ifneq ($(CPU),i386)
        CONFIG_X86_GAME_ABI_HACK :=
    endif

    # Disable Linux features on other systems
    ifneq ($(SYS),Linux)
        CONFIG_NO_ICMP := y
    endif

    # Hide ELF symbols by default
    CFLAGS_s += -fvisibility=hidden
    CFLAGS_c += -fvisibility=hidden
    CFLAGS_g += -fvisibility=hidden
    CFLAGS_r += -fvisibility=hidden
    CFLAGS_x += -fvisibility=hidden

    # Resolve all symbols at link time
    ifeq ($(SYS),Linux)
        LDFLAGS_s += -Wl,--no-undefined
        LDFLAGS_c += -Wl,--no-undefined
        LDFLAGS_g += -Wl,--no-undefined
        LDFLAGS_r += -Wl,--no-undefined
        LDFLAGS_x += -Wl,--no-undefined
    endif

    CFLAGS_s += -D_FILE_OFFSET_BITS=64
    CFLAGS_c += -D_FILE_OFFSET_BITS=64
    CFLAGS_g += -fPIC
    CFLAGS_r += -fPIC
    CFLAGS_x += -fPIC
endif

BUILD_DEFS := -DCPUSTRING='"$(CPU)"'
BUILD_DEFS += -DBUILDSTRING='"$(SYS)"'

VER_DEFS := -DREVISION=$(REV)
VER_DEFS += -DVERSION='"$(VER)"'

CONFIG_GAME_BASE ?= baseq2
CONFIG_GAME_DEFAULT ?=
PATH_DEFS := -DBASEGAME='"$(CONFIG_GAME_BASE)"'
PATH_DEFS += -DDEFGAME='"$(CONFIG_GAME_DEFAULT)"'

# System paths
ifndef CONFIG_WINDOWS
    CONFIG_PATH_DATA ?= .
    CONFIG_PATH_LIB ?= .
    CONFIG_PATH_HOME ?=
    PATH_DEFS += -DDATADIR='"$(CONFIG_PATH_DATA)"'
    PATH_DEFS += -DLIBDIR='"$(CONFIG_PATH_LIB)"'
    PATH_DEFS += -DHOMEDIR='"$(CONFIG_PATH_HOME)"'
endif

CFLAGS_s += $(BUILD_DEFS) $(VER_DEFS) $(PATH_DEFS) -DUSE_SERVER=1
CFLAGS_c += $(BUILD_DEFS) $(VER_DEFS) $(PATH_DEFS) -DUSE_SERVER=1 -DUSE_CLIENT=1
CFLAGS_g += -DTHISGAME=GAME_BASEQ2
CFLAGS_r += -DTHISGAME=GAME_ROGUE
CFLAGS_x += -DTHISGAME=GAME_XATRIX

# windres needs special quoting...
RCFLAGS_s += -DREVISION=$(REV) -DVERSION='\"$(VER)\"'
RCFLAGS_c += -DREVISION=$(REV) -DVERSION='\"$(VER)\"'
RCFLAGS_g += -DREVISION=$(REV) -DVERSION='\"$(VER)\"'
RCFLAGS_r += -DREVISION=$(REV) -DVERSION='\"$(VER)\"'
RCFLAGS_x += -DREVISION=$(REV) -DVERSION='\"$(VER)\"'


### Object Files ###

COMMON_OBJS := \
    src/common/bsp.o        \
    src/common/cmd.o        \
    src/common/cmodel.o     \
    src/common/common.o     \
    src/common/cvar.o       \
    src/common/error.o      \
    src/common/field.o      \
    src/common/fifo.o       \
    src/common/files.o      \
    src/common/math.o       \
    src/common/mdfour.o     \
    src/common/msg.o        \
    src/common/net/chan.o   \
    src/common/net/net.o    \
    src/common/pmove.o      \
    src/common/prompt.o     \
    src/common/sizebuf.o    \
    src/common/utils.o      \
    src/common/zone.o       \
    src/shared/shared.o

OBJS_c := \
    $(COMMON_OBJS)          \
    src/shared/m_flash.o    \
    src/client/ascii.o      \
    src/client/console.o    \
    src/client/crc.o        \
    src/client/demo.o       \
    src/client/download.o   \
    src/client/effects.o    \
    src/client/entities.o   \
    src/client/input.o      \
    src/client/keys.o       \
    src/client/locs.o       \
    src/client/main.o       \
    src/client/newfx.o      \
    src/client/parse.o      \
    src/client/precache.o   \
    src/client/predict.o    \
    src/client/refresh.o    \
    src/client/screen.o     \
    src/client/tent.o       \
    src/client/view.o       \
    src/client/sound/main.o \
    src/client/sound/mem.o  \
    src/server/commands.o   \
    src/server/entities.o   \
    src/server/game.o       \
    src/server/init.o       \
    src/server/save.o       \
    src/server/send.o       \
    src/server/main.o       \
    src/server/user.o       \
    src/server/world.o      \
    src/speedrun/timer.o    \
    src/speedrun/timer_helper.o \
    src/speedrun/strafe_helper/strafe_helper.o

OBJS_s := \
    $(COMMON_OBJS)  \
    src/client/null.o       \
    src/server/commands.o   \
    src/server/entities.o   \
    src/server/game.o       \
    src/server/init.o       \
    src/server/send.o       \
    src/server/main.o       \
    src/server/user.o       \
    src/server/world.o      \
    src/speedrun/timer.o    \
    src/speedrun/timer_helper.o

OBJS_g := \
    src/shared/shared.o         \
    src/shared/m_flash.o        \
    src/baseq2/g_ai.o           \
    src/baseq2/g_chase.o        \
    src/baseq2/g_cmds.o         \
    src/baseq2/g_combat.o       \
    src/baseq2/g_func.o         \
    src/baseq2/g_items.o        \
    src/baseq2/g_main.o         \
    src/baseq2/g_misc.o         \
    src/baseq2/g_monster.o      \
    src/baseq2/g_phys.o         \
    src/baseq2/g_ptrs.o         \
    src/baseq2/g_save.o         \
    src/baseq2/g_spawn.o        \
    src/baseq2/g_speedrun.o     \
    src/baseq2/g_svcmds.o       \
    src/baseq2/g_target.o       \
    src/baseq2/g_trigger.o      \
    src/baseq2/g_turret.o       \
    src/baseq2/g_utils.o        \
    src/baseq2/g_weapon.o       \
    src/baseq2/m_actor.o        \
    src/baseq2/m_berserk.o      \
    src/baseq2/m_boss2.o        \
    src/baseq2/m_boss31.o       \
    src/baseq2/m_boss32.o       \
    src/baseq2/m_boss3.o        \
    src/baseq2/m_brain.o        \
    src/baseq2/m_chick.o        \
    src/baseq2/m_flipper.o      \
    src/baseq2/m_float.o        \
    src/baseq2/m_flyer.o        \
    src/baseq2/m_gladiator.o    \
    src/baseq2/m_gunner.o       \
    src/baseq2/m_hover.o        \
    src/baseq2/m_infantry.o     \
    src/baseq2/m_insane.o       \
    src/baseq2/m_medic.o        \
    src/baseq2/m_move.o         \
    src/baseq2/m_mutant.o       \
    src/baseq2/m_parasite.o     \
    src/baseq2/m_soldier.o      \
    src/baseq2/m_supertank.o    \
    src/baseq2/m_tank.o         \
    src/baseq2/p_client.o       \
    src/baseq2/p_hud.o          \
    src/baseq2/p_trail.o        \
    src/baseq2/p_view.o         \
    src/baseq2/p_weapon.o

OBJS_r := \
    src/shared/shared.o         \
    src/shared/m_flash.o        \
    src/rogue/dm_ball.o         \
    src/rogue/dm_tag.o          \
    src/rogue/g_ai.o            \
    src/rogue/g_chase.o         \
    src/rogue/g_cmds.o          \
    src/rogue/g_combat.o        \
    src/rogue/g_func.o          \
    src/rogue/g_items.o         \
    src/rogue/g_main.o          \
    src/rogue/g_misc.o          \
    src/rogue/g_monster.o       \
    src/rogue/g_newai.o         \
    src/rogue/g_newdm.o         \
    src/rogue/g_newfnc.o        \
    src/rogue/g_newtarg.o       \
    src/rogue/g_newtrig.o       \
    src/rogue/g_newweap.o       \
    src/rogue/g_phys.o          \
    src/rogue/g_save.o          \
    src/rogue/g_spawn.o         \
    src/rogue/g_speedrun.o      \
    src/rogue/g_sphere.o        \
    src/rogue/g_svcmds.o        \
    src/rogue/g_target.o        \
    src/rogue/g_trigger.o       \
    src/rogue/g_turret.o        \
    src/rogue/g_utils.o         \
    src/rogue/g_weapon.o        \
    src/rogue/m_actor.o         \
    src/rogue/m_berserk.o       \
    src/rogue/m_boss2.o         \
    src/rogue/m_boss31.o        \
    src/rogue/m_boss32.o        \
    src/rogue/m_boss3.o         \
    src/rogue/m_brain.o         \
    src/rogue/m_carrier.o       \
    src/rogue/m_chick.o         \
    src/rogue/m_flipper.o       \
    src/rogue/m_float.o         \
    src/rogue/m_flyer.o         \
    src/rogue/m_gladiator.o     \
    src/rogue/m_gunner.o        \
    src/rogue/m_hover.o         \
    src/rogue/m_infantry.o      \
    src/rogue/m_insane.o        \
    src/rogue/m_medic.o         \
    src/rogue/m_move.o          \
    src/rogue/m_mutant.o        \
    src/rogue/m_parasite.o      \
    src/rogue/m_soldier.o       \
    src/rogue/m_stalker.o       \
    src/rogue/m_supertank.o     \
    src/rogue/m_tank.o          \
    src/rogue/m_turret.o        \
    src/rogue/m_widow.o         \
    src/rogue/m_widow2.o        \
    src/rogue/p_client.o        \
    src/rogue/p_hud.o           \
    src/rogue/p_trail.o         \
    src/rogue/p_view.o          \
    src/rogue/p_weapon.o

OBJS_x := \
    src/shared/shared.o         \
    src/shared/m_flash.o        \
    src/xatrix/g_ai.o           \
    src/xatrix/g_chase.o        \
    src/xatrix/g_cmds.o         \
    src/xatrix/g_combat.o       \
    src/xatrix/g_func.o         \
    src/xatrix/g_items.o        \
    src/xatrix/g_main.o         \
    src/xatrix/g_misc.o         \
    src/xatrix/g_monster.o      \
    src/xatrix/g_phys.o         \
    src/xatrix/g_save.o         \
    src/xatrix/g_spawn.o        \
    src/xatrix/g_speedrun.o     \
    src/xatrix/g_svcmds.o       \
    src/xatrix/g_target.o       \
    src/xatrix/g_trigger.o      \
    src/xatrix/g_turret.o       \
    src/xatrix/g_utils.o        \
    src/xatrix/g_weapon.o       \
    src/xatrix/m_actor.o        \
    src/xatrix/m_berserk.o      \
    src/xatrix/m_boss2.o        \
    src/xatrix/m_boss31.o       \
    src/xatrix/m_boss32.o       \
    src/xatrix/m_boss3.o        \
    src/xatrix/m_boss5.o        \
    src/xatrix/m_brain.o        \
    src/xatrix/m_chick.o        \
    src/xatrix/m_fixbot.o       \
    src/xatrix/m_flipper.o      \
    src/xatrix/m_float.o        \
    src/xatrix/m_flyer.o        \
    src/xatrix/m_gekk.o         \
    src/xatrix/m_gladb.o        \
    src/xatrix/m_gladiator.o    \
    src/xatrix/m_gunner.o       \
    src/xatrix/m_hover.o        \
    src/xatrix/m_infantry.o     \
    src/xatrix/m_insane.o       \
    src/xatrix/m_medic.o        \
    src/xatrix/m_move.o         \
    src/xatrix/m_mutant.o       \
    src/xatrix/m_parasite.o     \
    src/xatrix/m_soldier.o      \
    src/xatrix/m_supertank.o    \
    src/xatrix/m_tank.o         \
    src/xatrix/p_client.o       \
    src/xatrix/p_hud.o          \
    src/xatrix/p_trail.o        \
    src/xatrix/p_view.o         \
    src/xatrix/p_weapon.o

### Configuration Options ###

ifdef CONFIG_HTTP
    CURL_CFLAGS ?= $(shell pkg-config libcurl --cflags)
    CURL_LIBS ?= $(shell pkg-config libcurl --libs)
    CFLAGS_c += -DUSE_CURL=1 $(CURL_CFLAGS)
    LIBS_c += $(CURL_LIBS)
    OBJS_c += src/client/http.o
endif

ifdef CONFIG_CLIENT_GTV
    CFLAGS_c += -DUSE_CLIENT_GTV=1
    OBJS_c += src/client/gtv.o
endif

ifndef CONFIG_NO_SOFTWARE_SOUND
    CFLAGS_c += -DUSE_SNDDMA=1
    OBJS_c += src/client/sound/mix.o
    OBJS_c += src/client/sound/dma.o
endif

ifdef CONFIG_OPENAL
    CFLAGS_c += -DUSE_OPENAL=1
    OBJS_c += src/client/sound/al.o
    ifdef CONFIG_FIXED_LIBAL
        AL_CFLAGS ?= $(shell pkg-config openal --cflags)
        AL_LIBS ?= $(shell pkg-config openal --libs)
        CFLAGS_c += -DUSE_FIXED_LIBAL=1 $(AL_CFLAGS)
        LIBS_c += $(AL_LIBS)
        OBJS_c += src/client/sound/qal/fixed.o
    else
        OBJS_c += src/client/sound/qal/dynamic.o
    endif
endif

ifndef CONFIG_NO_MENUS
    CFLAGS_c += -DUSE_UI=1
    OBJS_c += src/client/ui/demos.o
    OBJS_c += src/client/ui/menu.o
    OBJS_c += src/client/ui/playerconfig.o
    OBJS_c += src/client/ui/playermodels.o
    OBJS_c += src/client/ui/script.o
    OBJS_c += src/client/ui/servers.o
    OBJS_c += src/client/ui/ui.o
endif

ifndef CONFIG_NO_DYNAMIC_LIGHTS
    CFLAGS_c += -DUSE_DLIGHTS=1
endif

ifndef CONFIG_NO_AUTOREPLY
    CFLAGS_c += -DUSE_AUTOREPLY=1
endif

ifndef CONFIG_NO_MAPCHECKSUM
    CFLAGS_c += -DUSE_MAPCHECKSUM=1
endif

ifndef CONFIG_NO_REFRESH
    CFLAGS_c += -DUSE_REF=1 -DVID_REF='"gl"'
    ifdef CONFIG_GLES
        CFLAGS_c += -DUSE_GLES=1
    endif
    OBJS_c += src/refresh/draw.o
    OBJS_c += src/refresh/hq2x.o
    OBJS_c += src/refresh/images.o
    OBJS_c += src/refresh/legacy.o
    OBJS_c += src/refresh/main.o
    OBJS_c += src/refresh/mesh.o
    OBJS_c += src/refresh/models.o
    OBJS_c += src/refresh/qgl.o
    OBJS_c += src/refresh/shader.o
    OBJS_c += src/refresh/sky.o
    OBJS_c += src/refresh/state.o
    OBJS_c += src/refresh/surf.o
    OBJS_c += src/refresh/tess.o
    OBJS_c += src/refresh/texture.o
    OBJS_c += src/refresh/world.o
endif

CONFIG_DEFAULT_MODELIST ?= 640x480 800x600 1024x768
CONFIG_DEFAULT_GEOMETRY ?= 640x480
CFLAGS_c += -DVID_MODELIST='"$(CONFIG_DEFAULT_MODELIST)"'
CFLAGS_c += -DVID_GEOMETRY='"$(CONFIG_DEFAULT_GEOMETRY)"'

ifndef CONFIG_NO_MD3
    CFLAGS_c += -DUSE_MD3=1
endif

ifndef CONFIG_NO_TGA
    CFLAGS_c += -DUSE_TGA=1
endif

ifdef CONFIG_PNG
    PNG_CFLAGS ?= $(shell libpng-config --cflags)
    PNG_LIBS ?= $(shell libpng-config --libs)
    CFLAGS_c += -DUSE_PNG=1 $(PNG_CFLAGS)
    LIBS_c += $(PNG_LIBS)
endif

ifdef CONFIG_JPEG
    JPG_CFLAGS ?=
    JPG_LIBS ?= -ljpeg
    CFLAGS_c += -DUSE_JPG=1 $(JPG_CFLAGS)
    LIBS_c += $(JPG_LIBS)
endif

ifdef CONFIG_ANTICHEAT_SERVER
    CFLAGS_s += -DUSE_AC_SERVER=1
    OBJS_s += src/server/ac.o
endif

ifdef CONFIG_MVD_SERVER
    CFLAGS_s += -DUSE_MVD_SERVER=1
    CFLAGS_c += -DUSE_MVD_SERVER=1
    OBJS_s += src/server/mvd.o
    OBJS_c += src/server/mvd.o
endif

ifdef CONFIG_MVD_CLIENT
    CFLAGS_s += -DUSE_MVD_CLIENT=1
    CFLAGS_c += -DUSE_MVD_CLIENT=1
    OBJS_s += src/server/mvd/client.o src/server/mvd/game.o src/server/mvd/parse.o
    OBJS_c += src/server/mvd/client.o src/server/mvd/game.o src/server/mvd/parse.o
endif

ifdef CONFIG_NO_ZLIB
    CFLAGS_c += -DUSE_ZLIB=0
    CFLAGS_s += -DUSE_ZLIB=0
else
    ZLIB_CFLAGS ?=
    ZLIB_LIBS ?= -lz
    CFLAGS_c += -DUSE_ZLIB=1 $(ZLIB_CFLAGS)
    CFLAGS_s += -DUSE_ZLIB=1 $(ZLIB_CFLAGS)
    LIBS_c += $(ZLIB_LIBS)
    LIBS_s += $(ZLIB_LIBS)
endif

ifndef CONFIG_NO_ICMP
    CFLAGS_c += -DUSE_ICMP=1
    CFLAGS_s += -DUSE_ICMP=1
endif

ifndef CONFIG_NO_SYSTEM_CONSOLE
    CFLAGS_c += -DUSE_SYSCON=1
    CFLAGS_s += -DUSE_SYSCON=1
endif

ifdef CONFIG_X86_GAME_ABI_HACK
    CFLAGS_c += -DUSE_GAME_ABI_HACK=1
    CFLAGS_s += -DUSE_GAME_ABI_HACK=1
    CFLAGS_g += -DUSE_GAME_ABI_HACK=1
    CFLAGS_r += -DUSE_GAME_ABI_HACK=1
    CFLAGS_x += -DUSE_GAME_ABI_HACK=1
endif

ifdef CONFIG_VARIABLE_SERVER_FPS
    CFLAGS_c += -DUSE_FPS=1
    CFLAGS_s += -DUSE_FPS=1
endif

ifdef CONFIG_WINDOWS
    OBJS_c += src/windows/client.o

    ifndef CONFIG_NO_SOFTWARE_SOUND
        OBJS_c += src/windows/wave.o
        ifdef CONFIG_DIRECT_SOUND
            CFLAGS_c += -DUSE_DSOUND=1
            OBJS_c += src/windows/dsound.o
        endif
    endif

    OBJS_c += src/windows/glimp.o
    OBJS_c += src/windows/wgl.o

    ifdef CONFIG_WINDOWS_CRASH_DUMPS
        CFLAGS_c += -DUSE_DBGHELP=1
        CFLAGS_s += -DUSE_DBGHELP=1
        OBJS_c += src/windows/debug.o
        OBJS_s += src/windows/debug.o
    endif

    ifdef CONFIG_WINDOWS_SERVICE
        CFLAGS_s += -DUSE_WINSVC=1
    endif

    OBJS_c += src/windows/hunk.o src/windows/system.o
    OBJS_s += src/windows/hunk.o src/windows/system.o

    # Resources
    OBJS_c += src/windows/res/q2pro.o
    OBJS_s += src/windows/res/q2proded.o
    OBJS_g += src/windows/res/baseq2.o
    OBJS_r += src/windows/res/rogue.o
    OBJS_x += src/windows/res/xatrix.o

    # System libs
    LIBS_s += -lws2_32 -lwinmm -ladvapi32
    LIBS_c += -lws2_32 -lwinmm
else
    SDL_CFLAGS ?= $(shell sdl2-config --cflags)
    SDL_LIBS ?= $(shell sdl2-config --libs)
    CFLAGS_c += -DUSE_SDL=2 $(SDL_CFLAGS)
    LIBS_c += $(SDL_LIBS)
    OBJS_c += src/unix/video.o

    ifndef CONFIG_NO_SOFTWARE_SOUND
        OBJS_c += src/unix/sound.o
        ifdef CONFIG_DIRECT_SOUND
            CFLAGS_c += -DUSE_DSOUND=1
            OBJS_c += src/unix/oss.o
        endif
    endif

    OBJS_s += src/unix/hunk.o src/unix/system.o
    OBJS_c += src/unix/hunk.o src/unix/system.o

    ifndef CONFIG_NO_SYSTEM_CONSOLE
        OBJS_s += src/unix/tty.o
        OBJS_c += src/unix/tty.o
    endif

    # System libs
    LIBS_s += -lm
    LIBS_c += -lm
    LIBS_g += -lm
    LIBS_r += -lm
    LIBS_x += -lm

    ifeq ($(SYS),Linux)
        LIBS_s += -ldl
        LIBS_c += -ldl -lpthread
    endif
endif

ifdef CONFIG_TESTS
    CFLAGS_c += -DUSE_TESTS=1
    CFLAGS_s += -DUSE_TESTS=1
    OBJS_c += src/common/tests.o
    OBJS_s += src/common/tests.o
endif

ifdef CONFIG_DEBUG
    CFLAGS_c += -D_DEBUG
    CFLAGS_s += -D_DEBUG
endif

ifeq ($(CPU),x86)
    OBJS_c += src/common/x86/fpu.o
    OBJS_s += src/common/x86/fpu.o
endif

ifeq ($(CPU),i386)
    OBJS_c += src/common/x86/fpu.o
    OBJS_s += src/common/x86/fpu.o
endif

### Targets ###

ifdef CONFIG_WINDOWS
    TARG_s := build/q2proded.exe
    TARG_c := build/q2pro.exe
    TARG_g := build/baseq2/game$(CPU).dll
    TARG_r := build/rogue/game$(CPU).dll
    TARG_x := build/xatrix/game$(CPU).dll
else
    TARG_s := build/q2proded
    TARG_c := build/q2pro
    TARG_g := build/baseq2/game$(CPU).so
    TARG_r := build/rogue/game$(CPU).so
    TARG_x := build/xatrix/game$(CPU).so
endif

all: $(TARG_s) $(TARG_c) $(TARG_g) $(TARG_r) $(TARG_x)

default: all

.PHONY: all default clean strip

# Define V=1 to show command line.
ifdef V
    Q :=
    E := @true
else
    Q := @
    E := @echo
endif

# Temporary build directories
BUILD_s := .q2proded
BUILD_c := .q2pro
BUILD_g := .baseq2
BUILD_r := .rogue
BUILD_x := .xatrix

# Rewrite paths to build directories
OBJS_s := $(patsubst %,$(BUILD_s)/%,$(OBJS_s))
OBJS_c := $(patsubst %,$(BUILD_c)/%,$(OBJS_c))
OBJS_g := $(patsubst %,$(BUILD_g)/%,$(OBJS_g))
OBJS_r := $(patsubst %,$(BUILD_r)/%,$(OBJS_r))
OBJS_x := $(patsubst %,$(BUILD_x)/%,$(OBJS_x))

DEPS_s := $(OBJS_s:.o=.d)
DEPS_c := $(OBJS_c:.o=.d)
DEPS_g := $(OBJS_g:.o=.d)
DEPS_r := $(OBJS_r:.o=.d)
DEPS_x := $(OBJS_x:.o=.d)

-include $(DEPS_s)
-include $(DEPS_c)
-include $(DEPS_g)
-include $(DEPS_r)
-include $(DEPS_x)

clean:
	$(E) [CLEAN]
	$(Q)$(RM) $(TARG_s) $(TARG_c) $(TARG_g) $(TARG_r) $(TARG_x)
	$(Q)$(RMDIR) $(BUILD_s) $(BUILD_c) $(BUILD_g) $(BUILD_r) $(BUILD_x)

strip: $(TARG_s) $(TARG_c) $(TARG_g) $(TARG_r) $(TARG_x)
	$(E) [STRIP]
	$(Q)$(STRIP) $(TARG_s) $(TARG_c) $(TARG_g) $(TARG_r) $(TARG_x)

# ------

$(BUILD_s)/%.o: %.c
	$(E) [CC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) -c $(CFLAGS) $(CFLAGS_s) -o $@ $<

$(BUILD_s)/%.o: %.rc
	$(E) [RC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(WINDRES) $(RCFLAGS) $(RCFLAGS_s) -o $@ $<

$(TARG_s): $(OBJS_s)
	$(E) [LD] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) $(LDFLAGS) $(LDFLAGS_s) -o $@ $(OBJS_s) $(LIBS) $(LIBS_s)

# ------

$(BUILD_c)/%.o: %.c
	$(E) [CC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) -c $(CFLAGS) $(CFLAGS_c) -o $@ $<

$(BUILD_c)/%.o: %.rc
	$(E) [RC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(WINDRES) $(RCFLAGS) $(RCFLAGS_c) -o $@ $<

$(TARG_c): $(OBJS_c)
	$(E) [LD] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) $(LDFLAGS) $(LDFLAGS_c) -o $@ $(OBJS_c) $(LIBS) $(LIBS_c)

# ------

$(BUILD_g)/%.o: %.c
	$(E) [CC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) -c $(CFLAGS) $(CFLAGS_g) -o $@ $<

$(BUILD_g)/%.o: %.rc
	$(E) [RC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(WINDRES) $(RCFLAGS) $(RCFLAGS_g) -o $@ $<

$(TARG_g): $(OBJS_g)
	$(E) [LD] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) $(LDFLAGS) $(LDFLAGS_g) -o $@ $(OBJS_g) $(LIBS) $(LIBS_g)

# ------

$(BUILD_r)/%.o: %.c
	$(E) [CC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) -c $(CFLAGS) $(CFLAGS_r) -o $@ $<

$(BUILD_r)/%.o: %.rc
	$(E) [RC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(WINDRES) $(RCFLAGS) $(RCFLAGS_r) -o $@ $<

$(TARG_r): $(OBJS_r)
	$(E) [LD] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) $(LDFLAGS) $(LDFLAGS_r) -o $@ $(OBJS_r) $(LIBS) $(LIBS_r)

# ------

$(BUILD_x)/%.o: %.c
	$(E) [CC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) -c $(CFLAGS) $(CFLAGS_x) -o $@ $<

$(BUILD_x)/%.o: %.rc
	$(E) [RC] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(WINDRES) $(RCFLAGS) $(RCFLAGS_x) -o $@ $<

$(TARG_x): $(OBJS_x)
	$(E) [LD] $@
	$(Q)$(MKDIR) $(@D)
	$(Q)$(CC) $(LDFLAGS) $(LDFLAGS_x) -o $@ $(OBJS_x) $(LIBS) $(LIBS_x)
