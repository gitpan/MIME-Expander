use strict;
use Test::More tests => 10;
#use Test::More qw(no_plan);

use MIME::Expander::Plugin::ApplicationTar;

sub read_file {
    my $src = shift;
    open IN, "<$src" or die "cannot open $src: $!";
    local $/ = undef;
    my $data = <IN>;
    close IN;
    return \ $data;
}

my $accepts = [qw{
    application/tar
    application/x-tar
    }];

is_deeply( MIME::Expander::Plugin::ApplicationTar->ACCEPT_TYPES,
    $accepts, 'ACCEPT_TYPES via class' );

my $plg = MIME::Expander::Plugin::ApplicationTar->new;
isa_ok( $plg, 'MIME::Expander::Plugin');
can_ok( $plg, 'ACCEPT_TYPES');
is_deeply( $plg->ACCEPT_TYPES,
    $accepts, 'ACCEPT_TYPES via instance' );

# is_acceptable
ok(   $plg->is_acceptable('application/tar'),'is_acceptable application/tar');
ok(   $plg->is_acceptable('application/x-tar'),'application/x-tar');
ok( ! $plg->is_acceptable('application/gnutar'),'not is_acceptable');

# expand
my $input   = read_file('t/untitled.tar');
my $names   = [];
my $sizes   = [];
my $cb = sub {
    my ($contents, $info) = @_;
    push @$names, $info->{filename};
    push @$sizes, length($$contents);
};
is( $plg->expand( $input, $cb ), 2, 'expand returns' );
is_deeply( [sort @$names], ['untitled/untitled.pdf','untitled/untitled.txt'], 'filenames');
is_deeply( [sort @$sizes], [15,7841], 'sizes');
