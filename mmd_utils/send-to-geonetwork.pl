#!/usr/bin/env perl

use autodie;
use strict;
use warnings;
use Pod::Usage;
use FindBin;
use LWP::Simple;
use LWP;
use LWP::UserAgent;
use File::Spec;
use Time::HiRes qw(time);


if( scalar(@ARGV) != 2 ){
    pod2usage(1);    
} 

my $verbose = 1;

my $url_file = shift @ARGV;
my $tmp_dir = shift @ARGV;

my $geonetwork_url = "http://metadata-bw.met.no/geonetwork/srv/eng/";

if( ! -e $url_file ){
    print "'$url_file' does not exist.\n";
    exit(1);
}

if( !(-e $tmp_dir) ){
    mkdir $tmp_dir;
}

open my $FILE, '<', $url_file;
my @metaadata_urls = <$FILE>;
close($FILE);


foreach my $metadata_url (@metaadata_urls) {

    $metadata_url =~ s/^\s+|\s+$//g; 

    info("Working on $metadata_url");

    my $filename = (split('/', $metadata_url))[-1];    

    my $metadata_file = File::Spec->catfile($tmp_dir, $filename);
    info("Trying to write to '$metadata_file");
    
    if(!is_success(getstore($metadata_url, $metadata_file))){
        print "Failed to store '$metadata_url' in '$filename'\n";
        next;
    }
    
    my $output_file = File::Spec->catfile($tmp_dir, "${filename}.iso");
    info("Trying to convert and store in '$output_file'");
    convert_to_iso($metadata_file, $output_file);
    

    my $geonetwork_id = find_geonetwork_id($output_file, $geonetwork_url);
    send_message_to_geonetwork($geonetwork_id, $output_file, $geonetwork_url);
}


sub send_message_to_geonetwork {
    my ($geonetwork_id, $iso_file, $geonetwork_url) = @_;
    
    my $xml_message;
    if($geonetwork_id) {
        $xml_message = create_update_message($geonetwork_id, $iso_file);
    } else {
        $xml_message = create_insert_message($iso_file);
    }
    
    if( !defined $xml_message ){
        print "Failed to create XML message to send to GeoNetwork\n";
        next;
    }
    
    my $full_url;
    if( $geonetwork_id ){
        $full_url = "${geonetwork_url}xml.metadata.update";    
    } else {
        $full_url = "${geonetwork_url}xml.metadata.insert";
    }
    
    info("Trying to send to '$full_url'\n");
    
    my $ua = LWP::UserAgent->new;
    $ua->agent("send-to-geonetwork script");
    $ua->cookie_jar( {} );
    
    if(authenticate_client($ua, $geonetwork_url)) {
    
        my $req = HTTP::Request->new(POST => $full_url);
        $req->content_type('application/xml');
        $req->content($xml_message);
         
        # Pass request to the user agent and get a response back
        my $res = $ua->request($req);
         
        # Check the outcome of the response
        if ($res->is_success) {
            return 1
        }
        else {
            print $res->content;
            print $res->status_line, "\n";
            return;
        }    
    }    
    
}

sub authenticate_client {
    my ($ua, $geonetwork_url) = @_;
    
    my $full_url = "${geonetwork_url}xml.user.login";
    
    my $xml_message = <<END_XML;
<?xml version="1.0" encoding="UTF-8"?>
<request>
    <username>admin</username>
    <password>oledole321</password>
</request>    
END_XML
    
    my $req = HTTP::Request->new(POST => $full_url);
    $req->content_type('application/xml');
    $req->content($xml_message);
     
    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);
     
    # Check the outcome of the response
    if ($res->is_success) {
        return 1;
    }
    else {
        print $res->content;
        print $res->status_line, "\n";
        return;
    }        
}


sub convert_to_iso {
    my ($input_file, $output_file) = @_;
    
    my $command = "xsltproc -o $output_file $FindBin::Bin/xslt/mmd-to-iso.xsl $input_file";
    info("Executing command: '$command'");
    
    system($command);    
}

sub info {
    my $msg = shift @_;
    print $msg . "\n" if $verbose;
}

sub find_geonetwork_id {
    my ($iso_file, $geonetwork_url) = @_;
    
    open my $ISO_FILE, '<', $iso_file;
    my $metadata_content = do { local $/; <$ISO_FILE> };
    close($ISO_FILE);
    
    my $xmllint_command = "xmllint --xpath \"//*[local-name()='title']/*[local-name()='CharacterString']/text()\" $iso_file";
    my $title = `$xmllint_command`;
    
    my $search_xml = <<"END_XML";
<?xml version="1.0" encoding="UTF-8"?>
<request>
  <title>$title</title>
</request>    
END_XML
    
    my $ua = LWP::UserAgent->new;
    $ua->agent("send-to-geonetwork script");
    
    my $full_url = "${geonetwork_url}xml.search";
    my $req = HTTP::Request->new(POST => $full_url);
    $req->content_type('application/xml');
    $req->content($search_xml);
     
    # Pass request to the user agent and get a response back
    my $res = $ua->request($req);
     
    # Check the outcome of the response
    if ($res->is_success) {
        my $xml_response = $res->content;
        print $xml_response;
        if( $xml_response =~ /<id>(\d+)<\/id>/){
            return $1;
        } else {
            return;
        }
    }
    else {
        print $res->content;
        print $res->status_line, "\n";
        return;
    }    
    
}

sub create_insert_message {
    my ($iso_file) = @_;
    
    open my $ISO_FILE, '<', $iso_file;
    my $metadata_content = do { local $/; <$ISO_FILE> };
    close($ISO_FILE);

    $metadata_content =~ s/<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>//;

    print time;

    my $xml_msg = <<"END_XML";    
<?xml version="1.0" encoding="UTF-8"?>
<request>
  <group>2</group>
  <category>_none_</category>
  <styleSheet>_none_</styleSheet>
  <data><![CDATA[
    $metadata_content
    ]]>
  </data>
</request>  
END_XML

    return $xml_msg;
    
}

sub create_update_message {
    my ($geonetwork_id, $iso_file) = @_;
    
    open my $ISO_FILE, '<', $iso_file;
    my $metadata_content = do { local $/; <$ISO_FILE> };
    close($ISO_FILE);

    $metadata_content =~ s/<\?xml version=\"1.0\" encoding=\"UTF-8\"\?>//;

    print time;

    my $xml_msg = <<"END_XML";    
<?xml version="1.0" encoding="UTF-8"?>
<request>
  <id>${geonetwork_id}</id>
  <version>101</version>
  <data><![CDATA[
$metadata_content
]]>
  </data>
</request>    
END_XML

    return $xml_msg;

}

__END__

=head1 NAME

send-to-geonetwork - Send a list of MMD metadata files to a GeoNetwork instance as ISO19139 metadata

=head1 SYNOPSIS

send-to-geonetwork.pl <file with metadata file urls> <tmp directory>

=head1 DESCRIPTION

Read a file with a list of URLs to MMD metadata files. For each file convert the file to ISO19139 and then 
send it to the GeoNetwork instance 

=cut


