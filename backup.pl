use strict;
use warnings;
use utf8;
use File::Copy 'copy';
use Email::MIME;
use Email::Sender::Simple qw(sendmail);
use Email::Sender::Transport::SMTP::TLS;
use MIME::Lite;
use Encode qw(encode);

my $times = time();
my ($sec, $min, $hour, $mday, $month, $year, $wday, $stime) = localtime($times);
$month++;
my $datetime = sprintf '%04d%02d%02d%02d%02d%02d', $year + 1900, $month, $mday, $hour, $min, $sec;

# Source file
my $src_file = 'hoge.txt';

# Dst
my $dst_dir = '//fuga\\foo\\' . $datetime;

# Create a date folder to be copied to.
mkdir $dst_dir or warn "Can not create folder: $!";

# Copy
if (copy $src_file, $dst_dir) {
  print "Copied!\n\n";
}
else {
  warn "Not copied: $!";
  &sendMail('Subject here...', "Body here...");
}


sub sendMail {
	my ($send_subject, $send_body) = @_;
	
	my $send_from    = '<FROM>';
	my $send_to      = '<TO>';
	my $send_cc      = '<Cc>';

	my $msg = MIME::Lite->new (
		From => $send_from,
		To => $send_to,
		Cc => $send_cc,
		Subject => encode( 'MIME-Header', $send_subject ),
		Type =>'multipart/mixed'
	);

	$msg->attach (
		Type => 'TEXT',
		Data => Encode::encode( 'utf8', $send_body )
	);
	
	MIME::Lite->send( 'smtp', '<DOMAIN>', Timeout=>60, AuthUser=>'<USER>', AuthPass=>'<PASSWORD>' );
	$msg->send;
}
