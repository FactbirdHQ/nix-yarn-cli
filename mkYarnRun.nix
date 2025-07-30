_: {
  packages.mkYarnRun = {writeShellScriptBin}: {
    yarn-cache,
    yarn-unplugged,
    yarn-wrapper,
    preRun,
  }:
    writeShellScriptBin "yarn-run" ''
      # Check and symlink cache directory
      CACHE_PATH=$(${yarn-wrapper}/bin/yarn config get cacheFolder)
      if [ ! -e $CACHE_PATH ]; then
        cp --reflink=auto --recursive ${yarn-cache} $CACHE_PATH
      fi

      # Check and symlink unplugged directory
      UNPLUGGED_PATH=$(${yarn-wrapper}/bin/yarn config get pnpUnpluggedFolder)
      if [ ! -e $UNPLUGGED_PATH ]; then
        cp --reflink=auto --recursive ${yarn-unplugged} $UNPLUGGED_PATH
      fi

      WORKSPACE_ROOT=$(dirname $(dirname $UNPLUGGED_PATH))
      export NODE_OPTIONS="--experimental-transform-types --experimental-import-meta-resolve --import $WORKSPACE_ROOT/modules/transpilation/index.js"

      ${preRun}

      ${yarn-wrapper}/bin/yarn "$@"
    '';
}
