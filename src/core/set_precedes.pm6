# This file implements the following set operators:
#   (<+)    precedes (ASCII)
#   ≼       precedes
#   (>+)    succeeds (ASCII)
#   ≽       succeeds

proto sub infix:<<(<+)>>($, $ --> Bool:D) is pure {
    DEPRECATED(
      "set operator {$*INSTEAD // "(<=)"}",
      "",
      "6.d",
      :what("Set operator {$*WHAT // "(<+)"}"),
      :up( 1 + ?$*WHAT )
    );
    {*}
}
multi sub infix:<<(<+)>>(Setty:D \a, QuantHash:D \b --> Bool:D) {
    nqp::if(
      (my $a := a.RAW-HASH),
      nqp::if(
        (my $b := b.RAW-HASH) && nqp::isge_i(nqp::elems($b),nqp::elems($a)),
        nqp::stmts(
          (my $iter := nqp::iterator($a)),
          nqp::while(
            $iter && nqp::existskey($b,nqp::iterkey_s(nqp::shift($iter))),
            nqp::null
          ),
          nqp::p6bool(nqp::isfalse($iter))
        ),
        False
      ),
      True
    )
}
multi sub infix:<<(<+)>>(Mixy:D \a, Baggy:D \b --> Bool:D) {
    nqp::if(
      (my $a := a.RAW-HASH),
      nqp::if(
        (my $b := b.RAW-HASH) && nqp::isge_i(nqp::elems($b),nqp::elems($a)),
        nqp::stmts(
          (my $iter := nqp::iterator($a)),
          nqp::while(
            $iter,
            nqp::if(
              nqp::not_i(nqp::existskey(
                $b,
                (my $key := nqp::iterkey_s(nqp::shift($iter)))
              )) ||
              nqp::getattr(nqp::decont(nqp::atkey($a,$key)),Pair,'$!value')
                > nqp::getattr(nqp::decont(nqp::atkey($b,$key)),Pair,'$!value'),
              (return False)
            )
          ),
          True
        ),
        False
      ),
      True
    )
}
multi sub infix:<<(<+)>>(Baggy:D \a, Baggy:D \b --> Bool:D) {
    nqp::if(
      (my $a := a.RAW-HASH),
      nqp::if(
        (my $b := b.RAW-HASH) && nqp::isge_i(nqp::elems($b),nqp::elems($a)),
        nqp::stmts(
          (my $iter := nqp::iterator($a)),
          nqp::while(
            $iter,
            nqp::if(
              nqp::not_i(nqp::existskey(
                $b,
                (my $key := nqp::iterkey_s(nqp::shift($iter)))
              )) ||
              nqp::isgt_i(
                nqp::getattr(nqp::decont(nqp::atkey($a,$key)),Pair,'$!value'),
                nqp::getattr(nqp::decont(nqp::atkey($b,$key)),Pair,'$!value')
              ),
              (return False)
            )
          ),
          True
        ),
        False
      ),
      True
    )
}
multi sub infix:<<(<+)>>(QuantHash:U $a, QuantHash:U $b --> True ) {}
multi sub infix:<<(<+)>>(QuantHash:U $a, QuantHash:D $b --> True ) {}
multi sub infix:<<(<+)>>(QuantHash:D $a, QuantHash:U $b --> Bool:D ) {
    not $a.elems
}
multi sub infix:<<(<+)>>(QuantHash:D $a, QuantHash:D $b --> Bool:D ) {
    return False if $a.AT-KEY($_) > $b.AT-KEY($_) for $a.keys;
    True
}

multi sub infix:<<(<+)>>(Any $, Failure:D $b) { $b.throw }
multi sub infix:<<(<+)>>(Failure:D $a, Any $) { $a.throw }
multi sub infix:<<(<+)>>(Any $a, Any $b --> Bool:D) {
    nqp::if(
      nqp::istype($a,Mixy) || nqp::istype($b,Mixy),
      infix:<<(<+)>>($a.Mix, $b.Mix),
      infix:<<(<+)>>($a.Bag, $b.Bag)
    )
}

# U+227C PRECEDES OR EQUAL TO
proto sub infix:<≼>(|) is pure {*}
multi sub infix:<≼>($a, $b --> Bool:D) {
    my $*WHAT    = "≼";
    my $*INSTEAD = "⊆";
    infix:<<(<+)>>($a, $b)
}

# $a (>+) $b === $a R(<+) $b
proto sub infix:<<(>+)>>(|) is pure {*}
multi sub infix:<<(>+)>>($a, $b --> Bool:D) {
    my $*WHAT    = "(>+)";
    my $*INSTEAD = "(>=)";
    infix:<<(<+)>>($b, $a)
}

# U+227D SUCCEEDS OR EQUAL TO
proto sub infix:<≽>(|) is pure {*}
multi sub infix:<≽>($a, $b --> Bool:D) {
    my $*WHAT    = "≽";
    my $*INSTEAD = "⊇";
    infix:<<(<+)>>($b, $a)
}

# vim: ft=perl6 expandtab sw=4
