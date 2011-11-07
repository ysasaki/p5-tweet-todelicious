package Tweet::ToDelicious::Entry;

use v5.14;
use utf8;
use warnings;
use List::MoreUtils qw(uniq);
use AnyEvent;
use AnyEvent::HTTP;
use Log::Minimal;
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
    @urls = $self->_expand_uri(
        uniq( map $_->{expanded_url}, @{ $self->{entities}->{urls} } ) );
    return @urls;
}

sub _expand_uri {
    my $self = shift;
    my @uri  = @_;
    return () if @uri == 0;

    my $cv = AE::cv;
    my @expaned;
    for my $uri (@uri) {
        $cv->begin;
        http_head $uri, sub {
            my ( $data, $headers ) = @_;
            if ( $headers->{Status} ~~ [ 200, 301, 302, 304 ] ) {
                debugf( "expand: %s => %s", $uri, $headers->{URL} );
                push @expaned, $headers->{URL};
            }
            else {
                debugf( "Status != 200. headers: %s", ddf($headers) );
                push @expaned, $headers->{Redirect}->[0]->{URL}
                    if exists $headers->{Redirect};
            }
            $cv->end;
        };
    }
    $cv->recv;
    return @expaned;
}

sub tags {
    my $self = shift;
    my @tags = map $_->{text}, @{ $self->{entities}->{hashtags} };
    my $text = $self->text;
    my (@from_text) = $text =~ m/\[([^\]]+?)\]/g;
    return uniq( @tags, @from_text, $self->{favorited} ? 'favorite' : () );
}

sub posts {
    my $self = shift;
    my @urls = $self->urls;
    my @posts;
    if ( @urls > 0 ) {
        my $tags = join ',', $self->tags, 'via:tweet2delicious';
        my $text = $self->text;
        @posts = map {
            +{  url         => $_,
                tags        => $tags,
                description => $text,
                replace     => 1
                }
        } @urls;
    }
    return @posts;
}
1;
