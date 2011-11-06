use v5.14;
use warnings;
use Test::More;
use t::Builder;

subtest 'can_ok' => sub {
    my $entry = entry( {} );
    can_ok $entry, $_ for qw/posts text retweeted screen_name
        in_reply_to_screen_name urls tags posts/;
};

subtest 'text' => sub {
    my $entry = entry( { text => 'example' } );
    is $entry->text, 'example';
};

subtest 'retweeted ok' => sub {
    my $entry = entry( { retweeted_status => {} } );
    ok $entry->retweeted;
};

subtest 'retweeted not ok' => sub {
    my $entry = entry( {} );
    ok !$entry->retweeted;
};

subtest 'screen_name' => sub {
    my $entry = entry( { user => { screen_name => 'example' } } );
    is $entry->screen_name, 'example';
};

subtest 'in_reply_to_screen_name' => sub {
    my $entry = entry( { in_reply_to_screen_name => 'example' } );
    is $entry->in_reply_to_screen_name, 'example';
};

done_testing;
