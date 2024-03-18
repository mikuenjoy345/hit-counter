#!/usr/bin/env perl
use Mojolicious::Lite -signatures;

my $counter_file = 'counter.numb';
my $counter = 0;
my $number_length = 6;

app->hook(before_server_start => sub ($server, $app) {
	if (! (-e $counter_file)) {
		write_counter();
	}
	read_counter();
	
	-e '/bin/montage' or die 'ImageMagick not installed? `/bin/montage`';
});

get '/' => sub ($c) {
	read_counter(); # hypnotoad or w/e may run on threads or something. awkward.
	make_image(to_number_length($counter++));
	$c->res->headers->header('Content-Security-Policy' => 'img-src * artemis.venus.place');
	$c->res->headers->header('Server' => 'nginx/1.22.1'); # lie :)
	$c->reply->file('tmp/counter.png');
	write_counter();
};

sub write_counter () {
	open my $fh, '>', $counter_file;
	syswrite $fh, $counter, length $counter, 0;
	close $fh;
}

sub read_counter () {
	open my $fh, '<', $counter_file;
	sysread $fh, $counter, 20; # 20 bytes to read which is more than enough for a counter
	close $fh;
}

sub to_number_length ($counter) {
	while (length $counter lt 6) {
		$counter = "0$counter";
	}
	return $counter;
}

## returns path for image
sub make_image ($counter) {

	my @args;
	for my $i (split(//, $counter)) {
		push @args, "asset/$i.png";
	}
	push @args, qw( -tile 6x1 -geometry +0+0 -background none -scale 50 );
	my $o = 'tmp/counter.png';
	push @args, $o;

	if (! (-w 'tmp/' and -d 'tmp/')) {
		mkdir 'tmp';
	}
	
	# user can refresh the page faster than this can run
	# I guess in theory someone can DOS me just by refreshing the page enough times
	system('/bin/montage', @args); 

	return $o;
}

app->start;
