#!/usr/bin/env dub

/+ dub.sdl:
name "aur"
dependency "sily" version="~>1.4.1"
dependency "sily:logger" version="~>1.4.1"
targetType "executable"
targetPath "build/"
+/

import std.getopt: getopt, Option, config;
import std.stdio: writeln, write, File, readln, stderr;
import std.array: split, replace;
import std.process: wait, spawnProcess, execute, environment;
import std.file;

import std.string: toStringz;

import sily.getopt;
import sily.bashfmt: eraseLines;

import core.sys.posix.unistd: access, F_OK;

import core.stdc.stdlib: exit, EXIT_FAILURE;

string fixPath(string p) {
    import std.path : absolutePath, buildNormalizedPath, expandTilde;
    return p.expandTilde.absolutePath.buildNormalizedPath;
}

const string gitPath = "https://aur.archlinux.org/REPO.git";
const string gitSSH = "ssh://aur@aur.archlinux.org/REPO.git";
const string _version = "aur v1.0.0";

bool optForce = false;
int main(string[] args) {
    bool optVersion = false;
    auto help = getopt(
        args,
        config.bundling, config.passThrough, config.caseSensitive,
        "version", "print version", &optVersion,
        "force|f", "forces command", &optForce,
    );

    Option[] commands = [
        customOption("clone", "clones https package"),
        customOption("clone", "clones ssh package"),
        customOption("build", "builds package"),
        customOption("install", "installs package"),
        customOption("srcinfo", "generates .SRCINFO"),
        customOption("test", "tests PKGUILD and package"),
        customOption("init", "creates new aur package"),
    ];

    if (optVersion) {
        writeln(_version);
        return 0;
    }

    if (help.helpWanted || args.length == 1) {
        printGetopt("aur <operation> [...]",
            "Options", help.options, "Commands", commands
        );
        return 0;
    }

    if (!checkDep("git")) error("Missing git binary");
    if (!checkDep("namcap")) error("Missing namcap binary");
    if (!checkDep("makepkg")) error("Missing makepkg binary");

    switch (args[1]) {
        case "clone_readonly": return cloneRepo(args[2], gitPath);
        case "clone": return cloneRepo(args[2], gitSSH);
        case "build": return buildPkg();
        case "install": return installPkg();
        case "srcinfo": return genSrcInfo();
        case "test": return testPkg();
        case "init": return initPkg();
        default: assistant("Unknown command");
    }

    return 0;
    // string kern = wait(spawnProcess(["uname", "-r"]).output[0..$-1]);
}

int cloneRepo(string repo, string gpath) {
    assistant("Cloning " ~ repo);
    auto _out = wait(spawnProcess(["git", "clone", gpath.replace("REPO", repo)]));
    return _out;
}

bool checkDep(string binary) {
    string[] PATH = environment.get("PATH").split(':');
    foreach (string p; PATH) {
        if (access(fixPath(p ~ '/' ~ binary).toStringz, F_OK) == 0) return true;
    }
    return false;
}

int buildPkg() {
    if (!exists("PKGBUILD")) {
        assistant("Missing PKGBUILD");
        return 0;
    }
    assistant("Making package");
    string args = optForce ? "-sf" : "-s";
    auto _out = wait(spawnProcess(["makepkg", args]));
    return _out;
}

int installPkg() {
    if (!exists("PKGBUILD")) {
        assistant("Missing PKGBUILD");
        return 0;
    }
    assistant("Installing package");
    string args = optForce ? "-fsi" : "-si";
    auto _out = wait(spawnProcess(["makepkg", args]));
    return _out;
}

int genSrcInfo() {
    if (!exists("PKGBUILD")) {
        assistant("Missing PKGBUILD");
        return 0;
    }
    assistant("Generating .SRCINFO");
    auto info = execute(["makepkg", "--printsrcinfo"]);
    if (info.status != 0) {
        writeln(info.output);
        return info.status;
    }
    auto srcinfo = File(".SRCINFO", "w");
    srcinfo.write(info.output);
    srcinfo.close();
    return 0;
}

