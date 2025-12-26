/// <reference types="node" />
import * as stream from "stream";
import * as fsPath from "path";
import type { IncomingHttpHeaders } from "node:http";
export declare function setEntryScriptPath(scriptPath: string): void;
/**
 * Echos error message to stdout and then exits with the specified exit code (defaults to 1)
 * @param error The error message string or Error object to print
 * @param exitCode
 */
declare const _error: (error: string | Error, exitCode?: number) => void;
declare const _usage: {
    (message: string, printAndExitIfHelpArgumentSpecified?: boolean): void;
    /**
     * Prints the usage message and then exists with the specified exit code (defaults to 1)
     * @param additionalMessage
     * @param exitCode
     */
    printAndExit: (exitCode?: number, additionalMessage?: string | undefined) => void;
};
declare type Arguments = Array<string> & {
    /**
     * Returns args as array (that can be destructured) or throws an error and exits if less than number of arguments specified were supplied
     * @param argCount
     * @param errorMessage
     * @param exitCode
     * @returns
     */
    assertCount(argCount: number, errorMessage?: string, exitCode?: number): string[];
} & {
    [argName: string]: string | boolean;
};
export declare function setupArguments(passedInArguments: Array<string>): void;
declare type Environment = {
    [envVar: string]: string;
} & {
    /**
     * Returns environment variable value or throws an error and exits if it is undefined
     * @param argCount
     * @param errorMessage
     * @param exitCode
     * @returns
     */
    assert(envVarName: string, throwIfEmpty?: boolean, exitCode?: number): string;
    assert(envVarName: string[], throwIfEmpty?: boolean, exitCode?: number): string[];
};
declare const _env: Environment;
declare const _stdin: () => string;
declare const _exit: (exitCode?: number) => void;
/**
 * Prints content to stdout with a trailing newline. Multiple arguments can be passed, with the first used as the primary message and all additional used as substitution values
 * @param content
 * @param optionalArgs
 */
declare const _echo: {
    (content: string | Error, ...optionalArgs: any[]): void;
    /**
     * Prints yellow colored content to stdout with a trailing newline. Multiple arguments can be passed, with the first used as the primary message and all additional used as substitution values
     * @param content
     * @param optionalArgs
     */
    yellow(content: string | Error, ...optionalArgs: any[]): void;
    /**
     * Alias for `echo.yellow`.
     */
    warn: (content: string | Error, ...optionalArgs: any[]) => void;
    /**
     * Prints green colored content to stdout with a trailing newline. Multiple arguments can be passed, with the first used as the primary message and all additional used as substitution values
     * @param content
     * @param optionalArgs
     */
    green(content: string | Error, ...optionalArgs: any[]): void;
    /**
     * Alias for `echo.green`.
     */
    success: (content: string | Error, ...optionalArgs: any[]) => void;
    /**
     * Prints red colored content to stdout with a trailing newline. Multiple arguments can be passed, with the first used as the primary message and all additional used as substitution values
     * @param content
     * @param optionalArgs
     */
    red(content: string | Error, ...optionalArgs: any[]): void;
    /**
     * Alias for `echo.red`.
     */
    error: (content: string | Error, ...optionalArgs: any[]) => void;
    /**
     * Prints blue colored content to stdout with a trailing newline. Multiple arguments can be passed, with the first used as the primary message and all additional used as substitution values
     * @param content
     * @param optionalArgs
     */
    blue(content: string | Error, ...optionalArgs: any[]): void;
    /**
     * Alias for `echo.blue`.
     */
    notice: (content: string | Error, ...optionalArgs: any[]) => void;
};
/**
 * Prints content *without* a trailing newline.
 * @param content
 * @returns
 */
declare const _printf: (content: string) => boolean;
/**
 * Prints a text prompt, waits for user input, and returns the input.
 * @param prompt A string or function that prompts the user for input.
 *   If a string is provided, echo() will be called with it.
 *   If a function is provided, the function will be called before prompting the user
 
*    Examples:
       const name = prompt("What's your name?");
       const name = prompt(() => { printf("What's your name? "); });
       const name = prompt(() => { echo.yellow("What's your name? "); });
});
 */
