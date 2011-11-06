package Tweet::ToDelicious::Entry;

use v5.14.2;
use utf8;
use warnings;
use List::MoreUtils qw(uniq);
use Carp qw(croak);
use Class::Accessor::Lite (
    new => 1,
    ro  => [qw(text in_reply_to_screen_name)],
);

sub retweeted { exists $_[0]->{retweeted_status} ? 1 : 0 }
sub screen_name { $_[0]->{user}->{screen_name} }

sub urls {
    my $self = shift;
    state @urls;
    @urls = map $_->{expanded_url}, @{ $self->{entities}->{urls} };
    return @urls;
}

sub tags {
    my $self = shift;
    my @tags = map $_->{text}, @{ $self->{entities}->{hashtags} };
    my $text = $self->text;
    my (@from_text) = $text =~ m/\[([^\]]+?)\]/g;
    return uniq(@tags, @from_text, $self->{favorited} ? 'favorite' : ());
}

sub posts {
    my $self = shift;
    my @urls = $self->urls;
    my @posts;
    if ( @urls > 0 ) {
        my $tags = join ',', $self->tags, 'via:tweet2delicious';
        my $text = $self->text;
        @posts = map {
            +{ url => $_, tags => $tags, description => $text, replace => 1 }
        } @urls;
    }
    return @posts;
}
1;
