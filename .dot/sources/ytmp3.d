#!/usr/bin/env dub

/+ dub.sdl:
name "ytmp3"
dependency "sily" version="~>5"
dependency "dini" version="~>2"
targetType "executable"
targetPath "build/"
+/


import std.stdio: writeln, write, readln;
import std.getopt: Option, getopt, config, GetoptResult;
import std.array: popFront, replace;
import std.json: parseJSON, JSONValue;
import std.process: executeShell, spawnShell, wait;
import std.net.curl: HTTPStatusException;
import std.uri: encodeComponent;
import std.file: exists, remove;
import std.conv: to;
import std.range: array;
import std.algorithm.iteration: filter;
import std.algorithm.searching: startsWith;

import core.stdc.stdlib: exit, EXIT_FAILURE;

import sily.getopt: printGetopt;
import sily.path: buildAbsolutePath;
import sily.uri: parseURI, URI;
import sily.curl: get;
import dini;

const string YT_DLP = `yt-dlp -q --progress --no-warnings -f 'ba' --embed-metadata --embed-thumbnail -x --audio-format mp3 https://www.youtube.com/watch?v={VID_ID} -o "{ARTIST} - {TITLE}.temp.mp3"`;
const string LASTFM_TRACK_TAGS = "http://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key={KEY}&artist={ARTIST}&track={TITLE}&format=json";
const string LASTFM_ARTIST_TAGS = "http://ws.audioscrobbler.com/2.0/?method=artist.getTopTags&api_key={KEY}&artist={ARTIST}&format=json";
const string YT_INFO = "https://www.googleapis.com/youtube/v3/videos?part=snippet&id={ID}&key={KEY}";
const string KEY_PATH = "~/.config/ytmetadl.ini";
const string META_CMD = `ffmpeg -loglevel panic -i "{FILEIN}" -metadata title="{TITLE}" -metadata artist="{ARTIST}" -metadata album="{ALBUM}" -metadata genre="{GENRE}" -metadata year="" -c:a copy "{FILEOUT}"`;

struct SongInfo {
    string title;
    string artist;
    string encodedTitle;
    string encodedArtist;
    string imageUrl;
    string genre;
    string album;
    SongGenre[] tags;
}

struct SongGenre {
    string name = "none";
    int count = 0;
}

