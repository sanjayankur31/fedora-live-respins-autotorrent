#!/usr/bin/perl
#
# Simple perl script
# Scrapes the live respins URL
# Checks for changes to torrent files
# If new torrent files are present, it downloads them to a specified location

use strict;
use warnings;
use Data::Dumper;
use WWW::Mechanize;
use File::Fetch;

my $respins_url = "http://dl.fedoraproject.org/pub/alt/live-respins/";
my $torrent_dir = "/home/asinha/Downloads/torrent_temps/rtorrent_watch/";

if (-d $torrent_dir)
{
    print("Downloading to $torrent_dir\n");
}
else
{
    print("$torrent_dir does not exist. Please correct path. Exiting\n");
    exit 1;
}

my $mech = WWW::Mechanize->new();
$mech->get( $respins_url );

my $lives_date = "";

if ($mech->success()) {
    my @all_links = $mech->links();
    foreach my $link (@all_links)
    {
        if ( $link->url =~ m/CHECKSUM512-(\d{8})/ )
        {
            $lives_date = $1;
            print("Current version of respins is: $lives_date\n");

            # TODO check if we've already downloaded these
            # my $file_loc = $respins_url.$link;
            # print("Downloading: $file_loc to $torrent_dir\n");
            # my $fetcher = File::Fetch->new(uri => $file_loc);
            # my $where = $fetcher->fetch(to => $torrent_dir);
        }

        # if ( $link =~ m/\.torrent$/ )
        # {
            # my $file_loc = $respins_url.$link;
            # print("Downloading: $file_loc to $torrent_dir\n");
            # my $fetcher = File::Fetch->new(uri => $file_loc);
            # my $where = $fetcher->fetch(to => $torrent_dir);
        # }
    }
}
else
{
    print("Unable to fetch URL. Exiting\n");
    exit 2;
}

exit 0;
