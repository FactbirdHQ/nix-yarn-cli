const { tgzUtils } = require("@yarnpkg/core");
const fs = require("fs");

const tgzToZip = async ({ name, input, output }) => {
  console.log({ name, input, output })
  const tgzBuffer = fs.readFileSync(input);
  const zip = await tgzUtils.convertToZip(tgzBuffer, { stripComponents: 1, prefixPath: `node_modules/${name}` });
  fs.writeFileSync(output, zip.getBufferAndClose())
}

module.exports = { tgzToZip };