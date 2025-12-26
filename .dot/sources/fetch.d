#!/usr/bin/env dub

/+ dub.sdl:
name "fetch"
dependency "sily" version="~>1.4.1"
dependency "sily:logger" version="~>1.4.1"
targetType "executable"
targetPath "build/"
+/

import std.stdio: writeln, write, writef;
import std.array: popFront, popBack, split, join;
import std.process: execute, spawnShell;
import std.algorithm: count, canFind;
import std.conv: to;
import std.string: startsWith;
import std.format: format;
import std.file: exists;

import core.stdc.stdlib: getenv;

import sily.terminal: terminalColorSupport, ColorSupport, terminalWidth;
import sily.file: readFile;
import sily.logger.pixelfont;
import sily.logger;
import sily.bashfmt;
import sily.array: repeat;

struct FileSys {
    string name;
    string size;
    string used;
    string aval;
    ubyte perc;
    string mnt;
}

string[] ignoreMount = ["/c", "/boot/efi", "/boot"];

void main() {
    string user = getenv("USER").to!string;
    string lastLogin = execute(["last", "-1R", user]).output[0..$-2];
    lastLogin = lastLogin.split('\n')[0].split(' ').nonEmpty()[2..6].join(' ');

    FileSys[] filesys = [];
    string[] fstmp = execute(["df", "-lh"]).output[0..$-1].split('\n')[1..$];
    foreach (fs; fstmp) {
        if (!fs.startsWith("/dev/")) continue;
        string[] fsys = fs.split(' ').nonEmpty();
        if (ignoreMount.canFind(fsys[5])) continue;
        filesys ~= FileSys(fsys[0], fsys[1], fsys[2], fsys[3], fsys[4][0..$-1].to!ubyte, fsys[5]);
    }

    string kern = execute(["uname", "-r"]).output[0..$-1];
    string uptime = execute(["uptime", "-p"]).output[3..$-1];
    string hostname = execute(["uname", "-n"]).output[0..$-1];

    string os_art = "";
    string art_file = getenv("HOME").to!string ~ "/.dot/data/fetch-" ~ hostname ~ ".txt";
    if (exists(art_file)) {
        os_art = readFile(art_file);
    }

    writeln("Welcome back, ", user, ".");
    if (os_art != "") fwriteln(FG.ltred, FM.bold, os_art[0..$-1], FR.reset);

    writeln();
    writeln("System");
    writeln("  Kernel: ", kern);
    writeln("  Login : ", lastLogin);
    writeln("  Uptime: ", uptime);
    writeln("  Column: ", terminalWidth());

    writeln();

    wstring[] art_lines = os_art.to!wstring().split('\n');
    ulong def_width = 49;
    ulong art_width = def_width;
    for (size_t i = 0; i < art_lines.length; ++i) {
        if (art_lines[i].length > art_width) art_width = art_lines[i].length;
    }
    long wdiff = art_width - def_width;

    writef("File systems     %*-sSize   Used   Aval   Use%%   Mntd\n", wdiff, "");
    foreach (fs; filesys) {
        writef("  %s%*-s%s%7s%7s%6d%%   %s\n", fs.name, 15 + wdiff - fs.name.length, "", fs.size, fs.used, fs.aval, fs.perc, fs.mnt);
        ulong len = def_width - 4 + wdiff;
        float tusd = len * 1.0f * (fs.perc / 100.0f);
        uint usd = tusd.to!int;
        write("  [");
        if (fs.perc <= 50) write("\033[92m"); else
        if (fs.perc <= 75) write("\033[93m"); else
        if (fs.perc <= 100) write("\033[91m");
        write('='.repeat(usd));
        write("\033[90m");
        write('='.repeat(len - usd));
        writeln("\033[0m]");
    }

    writeln("\0");
}

void center(string message, int customSize = -1) {
    if (customSize == -1) return sily.logger.center(message.to!dstring);
    int tw = terminalWidth;
    writef("%*s%s", (tw - customSize) / 2, "", message);
}

string[] nonEmpty(string[] arr) {
    string[] arrOut = [];
    foreach (e; arr) {
        if (e != "") {
            arrOut ~= e;
        }
    }
    return arrOut;
}
