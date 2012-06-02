#!/usr/bin/perl
#
# dbusAMAROK
# Amarok dbus now-playing announce script
# Copyright (C) 2009 Gregor Jehle <gjehle@gmail.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject
# to the following conditions:
# 
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

package AMAROK;

IRC::register ("dbusAMAROK", "1.0", "", "");
IRC::add_command_handler("dbusamarok", "AMAROK::dbus_amarok_handler");

sub dbus_get_string
{
	$meta = shift;
	$entry = shift;

	$pattern = "dict entry\\\( string \"$entry\" variant string \"(.*?)\" \\\)";
	$meta =~ /$pattern/i;
	return $1;
}

sub dbus_amarok_handler {
	$meta = `dbus-send --session --type=method_call --print-reply --dest=org.kde.amarok /Player org.freedesktop.MediaPlayer.GetMetadata`;

	$meta =~ s/\n/ /gm;
	$meta =~ s/(\t+|\s+)/ /g;

	$artist = &dbus_get_string($meta,"artist");
	$title =  &dbus_get_string($meta,"title");
	$title =~ s/_[^_]*_[^_]*_/ - /;
	$url = &dbus_get_string($meta,"location");
	$album = &dbus_get_string($meta,"album");



	if($url =~ /^http:/) {
		$np = "$artist - $title ($album)";
	} else {
		$np = "$artist - $title";
	}

	IRC::command("np: $np");
	return 1;
}

