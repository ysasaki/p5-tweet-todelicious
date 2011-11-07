package Tweet::ToDelicious;

use v5.14;
use utf8;
use warnings;
use Getopt::Long;
use Net::Delicious;
use AnyEvent;
use AnyEvent::Twitter::Stream;
use Coro;
use Coro::LWP;
use Log::Minimal;
use Tweet::ToDelicious::Entry;

our $VERSION = '0.04';

sub new {
    my $class = shift;
    my $cfg   = shift;
    my $self  = bless { config => $cfg }, $class;
    return $self;
}

sub run {
    my $self = shift;

    local $| = 1;
    local $Log::Minimal::AUTODUMP = 1;

    while(1) {
        my $delicious = $self->delicious;
        my $myname    = $self->{config}->{t2delicious}->{twitter_screen_name};
        my $cv        = AE::cv;
        my $listener  = AnyEvent::Twitter::Stream->new(
            %{ $self->{config}->{twitter} },
            method     => 'userstream',
            on_connect => sub {
                infof( 'Start watching twitter:@%s, delicious:%s',
                    $myname, $self->{config}->{delicious}->{user} );
            },
            on_tweet => sub {
                my $tweet = shift;
                my $entry = Tweet::ToDelicious::Entry->new($tweet);
                debugf( "screen_name: %s", $entry->screen_name || '__NONE__' );
                if (   ( $entry->screen_name ~~ $myname )
                    or ( $entry->in_reply_to_screen_name ~~ $myname ) )
                {
                    my @posts = $entry->posts;
                    debugf( "posts: %s", \@posts );
                    if ( @posts > 0 ) {
                        my @coro;
                        for my $post (@posts) {
                            push @coro, async {
                                my $done = $delicious->add_post($post);
                                infof("Post %s done", $post->{url}) if $done;
                            };
                        }
                        $_->join for @coro;
                    }
                }
              },
            on_error => sub {
                critf(shift);
                $cv->send;
            },
        );
        $cv->recv;
    }
}

sub delicious {
    my $self = shift;
    state $delicious = Net::Delicious->new( $self->{config}->{delicious} );
    return $delicious;
}

1;
__END__

=head1 NAME

Tweet::ToDelicious - Links in your tweet to delicious.

=head1 SYNOPSIS

  use Tweet::ToDelicious;
  Tweet::ToDelicious->new($cfg)->run;

=head1 DESCRIPTION

use L<t2delicious.pl> instead of this module directly.

=head1 DEPENDENCIES

L<Config::Any>, L<YAML::XS>, L<Net::Delicious>, L<LWP::Protocol::https>, L<Coro>, L<AnyEvent::Twitter::Stream>, L<Net::OAuth>, L<Net::SSLeay>, L<List::MoreUtils>, L<Log::Minimal>

=head1 SEE ALSO

L<AnyEvent::Twitter::Stream>, L<Net::Delicious>

=head1 AUTHOR

Yoshihiro Sasaki, E<lt>ysasaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Yoshihiro Sasaki

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
