import std.stdio    : writeln, write, writef;
import std.array    : popFront, popBack, split, join;
import std.process  : execute, spawnShell;
import std.algorithm: count, canFind;
import std.conv     : to;
import std.string   : startsWith, endsWith;
import std.format   : format;
import std.file     : exists, readText;
import std.path     : absolutePath;
import std.regex    : regex, match;

import std.math     : trunc;

import core.stdc.stdlib: getenv;

struct FileSys {
    string name;
    string size;
    string used;
    string aval;
    ubyte perc;
    string mnt;
}

string[] ignoreMount = ["/c", "/boot/efi", "/boot"];

string getPercCol(float val) {
    if (val <= 50)  return ("\033[92m");
    if (val <= 75)  return ("\033[93m");
    if (val <= 100) return ("\033[91m");
                    return ("\033[95m");
}

void main() {
    string user      = getenv("USER").to!string;
    string lastLogin = execute(["last", "-1R", user]).output[0..$-2];
    lastLogin        = lastLogin.split('\n')[0].split(' ').nonEmpty()[2..6].join(' ');

    FileSys[] filesys = [];
    string[] fstmp    = execute(["df", "-lh"]).output[0..$-1].split('\n')[1..$];
    foreach (fs; fstmp) {
        if (!fs.startsWith("/dev/")) continue;
        string[] fsys = fs.split(' ').nonEmpty();
        if (ignoreMount.canFind(fsys[5])) continue;
        filesys ~= FileSys(fsys[0], fsys[1], fsys[2], fsys[3], fsys[4][0..$-1].to!ubyte, fsys[5]);
    }

    string kern     = execute(["uname" , "-r"]).output[0..$-1];
    string uptime   = execute(["uptime", "-p"]).output[3..$-1];
    string hostname = execute(["uname" , "-n"]).output[0..$-1];

    string os_art = "";
    string art_file = getenv("HOME").to!string ~ "/.dot/data/fetch-" ~ hostname ~ ".txt";
    if (exists(art_file)) {
        import std.file: readText;

        os_art = readText(art_file);
    }

    writeln("Welcome back, \033[93m", user, "\033[0m.");
    if (os_art != "") writeln("\033[91m", "\033[1m", os_art[0..$-1], "\033[0m");

    int tw = terminalWidth();

    writeln();

    bool isKernelOutdated = false;
    size_t pkgInstall = 0;
    size_t pkgUpdate = 0;
    size_t pkgRemove = 0;
    size_t pkgHold = 0;
    if (exists(getenv("HOME").to!string ~ "/.local/share/cron/xbps-update-list.txt")) {
        string[] updateList =
            readText(getenv("HOME").to!string ~ "/.local/share/cron/xbps-update-list.txt").split('\n');
        foreach (string updateLine; updateList) {
            if (updateLine.length == 0) continue;
            switch (updateLine.split(' ')[1]) {
                case "install": ++pkgInstall; break;
                case "update" : ++pkgUpdate; break;
                case "remove" : ++pkgRemove; break;
                case "hold"   : ++pkgHold;   break;
                default: writeln("Unknown update specifier: ", updateLine);
            }
            if (match(updateLine, regex(r"linux\d+\.\d+-.+? update"))) isKernelOutdated = true;
        }
    }

    string kernText = kern;
    if (isKernelOutdated) {
        kernText = "\033[91m" ~ kern ~ "\033[0m";
    }

    writeln("System");
    writeln("  Kernel......: ", kernText);
    // linux6.12-6.12.63_1 update x86_64 https://mirror.yandex.ru/mirrors/voidlinux/current 170440499 164564194
    // linux6.12-headers-6.12.63_1 update x86_64 https://mirror.yandex.ru/mirrors/voidlinux/current 60230917 13058050

    if (exists(getenv("HOME").to!string ~ "/.local/share/cron/xbps-update-list.txt")) {
        // writeln("  Updates.....: ",
        //         count(readText(getenv("HOME").to!string ~ "/.local/share/cron/xbps-update-list.txt"), '\n'));
        // writeln("  Updates.....: ", "+1, -0, ~2");
        write(  "  Updates.....: ");
        if (pkgInstall == 0 && pkgUpdate == 0 && pkgRemove == 0 && pkgHold == 0) write("\033[92m0\033[0m");
        if (pkgInstall != 0) write("\033[94m+", pkgInstall, "\033[0m ");
        if (pkgUpdate  != 0) write("\033[92m~", pkgUpdate , "\033[0m ");
        if (pkgRemove  != 0) write("\033[91m-", pkgRemove , "\033[0m ");
        if (pkgHold    != 0) write("\033[90m=", pkgHold   , "\033[0m ");
        writeln();
        writeln();
    }

    writeln("  Login.......: ", lastLogin);
    writeln("  Uptime......: ", uptime);
    write(  "  Processes...: ");
    string[] procinfo = execute(["ps", "-eo", "user,pid,uid"]).output[0..$-1].split('\n')[1..$];
    size_t[string] userproc;
    size_t totalproc = 0;
    foreach (string proc; procinfo) {
        string puser = proc.split(' ')[0];
        size_t puid = proc.split(' ').nonEmpty()[2].to!size_t;
        if (puid > 0 && puid < 1000) continue;
        if (!(puser in userproc)) userproc[puser] = 0;
        userproc[puser] ++;
        totalproc++;
    }

    foreach (string puser; userproc.keys) {
        write("\033[92m", userproc[puser], "\033[0m", " (");
        write(puser == user ? "\033[93m" ~ puser ~ "\033[0m" : puser, "), ");
    }
    writeln("\033[92m", totalproc, "\033[0m", " (total)");

    writeln();
    writeln(
            "  CPU.........: ",
            execute(["lscpu", "-e=MODELNAME"]).output[0..$-1].split('\n')[1],
            " \033[92m", execute(["lscpu", "-e=CORE"]).output[0..$-1].split('\n')[1..$].length,
            "\033[0m@\033[92m", execute(["lscpu", "-e=MAXMHZ"]).output[0..$-1].split('\n')[1].split('.')[0],
            "\033[0mMHz"
            );
    write(  "  Memory......: ");
    string[] meminfo = readText("/proc/meminfo")[0..$-1].split('\n');
    size_t memTotal;
    size_t memFree;
    size_t memAvail;
    size_t gibibyte = 1_048_576;
    foreach (string line; meminfo) {
        string[] parts = line.split(' ').nonEmpty();
        if (parts[0] == "MemTotal:")     memTotal = parts[1].to!size_t;
        if (parts[0] == "MemFree:")      memFree  = parts[1].to!size_t;
        if (parts[0] == "MemAvailable:") memAvail = parts[1].to!size_t;
    }
    writeln(
            getPercCol(100f - cast(float) memFree / memTotal * 100f), trunc(10f * cast(float) (memTotal - memFree) / gibibyte) / 10f, "Gi\033[0m used, ",
            getPercCol(100f - cast(float) memAvail / memTotal * 100f), trunc(10f * cast(float) memAvail / gibibyte            ) / 10f, "Gi\033[0m avail, ",
            "\033[92m", trunc(10f * cast(float) memTotal / gibibyte            ) / 10f, "Gi\033[0m total"
            );
    writeln();

    write(  "  Net devices.: ");
    string[] netinterface = execute(["tcpdump", "--list-interfaces"]).output[0..$-1].split('\n');
    foreach (string inter; netinterface) {
        string name = inter.split(".")[1];
        if (name.endsWith("[none]")) continue;
        if (name.startsWith("any ")) continue;
        if (name.startsWith("lo ")) continue;
        write(name.split(" ")[0], " ");
    }
    writeln();

    write(  "  Local IP....: ");
    string[] localip = execute(["ip", "addr", "show"]).output[0..$-1].split('\n');
    foreach (string line; localip) {
        // writeln(line);
        if (!line.startsWith("    inet ")) continue;
        string ip = line.split(" ").nonEmpty()[1];
        if (ip.startsWith("127.0.0.1")) continue;
        write(ip, " ");
    }
    writeln();

    // writeln("  External IP.: ", execute(["curl", "ipinfo.io/ip", "--silent"]).output);
    // writeln("  External IP.: ", readText(getenv("HOME").to!string ~ "/.local/share/cron/external-ip.txt"));

    writeln();

    writeln("  IOCTL.......: ", tw >= 80 ? tw == 80 ? "\033[93m" : "\033[92m" : "\033[91m" ,tw, " columns", "\033[0m");
    // TODO: some special view type for ~80 columns

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
        writef("  %s%*-s%s%7s%7s%6d%%   %s\n",
                fs.name, 15 + wdiff - fs.name.length, "", fs.size, fs.used, fs.aval, fs.perc, fs.mnt);
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

    string svdir = getenv("SVDIR").to!string;
    if (svdir.length == 0) return;
    string[] services = listdir(svdir, true, false);
    if (services.length == 0) return;

    writeln();
    writeln("Services");

    for (size_t i = 0; i < services.length; ++i) {
        const size_t break_on = 3;
        string serv = services[i];
        writef("%s %-9s", i % break_on == 0 ? " " : "", serv ~ ":");
        string servstat = execute(["sv", "status", serv]).output[0..$-3];
        if (servstat.startsWith("run: ")) {
            write("\033[92m[ up ]\033[0m");
        } else {
            write("\033[91m[down]\033[0m");
        }
        if ((i + 1) % break_on != 0 && i + 1 != services.length) write(" |");
        if ((i + 1) >= break_on && (i + 1) % break_on == 0) writeln();
    }

    writeln();

    writeln("\0");
}

