#!/usr/bin/env perl
use strict;
use warnings;
use Finance::Card::Discover;

my $card = Finance::Card::Discover->new(
    username => $ENV{DISCOVERCARD_USERNAME},
    password => $ENV{DISCOVERCARD_PASSWORD},
    debug    => $ENV{FINANCE_DISCOVER_CARD_DEBUG},
);

for my $account ($card->accounts) {
    if (my $soan = $account->soan) {
        printf "soan: %s %s for account %s\n", $soan->number, $soan->cid,
            $account->number;
    }
    else {
        # SOAN request failed, see why.
        die $account->card->response->dump;
    }
}

die $card->response->dump unless $card->response->is_success;
