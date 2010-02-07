# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 2' to 'tests => last_test_to_print';

use Test::More tests => 2;
BEGIN { use_ok('Net::LibNIDS') };
use strict;
use Socket qw(inet_ntoa);

###my $fail = 0;
#foreach my $constname (qw(
#	NIDS_CLOSE NIDS_DATA NIDS_EXITING NIDS_JUST_EST NIDS_MAJOR NIDS_MINOR
#	NIDS_RESET NIDS_TIMED_OUT)) {
#  print Net::LibNIDS->$constname() . "\n";


#}
exit;

Net::LibNIDS::param::set_device('en1');

print Net::LibNIDS::init() ."\n";

Net::LibNIDS::tcp_callback(\&collector );
Net::LibNIDS::run();

sub collector {
  my $args = shift;
  print $args->state_string . " is called \n";
  if($args->state == Net::LibNIDS::NIDS_JUST_EST()) {
    if($args->server_ip eq '194.236.70.68') {
      $args->server->collect_on();
      $args->client->collect_on();
    }
    print $args->client_ip . ":" . $args->client_port . " -> " . $args->server_ip . ":" . $args->server_port;
    return;
  }
  if($args->server->count_new) {
    print $args->lastpacket_sec . "." . $args->lastpacket_usec . " -- ";
  
    print "GOT FROM CLIENT:\n" . $args->server->data();
  } elsif($args->client->count_new) {
    print $args->lastpacket_sec . "." . $args->lastpacket_usec . " -- ";
    print $args->server->curr_ts . "\n";
    print "GOT FROM SERVER:\n" . $args->client->data();
  } elsif($args->state == Net::LibNIDS::NIDS_CLOSE()) {
    exit;
  }
  print "\n***************\n";
}