/// Returns copy of array without empty (!= "") elements
string[] nonEmpty(string[] arr) {
    string[] arrOut = [];
    foreach (e; arr) {
        if (e != "") {
            arrOut ~= e;
        }
    }
    return arrOut;
}

/// Returns posix terminal width
int terminalWidth() {
    import core.sys.posix.sys.ioctl: winsize, ioctl, TIOCGWINSZ;
    winsize w;
    ioctl(0, TIOCGWINSZ, &w);
    return w.ws_col;
}

/**
Fills and returns new array with values `val` up to `size`
Params:
  val  = Values to fill with
  size = Amount of pos to fill
Returns: Filled array
*/
T[] repeat(T)(T val, size_t size){
    T[] arr = new T[](size);

    for (int i = 0; i < size; i ++) {
        arr[i] = val;
    }

    return arr;
}

/**
Returns array of files/dirs from path
Params:
  path = Path to dir
Returns:
 */
string[] listdir(string path, bool listDirs = true, bool listFiles = true) {
    import std.algorithm;
    import std.array;
    import std.file;
    import std.path;

    path = absolutePath(path);
    if (!exists(path) || !isDir(path)) return [];

    return std.file.dirEntries(path, SpanMode.shallow)
        .filter!(a => listFiles ? true : a.isFile || listDirs ? true : a.isDir)
        .map!((return a) => baseName(a.name))
        .array;
}