int main(string[] args) {
    GetoptResult help = getopt(
        args,
        config.passThrough,
        config.bundling,
        config.caseSensitive,
        // "opt|o", "does option", &optionVar,
    );

    if (help.helpWanted) {
        printGetopt("Usage: ytmp3 [options] videourl", "Options", help.options);
    }

    if (!isTool("ffmpeg")) {
        writeln("Missing binary for ffmpeg");
        return EXIT_FAILURE;
    }

    if (!isTool("yt-dlp")) {
        writeln("Missing binary for yt-dlp");
        return EXIT_FAILURE;
    }

    string[string] keys;
    try {
        keys = getKeys();
        if (keys["youtube"] == "") { writeln("Missing Youtube API key"); return EXIT_FAILURE; }
        if (keys["lastfm"] == "") { writeln("Missing LastFM API key"); return EXIT_FAILURE; }
    } catch (Exception e) {
        writeln("Failed to parse key config file");
        exit(EXIT_FAILURE);
    }

    args.popFront();

    if (args.length == 0) {
        writeln("Missing youtube link");
        return EXIT_FAILURE;
    }

    SongInfo song = getYoutubeInfo(getVideoID(args[0]), keys["youtube"]);

    if (song.title != "" && song.artist != "") {
        writeln("Found song:");
        song.title = song.title.replace(song.artist ~ " - ", "");
        writeln("Artist - '", song.artist, "'");
        writeln("Title  - '", song.title, "'");
        if (prompt("Do you want to change title or artist?", false)) {
            song.artist = prompt("Artist", song.artist);
            song.title = prompt("Title", song.title);
        }
    }

    bool trackHasTags = tryAddTrackTags(song, keys["lastfm"]);
    if (!trackHasTags) {
        trackHasTags = tryAddArtistTags(song, keys["lastfm"]);
    }

    bool userManualTag = false;
    if (trackHasTags) {
        writeln("Please select song genre:");
        SongGenre[] tags = song.tags.filter!(a => a.count >= 50).array;
        for (size_t i = 0; i < tags.length; ++i) {
            writeln("[", i + 1, "] ", tags[i].name);
        }
        int sel = prompt("Genre ID or 0 to set manually", 1);
        if (sel == 0) {
            userManualTag = true;
        } else {
            if (sel > tags.length) {
                writeln("Invlid Genre ID. Please set Genre manually");
                userManualTag = true;
            } else {
                song.genre = tags[sel - 1].name;
                writeln("Selected Genre - '", song.genre, "'");
            }
        }
    }

    if (!trackHasTags || userManualTag) {
        if (!trackHasTags) writeln("Failed to get song genre");
        song.genre = prompt("Type Song Genre", "");
    }

    if (song.album != "") {
        writeln("Found album for track - '", song.album, "'");
        if (prompt("Do you want to edit it?", false)) {
            song.album = prompt("Album", song.album);
        }
    } else {
        writeln("Failed to find track album. Please set Album manually");
        prompt("Album", "");
    }

    string dlpCommand = YT_DLP
        .replace("{VID_ID}", getVideoID(args[0]))
        .replace("{ARTIST}", song.artist.replace('\'', "\\'"))
        .replace("{TITLE}", song.title.replace('\'', "\\'"));

    string metaCommand = META_CMD
        .replace("{FILEIN}", song.artist ~ " - " ~ song.title ~ ".temp.mp3")
        .replace("{FILEOUT}", song.artist ~ " - " ~ song.title ~ ".mp3")
        .replace("{TITLE}", song.title.replace('\'', "\\'"))
        .replace("{ARTIST}", song.artist.replace('\'', "\\'"))
        .replace("{GENRE}", song.genre.replace('\'', "\\'"))
        .replace("{ALBUM}", song.album.replace('\'', "\\'"));

    writeln("Downloading song");
    int dlpStat = wait(spawnShell(dlpCommand));
    if (dlpStat != 0) {
        writeln("Encountered error when downloading track");
        return EXIT_FAILURE;
    }
    int metaStat = wait(spawnShell(metaCommand));
    if (exists(song.artist ~ " - " ~ song.title ~ ".temp.mp3")) remove(song.artist ~ " - " ~ song.title ~ ".temp.mp3");
    if (metaStat != 0) {
        writeln("Failed to write song metadata");
        return EXIT_FAILURE;
    }

    writeln("Successfully downloaded song");

    return 0;
}

bool tryAddTrackTags(ref SongInfo info, string apiKey) {
    string url = LASTFM_TRACK_TAGS
        .replace("{KEY}", apiKey)
        .replace("{ARTIST}", info.encodedArtist)
        .replace("{TITLE}", info.encodedTitle);

    JSONValue json;
    get(url).then((string data) {
        json = parseJSON(data);
        // writeln(json.toPrettyString());
    }).except((HTTPStatusException e) {
        writeln(e.message);
    });

    if (json.isNull) {
        writeln("Failed to get LastFM song info");
        return false;
    }
    if ("error" in json) {
        writeln("LastFM error: ", json["message"].get!string);
        return false;
    }

    JSONValue trackTags = getJSON(json, "track", "toptags", "tag");
    if (!trackTags.isNull()) {
        if (trackTags.array.length == 0) return false;
        info.tags = parseSongTags(trackTags.array);
        if (info.tags.length == 0) return false;
        return true;
    }

    JSONValue trackAlbum = getJSON(json, "track", "album", "title");
    if (!trackAlbum.isNull()) {
        info.album = trackAlbum.get!string;
    }

    // TODO: image?
    return false;
}

bool tryAddArtistTags(ref SongInfo info, string apiKey) {
    string url = LASTFM_ARTIST_TAGS
        .replace("{KEY}", apiKey)
        .replace("{ARTIST}", info.encodedArtist);

    JSONValue json;
    get(url).then((string data) {
        json = parseJSON(data);
        // writeln(json.toPrettyString());
    }).except((HTTPStatusException e) {
        writeln(e.message);
    });

    if (json.isNull) {
        writeln("Failed to get LastFM artist info");
        return false;
    }
    if ("error" in json) {
        writeln("LastFM error: ", json["message"].get!string);
        return false;
    }

    JSONValue trackTags = getJSON(json, "toptags", "tag");
    if (!trackTags.isNull()) {
        if (trackTags.array.length == 0) return false;
        info.tags = parseSongTags(trackTags.array);
        if (info.tags.length == 0) return false;
        return true;
    }

    return false;
}

