use vars qw($VERSION %IRSSI $path);

use Irssi;
use LWP::Simple qw/get/;
use XML::SimpleObject;
use vars qw/$spotifylookupurl $spotifysearchurl $content $parser $xmlobj/;

$VERSION = '1.0';
%IRSSI = (
    authors     => 'Marius Nettum',
    contact     => 'marius@intnernettum.no',
    name        => 'Irssify',
    description => 'Search for artist/track/album on spotify or lookup an URI using the spotify metadata API',
    license     => 'GPL'
);

$spotifylookupurl  = 'http://ws.spotify.com/lookup/1/?uri='; 
$spotifysearchurl = 'http://ws.spotify.com/search/1/';

sub getTrackinfo {
	my ($trackURI) = @_;
	$content = get($spotifylookupurl . $trackURI);
	
	if (defined($content)) {
	  	$parser = new XML::Parser(ErrorContext => 2, Style => "Tree");
		$xmlobj = new XML::SimpleObject($parser->parse($content));
		if ($xmlobj->child('track')) {
		    my $artist = $xmlobj->child('track')->child('artist')->child('name')->value;
		    my $track = $xmlobj->child('track')->child('name')->value;
		    my $trackinfo = $artist . ' - ' . $track;
		    return $trackinfo;
	  	}
	}
	return "No trackinfo found";
}

sub getAlbuminfo {
	my ($albumURI) = @_;
	$content = get($spotifylookupurl . $albumURI);
	
	if (defined($content)) {
	  	$parser = new XML::Parser(ErrorContext => 2, Style => "Tree");
		$xmlobj = new XML::SimpleObject($parser->parse($content));
		if ($xmlobj->child('album')) {
		    my $artist = $xmlobj->child('album')->child('artist')->child('name')->value;
		    my $album = $xmlobj->child('album')->child('name')->value;
		    my $year = $xmlobj->child('album')->child('released')->value;
		    my $albuminfo = $artist . ' - ' . $album . ' (' . $year . ')';
		    return $albuminfo;
	  	}
	}
	return "No albuminfo found";
}

sub getArtistinfo {
	my ($artistURI) = @_;
	$content = get($spotifylookupurl . $artistURI);
	
	if (defined($content)) {
	  	$parser = new XML::Parser(ErrorContext => 2, Style => "Tree");
		$xmlobj = new XML::SimpleObject($parser->parse($content));
		if ($xmlobj->child('artist')) {
		    my $artist = $xmlobj->child('artist')->child('name')->value;
		    my $artistinfo = $artist;
		    return $artistinfo;
	  	}
	}
	return "No artistinfo found";
}


sub getTrackResults {
	my ($tracksearch) = @_;
	my $maxresults = 5;
        $content = get($spotifysearchurl . 'track?q=' . $tracksearch);

	if (defined($content)) {
		$parser = new XML::Parser(ErrorContext => 2, Style => "Tree");
		$xmlobj = new XML::SimpleObject($parser->parse($content));
		
		my $trackresults = $xmlobj->child('tracks')->child('opensearch:totalResults')->value . " results for " . $tracksearch;
		if ($xmlobj->child('tracks')->child('opensearch:totalResults')->value > 5) {
			$trackresults .= ", displaying " . $maxresults . " of " . $xmlobj->child('tracks')->child('opensearch:totalResults')->value  . ":";
		}
		$trackresults .= "\n";
		my $i = 0;
		if ($xmlobj->child('tracks')->child('track')) {
		    foreach my $hit ($xmlobj->child('tracks')->children('track')) {
			last if ($i > 4);
		    	$trackresults .= $hit->child('artist')->child('name')->value;
			$trackresults .= " - ";
			$trackresults .= $hit->child('name')->value;
			$trackresults .= " (" . $hit->attribute('href') . ")\n";
			$i++;
		    }
		    return $trackresults;
		}
	}
    return $tracksearch . " returned 0 hits"
		  
}

