const { tgzUtils, structUtils } = require("@yarnpkg/core");
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

module.exports = { tgzToZip, getLocatorHash };