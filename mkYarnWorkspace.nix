
_: {
  packages.mkYarnWorkspace = {
    mkYarnWrapper,
    mkYarnCache,
    mkYarnUnplugged,
    mkYarnRun,
    mkYarnProject,
  }: { nodejs, yarnSrc, env, token, src, preRun } @ opts:
    rec {
      wrapper = mkYarnWrapper { inherit nodejs yarnSrc env; };
      cache = mkYarnCache { inherit token src wrapper; };
      unplugged = mkYarnUnplugged { inherit src wrapper cache; };
      run = mkYarnRun { inherit wrapper cache unplugged preRun; nodeOptions = opts.nodeOptions; };
      mkProject = {src}: mkYarnProject { inherit wrapper cache src; rootSrc = opts.src; nodeOptions = opts.nodeOptions; };
    };
}