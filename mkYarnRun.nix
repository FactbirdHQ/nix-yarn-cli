_: {
  packages.mkYarnRun = {writeShellScriptBin}: {
    cache,
    unplugged,
    wrapper,
    preRun,
    ...
  } @ opts: let setNodeOptions = if (builtins.hasAttr "nodeOptions" opts) then "export NODE_OPTIONS=${opts.nodeOptions}" else ""; in 
    writeShellScriptBin "yarn-run" ''
      # Check and symlink cache directory
      CACHE_PATH=$(${wrapper}/bin/yarn config get cacheFolder)
      if [ ! -e $CACHE_PATH ]; then
        cp --reflink=auto --recursive ${cache} $CACHE_PATH
      fi

      # Check and symlink unplugged directory
      UNPLUGGED_PATH=$(${wrapper}/bin/yarn config get pnpUnpluggedFolder)
      if [ ! -e $UNPLUGGED_PATH ]; then
        cp --reflink=auto --recursive ${unplugged} $UNPLUGGED_PATH
      fi

      WORKSPACE_ROOT=$(dirname $(dirname $UNPLUGGED_PATH))
      
      ${setNodeOptions}

      ${preRun}

      ${wrapper}/bin/yarn "$@"
    '';
}
