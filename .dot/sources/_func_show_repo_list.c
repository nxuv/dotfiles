/******************************************************************************
 * FILENAME: listrepo.c                                                       *
 * DESCRIPTION:                                                               *
 *                                                                            *
 * Script to parse and output list of "repositories"  in /g (git)             *
 * without checking for if directory is an actual git repository.             *
 *                                                                            *
 * Expected output is a list of "USER/REPO", unless directory                 *
 * contains ".metarepo" file, then it should be "REPO". If                    *
 * directory contains ".nonrepo" then skip it. Additionally                   *
 * skip all the hidden and/or windows-specific directories.                   *
 *                                                                            *
 * AUTHOR: nxuv                                                               *
 * DATE: 23/12/24                                                             *
 ******************************************************************************/

#include "stdio.h"
#include "stdlib.h"
#include "stdint.h"
#include "string.h"
#include "stdbool.h"

#define DISCARD (void)
#define cast(T) (T)

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

#include "dirent.h"
#include "unistd.h"

#define MAX_DIRS 2048
#define MAX_FNAME 256

int list_dir(char *path, char arr_out[MAX_DIRS][MAX_FNAME], size_t *arr_pos) {
    DIR *dir = opendir(path);
    struct dirent *entry;

    if (dir != NULL) {
        while ((entry = readdir(dir)) != NULL) {
            size_t nsize = strlen(entry->d_name);
            if (nsize == 0) continue;
            if (entry->d_type != DT_DIR) continue;
            memcpy(cast(void*) (arr_out[(*arr_pos)++] + 0), entry->d_name, nsize);
        }
    } else {
        perror("Failed to open directory.");
        return -1;
    }
    DISCARD closedir(dir);
    return 0;
}

int filter_dir(char *path, char arr_out[MAX_DIRS][MAX_FNAME], size_t *arr_pos) {
    char   top_dir[MAX_DIRS][MAX_FNAME] = {0};
    size_t top_pos = 0;

    size_t path_size = strlen(path);

    if (list_dir(cast(char*) path, top_dir, &top_pos) != 0) {
        perror("Failed to read directory");
        return -1;
    }

    for (size_t i = 0; i < top_pos; ++i) {
        char   dir_name[MAX_FNAME] = {0};
        size_t dir_size = strlen(top_dir[i]);

        memcpy(dir_name, top_dir[i], dir_size);

        if (dir_name[0] == '.') continue;
        if (dir_name[0] == '$') continue;
        if (dir_name[0] == '\'') continue;
        if (strcmp(dir_name, "System Volume Information") == 0) continue;

        char path_none[MAX_FNAME] = {0};
        memcpy(cast(void*) (path_none + 0), path, path_size);
        memcpy(cast(void*) (path_none + path_size + 1), cast(void*) dir_name, dir_size);
        memcpy(cast(void*) (path_none + path_size + 1 + dir_size), "/.nonrepo", 10);
        path_none[path_size] = '/';
        if (access(path_none, F_OK) == 0) continue;

        memcpy(cast(void*) (arr_out[(*arr_pos)++] + 0), dir_name, dir_size);
    }

    return 0;
}

int find_repos(char *path, char arr_out[MAX_DIRS][MAX_FNAME], size_t *arr_pos) {
    char   user_list[MAX_DIRS][MAX_FNAME] = {0};
    size_t user_pos  = 0;
    size_t root_size = strlen(path);

    if (filter_dir(path, user_list, &user_pos) != 0) {
        perror("Failed to filter users");
        return -1;
    }

    for (size_t i = 0; i < user_pos; ++i) {
        char   dir_name[MAX_FNAME] = {0};
        size_t dir_size = strlen(user_list[i]);

        memset(dir_name, '\0', MAX_FNAME);
        memcpy(dir_name, user_list[i], dir_size);

        char   repo_list[MAX_DIRS][MAX_FNAME] = {0};
        size_t repo_pos = 0;

        char repo_path[MAX_FNAME] = {0};
        memcpy(cast(void*) (repo_path + 0), path, root_size);
        memcpy(cast(void*) (repo_path + root_size + 1), dir_name, dir_size);
        repo_path[root_size] = '/';

        char   path_meta[MAX_FNAME] = {0};
        size_t init_size = strlen(repo_path);
        memcpy(cast(void*) (path_meta + 0), repo_path, init_size);
        memcpy(cast(void*) (path_meta + init_size), "/.metarepo", 11);

        if (access(path_meta, F_OK) == 0) {
            memcpy(cast(void*) (arr_out[(*arr_pos)++] + 0), dir_name, dir_size);
            continue;
        }

        if (filter_dir(repo_path, repo_list, &repo_pos) != 0) {
            perror("Failed to filter repos");
            return -1;
        }

        for (size_t j = 0; j < repo_pos; ++j) {
            char   path_name[MAX_FNAME] = {0};
            size_t repo_size = strlen(repo_list[j]);
            size_t path_size = dir_size + 1 + repo_size;

            memcpy(cast(void*) (path_name + 0), dir_name, dir_size);
            memcpy(cast(void*) (path_name + dir_size + 1), repo_list[j], repo_size);
            path_name[dir_size] = '/';

            memcpy(cast(void*) (arr_out[(*arr_pos)++] + 0), path_name, path_size);
        }
    }

    return 0;
}

int main() {
    char   repo_list[MAX_DIRS][MAX_FNAME] = {0};
    size_t repo_pos = 0;

    if (find_repos(cast(char*) "/g", repo_list, &repo_pos) != 0) {
        perror("Failed to find repos");
        return -1;
    }

    for (size_t i = 0; i < repo_pos; ++i) {
        puts(repo_list[i]);
    }

    return 0;
}

