export PATH=/nix/store/xdlpraypxdimjyfrr4k06narrv8nmfgh-nix-2.11.1/bin:$PATH
export NIX_REMOTE=daemon

# from nix.sh
if [ -n "$HOME" ] && [ -n "$USER" ]; then

  # Set up the per-user profile.

  NIX_LINK=$HOME/.nix-profile

  # Set up environment.
  # This part should be kept in sync with nixpkgs:nixos/modules/programs/environment.nix
  export NIX_PROFILES="/nix/var/nix/profiles/default $HOME/.nix-profile"

  # Set $NIX_SSL_CERT_FILE so that Nixpkgs applications like curl work.
  if [ -e /etc/ssl/certs/ca-certificates.crt ]; then # NixOS, Ubuntu, Debian, Gentoo, Arch
    export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
  elif [ -e /etc/ssl/ca-bundle.pem ]; then # openSUSE Tumbleweed
    export NIX_SSL_CERT_FILE=/etc/ssl/ca-bundle.pem
  elif [ -e /etc/ssl/certs/ca-bundle.crt ]; then # Old NixOS
    export NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt
  elif [ -e /etc/pki/tls/certs/ca-bundle.crt ]; then # Fedora, CentOS
    export NIX_SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
  elif [ -e "$NIX_LINK/etc/ssl/certs/ca-bundle.crt" ]; then # fall back to cacert in Nix profile
    export NIX_SSL_CERT_FILE="$NIX_LINK/etc/ssl/certs/ca-bundle.crt"
  elif [ -e "$NIX_LINK/etc/ca-bundle.crt" ]; then # old cacert in Nix profile
    export NIX_SSL_CERT_FILE="$NIX_LINK/etc/ca-bundle.crt"
  fi

  # Only use MANPATH if it is already set. In general `man` will just simply
  # pick up `.nix-profile/share/man` because is it close to `.nix-profile/bin`
  # which is in the $PATH. For more info, run `manpath -d`.
  if [ -n "${MANPATH-}" ]; then
    export MANPATH="$NIX_LINK/share/man:$MANPATH"
  fi

  export PATH="$NIX_LINK/bin:$PATH"
  unset NIX_LINK
fi
