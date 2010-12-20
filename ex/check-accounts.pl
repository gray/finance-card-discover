#!/usr/bin/env perl
use strict;
use warnings;
use Finance::Card::Discover;

my $card = Finance::Card::Discover->new(
    username => $ENV{DISCOVERCARD_USERNAME},
    password => $ENV{DISCOVERCARD_PASSWORD},
);

for my $account ($card->accounts) {
    my $number     = $account->number;
    my $expiration = $account->expiration;
    print "account: $number $expiration %s\n";

    my $balance = $account->balance;
    print "balance: $balance\n";
    my $profile = $account->profile;

    my @transactions = $account->transactions;

    if (my $soan = $account->soan) {
        my $number = $soan->number;
        my $cid    = $soan->cid;
        print "soan: $number $cid\n";
    }
    else {
        # SOAN request failed, see why.
        croak $account->card->response->dump;
    }

    for my $transaction ($account->soan_transactions) {
        my $date     = $transaction->date;
        my $merchant = $transaction->merchant;
        my $amount   = $transaction->amount;
        printf "transaction: $date $amount $merchant\n";
    }
}
