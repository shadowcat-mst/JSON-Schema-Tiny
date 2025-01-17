use strict;
use warnings;
no if "$]" >= 5.031009, feature => 'indirect';
no if "$]" >= 5.033001, feature => 'multidimensional';
no if "$]" >= 5.033006, feature => 'bareword_filehandles';
use open ':std', ':encoding(UTF-8)'; # force stdin, stdout, stderr into utf8

use Test::More 0.96;
use Test::Fatal;
use Test::Deep;
use Storable 'dclone';
use JSON::Schema::Tiny 'evaluate';
use lib 't/lib';
use Helper;

subtest 'local JSON pointer' => sub {
  cmp_deeply(
    evaluate(true, { '$defs' => { true => true }, '$ref' => '#/$defs/true' }),
    { valid => true },
    'can follow local $ref to a true schema',
  );

  cmp_deeply(
    evaluate(true, { '$defs' => { false => false }, '$ref' => '#/$defs/false' }),
    {
      valid => false,
      errors => [
        {
          error => 'subschema is false',
          instanceLocation => '',
          keywordLocation => '/$ref',
          absoluteKeywordLocation => '#/$defs/false',
        },
      ],
    },
    'can follow local $ref to a false schema',
  );

  is(
    exception {
      my $result = evaluate(true, { '$ref' => '#/$defs/nowhere' });
      like(
        $result->{errors}[0]{error},
        qr{^EXCEPTION: unable to find resource \#/\$defs/nowhere},
        'got error for unresolvable ref',
      );
    },
    undef,
    'no exception',
  );
};

subtest 'fragment with URI-escaped and JSON Pointer-escaped characters' => sub {
  cmp_deeply(
    evaluate(
      1,
      {
        '$defs' => { 'foo-bar-tilde~-slash/-braces{}-def' => true },
        '$ref' => '#/$defs/foo-bar-tilde~0-slash~1-braces%7B%7D-def',
      },
    ),
    { valid => true },
    'can follow $ref with escaped components',
  );
};

subtest 'local anchor' => sub {
  local $TODO = '$anchor is not yet supported';
  fail;
};

done_testing;
