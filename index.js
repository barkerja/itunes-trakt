const fs = require("fs");
const plist = require("plist");
const ProgressBar = require("progress");
const Trakt = require("trakt.tv");

(async function() {
  const trakt = new Trakt({
    client_id: process.env["CLIENT_ID"],
    client_secret: process.env["CLIENT_SECRET"],
    redirect_uri: null
  });

  await trakt.import_token({
    access_token: process.env["ACCESS_TOKEN"],
    // expires: 1550906735076,
    refresh_token: process.env["REFRESH_TOKEN"]
  });

  const obj = plist.parse(fs.readFileSync(process.argv[2], "utf8"));

  const tracks = [];
  for (const track of Object.values(obj["Tracks"])) {
    if (!track["Movie"]) continue;
    tracks.push(track);
  }

  const bar = new ProgressBar(":bar", { total: tracks.length });

  const movies = [];
  for (const track of tracks) {
    const results = await trakt.search.text({
      query: track["Name"]
        .replace(/[^\x00-\x7F]/g, "")
        .replace(/\([^\)]+\)/, ""),
      fields: "title",
      type: "movie"
    });

    const result = results.find(result => result.movie.year === track["Year"]);
    if (!result) continue;

    const movie = {
      ids: result.movie.ids,
      year: track["Year"],
      collected_at: track["Date Added"].toISOString(),
      media_type: "digital"
    };

    movies.push(movie);
    bar.tick();
  }

  const response = await trakt.sync.collection.add({ movies });
  console.log(response);
})();
