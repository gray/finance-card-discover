use strict;
use warnings;
use ExtUtils::MakeMaker;

my @prereq;
unless (eval { require IO::Socket::SSL; 1 }) {
    push @prereq, 'Crypt::SSLeay' => 0;
}

my %conf = (
    NAME           => 'Finance::Card::Discover',
    AUTHOR         => 'gray <gray@cpan.org>',
    LICENSE        => 'perl',
    VERSION_FROM   => 'lib/Finance/Card/Discover.pm',
    ABSTRACT_FROM  => 'lib/Finance/Card/Discover.pm',
    PREREQ_PM => {
        'DateTime::Tiny' => 0,
        'LWP::UserAgent' => 0,
        'Object::Tiny'   => 0,
        'URI'            => 1.36,
        @prereq
    },
    BUILD_REQUIRES => {
        'Test::More' => 0.82,
    },
    META_MERGE     => {
        resources  => {
            repository => 'http://github.com/gray/finance-card-discover',
        },
    },
    dist           => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean          => { FILES => 'Finance-Card-Discover-*' },
);

my $eumm_version =  do {
    no warnings 'numeric';
    eval $ExtUtils::MakeMaker::VERSION;
};
delete $conf{META_MERGE} if $eumm_version < 6.46;
$conf{PREREQ_PM} = {
    %{ $conf{PREREQ_PM} || {} }, %{ delete $conf{BUILD_REQUIRES} },
} if ($conf{BUILD_REQUIRES} and $eumm_version < 6.5503);

WriteMakefile(%conf);


sub MY::postamble {
    return <<"    MAKE_FRAG";
authortest:
\t\$(MAKE) -e \$(TEST_TYPE) TEST_FILES="xt/*.t"
    MAKE_FRAG
}

sub MY::dist_test {
    my $self = shift;
    return $self->MM::dist_test . <<"    MAKE_FRAG";
\tcd \$(DISTVNAME) && \$(MAKE) authortest \$(PASTHRU)
    MAKE_FRAG
}
