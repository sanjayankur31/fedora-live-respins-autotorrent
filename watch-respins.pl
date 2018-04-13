#!/usr/bin/perl
#
# Simple perl script
# Scrapes the live respins URL
# Checks for changes to torrent files
# If new torrent files are present, it downloads them to a specified location

use 5.10.0;
use strict;
use warnings;
use Data::Dumper;
use WWW::Mechanize;
use File::Fetch;

# Time out after 30 seconds if a download doesn't succeed
$File::Fetch::TIMEOUT = 30;

my $release = "F27";
my $respins_url = "http://dl.fedoraproject.org/pub/alt/live-respins/";
my $torrent_dir = "/home/asinha/Downloads/torrent_temps/rtorrent_watch/";
my @current_files = ();
my $download_dir;
# Select what flavours to download
my @flavours = (qr/CINN/, qr/KDE/, qr/LXDE/, qr/LXQT/, qr/MATE/, qr/SOAS/, qr/WORK/, qr/XFCE/ );

if (-d $torrent_dir)
{
    print("Downloading to $torrent_dir\n");
    opendir $download_dir, $torrent_dir or die "Cannot open directory: $!";
    @current_files = readdir $download_dir;
}
else
{
    print("$torrent_dir does not exist. Please correct path. Exiting\n");
    exit 1;
}

my $mech = WWW::Mechanize->new();
$mech->get( $respins_url );

if ($mech->success()) {
    my @all_links = $mech->links();

    foreach my $link (@all_links)
    {
        if ( $link->url =~ m/\.torrent$/ and $link->url ~~ @flavours)
        {
            $link->url =~ m/$release-(.*)-x86_64-(\d{8})\.torrent$/;
            my $flavour = $1;
            my $remote_version = $2;
            my $local_version = "";
            print("Checking requested flavour: $flavour\n");

            my $local_version = "0";
            foreach my $current_file (@current_files)
            {
                if ($current_file =~ m/$release-$flavour-x86_64-(\d{8})/ )
                {
                    $local_version = $1;
                }
            }
            if ($local_version ne $remote_version)
            {
                print("Local version ($local_version) is different from remote version ($remote_version). Downloading\n");
                my $file_loc = $respins_url.$link->url;
                print("Downloading: $file_loc to $torrent_dir\n");
                my $fetcher = File::Fetch->new(uri => $file_loc);
                my $where = $fetcher->fetch(to => $torrent_dir);
            }
        }
    }
    closedir $download_dir;
}
else
{
    print("Unable to fetch URL. Exiting\n");
    exit 2;
}

exit 0;
