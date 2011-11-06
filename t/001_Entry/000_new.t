use v5.14;
use warnings;
use Test::More;

BEGIN { use_ok 'Tweet::ToDelicious::Entry' }

subtest 'new_ok' => sub {
    new_ok 'Tweet::ToDelicious::Entry', [ {} ];
};

done_testing;
