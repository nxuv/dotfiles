#!/bin/perl

# Example ~/.config/elinks/hooks.pl
#
# Copyleft by Russ Rowan (See the file "COPYING" for details.)
#
# To get documentation for this file:
#   pod2html hooks.pl > hooks.html && elinks hooks.html
# or
#   perldoc hooks.pl

=head1 NAME

hooks.pl -- Perl hooks for the ELinks text WWW browser

=head1 DESCRIPTION

This file contains the Perl hooks for the ELinks text WWW browser.

These hooks change the browser's behavior in various ways.  They allow
shortcuts to be used in the Goto URL dialog, modifying the source of a page,
proxy handling, and other things such as displaying a fortune at exit.

=cut
use 5.040;

use strict;
use warnings;
use diagnostics;

=head1 CONFIGURATION FILE

This hooks file reads its configuration from I<~/.config/elinks/config.pl>.
The following is an example of the configuration file:

	bork:       yep       # BORKify Google?
	collapse:   okay      # Collapse all XBEL bookmark folders on exit?
	email:                # Set to show one's own bugs with the "bug" prefix.
	external:   wget      # Send the current URL to this application.
	fortune:    elinks    # *fortune*, *elinks* tip, or *none* on quit?
	googlebeta: hell no   # I miss DejaNews...
	gotosearch: why not   # Anything not a URL in the Goto URL dialog...
	ipv6:       sure      # IPV4 or 6 address blocks with "ip" prefix?
	language:   english   # "bf nl en" still works, but now "bf nl" does too
	news:       msnbc     # Agency to use for "news" and "n" prefixes
	search:     elgoog    # Engine for (search|find|www|web|s|f|go) prefixes
	usenet:     google    # *google* or *standard* view for news:// URLs
	weather:    cnn       # Server for "weather" and "w" prefixes

	# news:    bbc, msnbc, cnn, fox, google, yahoo, reuters, eff, wired,
	#          slashdot, newsforge, usnews, newsci, discover, sciam
	# search:  elgoog, google, yahoo, ask jeeves, a9, altavista, msn, dmoz,
	#          dogpile, mamma, webcrawler, netscape, lycos, hotbot, excite
	# weather: weather underground, google, yahoo, cnn, accuweather,
	#          ask jeeves

I<Developer's usage>: The function I<loadrc()> takes a preference name as its
single argument and returns either an empty string if it is not specified,
I<yes> for a true value (even if specified like I<sure> or I<why not>), I<no>
for a false value (even if like I<nah>, I<off> or I<0>), or the lowercased
preference value (like I<cnn> for C<weather: CNN>).

=cut
sub pre_format_html_hook {
	my $url = shift;
	my $html = shift;
	my $content_type = shift;


=item Slashdot Sanitation

Kills Slashdot's Advertisements.  (This one is disabled due to weird behavior
with fragments.)

=cut
	# /. sanitation
	if ($url =~ 'slashdot\.org') {
	#	$html =~ s/^<!-- Advertisement code. -->.*<!-- end ad code -->$//sm;
	#	$html =~ s/<iframe.*><\/iframe>//g;
	#	$html =~ s/<B>Advertisement<\/B>//;
	}


=item Obvious Google Tips Annihilator

Kills some irritating Google tips.

=cut
	# yes, I heard you the first time
	if ($url =~ 'google\.com') {
		$html =~ s/Teep: In must broosers yuoo cun joost heet zee retoorn key insteed ooff cleecking oon zee seerch boottun\. Bork bork bork!//;
		$html =~ s/Tip:<\/font> Save time by hitting the return key instead of clicking on "search"/<\/font>/;
	}


=item SourceForge AdSmasher

Wipes out SourceForge's Ads.

=cut
	# SourceForge ad smasher
	if ($url =~ 'sourceforge\.net') {
		$html =~ s/<!-- AD POSITION \d+ -->.*?<!-- END AD POSITION \d+ -->//smg;
		$html =~ s/<b>&nbsp\;&nbsp\;&nbsp\;Site Sponsors<\/b>//g;
	}


=item Gmail's Experience

Gmail has obviously never met ELinks...

=cut
	# Gmail has obviously never met ELinks
	if ($url =~ 'gmail\.google\.com') {
		$html =~ s/^<b>For a better Gmail experience, use a.+?Learn more<\/a><\/b>$//sm;
	}


=item Source readability improvements

Rewrites some evil characters to entities and vice versa.  These will be
disabled until such time as pre_format_html_hook only gets called for
content-type:text/html.

=cut
	# demoronizer
	# if ($content_type =~ 'text/html') {
	# 	$html =~ s/Ñ/\&mdash;/g;
	# 	$html =~ s/\&#252/ü/g;
	# 	$html =~ s/\&#039(?!;)/'/g;
	# 	$html =~ s/]\n>$//gsm;
	# 	$html =~ s/%5B/[/g;
	# 	$html =~ s/%5D/]/g;
	# 	$html =~ s/%20/ /g;
	# 	$html =~ s/%2F/\//g;
	# 	$html =~ s/%23/#/g;
	# }

    # $html = "IT WERKEZ";

    # $html =~ s/(\<.+?) style\=["'].+?["'](.+?\>)/$1$2/g;

	# if ($content_type =~ 'text/html') {
        # ain't working for some reason
        # IT WERKS!!!!!!!!!!!
        $html = $html =~ s/\s*style=(["']).*?\1//gir;
        # $html = $html =~ s/\s*class=(["']).*?\1//gir;
        # $html = $html =~ s/\s*href=(["']).*?\1//gir;
        # $html = $html =~ s/a/E/gr;
        # $html = $html =~ s/o/U/gr;
        # $html = $html =~ s/e/I/gr;
        # $html = $html =~ s/y/EI/gr;
        # $html = $html =~ s/i/EE/gr;
    # }


	return $html;
}

sub isurl {
	my ($url) = @_;
	return 'false' if not $url;
	opendir(my $DIR, '.');
	my @files = readdir($DIR);
	closedir($DIR);
	foreach my $file (@files) {
		return 'true' if $url eq $file;
	}
	return 'true' if $url =~ /^(\/|~)/;
	return 'true' if $url =~ /([0-9]{1,3}\.){3}[0-9]{1,3}($|\/|\?|:[0-9]{1,5})/;
	return 'true' if $url =~ /^((::|)[[:xdigit:]]{1,4}(:|::|)){1,8}($|\/|\?|:[0-9]{1,5})/ and $url =~ /:/;
	if (     $url =~ /^(([a-zA-Z]{3,}(|4|6):\/\/|(www|ftp)\.)|)[a-zA-Z0-9]+/
		and ($url =~ /[a-zA-Z0-9-]+\.(com|org|net|edu|gov|int|mil)($|\/|\?|:[0-9]{1,5})/
		or   $url =~ /[a-zA-Z0-9-]+\.(biz|info|name|pro|aero|coop|museum)($|\/|\?|:[0-9]{1,5})/
		or   $url =~ /[a-zA-Z0-9-]+\.[a-zA-Z]{2}($|\/|\?|:[0-9]{1,5})/)) {
		return 'true';
	}
	return 'true' if $url =~ /^about:/;

	return 'false';
}



# vim: ts=4 sw=4 sts=0 nowrap
