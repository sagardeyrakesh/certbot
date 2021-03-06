BootstrapMac() {
  if hash brew 2>/dev/null; then
    echo "Using Homebrew to install dependencies..."
    pkgman=brew
    pkgcmd="brew install"
  elif hash port 2>/dev/null; then
    echo "Using MacPorts to install dependencies..."
    pkgman=port
    pkgcmd="$SUDO port install"
  else
    echo "No Homebrew/MacPorts; installing Homebrew..."
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    pkgman=brew
    pkgcmd="brew install"
  fi

  $pkgcmd augeas
  if [ "$(which python)" = "/System/Library/Frameworks/Python.framework/Versions/2.7/bin/python" \
      -o "$(which python)" = "/usr/bin/python" ]; then
    # We want to avoid using the system Python because it requires root to use pip.
    # python.org, MacPorts or HomeBrew Python installations should all be OK.
    echo "Installing python..."
    $pkgcmd python
  fi

  # Workaround for _dlopen not finding augeas on OS X
  if [ "$pkgman" = "port" ] && ! [ -e "/usr/local/lib/libaugeas.dylib" ] && [ -e "/opt/local/lib/libaugeas.dylib" ]; then
    echo "Applying augeas workaround"
    $SUDO mkdir -p /usr/local/lib/
    $SUDO ln -s /opt/local/lib/libaugeas.dylib /usr/local/lib/
  fi

  if ! hash pip 2>/dev/null; then
      echo "pip not installed"
      echo "Installing pip..."
      curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | python
  fi

  if ! hash virtualenv 2>/dev/null; then
      echo "virtualenv not installed."
      echo "Installing with pip..."
      pip install virtualenv
  fi
}
