const fs = require("fs");
const plist = require("plist");

const obj = plist.parse(fs.readFileSync(process.argv[2], "utf8"));

const tracks = [];
for (const track of Object.values(obj["Tracks"])) {
  if (!track["Movie"]) continue;
  tracks.push(track);
}

const movies = [];
for (const track of tracks) {
  console.log(JSON.stringify(track));
}