declare const _prompt: (prompt: string | (() => void)) => string;
/**
 * Sleeps synchronously for the specified number of milliseconds.  Will not block the event loop.
 * Note: On Windows, sleep duration is only supported for seconds (1000ms) so the specified number of milliseconds will be rounded up to the nearest second.
 * @param ms
 */
declare const _sleep: (ms: number) => void;
export interface ICommandOptions {
    /**
     * If true will capture stdout from command and return it.  If false, stdout will not be captured but only printed to the console.
     */
    captureStdout?: boolean;
    /**
     * If true will echo the command itself before running it
     */
    echoCommand?: boolean;
    /**
     * If set to true, will not throw if the command returns a non-zero exit code
     */
    noThrow?: boolean;
    /**
     *  In milliseconds the maximum amount of time the process is allowed to run
     */
    timeout?: number;
    shell?: string | boolean | undefined;
    maxBuffer?: number;
}
export declare class CommandError extends Error {
    command: string;
    stdout: string;
    stderr: string;
    status: number;
    constructor(command: string, stdout: string, stderr: string, status: number);
}
/**
 * Runs a command and returns the stdout
 * @param command The command to run.
 * @param options
 * @returns
 */
declare const _$: (command: string, options?: ICommandOptions) => string;
declare type IExecCommandOptions = Omit<ICommandOptions, "echoStdout">;
/**
 * Runs a command and echos its stdout as it executes.  Stdout from the command is not captured.
 * @param command The command to run
 * @param options
 * @returns void
 */
declare const _exec: (command: string, options?: IExecCommandOptions) => void;
export declare type HttpMethod = "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
export declare type HttpData = object | stream.Readable | null;
export interface IHttpRawRequestOptions {
    protocol: string;
    hostname: string;
    port: number;
    path: string;
    url: string;
    method: string;
    headers?: NodeJS.Dict<string | string[] | number>;
    /**
     * The number of milliseconds of inactivity before a socket is presumed to have timed out.
     */
    timeout?: number;
}
export declare type IHttpRequestOptions = Pick<Partial<IHttpRawRequestOptions>, "headers" | "timeout"> & {
    /**
     * If set to true, will not throw if the response status code is not 2xx
     */
    noThrow?: boolean;
    /** If set to true, will not include response body in error message */
    omitResponseBodyInErrorMessage?: boolean;
    noFollowRedirects?: boolean;
    saveResponseToFile?: string;
};
export interface IHttpResponse<T> {
    data: T;
    body: string | null;
    headers: IncomingHttpHeaders;
    statusCode: number | undefined;
    statusMessage: string | undefined;
    requestOptions: IHttpRawRequestOptions;
}
export declare class HttpRequestError<T> extends Error {
    request: IHttpRawRequestOptions;
    response: IHttpResponse<T> | null;
    constructor(message: string, request: IHttpRawRequestOptions, options: IHttpRequestOptions, response?: IHttpResponse<T> | null);
    get data(): T | undefined;
    get body(): string | null | undefined;
    get statusCode(): number | undefined;
    get statusMessage(): string | undefined;
}
/**
 * Makes an asynchronous HTTP request and returns the response.   Will reject with an error if the response status code is not 2xx.
 * @param method
 * @param url
 * @param data
 * @param headers
 * @returns IHttpResponse<T>
 */
