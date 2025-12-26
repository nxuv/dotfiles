#!/usr/bin/env dub

/+ dub.sdl:
name "floppy-watch"
// dependency "sily" version="~>1.4.1"
// dependency "sily:logger" version="~>1.4.1"
targetType "executable"
targetPath "build/"
+/

module app;

import std.getopt: getopt, Option, config;
import std.array: split, replace;
import std.process: wait, spawnProcess, executeShell, spawnShell;
import std.range: array;
import std.algorithm: filter, startsWith, canFind;
import std.string: fromStringz, toStringz;
import std.file: readText, isFile, exists, FileException, tempDir, getAttributes, setAttributes;
import std.path: absolutePath, buildNormalizedPath, expandTilde;
import std.datetime;
import std.conv: octal;

import core.stdc.stdlib: getenv, exit, EXIT_FAILURE, EXIT_SUCCESS;
import core.sys.posix.unistd: getuid, fork, pid_t, setsid, chdir;

static import std.stdio;

const string MOUNT_POINT = "/media/floppy";
const string AUTORUN_NAME = "autorun.sh";
const string AUTOCLOSE_NAME = "autoclose.sh";
const string AUTOCLOSE_TEMP_NAME = "sily-floppy-watch-autoclose.sh";
const string TMP_LOGNAME = "floppy-watch.log";

struct Device {
    bool empty = true;

    string name = "";
    string fstype = "";
    string fsver = "";
    string label = "";
    string uuid = "";
    string fsaval = "";
    string fsusep = "";
    string mount = "";

    @property bool mounted() => mount != "";
}

Device floppy;
string autocloseFile = "";
std.stdio.File log;

void writeln(T...)(T args) {
    string time = Clock.currTime().toSimpleString();
    log.writeln(time, " ", args);
    log.flush();
}

// ["sda"]
// ["sdb", "vfat", "FAT12", "1807-1664"]
//
// ["sda"]
// ["sdb", "vfat", "FAT12", "1807-1664", "1.4M", "0%", "/mnt/floppy"]
//
//
// ["sda"]
// ["sdb", "vfat", "FAT12", "CLARION\\x205", "13F2-3E4D"]
//
// ["sda"]
// ["sdb", "vfat", "FAT12", "CLARION\\x205", "13F2-3E4D", "1.4M", "0%", "/mnt/floppy"]

void main() {
    _daemon();
}

void _daemon() {
    // // Uncomment to deamonize
    // pid_t pid;
    // pid_t sid;
    //
    // pid = fork();
    // if (pid < 0) exit(EXIT_FAILURE);
    // if (pid > 0) exit(EXIT_SUCCESS);
    // sid = setsid();
    // if (sid < 0) exit(EXIT_FAILURE);
    // if ((chdir("/".toStringz)) < 0) exit(EXIT_FAILURE);

    string logPath = fixPath(tempDir() ~ TMP_LOGNAME);
    log = std.stdio.File(logPath, "w+");

    while (true) {
        // Get list of devices
        auto res = executeShell(`lsblk -nfdaP`);
        // Failed to execute
        if (res.status != 0) continue;
        // Get array of devices
        string[] lines = res.output[0..$-1].split('\n');

        Device[] devices = new Device[](lines.length);

        // On each device
        for (size_t i = 0; i < devices.length; ++i) {
            // Get device info
            string[] inf = lines[i].split(' ');

            devices[i] = mapDevice(inf);
        }

        bool floppyFound = false;
        foreach (dev; devices) {
            if (floppy.empty && dev.fstype == "vfat" && dev.fsver == "FAT12") {
                writeln();
                writeln("Found new device:");
                writeln("    Path: /dev/" ~ dev.name);
                writeln("    Labl: " ~ dev.label);
                writeln("    UUID: " ~ dev.uuid);
                writeln("    Fsty: " ~ dev.fstype);
                writeln("    Fsvr: " ~ dev.fsver);
                writeln("    Mont: " ~ dev.mount);
                floppyFound = true;
                floppy = dev;
                if (floppy.mounted) break;
                mountFloppy(floppy);
                writeln("Autorun:");
                string autorun = tryReadAutorun(floppy);
                writeln(autorun);
                writeln("Autoclose:");
                string autoclose = tryReadAutoclose(floppy);
                writeln(autoclose);
                if (autorun != "") {
                    string arpath = fixPath(MOUNT_POINT ~ '/' ~ AUTORUN_NAME);
                    writeln(arpath);
                    spawnShell(arpath);
                }
                if (autoclose != "") {
                    makeAutocloseCopy(floppy);
                }
                break;
            }

            if (floppy.name == dev.name) {
                floppyFound = true;
                floppy = dev;
                break;
            }
        }

        bool floppyInvalid = floppyFound == false && floppy.empty == false;
        bool floppyEjected = floppy.fstype == "";
        bool shouldUnmount = floppyInvalid || floppyEjected;
        if (shouldUnmount && !floppy.empty) {
            if (autocloseFile != "" && exists(autocloseFile)) spawnShell(autocloseFile);
            autocloseFile = "";
            unmountFloppy(floppy);
            sleep(1000);
            continue;
        }

        sleep(1000);
    }

    scope (exit) {
        log.close();
    }

    exit(EXIT_SUCCESS);
}

