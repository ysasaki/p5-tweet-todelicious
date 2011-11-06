#!perl
use v5.14;
use warnings;
use Config::Any;
use File::Spec::Functions qw(catfile);
use File::Basename qw(dirname);
use Tweet::ToDelicious;

my $filename = 'config.yaml';
my $cfg      = Config::Any->load_files(
    {   files   => [ catfile( dirname(__FILE__) ), $filename ],
        use_ext => 1
    }
);

Tweet::ToDelicious->new( $cfg->[0]->{$filename} )->run;

__END__

=head1 NAME

t2delicious.pl - Links in your tweet to delicious.

=head1 SYNOPSIS

  carton exec -- perl ./bin/t2delicious.pl

=head1 CONFIG

Copy config.yaml.sample to config.yaml. And write your config.

=head1 AUTHOR

Yoshihiro Sasaki, E<lt>ysasaki at cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Yoshihiro Sasaki

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