declare const _http: {
    <T>(method: HttpMethod, url: string, data?: HttpData, options?: IHttpRequestOptions): Promise<IHttpResponse<T>>;
    /**
     * Makes a GET HTTP request and returns the response data.  Will throw an error if the response status code is not 2xx.
     * @param url
     * @param headers
     * @returns
     */
    get<T_1>(url: string, headers?: {
        [name: string]: string;
    }): Promise<T_1>;
    /**
     * Makes a POST HTTP request and returns the response data.  Will throw an error if the response status code is not 2xx.
     * @param url
     * @param headers
     * @returns
     */
    post<T_2>(url: string, data: HttpData, headers?: {
        [name: string]: string;
    }): Promise<T_2>;
    /**
     * Makes a PUT HTTP request and returns the response data.  Will throw an error if the response status code is not 2xx.
     * @param url
     * @param headers
     * @returns
     */
    put<T_3>(url: string, data: HttpData, headers?: {
        [name: string]: string;
    }): Promise<T_3>;
    /**
     * Makes a PATCH HTTP request and returns the response data.  Will throw an error if the response status code is not 2xx.
     * @param url
     * @param headers
     * @returns
     */
    patch<T_4>(url: string, data: HttpData, headers?: {
        [name: string]: string;
    }): Promise<T_4>;
    /**
     * Makes a DELETE HTTP request and returns the response data.  Will throw an error if the response status code is not 2xx.
     * @param url
     * @param headers
     * @returns
     */
    delete<T_5>(url: string, data: HttpData, headers?: {
        [name: string]: string;
    }): Promise<T_5>;
    /**
     * Makes a POST HTTP request and uploads a file.  Will throw an error if the response status code is not 2xx.
     * @param url
     * @param sourceFilePath
     * @param contentType The media type of the file being uploaded (e.g. "image/png", "application/pdf", "text/plain", etc.)
     * @param headers
     * @returns
     */
    upload<T_6>(url: string, sourceFilePath: string, contentType: string, headers?: {
        [name: string]: string;
    }): Promise<T_6>;
    /**
     * Makes a GET HTTP request and saves the response to a file.
     * Will throw an error if the response status code is not 2xx.
     * @param url
     * @param filePath
     * @param headers
     * @returns
     */
    download<T_7>(url: string, destinationFilePath: string, headers?: {
        [name: string]: string;
    }): Promise<IHttpResponse<T_7>>;
};
/**
 * Returns `true` if the path exists, `false` otherwise.
 * @param path
 * @returns
 */
declare const _exists: (path: string) => boolean;
/**
 * Returns `true` if the path exists and it is a directory, `false` otherwise.
 * @param path
 * @returns
 */
declare const _dirExists: (path: string) => boolean;
/**
 * Create a directory if it does not exist.
 * @param path
 * @param recursive Whether parent directories should also be created. Defaults to true.
 */
declare const _mkDir: (path: string, recursive?: boolean) => void;
/**
 * Removes a file or directory if it exists.
 * @param path
 * @param recursive Whether child directories should also be removed. Defaults to true.
 */
declare const _rm: (path: string, recursive?: boolean) => void;
/**
 * Returns the list of files in a directory path
 * @param path
 * @param recursive Whether files from child directories should be included.  Defaults to true.
 * @returns
 */
declare const _readdir: (path: string, recursive?: boolean) => string[];
/**
 * Reads a file and returns its contents.
 * @param path
 * @param encoding
 * @returns
 */
declare const _readFile: (path: string, encoding?: BufferEncoding) => string;
/**
 * Writes contents to a file, replacing the file if it exists.
 * @param path
 * @param contents
 * @param encoding
 */
declare const _writeFile: (path: string, contents: string, encoding?: BufferEncoding) => void;
declare global {
    var __filename: string;
    var __dirname: string;
    var dirName: typeof fsPath.dirname;
    var dirname: typeof fsPath.dirname;
    var exit: typeof _exit;
    var error: typeof _error;
    var echo: typeof _echo;
    var printf: typeof _printf;
    var prompt: typeof _prompt;
    var read: typeof _prompt;
    var sleep: typeof _sleep;
    var $: typeof _$;
    var exec: typeof _exec;
    var http: typeof _http;
    var cd: typeof process.chdir;
    var exists: typeof _exists;
    var dirExists: typeof _dirExists;
    var mkDir: typeof _mkDir;
    var mkdir: typeof _mkDir;
    var rm: typeof _rm;
    var rmDir: typeof _rm;
    var rmdir: typeof _rm;
    var readDir: typeof _readdir;
    var readdir: typeof _readdir;
    var readFile: typeof _readFile;
    var cat: typeof _readFile;
    var writeFile: typeof _writeFile;
    var env: typeof _env;
    var stdin: typeof _stdin;
    var args: Arguments;
    var $0: string;
    var $1: string;
    var $2: string;
    var $3: string;
    var $4: string;
    var $5: string;
    var $6: string;
    var $7: string;
    var $8: string;
    var $9: string;
    var $10: string;
    var usage: typeof _usage;
}
export {};
