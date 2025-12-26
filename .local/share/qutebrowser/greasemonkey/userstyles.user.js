// ==UserScript==
// @name         Userstyles.org downloader
// @namespace    https://ericmedina024.com/
// @version      0.1
// @description  d!
// @author       Eric Medina (ericmedina024)
// @match        https://userstyles.org/*
// @icon         https://www.google.com/s2/favicons?sz=64&domain=userstyles.org
// @grant        none
// ==/UserScript==

async function downloadCurrentSyle() {
    let loc = window.location.href;
    let styleID = loc.split("/")[4];
    let resp = await fetch(`https://userstyles.org/styles/chrome/${styleID}.json`);
    let json = await resp.json();
    let style = json.sections[0].code.replaceAll("\r", "");
}
