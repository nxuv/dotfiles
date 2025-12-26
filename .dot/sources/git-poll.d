/++ dub.sdl:
name "git_poll"
dependency "sily" version="~>5.0.2"
dependency "sily:term" version="~>5.0.2"
targetType "executable"
targetPath "build/"
+/

module app;

import std.stdio: writef;
import std.process: executeShell;
import std.array: split, join, replace;
import std.format: format;
import std.file: getcwd;
import std.path: dirSeparator;
import std.algorithm.searching: canFind;
import std.algorithm.sorting: sort;
import std.range: array;
import std.conv: to;
import std.getopt: getopt, GetoptResult, config;

import sily.path: buildAbsolutePath, listdir;
import sily.bash;
import sily.getopt;

struct Repo {
    string status;
    string ahead;
    string behind;
    string date;
    string name;
    size_t stamp;
}

Repo[] repos;

void main(string[] args) {
    bool hideEmpty = false;
    bool sortAhead = false;
    bool sortBehind = false;
    bool sortStatus = false;
    bool sortRepo = false;
    bool sortCommit = false;
    bool doFetch = false;
    bool doSubdir = false;

    GetoptResult help = getopt(
        args,
        config.bundling, config.passThrough, config.caseSensitive,
        "hideEmpty|e", "Hides up to date repos", &hideEmpty,
        "ahead|a", "Sorts repos by ahead field", &sortAhead,
        "behind|b", "Sorts repos by behind field", &sortBehind,
        "status|s", "Sorts repos by status field", &sortStatus,
        "repo|r", "Sorts repos by repo field", &sortRepo,
        "commit|c", "Sorts repos by commit field", &sortCommit,
        "fetch|f", "Fetches before polling", &doFetch,
        "subdir|d", "Looks at repos in subdirectories", &doSubdir,
    );

    if (help.helpWanted) {
        printGetopt("git_poll <options>",
            "Options", help.options
        );
        return;
    }


    printHeader();
    string[] dirs;
    if (doSubdir) {
        string[] topdirs = listdir(getcwd(), true, false);
        foreach (dir; topdirs) {
            string[] subdirs = listdir(dir, true, false);
            foreach (sdir; subdirs) {
                dirs ~= dir ~ dirSeparator ~ sdir;
            }
        }
    } else {
        dirs = listdir(getcwd(), true, false);
    }

    foreach (dir; dirs) {
        string path = buildAbsolutePath(getcwd() ~ dirSeparator ~ dir);
        if (!listdir(path).canFind(".git")) continue;
        if (doFetch) gitFetch(path);
        Repo r;
        r.status = getStatusCount(path);
        r.ahead = getAheadCount(path);
        r.behind = getBehindCount(path);
        r.date = getCommitDate(path);
        r.stamp = getCommitTimeStamp(path);
        r.name = dir;
        repos ~= r;
    }

    if (sortCommit) repos = repos.sort!((a, b) => a.stamp > b.stamp).array;
    if (sortAhead) repos = repos.sort!((a, b) => a.ahead.to!int > b.ahead.to!int).array;
    if (sortBehind) repos = repos.sort!((a, b) => a.behind.to!int > b.behind.to!int).array;
    if (sortStatus) repos = repos.sort!((a, b) => a.status.to!int > b.status.to!int).array;
    if (sortRepo) repos = repos.sort!((a, b) => a.name < b.name).array;

    foreach (r; repos) {
        if (hideEmpty && r.ahead == "0" && r.behind == "0" && r.status == "0") continue;
        printLine(r.ahead, r.behind, r.status, r.name, r.date);
    }
}

void printLine(string ahead, string behind, string status, string repo, string commitDate) {
    // align left %-1s
    // align right %1s
    // align by arg %*s
    writef(
        "%s%-5s%s %s%-6s%s %s%-6s%s %s%-26s%s %s%-16s%s\n",
        FG.LT_GREEN, ahead, FRESET.ALL,
        FG.LT_MAGENTA, behind, FRESET.ALL,
        FG.LT_GRAY, status, FRESET.ALL,
        FG.LT_BLUE, repo, FRESET.ALL,
        FG.LT_YELLOW, commitDate, FRESET.ALL,
    );
}

void printHeader() {
    // align left %-1s
    // align right %1s
    // align by arg %*s
    writef(
        "%s%-5s%s %s%-6s%s %s%-6s%s %s%-26s%s %s%-16s%s\n",
        FG.LT_GREEN ~ FORMAT.UNDERLINE, "Ahead", FRESET.ALL,
        FG.LT_MAGENTA ~ FORMAT.UNDERLINE, "Behind", FRESET.ALL,
        FG.LT_GRAY ~ FORMAT.UNDERLINE, "Status", FRESET.ALL,
        FG.LT_BLUE ~ FORMAT.UNDERLINE, "Repo", FRESET.ALL,
        FG.LT_YELLOW ~ FORMAT.UNDERLINE, "Last commit", FRESET.ALL,
    );
}

void gitFetch(string absolutePath) {
    executeShell(format("git -C '%s' fetch", absolutePath));
}

string getStatusCount(string absolutePath) {
    auto res = executeShell(format("git -C '%s' status --porcelain | wc -l", absolutePath));
    if (res.status != 0) return "err";
    return res.output[0..$-1];
}

string getBehindCount(string absolutePath) {
    auto res = executeShell(format("git -C '%s' rev-list --count HEAD..@{u}", absolutePath));
    if (res.status != 0) return "err";
    return res.output[0..$-1];
}

string getAheadCount(string absolutePath) {
    auto res = executeShell(format("git -C '%s' rev-list --count @{u}..HEAD", absolutePath));
    if (res.status != 0) return "err";
    return res.output[0..$-1];
}

string getCommitDate(string absolutePath) {
    auto res = executeShell(format("git -C '%s' show -s --format=%%cd --date=relative", absolutePath));
    if (res.status != 0) return "err";
    return res.output[0..$-1];
}

size_t getCommitTimeStamp(string absolutePath) {
    auto res = executeShell(format("git -C '%s' log -1 --format=%%at", absolutePath));
    if (res.status != 0) return 0;
    return res.output[0..$-1].to!size_t;
}
