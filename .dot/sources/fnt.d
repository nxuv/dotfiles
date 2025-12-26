#!/usr/bin/env dub

/+ dub.sdl:
name "fnt"
dependency "sily" version="~>1.4.1"
dependency "sily:logger" version="~>1.4.1"
targetType "executable"
targetPath "build/"
+/

// FIXME: convert is deprecated, figure out how to use magick here

import std.getopt: getopt, Option, config;
import std.stdio: writeln, write, File, readln;
import std.array: split, replace, split, join, array;
import std.process: wait, spawnProcess, execute, spawnShell, executeShell;
import std.file: tempDir, exists, remove, mkdirRecurse, rmdirRecurse, isFile; // tempDir
import std.path: baseName;
import std.algorithm.searching: countUntil, startsWith, canFind, endsWith;
import std.algorithm.iteration: filter;
import std.algorithm.sorting: sort;
import std.string: toStringz, fromStringz;
import std.conv: to;
import std.format: format;

import core.stdc.stdlib: c_getenv = getenv;
import core.stdc.stdlib: exit;

import sily.getopt;
import sily.bashfmt: eraseLines;

string fixPath(string p) {
    import std.path : absolutePath, buildNormalizedPath, expandTilde;
    return p.expandTilde.absolutePath.buildNormalizedPath;
}

const string FONTS_GOOGLE = "https://sid.ethz.ch/debian/google-fonts/fonts-master";
const string FONTS_INDEX = "https://deb.debian.org/debian/dists/sid/main/binary-all/Packages.xz";
const string FONTS_MIRROR = "https://deb.debian.org/debian";

// in case of no kitty replace kitty icat --align=left with wezterm imgcat
// const string HB_VIEW = "hb-view \"$FONT\" --text \"$TEXT\" --background=#282828 --foreground=#ebdbb2 -O svg | rsvg-convert | convert -trim -resize '25%' - - | kitty icat --align=left";
const string HB_VIEW = "hb-view \"$FONT\" --text \"$TEXT\" --background=#282828 --foreground=#ebdbb2 -O svg | rsvg-convert | convert -trim -resize '25%' - - | wezterm imgcat";
const string FN_INFO = "otfinfo -i \"$FONT\" | head -6";

const string _version = "fnt v1.0.0";
string fontPath = "";
string fontTemp = "";
string fontCache = "";
string fontPackage = "";
string fontGoogleCache = "";

string previewText = "";

int main(string[] args) {
    bool optVersion = false;
    auto help = getopt(
        args,
        config.bundling, config.passThrough, config.caseSensitive,
        "version", "print version", &optVersion,
        "text|t", "sets preview text", &previewText,
    );

    Option[] commands = [
        customOption("update , u", "updates font cache"),
        customOption("list   , l", "lists installed fonts"),
        customOption("install, i", "installs font"),
        customOption("remove , r", "removes font"),
        customOption("preview, p", "displays font preview"),
        customOption("search , s", "searches for font"),
    ];

    if (optVersion) {
        writeln(_version);
        return 0;
    }

    if (help.helpWanted || args.length == 1) {
        printGetopt("fnt <operation> [...]",
            "Options", help.options, "Commands", commands
        );
        return 0;
    }

    ensureFontDirectory();

    // assistant("Main font path: ", fontPath);
    // writeln();
    // assistant("Temp font path: ", fontTemp);
    // writeln();
    // assistant("Font cache: ", fontCache);

    args[1] = args[1][0].to!string;

    import std.array: popFront;
    string[] opts = args.dup;
    opts.popFront(); // [0]
    opts.popFront(); // command

    switch (args[1]) {
        case "u": return updateFonts();
        case "l": return listFonts();
        case "i": return installFont(opts);
        case "r": return removeFont(opts);
        case "p": return previewFont(opts);
        case "s": return searchFont(opts);
        default: assistant("Unknown command");
    }

    return 0;
    // string kern = wait(spawnProcess(["uname", "-r"]).output[0..$-1]);
}

int updateFonts() {
    assistant("Downloading font cache");
    downloadFontCache();
    return 0;
}

int listFonts() {
    assistant("Listing fonts");
    string[] fonts = listdirfull(fontPath);
    foreach (f; fonts) {
        f.writeln();
    }
    return 0;
}