string tryReadAutorun(Device dev) {
    if (!dev.mounted) return "";
    string path = fixPath(MOUNT_POINT ~ '/' ~ AUTORUN_NAME);
    if (path.exists && path.isFile) {
        string contents = readFile(path);
        return contents;
    }
    return "";
}

string tryReadAutoclose(Device dev) {
    if (!dev.mounted) return "";
    string path = fixPath(MOUNT_POINT ~ '/' ~ AUTOCLOSE_NAME);
    if (path.exists && path.isFile) {
        string contents = readFile(path);
        return contents;
    }
    return "";
}

void makeAutocloseCopy(Device dev) {
    if (!dev.mounted) return;
    string path = fixPath(MOUNT_POINT ~ '/' ~ AUTOCLOSE_NAME);
    if (path.exists && path.isFile) {
        string tempPath = fixPath(tempDir() ~ AUTOCLOSE_TEMP_NAME);
        wait(spawnShell("cp -f '" ~ path ~ "' '" ~ tempPath ~ "'"));
        tempPath.setAttributes(tempPath.getAttributes | octal!700);
        autocloseFile = tempPath;
    }
}

void mountFloppy(ref Device dev) {
    writeln("Mounting");
    string mountCommand = "udevil mount -t " ~ dev.fstype ~ " -o rw,users,umask=000,exec,noatime /dev/" ~ dev.name ~ " " ~ MOUNT_POINT;
    writeln(mountCommand);
    auto r = executeShell(mountCommand);
    if (r.status == 0) {
        writeln("Successfully mounted floppy drive to " ~ MOUNT_POINT);
        if (r.output.canFind("read-only")) {
            writeln("Device is read only");
        }
        dev.mount = MOUNT_POINT;
    } else {
        writeln("Failed to mount floppy drive. Will attempt again");
    }
}

void unmountFloppy(ref Device dev) {
    writeln("Failed to find device. Unmounting");
    if (dev.mounted) {
        writeln("udevil umount -l /dev/" ~ dev.name);
        auto r = executeShell("udevil umount -l /dev/" ~ dev.name);
        if (r.status == 0) {
            writeln("Successfully unmounted floppy drive");
            dev = Device();
        } else {
            writeln("There was error when unmounting floppy drive. Will attempt again");
        }
    } else {
        dev = Device();
    }
}

import core.thread: Thread;
import core.time: dmsecs = msecs;

/// Sleeps for set amount of msecs
void sleep(uint msecs) {
    Thread.sleep(msecs.dmsecs);
}

Device mapDevice(string[] inf) {
    Device dev;
    foreach (i; inf) {
        if (i.startsWith("NAME")) dev.name = i.split('=')[1][1..$-1];
        if (i.startsWith("FSTYPE")) dev.fstype = i.split('=')[1][1..$-1];
        if (i.startsWith("FSVER")) dev.fsver = i.split('=')[1][1..$-1];
        if (i.startsWith("LABEL")) dev.label = i.split('=')[1][1..$-1];
        if (i.startsWith("UUID")) dev.uuid = i.split('=')[1][1..$-1];
        if (i.startsWith("FSAVAIL")) dev.fsaval = i.split('=')[1][1..$-1];
        if (i.startsWith("FSUSE%")) dev.fsusep = i.split('=')[1][1..$-1];
        if (i.startsWith("MOUNTPOINTS")) dev.mount = i.split('=')[1][1..$-1];
    }
    dev.empty = dev.name == "";
    return dev;
}

string fixPath(string path) {
    return path.expandTilde.buildNormalizedPath.absolutePath;
}

void writeFile(string path, string content) {
    string file = path.fixPath();
    std.stdio.File f;
    f = std.stdio.File(file, "w");
    f.write(content);
    f.close();
}

string readFile(string path) {
    string file = path.fixPath();
    if (!file.exists) return "";
    if (!file.isFile) return "";
    return readText(file);
}


