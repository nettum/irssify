# Irssify

Search for artist/track/album or lookup spotify URLs & URIs from irssi


## Requirements

irssi (duh)  
LWP::Simple (apt-get install libwww-perl)  
XML::SimpleObject (apt-get install libxml-simpleobject-perl)  


## Installation

1. Copy irssify.pl to ~/.irssi/scripts
2. Load script from irssi with '/load irssify.pl'


## Usage

### Search

1. Artist  
`!spotify:artist <artist_name>`

2. Track  
`!spotify:track <track_name>`

3. Album  
`!spotify:album <album_name>`


### Lookup

The script will automatically lookup artist/track/album URLs and URIs pasted in channels
