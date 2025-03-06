#!/usr/bin/env perl
use Mojolicious::Lite -signatures;
use IO::Socket::UNIX;
## no critic (prototypes)

my $counter = 0;
my $number_length = $ENV{ COUNTER_NUMBER_LENGTH };
my $counter_socket = $ENV{ COUNTER_SERVER_SOCKET };
my $timeout = $ENV{ COUNTER_IMAGE_TIMEOUT }; # in seconds, for creating images
my $content_security_policy = $ENV{ CONTENT_SECURITY_POLICY  };
my $temp_dir = $ENV{ COUNTER_TEMP_DIR };
my $image_file = $ENV{ COUNTER_IMAGE_FILE };
my $asset_dir = $ENV{ COUNTER_ASSET_DIR };

app->hook(before_server_start => sub ($server, $app) {
	my $c = IO::Socket::UNIX->new(
		Type => SOCK_STREAM(),
		Peer => $counter_socket,
	) or die "Cannot connect to counter server ('$counter_socket'): $!";
	print $c 'ping';
	$c->shutdown(SHUT_WR);
	$c->recv(my $buff, 12);
	$c->close();
	if ($buff ne 'pong') {
		die "Inapproriate reply from counter server (expected 'pong'); $buff";
	}
	-e '/bin/montage' or die 'ImageMagick not installed? `/bin/montage`';
});

get '/' => sub ($c) {
	update_counter();
	make_image(to_number_length($counter));
	$c->res->headers->header('Content-Security-Policy' => "img-src * $content_security_policy");
	$c->res->headers->header('Server' => 'nginx/1.22.1'); # lie :)
	$c->reply->file("${temp_dir}${image_file}");
};

sub update_counter () {
	my $good = 1;
	my $c = IO::Socket::UNIX->new(
		Type => SOCK_STREAM(),
		Peer => $counter_socket,
	) or do {warn "issue connecting to socket ('$counter_socket'): $!"; $counter = 0; return};
	print $c 'up';
	$c->shutdown(SHUT_WR);
	$c->recv($counter, 12); # future proofing... xxx_xxx_xxx_xxx  billions of visitors!
	$c->close();
}

sub to_number_length ($counter) {
	while (length $counter < $number_length) {
		$counter = "0$counter";
	}
	return $counter;
}

## returns path for image
sub make_image ($counter) {
	state $time_since_last_creation = 0;

	if ($time_since_last_creation + $timeout < time) {
		my @args;
		for my $i (split(//, $counter)) {
			push @args, "${asset_dir}$i.png";
		}
		push @args, qw( -tile ),  "${number_length}x1", qw( -geometry +0+0 -background none -scale 50 );
		my $o = "$temp_dir/$image_file";
		push @args, $o;

		if (! (-w $temp_dir and -d $temp_dir)) {
			mkdir $temp_dir;
		}
		
		# user can refresh the page faster than this can run
		# I guess in theory someone can DOS me just by refreshing the page enough times
		system('/bin/montage', @args); 

		$time_since_last_creation = time;
		return $o;
	}
}

app->start;