sub getArtistResults {
	my ($artistsearch) = @_;
	my $maxresults = 5;
        $content = get($spotifysearchurl . 'artist?q=' . $artistsearch);

	if (defined($content)) {
		$parser = new XML::Parser(ErrorContext => 2, Style => "Tree");
		$xmlobj = new XML::SimpleObject($parser->parse($content));
		
		my $artistresults = $xmlobj->child('artists')->child('opensearch:totalResults')->value . " results for " . $artistsearch;
		if ($xmlobj->child('artists')->child('opensearch:totalResults')->value > 5) {
			$artistresults .= ", displaying " . $maxresults . " of " . $xmlobj->child('artists')->child('opensearch:totalResults')->value  . ":";
		}
		$artistresults .= "\n";
		my $i = 0;
		if ($xmlobj->child('artists')->child('artist')) {
		    foreach my $hit ($xmlobj->child('artists')->children('artist')) {
			last if ($i > 4);
		    	$artistresults .= $hit->child('name')->value;
			    $artistresults .= " (" . $hit->attribute('href') . ")\n";
			$i++;
		    }
		    return $artistresults;
		}
	}
    return $artistsearch . " returned 0 hits"
		  
}

sub getAlbumResults {
	my ($albumsearch) = @_;
	my $maxresults = 5;
        $content = get($spotifysearchurl . 'album?q=' . $albumsearch);

	if (defined($content)) {
		$parser = new XML::Parser(ErrorContext => 2, Style => "Tree");
		$xmlobj = new XML::SimpleObject($parser->parse($content));
		
		my $albumresults = $xmlobj->child('albums')->child('opensearch:totalResults')->value . " results for " . $albumsearch;
		if ($xmlobj->child('albums')->child('opensearch:totalResults')->value > 5) {
			$albumresults .= ", displaying " . $maxresults . " of " . $xmlobj->child('albums')->child('opensearch:totalResults')->value  . ":";
		}
		$albumresults .= "\n";
		my $i = 0;
		if ($xmlobj->child('albums')->child('album')) {
		    foreach my $hit ($xmlobj->child('albums')->children('album')) {
			last if ($i > 4);
		    	$albumresults .= $hit->child('artist')->child('name')->value;
                $albumresults .= " - ";
                $albumresults .= $hit->child('name')->value;
			    $albumresults .= " (" . $hit->attribute('href') . ")\n";
			$i++;
		    }
		    return $albumresults;
		}
	}
    return $albumsearch . " returned 0 hits"
		  
}


sub handleinput {
    my ($server, $msg, $nick, $addr, $target) = @_;

	if ($msg =~ m/^!spotify:track\s{1}(.*)/) {
		my $trackresults = &getTrackResults($1);
		my @msgs = split("\n" ,$trackresults);
		foreach $line (@msgs) {
			$server->command("msg " . $target . " " . $line);
		}
		return;
	}

	if ($msg =~ m/^!spotify:album\s{1}(.*)/) {
		my $albumresults = &getAlbumResults($1);
		my @msgs = split("\n" ,$albumresults);
		foreach $line (@msgs) {
			$server->command("msg " . $target . " " . $line);
		}
		return;
	}

	if ($msg =~ m/^!spotify:artist\s{1}(.*)/) {
		my $artistresults = &getArtistResults($1);
		my @msgs = split("\n" ,$artistresults);
		foreach $line (@msgs) {
			$server->command("msg " . $target . " " . $line);
		}
		return;
	}
	
	if ($msg =~ m/(spotify:track:\w{22})/ || $msg =~ m/(http:\/\/open.spotify.com\/track\/\w{22})/) {
		my $track = &getTrackinfo($1);
		$server->command('msg ' . $target . ' ' . $track);
		return;
	}
	if ($msg =~ m/(spotify:album:\w{22})/ || $msg =~ m/(http:\/\/open.spotify.com\/album\/\w{22})/) {
		my $album = &getAlbuminfo($1);
		$server->command('msg ' . $target . ' ' . $album);
		return;
	}
	if ($msg =~ m/(spotify:artist:\w{22})/ || $msg =~ m/(http:\/\/open.spotify.com\/artist\/\w{22})/) {
		my $artist = &getArtistinfo($1);
		$server->command('msg ' . $target . ' ' . $artist);
		return;
	}
}

Irssi::signal_add('message public', 'handleinput');
Irssi::print("Irssify v$VERSION loaded successfully");
