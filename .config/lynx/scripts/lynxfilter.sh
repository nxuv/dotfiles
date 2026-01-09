#! /usr/bin/gnu/bash

#### lynxfilter.sh ####

# ***
# *** CONFIGURATION
# ***

# export all variable setting 
set -a

############# Section you need to change ###################
# I (dd) had to fully specify these two, maybe a bug in 2.8.2
# make them point to your own lynx binary and config file
LYNX=/usr/local/bin/lynx
LYNX_FLAGS="-cfg=/home/nxuv/.config/lynx/lynx.cfg"

# flag for the filter itself
# tablin is a simple script that does "java Linearize $*"
# (it's provided with the tablin source archive)
FILTER=/u/www47/0/w3c/danield/tmp/Tablin/tablin
FILTER_FLAGS=
# where you put the Tablin java classes root
CLASSPATH=/u/www47/0/w3c/danield/tmp/Tablin
# if you need a local version of java, like I do
PATH=/u/tarantula/0/w3c/ylafon/jdk1.1.7A/bin/:$PATH
############# End section you need to change ###################



############# DOCUMENTATION ###################################
# This script can be used within lynx, in a CGI-like environment,
# to run a given filter program on a given URL document and display
# the output instead of the original. 
# This filter must read HTML text from stdin and produces HTML text on stdout.
#
# A child lynx process is used to retrieve the HTML document (one
# could use wget or libwww-perl instead).  No temporary files needed.
#

# Required:
# o Lynx on a Unix system, configured and compiled with LYNCGI_LINKS
#   support (only tested with 2.8.2)
# o Bourne shell for the script (only tested with bash)
# o A working binary of the filter you want to use (this script is
#   tailored for stdin/stdout-like filters)
# o sed (optional: Perl)
#
#
# TEST:
# Instructions for use with a test filter called 'aafilter':
# o Put the line "sed s/a/aa/g" into a file called 'aafilter'
#    somewhere on your system (this doubles all 'a' in its input)
#   chmod +x on this file (for unix user)
#   Put location of this executable on the line below that starts
#   with FILTER=
# o Change other paths and flags in configuration section below
#   as needed.
# o Make sure Lynx is compiled with LYNXCGI support.  Make lynxfilter.sh 
#   is executable with chmod.  Put it in a location where your lynx.cfg
#   allows lynxcgi scripts.  (Read the relevant comments in lynx.cfg
#   if you are not sure, search for CGI.)
# o Define the following environment variables *outside of lynx*,
#   before starting lynx.  Putting them in lynx.cfg *does not work*.
#      export xhttp_proxy='lynxcgi://localhost/PATH/TO/lynxfilter.sh?/'
#   (Note the extra ?/ at the end)
#
# Usage:
# o When you view a Page in lynx that you want to run through the filter,
#   - press 'G' (note capital) to start editing current document's URL
#   - prefix URL with an x, so that "http:" becomes "xhttp:", and
#     press ENTER.
#   In other words, the 4 key sequence 'G', Ctrl-A, 'x', ENTER.
#   - you should see the same page with 'aa' instead of 'a' everywhere.
#
# Debug:
#   Note that you may get an empty page if the filter fails to produce
#   anything but error messages.
# o Test whether you can access the following URL with Lynx:
#    <lynxcgi://localhost/PATH/TO/lynxfilter.sh?/xxhttp://lynx.browser.org>
#   Of course, change PATH/TO, to wherever you put this script.
# o When you also want to see the messages from the filter together with
#   the rendered document, use xx instead of one x.  In other words, define
#      xxhttp_proxy='lynxcgi://localhost/PATH/TO/lynxfilter.sh?/'
#   and then use the five keys 'G', Ctrl-A, 'x', 'x', ENTER.
#   Note that messages are intermixed with the filtered document,
#   so the combination fed to lynx see is most likely invalid HTML;
#   lynx may complain about it or produce strange rendering sometimes.
#
# Tips:
# o If enabled below with ALLOW_FILTER_PARAM_FLAGS, additional flags can
#   be passed to the filter by appending ";opt<=some_flags>" to the x-URL.
#   Use '+' characters for spaces, for example
#   For example "xhttp://some.server/something.html;opt=-e+-utf8".
# o Settings for no_proxy (from lynx.cfg or environment) still apply
#   for our fake lynxcgi proxy, so beware.  For example xfile_proxy
#   will not work for xfile://localhost/ if localhost is listed in
#   no_proxy.
# o If you use a (real) proxy, you should export the relevant variables
#   to this script, i.e. add LYNXCGI_ENVIRONMENT:http_proxy etc.
# o You may want to create a separate lynx.cfg file for the child lynx
#   process (see LYNX_FLAGS below) and take out unnecessary options.
#   Setting GLOBAL_MAILCAP and PERSONAL_MAILCAP to /dev/null should
#   make the child lynx start up faster, especially if you have lots
#   of tests in the mailcap files.
# o Add equivalent variables xftp_proxy, xxftp_proxy etc. if you want,
#   or even xfile_proxy, xxfile_proxy for local files.



