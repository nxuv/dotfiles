#!/usr/bin/env -S NODE_NO_WARNINGS=1 npx jsh
/// <reference path="/home/al1-ce/.dotfiles/nvdefs/js/jsh.d.ts" />
/// https://github.com/bradymholt/jsh

// const text = readFile(env["HOME"] + "/.dotfiles/remind");
// const lines = text.split("\n");
//
// for (let i = 0; i < lines.length - 1; ++i) {
//     const line = lines[i];
//     if (line.startsWith("#")) {
//         echo("\x1b[2m\x1b[4m" + line + "\x1b[0m");
//     } else {
//         echo(line);
//     }
// }

echo.gray = function (content) { echo("\x1b[37m%s\x1b[0m", content); }

function join_array(arr, sep) {
    let str = "";
    for (let i = 0; i < arr.length; ++i) {
        if (i != 0) str += sep;
        str += arr[i];
    }
    return str;
}

function eza(dir, color = false) {
    let out = $(`eza -1a --color=${color ? "always" : "never"} --no-symlinks --git-ignore -D -F=always ` + dir);
    // echo(out);
    return out.split("\n");
}

const proj_dir = "/g/";
let userlist = eza(proj_dir);
let repolist = [];

for (let user of userlist) {
    if (user == "") continue;
    if (!user.endsWith("/")) continue;
    if (user.startsWith(".")) continue;
    if (user.startsWith("$")) continue;
    if (user.startsWith("'")) continue;
    if (exists(proj_dir + "/" + user + ".nonrepo")) continue;
    if (exists(proj_dir + "/" + user + ".metarepo")) {
        repolist.push(user.substring(0, user.length - 1));
        continue;
    }
    let repos = eza(proj_dir + "/" + user);
    // console.log(repos);
    if (repos.length == 0 || (repos.length == 1 && repos[0] == "")) {
        repolist.push(user.substring(0, user.length - 1));
        continue;
    }
    for (let repo of repos) {
        if (exists(proj_dir + "/" + user + "/" + repo + ".nonrepo")) continue;
        repolist.push(user.substring(0, user.length - 1) + "/" + repo.substring(0, repo.length - 1));
    }
}

// console.log(repolist);

// exec(`cd "${proj_dir}/$(gum filter --indicator="-" --header="Cloned Repositories" --limit=1 --select-if-one  "${repolist.join(`" "`)}")"`, {echoCommand:false});

exec(`echo ${proj_dir}/$(echo '${repolist.join(`\n`)}' | fzf --prompt="Select repo > " --layout=reverse --height=35%)`, {echoCommand:false});

