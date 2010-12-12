package Finance::Card::Discover::Account;

use strict;
use warnings;

use DateTime::Tiny;
use Object::Tiny qw(
    card credit expiration id nickname number type
);

use Finance::Card::Discover::Account::Profile;
use Finance::Card::Discover::Account::SOAN;

sub new {
    my ($class, $data, $num, %params) = @_;

    my ($year, $month) = split '/', $data->{"expiry${num}"}, 2;
    $year += 2000 if 2000 > $year;

    return bless {
        card       => $params{card},
        credit     => $data->{"AccountOpenToBuy${num}"},
        expiration => DateTime::Tiny->new(year => $year, month => $month),
        id         => $data->{"cardsubid${num}"},
        nickname   => $data->{"nickname$num"},
        number     => $data->{"pan${num}"},
        type       => $data->{"cardtype${num}"},
    }, $class;
}

sub profile {
    my ($self) = @_;

    my $data = $self->card->_request(
        cardsubid   => $self->id,
        cardtype    => $self->type,
        msgnumber   => 0,
        profilename => 'billing',
        request     => 'getprofile',
    );
    return unless $data;
    return Finance::Card::Discover::Account::Profile->new(
        $data, account => $self
    );
}

sub soan {
    my ($self) = @_;

    my $data = $self->card->_request(
        cardsubid  => $self->id,
        cardtype   => $self->type,
        clienttype => 'thin',
        cpntype    => 'MA',
        latched    => 'Y',
        msgnumber  => 2,
        request    => 'ocode',

        # TODO: test to see if this setting alters the expiration from the
        # default value. Currently, a user must call or send a message to
        # DiscoverCard to cancel a SOAN.
        validfor   => undef,
    );
    return unless $data;
    return Finance::Card::Discover::Account::SOAN->new(
        $data, account => $self
    );
}


1;

__END__

=head1 NAME

Finance::Card::Discover::Account

=head1 ACCESSORS

=over

=item * card

The associated L<Finance::Card::Discover::Card> object.

=item * credit

The remaining credit for the account.

=item * expiration

The expiration date of the account, as a L<DateTime::Tiny> object.

=item * id

=item * nickname

=item * number

The account number.

=item * type

=back

=head1 METHODS

=head2 profile

Requests profile data for the account and returns
a L<Finance::Card::Discover::Account::Profile> object.

=head2 soan

Requests a new Secure Online Account Number and returns
a L<Finance::Card::Discover::Account::SOAN> object.

=cut
