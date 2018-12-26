const fs = require("fs");
const plist = require("plist");

const data = fs.readFileSync(process.argv[2], "utf8");
const obj = plist.parse(data);

console.log(JSON.stringify(obj));