SongGenre[] parseSongTags(JSONValue[] json) {
    SongGenre[] arr;
    foreach (val; json) {
        SongGenre tag;
        if ("name" in val) tag.name = val["name"].get!string;
        if ("count" in val) tag.count = val["count"].get!int;
        if (tag.name == "" || tag.count == 0) continue;
        arr ~= tag;
    }
    return arr;
}

SongInfo getYoutubeInfo(string id, string apiKey) {
    string url = YT_INFO.replace("{KEY}", apiKey).replace("{ID}", id);

    JSONValue json;
    get(url).then((string data) {
        // writeln(data);
        json = parseJSON(data);
        // writeln(json.toPrettyString());
    }).except((HTTPStatusException e) {
        writeln(e.message);
    });

    if (json.isNull) {
        writeln("Failed to get Youtube data");
        return SongInfo();
    }

    if (json["items"].array.length == 0) {
        writeln("Invalid URL");
        exit(EXIT_FAILURE);
    }

    SongInfo info;
    info.title = json["items"][0]["snippet"]["title"].get!string;
    info.artist = json["items"][0]["snippet"]["channelTitle"].get!string;
    info.artist = info.artist.replace(" - Topic", "");
    info.title = info.title
        .replace(" (official video)", "")
        .replace(" official video", "")
        .replace(" (Official Video)", "")
        .replace(" Official Video", "")
        .replace(" High Quality", "")
        .replace(" high quality", "")
        .replace(" lyrics", "")
        .replace(" Lyrics", "")
        .replace(" (remastered)", "")
        .replace(" (Remastered)", "")
        .replace(" - (official video)", "")
        .replace(" - official video", "")
        .replace(" - (Official Video)", "")
        .replace(" - Official Video", "")
        .replace(" - High Quality", "")
        .replace(" - high quality", "")
        .replace(" - lyrics", "")
        .replace(" - Lyrics", "")
        .replace(" - (remastered)", "")
        .replace(" - (Remastered)", "");

    info.encodedTitle = info.title.encodeComponent();
    info.encodedArtist = info.artist.encodeComponent();
    return info;
}

string[string] getKeys() {
    string[string] res = [ "youtube": "", "lastfm": ""];
    string path = buildAbsolutePath(KEY_PATH);
    if (!path.exists) {
        writeln("Missing key config file with section '[key]' and keys 'youtube=', 'lastfm=' which contain API keys");
        exit(EXIT_FAILURE);
    }
    Ini ini = Ini.Parse(path);
    if (ini.hasSection("key")) {
        Ini keys = ini.getSection("key");
        if (keys.hasKey("youtube")) { res["youtube"] = keys.getKey("youtube"); }
        if (keys.hasKey("lastfm")) { res["lastfm"] = keys.getKey("lastfm"); }
    }
    return res;
}

string getVideoID(string url) {
    URI uri = parseURI(url);
    if ("v" in uri.query) {
        return uri.query["v"];
    }

    return "";
}

JSONValue getJSON(JSONValue val, string[] keys ...) {
    if (keys.length == 0) return JSONValue(null);
    if (keys[0] in val) {
        if (keys.length == 1) return val[keys[0]];
        return getJSON(val[keys[0]], keys[1..$]);
    }
    return JSONValue(null);
}

bool prompt(string msg, bool p_default) {
    if (p_default) write(msg ~ " [Y/n]: "); else write(msg ~ " [y/N]: ");
    char answer = readln()[0];
    if (answer == '\n') return p_default;
    if (answer == 'y' || answer == 'Y') return true;
    if (answer == 'n' || answer == 'N') return false;
    writeln("Please type 'y' or 'n'");
    return prompt(msg, p_default);
}

string prompt(string msg, string p_default) {
    write(msg ~ " [" ~ p_default ~ "]"~ ": ");
    string answer = readln()[0..$-1];
    if (answer.length == 0) return p_default;
    return answer;
}

int prompt(string msg, int p_default) {
    import std.conv: parse;
    import std.string: isNumeric;

    write(msg ~ " [" ~ p_default.to!string ~ "]"~ ": ");
    string answer = readln()[0..$-1];
    if (answer.length == 0) return p_default;

    if (answer.isNumeric) return parse!int(answer);
    writeln("Please type a number");
    return prompt(msg, p_default);
}

bool isTool(string app) {
    auto res = executeShell("which " ~ app);
    if (res.status != 0) { return false; }
    if (res.output.startsWith("which: no ")) { return false; }
    return true;
}

