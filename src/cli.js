const { tgzUtils, structUtils,Configuration, Project, Cache, ThrowReport, } = require("@yarnpkg/core");
const { PatchFetcher } = require("@yarnpkg/plugin-patch");
const { getPluginConfiguration } = require("@yarnpkg/cli");
const fs = require("fs");

const tgzToZip = async ({ name, input, output, compressionLevel }) => {
  console.log({ name, input, output, compressionLevel })
  const tgzBuffer = fs.readFileSync(input);
  const zip = await tgzUtils.convertToZip(tgzBuffer, { stripComponents: 1, prefixPath: `node_modules/${name}`, compressionLevel: compressionLevel == "mixed" ? "mixed" : parseInt(compressionLevel) });
  fs.writeFileSync(output, zip.getBufferAndClose())
}

const getLocatorHash = ({ locator }) => {
  console.log(structUtils.parseLocator(locator).locatorHash);
}

const fetchPatch = async ({ locator, output }) => {
  const patchFetcher = new PatchFetcher()
  const locatorObj =  structUtils.parseLocator(locator)

  const configuration = await Configuration.find(process.cwd(), getPluginConfiguration());
  const {project} = await Project.find(configuration, process.cwd());
  const cache = await Cache.find(configuration);
  const fetcher = configuration.makeFetcher();
  const opts = {project, fetcher, cache, checksums: project.storedChecksums, report: new ThrowReport(), cacheOptions: {skipIntegrityCheck: true}};

  const outpuBuffer = (await patchFetcher.patchPackage(locatorObj, opts)).getBufferAndClose();
  fs.writeFileSync(output, outpuBuffer)
}


module.exports = { tgzToZip, getLocatorHash, fetchPatch };