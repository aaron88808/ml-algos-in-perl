#!/usr/bin/perl

use strict;
use warnings;
use File::Basename;
use vars qw($Script);

$Script = basename();

MAIN_BLOCK:
{
    if (! @ARGV) {
        print "usage: $Script data-file class-column\n";
        exit(1)
    }
    my $data_filename = shift @ARGV;
    my $class_column = shift @ARGV;
    

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
        for(my $i=0; $i < scalar(@column_names); $i++) {
            my $name = $column_names[$i];
            my $value = $columns[$i];
            $row->{$name} = $value;
        }
    }
    close $fh
        or die "$Script: cannot close '$data_filename': $!";
    

    my $col_to_att = {};
    for( my $i=0; $i<@column_names; $i++) {
        my $column_name = $column_names[$i];
        foreach my $row (@$data_table) {
            my $att = $row->{$column_name};
            my $class = $row->{$class_column};
            $col_to_att->{$column_name}->{$att}->{'class-counts'}->{$class}++;
            $col_to_att->{$column_name}->{$att}->{'totals'}++
        }
    }

    my $rules = {};
    foreach my $column_name (@column_names) {
        foreach my $att (keys %{$col_to_att->{$column_name}}) {
            my $occurences = 0;
            foreach my $class (keys %{$col_to_att->{$column_name}->{$att}->{'class-counts'}}) {
                if ($occurences < $col_to_att->{$column_name}->{$att}->{'class-counts'}->{$class}) {
                    $occurences = $col_to_att->{$column_name}->{$att}->{'class-counts'}->{$class};
                    $col_to_att->{$column_name}->{$att}->{'rule'} = $class;
                }
            }
        }
    }
    
    foreach my $column_name (@column_names) {
        foreach my $att (keys %{$col_to_att->{$column_name}}) {
            my $rule = $col_to_att->{$column_name}->{$att}->{'rule'};
            my $total = $col_to_att->{$column_name}->{$att}->{'totals'};
            my $rule_count = $col_to_att->{$column_name}->{$att}->{'class-counts'}->{$rule};
            my $abs_error = $total - $rule_count;
            $col_to_att->{$column_name}->{$att}->{'error-rate'} = $abs_error / $total;;
        }
    }
    

    exit(0);
}

