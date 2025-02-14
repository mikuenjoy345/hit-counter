#!/usr/bin/env perl

use strict;
use warnings;
no warnings qw(redefine); # debug
use 5.010;

use IO::Socket::UNIX;

BEGIN {
	unless (exists $ENV{ COUNTER_SERVER_DEBUG } and $ENV{ COUNTER_SERVER_DEBUG } == 1 ) {
		*debug = sub ($) {};
	}
}

## no critic prototype
sub debug ($) { # prototype; this accepts 1 (one) thing
	say $_[0];
}

$SIG{INT} = sub { die "Caught a sigint, killing myself gracefully" };

my $counter = 0;
my $socket = $ENV{ COUNTER_SERVER_SOCKET };
my $counter_file = $ENV{ COUNTER_NUMBER_FILE };
my $save_frequency = $ENV{ COUNTER_NUMBER_SAVE_FREQUENCY  } # seconds
my $last_save_time = time;

debug "read counter_file '$counter_file'";
open my $fh, '<', $counter_file;
$fh and sysread ($fh, $counter, 20, 0) or debug "'$counter_file' does not exist, but this probably ok";
close $fh;

debug "removing socket '$socket' if existing";
-e $socket and unlink $socket;
my $sock = IO::Socket::UNIX->new(
	Type => SOCK_STREAM,
	Local => $socket,
	Listen => 1,
) or die "Can't open socket: $IO::Socket::UNIX::errstr";
$IO::Socket::UNIX::errstr if 0; # removing this line gets a 'once' warning

debug 'Begin accept() loop';
while (my $conn = $sock->accept()) {
	$conn->recv(my $request, 20);
	debug "Client request: '$request'";

	if ('up' eq $request) {
		debug 'Counter incremented';
		$counter++;
	}
	elsif ('get' eq $request) {
		debug 'get counter';
	}
	elsif ('save' eq $request) {
		debug 'Counter will be saved';
		save_counter();
	}
	elsif ('shutdown' eq $request) {
		debug 'Shutdown recieved';
		last;
	}
	elsif ('ping' eq $request) {
		debug 'Ping received' ;
		print $conn 'pong';
		debug 'pong';
		debug 'Will indicate to connection that we are done talking';
		$conn->shutdown(SHUT_WR);
		next;
	}
	else {
		debug 'Mystery request';
	}

	debug "Reply to client; '$counter'";
	local $SIG{PIPE} = sub { debug 'Some kind of connection issue; unable to send reply' };
	print $conn $counter;
	debug 'Will indicate to connection that we are done talking';
	$conn->shutdown(SHUT_WR);

	if (time - $last_save_time >= $save_frequency) {
		debug "time elapsed, time to save counter";
		save_counter();
		$last_save_time = time;
	}
}

sub save_counter {
	debug "Opening '$counter_file'";
	open my $fh, '>', $counter_file;
	debug "saving current counter; '$counter' to opened file";
	syswrite $fh, $counter, length $counter, 0;
}

END {
	debug 'Closing socket...';
	$sock->close();
	debug 'Removing socket file...';
	unlink $socket;
	debug 'Saving current count...';
	save_counter();
	debug "All done.  Exit program.";
}
