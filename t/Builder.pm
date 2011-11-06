package t::Builder;

use v5.14.2;
use warnings;
use parent 'Exporter';
use Tweet::ToDelicious::Entry;

our @EXPORT = qw(entry);

sub entry {
    Tweet::ToDelicious::Entry->new(shift)
}

1;
