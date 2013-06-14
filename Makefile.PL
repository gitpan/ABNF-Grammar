use 5.008008;

use strict;
use warnings;

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'ABNF::Grammar',
    AUTHOR            => 'Arseny Krasikov <nyaapa@cpan.com>',
    LICENSE           => 'perl_5',
    VERSION_FROM      => 'lib/ABNF/Grammar.pm', # finds $VERSION
    ABSTRACT_FROM     => 'lib/ABNF/Grammar.pm',
    PREREQ_PM         => {
        'Parse::ABNF'         => 0.05,
        'Storable'            => 2.39,
		'Method::Signatures ' => 20130505,
		'Readonly'            => 1.03,
    },
	META_MERGE   => {
		requires  => { perl => '5.014' },
		resources => {
			license     => 'http://dev.perl.org/licenses/',
			repository  => 'https://bitbucket.org/afiskon/pl-vkmp3'
		},
	}
);
