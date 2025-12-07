#!/usr/bin/env dub

/+ dub.sdl:
name "fetch"
dependency "sily" version="~>1.4.1"
dependency "sily:logger" version="~>1.4.1"
targetType "executable"
targetPath "bin/"
+/

import std.stdio: writeln, write, writef;
import std.array: popFront, popBack, split, join;
import std.process: execute, spawnShell;
import std.algorithm: count, canFind;
import std.conv: to;
import std.string: startsWith;
import std.format: format;

import core.stdc.stdlib: getenv;

import sily.terminal: terminalColorSupport, ColorSupport, terminalWidth;
import sily.logger.pixelfont;
import sily.logger;
import sily.bashfmt;
import sily.array: repeat;

string atheosString = `
      ___   __  __         ____  _____
     /   | / /_/ /_  ___  / __ \/ ___/
    / /| |/ __/ __ \/ _ \/ / / /\__ \
   / ___ / /_/ / / /  __/ /_/ /___/ /
  /_/  |_\__/_/ /_/\___/\____//____/
`[1..$-1];

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
    // string shell = getenv("SHELL").to!string.split('/')[$-1];
    // string shell = execute(["echo", "$0"])
        // .output.to!string.split('/')[$-1];
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
    // ulong pkgins = execute(["yay", "-Q"]).output[0..$-2].count('\n');
    // ulong pkgupd = execute(["yay", "-Qu"]).output[0..$-2].count('\n');
    // TODO: fetch packages once in a while?
    // size_t services = execute(["systemctl", "--type=service", "--state=running"]).output.count("running");

    // int tw = terminalWidth;
    //
    // writef("%*sWelcome back, %s.\n", tw / 2 - (user.length + 15) / 2, "", user);
    // fwrite(FG.ltred, FM.bold);
    // sily.logger.center(atheosString.to!dstring);
    // fwrite(FR.reset);
    //
    // writeln();
    //
    // int width = 51;
    // // writef("System");
    // // writeln("  Kernel: ", execute(["uname", "-rsmo"]).output[0..$-1]);
    // writef("%*sShell%*s\n", (tw - width) / 2, "", width - "Shell".length, shell);
    // writef("%*sKernel%*s\n", (tw - width) / 2, "", width - "Kernel".length, kern);
    // writef("%*sLogin%*s\n", (tw - width) / 2, "", width - "Login".length, lastLogin);
    // writef("%*sUptime%*s\n", (tw - width) / 2, "", width - "Uptime".length, uptime);
    // writef("%*sPackages%*s\n", (tw - width) / 2, "", width - "Packages".length, pkgins);
    writeln("Welcome back, ", user, ".");
    fwriteln(FG.ltred, FM.bold, atheosString, FR.reset);

    writeln();
    writeln("System");
    // writeln("  Kernel: ", execute(["uname", "-rsmo"]).output[0..$-1]);
    // writeln("  Shell   : ", shell);
    writeln("  Kernel  : ", kern);
    writeln("  Login   : ", lastLogin);
    writeln("  Uptime  : ", uptime);
    // writeln("  Packages: ", pkgins);
    // writeln("  Services: ", services);

    // --------
    // writeln();
    // writeln("  Status?");
    // writeln();
    // writeln("Packages:");

    // writeln("  Installed: ", pkgins);
    // writeln("  Updates  : ", pkgupd);
    // --------

    writeln();
    // center("File systems       Size   Used   Aval   Use%   Mntd");
    // foreach (fs; filesys) {
    //     string fsinfo = format("%*-s%7s%7s%7s%6d%%   %s\n", 16, fs.name, fs.size, fs.used, fs.aval, fs.perc, fs.mnt);
    //     uint len = 49;
    //     float tusd = len * 1.0f * (fs.perc / 100.0f);
    //     uint usd = tusd.to!int;
    //     string fsfill = "[";
    //     if (fs.perc <= 50) fsfill ~= "\033[92m"; else
    //     if (fs.perc <= 75) fsfill ~= "\033[93m"; else
    //     if (fs.perc <= 100) fsfill ~= "\033[91m";
    //     fsfill ~= '='.repeat(usd);
    //     fsfill ~= "\033[90m";
    //     fsfill ~= '='.repeat(len - usd);
    //     fsfill ~= "\033[0m]\n";
    //     center(fsinfo, width);
    //     center(fsfill, width);
    // }
    writeln("File systems         Size   Used   Aval   Use%   Mntd");
    foreach (fs; filesys) {
        writef("  %*-s%7s%7s%7s%6d%%   %s\n", 16, fs.name, fs.size, fs.used, fs.aval, fs.perc, fs.mnt);
        uint len = 49;
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

    // writeln("Last login: ", lastLogin);
    // writeln();
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