int installFont(string[] args) {
    string[] fonts = getFontNames();
    string fontName = args.join(' ');

    if (!fonts.canFind(fontName)) {
        assistant("Failed to find font");
        exit(0);
    }

    assistant("Installing " ~ fontName);

    string font = fontName;

    if (font.startsWith("google-")) {
        string fname = font[7..$];
        string[] apache = getFontNamesGoogle("apache");
        string repo = "ofl";
        if (apache.canFind(font)) repo = "apache";

        string[] res = downloadFontGoogle(repo, fname);
        string fpath = fixPath(fontPath ~ "/" ~ font);
        if (!fpath.exists) mkdirRecurse(fpath);
        foreach (ftmp; res) {
            executeShell(format("cp %s %s/", ftmp, fpath));
        }
    } else { // fonts-
        string[] fnts = downloadFontDebian(font);
        string fpath = fixPath(fontPath ~ "/" ~ font);
        if (!fpath.exists) mkdirRecurse(fpath);
        foreach (fnt; fnts) {
            executeShell(format("cp %s %s/", fnt, fpath));
        }

        return 0;
    }

    return 0;
}

int removeFont(string[] args) {
    string font = args.join();
    string[] fonts = listdirfull(fontPath);
    if (fonts.canFind(font)) {
        assistant("Removing font");
        rmdirRecurse(fixPath(fontPath ~ "/" ~ font));
        return 0;
    }
    assistant("Unable to find font to remove");
    return 0;
}

int previewFont(string[] args) {
    string fontName = args.join();
    if (exists(fontName) && isFile(fontName)) {
        string previewFile = fontName.fixPath();
        if (!exists(previewFile)) {
            assistant("Failed to find font for preview");
            exit(0);
        }
        assistant("Preview for " ~ previewFile);
        string fin = FN_INFO;
        fin = fin.replace("$FONT", previewFile);
        string fpr = HB_VIEW;
        fpr = fpr.replace("$FONT", previewFile);
        fpr = fpr.replace("$TEXT", previewText == "" ? baseName(previewFile) : previewText);
        wait(spawnShell(fin));
        wait(spawnShell(fpr));
        return 0;
    }

    string[] fonts = getFontNames();
    string fontInstall = "";

    foreach (font; fonts) {
        if (font == fontName) fontInstall = font;
    }

    if (fontInstall.length == 0) {
        assistant("Failed to find font");
        exit(0);
    }

    assistant("Preview for " ~ fontInstall);

    string font = fontInstall;

    if (font.startsWith("google-")) {
        string fname = font[7..$];
        string[] apache = getFontNamesGoogle("apache");
        string repo = "ofl";
        if (apache.canFind(font)) repo = "apache";

        string[] res = downloadFontGoogle(repo, fname);
        foreach (ftmp; res) {
            string fin = FN_INFO;
            fin = fin.replace("$FONT", ftmp.replace(`"`, `\"`));
            string fpr = HB_VIEW;
            fpr = fpr.replace("$FONT", ftmp.replace(`"`, `\"`));
            fpr = fpr.replace("$TEXT", previewText == "" ? font.replace(`"`, `\"`) : previewText.replace(`"`, `\"`));
            wait(spawnShell(fin));
            wait(spawnShell(fpr));
        }
    } else { // fonts-
        string[] fnts = downloadFontDebian(font);
        foreach (fnt; fnts) {
            string fin = FN_INFO;
            fin = fin.replace("$FONT", fnt.replace(`"`, `\"`));
            string fpr = HB_VIEW;
            fpr = fpr.replace("$FONT", fnt.replace(`"`, `\"`));
            fpr = fpr.replace("$TEXT", previewText == "" ? font.replace(`"`, `\"`) : previewText.replace(`"`, `\"`));
            wait(spawnShell(fin));
            wait(spawnShell(fpr));
        }

        return 0;
    }

    return 0;
}

int searchFont(string[] args) {
    string[] fonts = getFontNames();
    string fontName = args.join();

    assistant("Searching fonts");

    foreach (font; fonts) {
        if (font.canFind(fontName)) writeln(font);
    }

    return 0;
}

string[] downloadFontGoogle(string repo, string fname) {
    string maybeFonts = fixPath(fontPath ~ "/google-" ~ fname);
    if (exists(maybeFonts)) {
        string[] fonts = listdir(maybeFonts);
        for (int i = 0; i < fonts.length; ++i) {
            fonts[i] = fixPath(maybeFonts ~ "/" ~ fonts[i]);
        }
        return fonts;
    }

    string[] res = getGoogleFontsUrl(repo, fname);
    string[] _out;

    foreach (f; res) {
        string url = FONTS_GOOGLE ~ "/" ~ repo ~ "/" ~ fname ~ "/" ~ f;
        string ftmp = fixPath(fontTemp ~ "/downloaded_fonts/google-" ~ fname ~ "/" ~ f);
        string ftph = fixPath(fontTemp ~ "/downloaded_fonts/google-" ~ fname ~ "/");
        if (!exists(ftph)) mkdirRecurse(ftph);
        if (!exists(ftmp)) {
            wait(spawnShell(format(`curl -g -s "%s" -o "%s"`, url, ftmp)));
        }
        _out ~= ftmp;
    }

    return _out;
}

