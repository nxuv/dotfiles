#!/usr/bin/env dub

/+ dub.sdl:
name "floppy-test"
// dependency "sily" version="~>1.4.1"
// dependency "sily:logger" version="~>1.4.1"
targetType "executable"
targetPath "build/"
+/

module app;

import std.getopt: getopt, Option, config;
import std.stdio: writeln, write, File, readln;
import std.array: split, replace;
import std.process: wait, spawnProcess, executeShell, spawnShell;
import std.range: array;
import std.algorithm: filter, startsWith, canFind;
import std.string: fromStringz;
import std.file: readText, isFile, exists, FileException;
import std.path: absolutePath, buildNormalizedPath, expandTilde;

import core.stdc.stdlib: getenv;
import core.sys.posix.unistd: getuid;

string MOUNT_POINT = "/mnt/floppy";
string SUDO_COMMAND = "sudo -u '#USER' XDG_RUNTIME_DIR=/run/user/USER";
string COPY_PATH = "/g/floppy-bak";

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
    if (getuid() != 0) {
        writeln("Please run program as SU to allow it to mount floppy drives");
        return;
    }

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
                testFloppy(floppy);
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
            unmountFloppy(floppy);
            sleep(1000);
            continue;
        }

        sleep(1000);
    }
}

void testFloppy(Device dev) {
    if (!dev.mounted) return;
    string path = fixPath(MOUNT_POINT ~ "/sily-floppy-test.txt");
    wait(spawnShell("eza " ~ MOUNT_POINT));
    import std.stdio: File;
    bool wasError = false;
    File f;
    try {
        f = File(path, "w");
        f.write("testing");
    } catch (Exception e) {
        wasError = true;
    }
    try {
        f.close();
    } catch (Exception e) {
        writeln("No space left");
        wasError = true;
    }
    string contents = readFile(path);
    if (contents != "testing") {
        wasError = true;
    }
    import std.file: remove;
    try {
        remove(path);
    } catch (Exception e) {
        wasError = true;
    }

    if (wasError) {
        playSound("error");
    } else {
        playSound("success");

        // string floppyCopyTo = fixPath(COPY_PATH ~ '/' ~ floppy.uuid);
        // string floppyCopyFrom = fixPath(floppy.mount);
        // executeShell("mkdir -r " ~ floppyCopyTo);
        // executeShell("cp -r -f " ~ floppyCopyFrom ~ " " ~ floppyCopyTo);
        // // Check before use!!!
        // executeShell("mkfs -t vfat /dev/" ~ floppy.name);
    }
}

void playSound(string name) {
    import std.file: thisExePath;
    import std.path: dirName;
    spawnShell(getUserSudo() ~ " aplay '" ~ fixPath(thisExePath().dirName() ~ "/" ~ name ~ ".wav") ~ "'");
}

string getUserSudo() {
    import std.datetime;
    auto r = executeShell("lslogins -Lue --time-format=iso");
    if (r.status != 0) return "";
    string[] lines = r.output[0..$-1].split('\n');
    string uid = "";
    DateTime time = DateTime.fromSimpleString("1970-Jan-01 00:00:00");
    foreach (line; lines) {
        string[] inf = line.split(' ');
        string tmp = "";
        string ll = "";

        foreach (i; inf) {
            if (i.startsWith("UID")) tmp = i.split('=')[1][1..$-1];
            if (tmp == "0") continue;
            if (i.startsWith("LAST-LOGIN")) ll = i.split('=')[1][1..$-1];
        }
        if (ll == "") continue;
        if (tmp == "") continue;
        DateTime t = DateTime.fromISOExtString(ll.split('+')[0]);

        if (time < t) {
            uid = tmp;
            time = t;
        }
    }

    if (uid == "") return "";
    return SUDO_COMMAND.replace("USER", uid);
}

void mountFloppy(ref Device dev) {
    writeln("Mounting");
    writeln("mount -t " ~ dev.fstype ~ " -o rw,users,umask=000,exec /dev/" ~ dev.name ~ " " ~ MOUNT_POINT);
    auto r = executeShell("mount -t " ~ dev.fstype ~ " -o rw,users,umask=000,exec /dev/" ~ dev.name ~ " " ~ MOUNT_POINT);
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
        writeln("umount -l /dev/" ~ dev.name);
        auto r = executeShell("umount -l /dev/" ~ dev.name);
        if (r.status == 0) {
            writeln("Successfully unmounted floppy drive");
            dev = Device();
        } else {
            writeln("There was error when unmounting floppy drive");
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
    File f;
    f = File(file, "w");
    f.write(content);
    f.close();
}

string readFile(string path) {
    string file = path.fixPath();
    if (!file.exists) return "";
    if (!file.isFile) return "";
    return readText(file);
}



