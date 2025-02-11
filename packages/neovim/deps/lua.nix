{ pkgs ? import <nixpkgs> { }, commonCmakeFlags ? [ ] }:
let
  inherit (pkgs)
    stdenv
    fetchurl
    libedit
    gnumake
    makeWrapper;

  LUA_CFLAGS_LINUX = "-O2 -g3 -fPIC";
  LUA_CFLAGS_DARWIN = "-O2 -g3 -fPIC -mmacosx-version-min=10.7";

  LUA_LDFLAGS_LINUX = "";
  LUA_LDFLAGS_DARWIN = "-pagezero_size 10000 -image_base 100000000";

in
stdenv.mkDerivation {
  pname = "lua";
  version = "5.1.5";

  src = fetchurl {
    url = "https://www.lua.org/ftp/lua-5.1.5.tar.gz";
    sha256 = "2640fc56a795f29d28ef15e13c34a47e223960b0240e8cb0a82d9b0738695333";
  };

  nativeBuildInputs = [ gnumake makeWrapper libedit ];

  preConfigure = ''
    sed -i "/^CC/ s|gcc|${stdenv.cc.targetPrefix}cc|" src/Makefile
    sed -i "/^CFLAGS/ s|-O2|${if stdenv.isDarwin then LUA_CFLAGS_DARWIN else LUA_CFLAGS_LINUX}|" src/Makefile
    sed -i "s|-lreadline||g" src/Makefile
    sed -i "s|-lhistory||g" src/Makefile
    sed -i "s|-lncurses||g" src/Makefile
    sed -i "/^MYLDFLAGS/ s|$|${if stdenv.isDarwin then LUA_LDFLAGS_DARWIN else LUA_LDFLAGS_LINUX}|" src/Makefile
    sed -i "/#define LUA_USE_READLINE/ d" src/luaconf.h
    sed -i "s|\\(#define LUA_ROOT[   ]*\"\\)/usr/local|\\1${placeholder "out"}|" src/luaconf.h
  '';

  buildPhase = ''
    make ${if stdenv.isDarwin then "macosx" else "linux"}
  '';

  installPhase = ''
    make TO_BIN="lua luac" INSTALL_TOP=$out install
  '';

  meta = {
    description = "Lua programming language, version 5.1.5";
    platforms = with pkgs.lib.platforms; linux ++ darwin;
    license = pkgs.lib.licenses.mit;
    homepage = "https://www.lua.org/";
  };
}

