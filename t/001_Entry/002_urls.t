use v5.14;
use warnings;
use Test::More;
use Test::TCP;
use AnyEvent;
use AnyEvent::Socket;
use t::Builder;

subtest 'urls' => sub {
    my $tweet = {
        'entities' => {
            'user_mentions' => [],
            'hashtags'      => [],
            'urls'          => [
                {   'display_url'  => 'google.com',
                    'expanded_url' => 'http://www.google.co.jp/',
                    'url'          => 'http://t.co/tYSEO8de',
                    'indices'      => [ 5, 25 ]
                },
                {   'display_url'  => 'yahoo.com',
                    'expanded_url' => 'http://www.yahoo.com/',
                    'url'          => 'http://t.co/rtd3JeP5',
                    'indices'      => [ 26, 46 ]
                }
            ]
        },
    };
    my $entry = entry($tweet);
    my @urls  = $entry->urls;
    is_deeply \@urls,
        [ 'http://www.google.co.jp/', 'http://www.yahoo.com/', ];
};

subtest 'expand' => sub {
    my $port  = empty_port();
    my $cv    = AE::cv;
    my $guard = tcp_server '127.0.0.1', $port, sub {
        my ($fh)        = @_;
        my @data        = <$fh>;
        my ($path_info) = $data[0] =~ m{^HEAD (/[^\s]*).+};
        print $fh <<EOM;
HTTP/1.1 301 Moved Permanently
Location: http://127.0.0.1:$port/redirected
Connection: close
Content-Type: text/html; charset=iso-8859-1

EOM
        $cv->send;
    };
    my $t;
    $t = AE::timer 3, 0, sub {
        $cv->send;
        undef $t;
    };

    my $tweet = {
        'entities' => {
            'urls' => [ { 'expanded_url' => "http://127.0.0.1:$port/" }, ]
        },
    };
    my $entry = entry($tweet);
    my @urls  = $entry->urls;
    $cv->recv;
    is_deeply \@urls, ["http://127.0.0.1:$port/redirected"];
};
done_testing;
