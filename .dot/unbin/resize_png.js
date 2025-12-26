#!/usr/bin/env -S NODE_NO_WARNINGS=1 npx jsh
/// <reference path="/home/nxuv/.local/share/definitions/js/jsh.d.ts" />
/// https://github.com/bradymholt/jsh

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
    let out = $(`eza -1a --color=${color ? "always" : "never"} --no-symlinks --git-ignore --group-directories-first -F=always ` + dir);
    // echo(out);
    return out.split("\n");
}

const curr_dir = process.cwd();

let files = eza(curr_dir);

for (let file of files) {
    if (!file.endsWith(".png")) continue;
    exec(`convert  ${curr_dir}/${file} -resize 64x64 ${curr_dir}/${file}`);
}

// for (let user of userlist) {
//     if (user == "") continue;
//     if (!user.endsWith("/")) continue;
//     if (user.startsWith(".")) continue;
//     if (exists(proj_dir + "/" + user + ".nonrepo")) continue;
//     if (exists(proj_dir + "/" + user + ".metarepo")) {
//         repolist.push(user.substring(0, user.length - 1));
//         continue;
//     }
//     let repos = eza(proj_dir + "/" + user);
//     // console.log(repos);
//     if (repos.length == 0 || (repos.length == 1 && repos[0] == "")) {
//         repolist.push(user.substring(0, user.length - 1));
//         continue;
//     }
//     for (let repo of repos) {
//         if (exists(proj_dir + "/" + user + "/" + repo + ".nonrepo")) continue;
//         repolist.push(user.substring(0, user.length - 1) + "/" + repo.substring(0, repo.length - 1));
//     }
// }

// // console.log(repolist);

// // exec(`cd "${proj_dir}/$(gum filter --indicator="-" --header="Cloned Repositories" --limit=1 --select-if-one  "${repolist.join(`" "`)}")"`, {echoCommand:false});
// exec(`echo ${proj_dir}/$(echo '${repolist.join(`\n`)}' | fzf --prompt="Select repo > " --layout=reverse --height=35%)`, {echoCommand:false});

