use strict;
use warnings;
use 5.016;
no if "$]" >= 5.031009, feature => 'indirect';
no if "$]" >= 5.033001, feature => 'multidimensional';
no if "$]" >= 5.033006, feature => 'bareword_filehandles';
use open ':std', ':encoding(UTF-8)'; # force stdin, stdout, stderr into utf8

use Test::More 0.88;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';
use Test::Fatal;
use Test::Deep;
use JSON::Schema::Tiny 'evaluate';
use lib 't/lib';
use Helper;

my @tests = (
  { schema => false, result => false },
  { schema => true, result => true },
  { schema => {}, result => true },
);

foreach my $test (@tests) {
  my $data = 'hello';
  is(
    exception {
      my $result = evaluate($data, $test->{schema});
      cmp_deeply(
        $result,
        {
          valid => $test->{result},
          $test->{result} ? () : (errors => supersetof()),
        },
        'invalid result structure looks correct',
      );

      local $JSON::Schema::Tiny::BOOLEAN_RESULT = 1;
      my $bool_result = evaluate($data, $test->{schema});
      ok(!($bool_result xor $test->{result}), json_sprintf('schema: %s evaluates to: %s', $test->{schema}, $test->{result}));
    },
    undef,
    'no exceptions in evaluate',
  );
}

cmp_deeply(
  evaluate('hello', []),
  {
    valid => false,
    errors => [
      {
        instanceLocation => '',
        keywordLocation => '',
        error => 'invalid schema type: array',
      },
    ],
  },
  'invalid schema type results in error',
);

done_testing;