string[] downloadFontDebian(string font) {
    string maybeFonts = fixPath(fontPath ~ "/" ~ font);
    if (exists(maybeFonts)) {
        string[] fonts = listdir(maybeFonts);
        for (int i = 0; i < fonts.length; ++i) {
            fonts[i] = fixPath(maybeFonts ~ "/" ~ fonts[i]);
        }
        return fonts;
    }

    string[] _out;
    string fname = font[6..$];
    auto res = executeShell(`unxz -c "` ~ fontPackage ~ `"`);

    if (res.status != 0) {
        assistant("Failed getting font list");
        write(res.output);
        exit(0);
    }
    string[] packages = res.output.split('\n');

    size_t idx = packages.countUntil("Package: " ~ font);
    if (idx == -1) {
        assistant("Could not find font in cache");
        exit(0);
    }

    string filename;
    string filepath;

    for (size_t i = idx; i < packages.length; ++i) {
        if (packages[i].startsWith("Filename: ")) {
            filepath = packages[i][10..$];
            import std.path: baseName;
            filename = filepath.baseName();
            break;
        }
    }

    if (filepath == "") {
        assistant("Failed to retrieve font filename");
        exit(0);
    }

    string cachedName = (fontTemp ~ filename).fixPath;
    if (!exists(cachedName)) {
        wait(spawnShell(format(`curl -s "%s/%s" -o "%s"`, FONTS_MIRROR, filepath, cachedName)));
    }
    if (!exists(cachedName)) {
        assistant("Failed retrieving font file");
        exit(0);
    }

    auto art = executeShell(format(`ar t "%s" | grep '^data\.tar'`, cachedName));
    executeShell(format(`ar x "%s" --output="%s" "%s"`, cachedName, fontTemp, art.output[0..$-1]));
    string tmpDebFont = fixPath(fontTemp ~ "downloaded_fonts/" ~ font ~ "/");
    if (!exists(tmpDebFont)) {
        mkdirRecurse(tmpDebFont);
    }
    wait(spawnShell(format(`tar xf "%s%s" -C "%s"`, fontTemp, art.output[0..$-1], tmpDebFont)));
    string tmpDwnFont = fixPath(tmpDebFont ~ "/usr/share/fonts/truetype/" ~ fname ~ "/");
    string[] fnts = listdir(tmpDwnFont);
    foreach (fnt; fnts) {
        string ftmp = fixPath(tmpDwnFont ~ "/" ~ fnt);
        _out ~= ftmp;
    }

    return _out;
}

string[] getGoogleFontsUrl(string repo, string font) {
    string[] tmp;
    // auto res = executeShell(`curl -s "` ~ FONTS_GOOGLE ~ `/` ~ repo ~ `/` ~ font ~ `/"`);
    auto res = executeShell(format(`curl -s "%s/%s/%s/"`, FONTS_GOOGLE, repo, font));
    if (res.status != 0) {
        assistant("Failed to retrieve google " ~ repo ~ " index");
        writeln(res.output);
        exit(0);
    }
    tmp = res.output[0..$-1].split('\n');
    tmp = tmp.filter!(a => a.startsWith("<a href=")).array;

    string[] _out;

    for (int i = 0; i < tmp.length; ++i) {
        string t = tmp[i];
        size_t a = t.countUntil('>') + 1;
        t = t[a..$];
        size_t b = t.countUntil('<');
        t = t[0..b];
        if (t.endsWith(".ttf")) _out ~= t;
        if (t.endsWith(".otf")) _out ~= t;
    }

    return _out;
}

string[] getFontNames() {
    return sort!((a, b) => a < b)(getFontNamesDebian() ~ getFontNamesGoogleAll()).array;
}

string[] getFontNamesGoogleAll() {
    return getFontNamesGoogle("ofl") ~ getFontNamesGoogle("apache");
}