int testPkg() {
    if (!exists("PKGBUILD")) {
        assistant("Missing PKGBUILD");
        return 0;
    }

    auto _out = wait(spawnProcess(["makepkg", "-f"]));
    assistant("Testing PKGBUILD");
    if (_out != 0) return _out;
    _out = wait(spawnProcess(["namcap", "-i", "PKGBUILD"]));
    if (_out != 0) return _out;
    assistant("Testing package");
    foreach(string filename; dirEntries(getcwd(), "*.pkg.tar.zst", SpanMode.shallow)) {
        _out = wait(spawnProcess(["namcap", "-i", filename]));
        if (_out != 0) return _out;
    }
    return 0;
}

int initPkg() {
    if (exists(".git") && isDir(".git")) {
        assistant("Git repository already exists");
        return 0;
    }

    auto gitignore = File(".gitignore", "w");
    gitignore.writeln("pkg/");
    gitignore.writeln("src/");
    gitignore.writeln("*.pkg.tar.zst");
    gitignore.writeln("*.tag.gz");
    gitignore.close();

    auto pkgbuild = File("PKGBUILD", "w");
    string maintainerName = read("Maintainer Name");
    string maintainerMail = read("Maintainer Email");
    pkgbuild.writeln("# Maintainer: ", maintainerName, " <", maintainerMail, ">");
    pkgbuild.writeln();
    string pkgName = read("Package Name");
    pkgbuild.writeln("pkgname='", pkgName, "'");
    pkgbuild.writeln("pkgver=", read("Package Version"));
    pkgbuild.writeln("pkgrel=1");
    pkgbuild.writeln("pkgdesc='", read("Package Description"), "'");
    pkgbuild.writeln("arch=('i686' 'x86_64')");
    string url = read("Upstream URL (GitHub Repo without trailing /)");
    pkgbuild.writeln("url='", url, "'");
    pkgbuild.writeln("license=('", read("License"), "')");
    string makedeps = read("Make Dependencies (separated by space)").replace(' ', "' '");
    if (makedeps.length == 0) {
        pkgbuild.writeln("makedepends=()");
    } else {
        pkgbuild.writeln("makedepends=('", makedeps, "')");
    }
    string deps = read("Dependencies (separated by space)").replace(' ', "' '");
    if (deps.length == 0) {
        pkgbuild.writeln("depends=()");
    } else {
        pkgbuild.writeln("depends=('", deps, "')");
    }
    pkgbuild.writeln(`source=("`, "$pkgname-$pkgver.tar.gz::", url ,"/archive/v$pkgver.tar.gz",`")`);
    pkgbuild.writeln("md5sums=('SKIP')");
    pkgbuild.writeln("validpgpkeys=()");
    pkgbuild.writeln();
    pkgbuild.writeln("# Build script");
    pkgbuild.writeln("build() {");
    pkgbuild.writeln(`    cd "${srcdir}/${pkgname}-${pkgver}"`);
    pkgbuild.writeln(`    # REPLACE WITH BUILD COMMANDS`);
    pkgbuild.writeln("}");
    pkgbuild.writeln();
    pkgbuild.writeln("# Package install script");
    pkgbuild.writeln("package() {");
    pkgbuild.writeln(`    cd "${srcdir}/${pkgname}-${pkgver}"`);
    pkgbuild.writeln(`    install -Dm755 "bin/$pkgname" "$pkgdir/usr/bin/$pkgname"`);
    pkgbuild.writeln("}");
    pkgbuild.writeln();
    pkgbuild.close();

    auto _out = wait(spawnProcess(["git", "init"]));
    if (_out != 0) return _out;
    _out = wait(spawnProcess(["git", "remote", "add", "origin", gitPath.replace("@", pkgName)]));
    if (_out != 0) return _out;
    // _out = wait(spawnProcess(["git", "branch", "--set-upstream-to=origin/master", "master"]));
    // write(_out.output);
    // if (_out.status != 0) return _out.status;

    assistant("Successfully created package");

    return 0;
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

void error(string msg) {
    stderr.writeln(msg);
    exit(EXIT_FAILURE);
}

