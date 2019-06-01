#!/usr/bin/env perl

use autodie;
use strict;
use warnings;
use Pod::Usage;
use Cwd 'abs_path';
use FindBin;
use File::Basename qw(fileparse);
use File::Spec;


if( scalar(@ARGV) != 3 ){
    pod2usage(1);    
} 

my $format = shift @ARGV;
my $from_file_or_dir = shift @ARGV;
my $to_file_or_dir = shift @ARGV;

my %supported_from_formats = (
    'mm2' => \&convert_from_mm2,
    'dif' => \&convert_from_dif,
    'iso' => \&convert_from_iso,    
);

if( ! exists $supported_from_formats{$format} ) {
    print "'$format' is not a supported format\n";
    exit(1);
}

my $convert_func = $supported_from_formats{$format};

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
        if( $suffix ne '.xml' ){
            next;
        }
        
        my $input_file = File::Spec->catfile($from_file_or_dir, $filename);
        my $output_file = File::Spec->catfile($to_file_or_dir, $filename);
        $convert_func->($input_file, $output_file);
    }

    
} else {
    $convert_func->($from_file_or_dir, $to_file_or_dir);
}


sub convert_from_mm2 {
    my ($input_file, $output_file) = @_;

    my $input_abs_path = abs_path($input_file);
    my ($filename, $directories, $suffix) = fileparse($input_abs_path, qr/\.[^.]*/);
    

    my $xmd_file = File::Spec->catfile($directories, "${filename}.xmd");
    system("xsltproc -o $output_file --stringparam xmd ${xmd_file} $FindBin::Bin/xslt/mm2-to-mmd.xsl $input_file");        

}

sub convert_from_dif {
    my ($input_file, $output_file) = @_;
    
    system("xsltproc -o $output_file $FindBin::Bin/xslt/dif-to-mmd.xsl $input_file");
}

sub convert_from_iso {
    my ($input_file, $output_file) = @_;
    
    system("xsltproc -o $output_file $FindBin::Bin/xslt/iso-to-mmd.xsl $input_file");
}

__END__

=head1 NAME

convert-to-mmd.pl - Convert files to MMD from different formats.

=head1 SYNOPSIS

mmd-convert.pl <from format> <input file or dir> <output file or dir>

=head1 DESCRIPTION

Convert either a file or all the files in a directory to MMD. 

=cut


