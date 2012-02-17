#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use Google::API::Client;
use OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;

use constant MAX_PAGE_SIZE => 50;


my $client = Google::API::Client->new;
my $service = $client->build('adsense', 'v1');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";
my $access_token = get_or_restore_token($dat_file, $auth_driver);

# Call adclients.list
my $res = $service->adclients->list(
    body => {
        maxResults => MAX_PAGE_SIZE
    })->execute({ auth_driver => $auth_driver });
for my $ad_client (@{$res->{items}}) {
    say "Ad client for product $ad_client->{productCode} with ID $ad_client->{id} was found";
    say "  Supports reporting: $ad_client->{supportsReporting} and 'Yes' or 'No'";
}

store_token($dat_file, $auth_driver);

say 'Done';
__END__
