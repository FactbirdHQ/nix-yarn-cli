import { tgzUtils } from "@yarnpkg/core";
import fs from "fs";


const cli = async ({ name, input, output }) => {
  console.log({ name, input, output })
  const tgzBuffer = fs.readFileSync(input);
  const zip = await tgzUtils.convertToZip(tgzBuffer, { stripComponents: 1, prefixPath: `node_modules/${name}` });
  fs.writeFileSync(output, zip.getBufferAndClose())
}


cli({ name: process.argv[2], input: process.argv[3], output: process.argv[4] })