use strict;
use warnings;
use 5.016;
no if "$]" >= 5.031009, feature => 'indirect';
no if "$]" >= 5.033001, feature => 'multidimensional';
no if "$]" >= 5.033006, feature => 'bareword_filehandles';
use utf8;
use open ':std', ':encoding(UTF-8)'; # force stdin, stdout, stderr into utf8

use Test::More 0.96;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::Deep;
use JSON::Schema::Tiny 'evaluate';

use lib 't/lib';
use Helper;

my $tests = sub {
  my ($char, $test_substr) = @_;

  cmp_deeply(
    evaluate($char, { pattern => '[a-z]' }),
    {
      valid => false,
      errors => [
        {
          instanceLocation => '',
          keywordLocation => '/pattern',
          error => 'pattern does not match',
        },
      ],
    },
    $test_substr.' LATIN SMALL LETTER E WITH ACUTE does not match the ascii range [a-z]',
  );

  cmp_deeply(
    evaluate($char, { pattern => '\w' }),
    {
      valid => true,
    },
    $test_substr.' LATIN SMALL LETTER E WITH ACUTE does match the "word" character class, because unicode semantics are used for matching',
  );
};

my $letter = "é";
$tests->($letter, 'unchanged');

utf8::upgrade($letter);
$tests->($letter, 'upgraded');

utf8::downgrade($letter);
$tests->($letter, 'downgraded');

done_testing;
