#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use vars qw($Script);

$Script = basename();

MAIN_BLOCK:
{
    if (! @ARGV) {
        print "usage: $Script data-file predicted-column\n";
        exit(1)
    }
    my $data_filename = shift @ARGV;
    my $predicted_column = shift @ARGV;
    

    open my $fh, "$data_filename"
        or die "$Script: cannot open '$data_filename': $!";
    my $line = <$fh>;
    die "$Script: no first line in file" unless(defined($line));
    chomp $line;
    $line =~ s/\s*//g;
    my @column_names = split /,/, $line;
    my $data_table = [];
    while(defined($line=<$fh>)){
        chomp $line;
        my @columns = split /,/, $line;
        my $row = {};
        push @$data_table, $row;
        for(my $i=0; $i < scalar(@columns_names); $i++) {
            my $name = $column_names[$i];
            my $value = $columns[$i];
            $row->{$name} = $value;
        }
    }
    
    close $fh
        or die "$Script: cannot close '$data_filename': $!";
    

    exit(0);
}