# *** Any non-empty value means YES for boolean settings.

# Should we use perl?
USE_PERL=YES
# Preserve HTTP headers, needs perl, ignored if USE_PERL is unset.
USE_MIME_HEADER=YES
PERL=perl
SED=sed
ALLOW_FILTER_PARAM_FLAGS=YES    # look for filter options in URL param
DEBUG=	# Set this to get a lot of debugging info instead of rendered doc
straceprefix='/usr/bin/strace -o strace.log' # if you have strace, for DEBUG
traceflags='-trace -tlog'	# for the child lynx process, with DEBUG

# ***
# *** end of configuration
# ***
 


if [ "$DEBUG" ]; then
	echo "content-type: text/plain"
	echo
	set -vx
#	/usr/sbin/lsof -p $$	# if you have it...
	debugflags="$traceflags"
	prefix="$straceprefix"
fi

   echo "content-type: text/plain"
   echo ""
   echo "aaaaaaaaaaaaaaaa"
   echo
   exit 0
# if [ ! -x "$LYNX" -o ! -x "$FILTER" ]; then
#    echo "content-type: text/plain"
#    echo
#    echo "$LYNX or $FILTER not found, or cannot be executed."
#    exit
# fi

if [ "$USE_MIME_HEADER" ]; then
   if [ "${QUERY_STRING#/xhttp}" = "$QUERY_STRING" -a \
	"${QUERY_STRING#/xxhttp}" = "$QUERY_STRING" ]; then
      USE_MIME_HEADER=""	# -mime_header works only for http URLs
   fi
fi

# It's finally time to look at the URL...
if [ "${QUERY_STRING#/xx}" = "$QUERY_STRING" ]; then
   IGNORE_STDERR=YES	# if QUERY_STRING does not start with "/xx"
   real_url="${QUERY_STRING#/x}"
else
   IGNORE_STDERR=""	# QUERY_STRING should start with "/xx"
   real_url="${QUERY_STRING#/xx}"
fi

if [ "$ALLOW_FILTER_PARAM_FLAGS" ]; then
   if [ "${QUERY_STRING%;opt=*}" != "$QUERY_STRING" ]; then
	FILTER_PARAM_FLAGS="${QUERY_STRING##*;opt=}"
	FILTER_PARAM_FLAGS="${FILTER_PARAM_FLAGS//+/ }"
	real_url="${real_url%;opt=*}"
   fi
fi

if [ "$USE_MIME_HEADER" ]; then
   lynxmainflag="-mime_header"
else
   echo "content-type: text/html"
   echo
   lynxmainflag="-source"
fi

FILTERCOMMAND="$FILTER $FILTER_FLAGS $FILTER_PARAM_FLAGS"

if [ "$USE_PERL" ]; then
    if [ "$USE_MIME_HEADER" ];then
      PERL_COMMANDS='$|=1;
         while (<>) {
            if (($. ==  1 && (/^HTTP/))../^\s*$/) {print $_;next;}
            if (!$first++) {
               open(P,"|'$FILTERCOMMAND'") || die "could not start the filter";
               select P;$|=1;
            }
         print P;
         }
         close P or die "could not close pipe"'
   else		# USE_PERL but not MIME_HEDER, not very useful
      PERL_COMMANDS='$|=1;
         while (<>) {
            if (!$first++) {
               open(P,"|'$FILTERCOMMAND'") || die "could not start the filter";
               select P;$|=1;
            }
         print P;
         }
         close P or die "could not close pipe"'
   fi
fi

LYNXCOMMAND="$prefix $LYNX $real_url $LYNX_FLAGS $lynxmainflag $debugflags"

if [ "$USE_PERL" ]; then
   if [ "$IGNORE_STDERR" ]; then
      $LYNXCOMMAND </dev/null \
      | $PERL -e "$PERL_COMMANDS" 2>/dev/null
   else		# intermix stderr with output
      $LYNXCOMMAND </dev/null \
      | $PERL -e "$PERL_COMMANDS" 3>&2 2>&1 1>&3 \
      | $SED -e 's/\&/\&amp;/g' \
             -e 's/</\&lt;/g' \
             -e 's/^\(.*\)$/<PRE>filter: <EM>\1\
<\/EM><\/PRE>/'
   fi
else		# not USE_PERL
   if [ "$IGNORE_STDERR" ]; then
      $LYNXCOMMAND \
      | $FILTERCOMMAND 2>/dev/null
   else		# intermix stderr with output
      $LYNXCOMMAND \
      | $FILTERCOMMAND 3>&2 2>&1 1>&3 \
      | $SED -e 's/\&/\&amp;/g' \
             -e 's/</\&lt;/g' \
             -e 's/^\(.*\)$/<PRE>filter: <EM>\1\
<\/EM><\/PRE>/'
   fi
fi

