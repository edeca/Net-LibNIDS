
use Test::More tests => 8;
BEGIN { use_ok('Net::LibNIDS') };
use strict;


# This test builds on 4.t by seeing whether nids_discard is working properly.
Net::LibNIDS::param::set_filename("t/http-test.dump");

is(Net::LibNIDS::param::get_filename(), "t/http-test.dump", "Filename is set");
ok(Net::LibNIDS::init(), "Init it...");

my $i = 0;
Net::LibNIDS::tcp_callback(\&collector );
Net::LibNIDS::run();


sub collector {
    my $stream = shift;
    
    if($stream->state == Net::LibNIDS::NIDS_JUST_EST()) {
	$stream->server->collect_on;
    } 
    elsif($stream->state == Net::LibNIDS::NIDS_DATA()) {
	my $half_stream;
	if($stream->client->count_new) {
	    $half_stream = $stream->client;
	} else {
	    $half_stream = $stream->server;
	}
	if($i == 0) {
	    like($half_stream->data, qr{GET / HTTP/1.1}, "Inital GET");
		# Default libnids behaviour is to remove all new data from the buffer.  Instead
		# we'll just remove the GET.
		$stream->discard(3);
	} elsif($i == 1) {
        # Data buffer should now start like above minus GET.
	    like($half_stream->data, qr{^ / HTTP/1.1}, "Initial request minus GET");

		# But should also contain the second request.
	    like($half_stream->data, qr{GET /apache_pb.gif HTTP/1.1}, "Fetch the image");
	    like($half_stream->data, qr{it;q=0.62, ja-jp;q=0.59, en;q=0.97, es-es;q=0.52, es;q=0.48, da-dk;q=0.45, da;q=0.41, fi-fi;q=0.38}, "Insane ordering languages :)");
	} elsif($i == 2) {
	    fail("Shouldn't be called back 3 times with data");
	}
	$i++;
    }
    elsif($stream->state == Net::LibNIDS::NIDS_CLOSE()) {
	pass("Closing the connection");
    }
}
