#!/usr/bin/env perl

use autodie;
use strict;
use warnings;
use Pod::Usage;
use FindBin;
use File::Basename;

if( scalar(@ARGV) != 3 ){
    pod2usage(1);    
} 

my $format = shift @ARGV;
my $from_file_or_dir = shift @ARGV;
my $to_file_or_dir = shift @ARGV;

my %supported_to_formats = (
    'mm2' => \&convert_to_mm2,
    'dif' => \&convert_to_dif,
    'iso' => \&convert_to_iso,    
);

my $convert_func = $supported_to_formats{$format};

if( ! exists $supported_to_formats{$format} ) {
    print "'$format' is not a supported format\n";
    exit(1);
}

if( ! -e $from_file_or_dir ){
    print "'$from_file_or_dir' does not exist.\n";
    exit(1);
}

if( -d $from_file_or_dir && -e $to_file_or_dir && -f $to_file_or_dir){
    print "Output should be a directory but it is an existing file.\n";
    exit(1);
}

if( -d $from_file_or_dir && ! (-e $to_file_or_dir ) ){
    mkdir $to_file_or_dir;
}



if( -d $from_file_or_dir ){

    opendir(my $DIRHANDLE, $from_file_or_dir);
    
    while( my $filename = readdir($DIRHANDLE) ){
        
        my ($dummy, $dummy2, $suffix) = fileparse($filename, qr/\.[^.]*/);
        if( !($suffix eq '.mmd' || $suffix eq '.xml') ){
            next;
        }
        
        my $input_file = File::Spec->catfile($from_file_or_dir, $filename);
        my $output_file = File::Spec->catfile($to_file_or_dir, $filename);
        $convert_func->($input_file, $output_file);
    }

    
} else {
    $convert_func->($from_file_or_dir, $to_file_or_dir);
}


sub convert_to_mm2 {
    my ($input_file, $output_file) = @_;

    system("xsltproc -o $output_file $FindBin::Bin/xslt/mmd-to-mm2.xsl $input_file");

}

sub convert_to_dif {
    my ($input_file, $output_file) = @_;
    
    system("xsltproc -o $output_file $FindBin::Bin/xslt/mmd-to-dif.xsl $input_file");

}

sub convert_to_iso {
    my ($input_file, $output_file) = @_;
    print "$input_file $output_file\n ";
    system("xsltproc -o $output_file $FindBin::Bin/xslt/mmd-to-iso.xsl $input_file");    
}


__END__

=head1 NAME

convert-from-mmd.pl - Convert files from MMD from different formats.

=head1 SYNOPSIS

convert-from-mmd.pl <to format> <input file or dir> <output file or dir>

=head1 DESCRIPTION

Convert either a file or all the files in a directory from MMD to a different metadata format. 

=cut