string[] getFontNamesGoogle(string repo, bool recache = false) {
    if (recache) {
        string[] tmp;
        auto res = executeShell(`curl -s "` ~ FONTS_GOOGLE ~ `/` ~ repo ~ `/"`);
        if (res.status != 0) {
            assistant("Failed to retrieve google ofl index");
            writeln(res.output);
            exit(0);
        }
        tmp = res.output[0..$-1].split('\n');
        tmp = tmp.filter!(a => a.startsWith("<a href=")).array;

        string[] _out = new string[](tmp.length);
        string fpath = fontGoogleCache.replace("$REPO", repo);
        File f = File(fpath, "w");

        for (int i = 0; i < tmp.length; ++i) {
            string t = tmp[i];
            size_t a = t.countUntil('>') + 1;
            t = t[a..$];
            size_t b = t.countUntil('/');
            t = t[0..b];
            _out[i] = "google-" ~ t;
            f.writeln(_out[i]);
        }

        return _out;
    } else {
        string fpath = fontGoogleCache.replace("$REPO", repo);
        if (!exists(fpath)) {
            assistant("Missing font cache, please run update");
            exit(0);
        }

        string[] _out;
        File f = File(fpath, "r");
        string line;
        while ((line = f.readln) != null) {
            _out ~= line[0..$-1];
        }
        return _out;
    }
}

string[] getFontNamesDebian() {
    if (!exists(fontPackage)) {
        assistant("Missing font cache, please run update");
        exit(0);
    }

    auto res = executeShell(`unxz -c "` ~ fontPackage ~ `"`);
    if (res.status != 0) {
        writeln("Failed getting font list");
        write(res.output);
        exit(0);
    }
    string[] fonts = res.output.split('\n').filter!(a => a.startsWith("Package: fonts-")).array;

    for (int i = 0; i < fonts.length; ++i) {
        fonts[i] = fonts[i][9..$];
    }

    return fonts;
}

void ensureFontDirectory() {
    string dataHome = getenv("XDG_DATA_HOME");
    string home = getenv("HOME").fixPath;
    if (dataHome.length == 0) {
        dataHome = (home ~ '/' ~ ".local/share").fixPath;
    }

    string target = (dataHome ~ "/fonts/fnt/").fixPath;
    if (!exists(target)) mkdirRecurse(target);

    string cacheDir = getenv("XDG_CACHE_HOME");
    cacheDir = (cacheDir.length == 0 ? home ~ '/' ~ ".cache" : cacheDir).fixPath;
    if (!exists(cacheDir)) mkdirRecurse(cacheDir);

    fontPath = target;
    fontTemp = tempDir;
    fontCache = cacheDir;
    fontPackage = (fontCache ~ '/' ~ "Fonts_Cache_Packages.xz").fixPath();
    fontGoogleCache = (fontCache ~ '/' ~ "Fonts_Cache_Google_$REPO.txt").fixPath();
}

void downloadFontCache() {
    if (exists(fontPackage)) remove(fontPackage);
    spawnShell(`curl -s "` ~ FONTS_INDEX ~ `" -o "` ~ fontPackage ~ `"`);
    getFontNamesGoogle("ofl", true);
    getFontNamesGoogle("apache", true);
}

string getenv(string name) {
    return c_getenv(name.toStringz).fromStringz.to!string;
}

string read(string prompt) {
    assistant(prompt.split('\n'));
    string r = readln()[0..$-1];

    eraseLines(4);
    return r;
}

void assistant(string[] prompt...) {
    import std.random;
    while (prompt.length < 2) prompt ~= "";
    writeln(` /\_/\  `, prompt[0]);
    uint r = choice([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
    if (r == 0) writeln("( o o ) ", prompt[1]);
    else        writeln("( . . ) ", prompt[1]);
}

/**
Returns array of files/dirs from path
Params:
  pathname = Path to dir
Returns:
 */
string[] listdir(string pathname) {
    import std.algorithm;
    import std.array;
    import std.file;
    import std.path;

    return std.file.dirEntries(pathname, SpanMode.shallow)
        .filter!(a => a.isFile)
        .filter!(a => baseName(a.name) != ".uuid")
        .map!((return a) => baseName(a.name))
        .array;
}

/**
Returns array of files/dirs from path
Params:
  pathname = Path to dir
Returns:
 */
string[] listdirfull(string pathname) {
    import std.algorithm;
    import std.array;
    import std.file;
    import std.path;

    return std.file.dirEntries(pathname, SpanMode.shallow)
        .filter!(a => baseName(a.name) != ".uuid")
        .map!((return a) => baseName(a.name))
        .array;
}

