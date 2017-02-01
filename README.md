# Ximian
Generate an iTunes XML from your Swinsian (smart) playlists

This tool is heavily inspired by the excellent work done by @mhite who 
developed https://github.com/mhite/swinsian2itlxml. It's a great tool,
though unfortunately it doesn't work with Swinsian's smart playlists and
when importing the generated iTunes XML into Rekordbox it regularly didn't
show any tracks or playlists.

Enter Ximian. It is written in Swift and has the advantage that it can read
the NSPredicate objects necessary to get the track lists of smart playlists.

Usage is easy, just run it and it will automatically use the default
locations for both the Swinsian database as your iTunes XML.

## Warning

This script overwrites the iTunes XML file. It does not back anything up --
use at your own peril!

To force iTunes versions prior to 12.2 to regenerate the XML file, simply
delete it and relaunch iTunes. Do not delete the .itl file.

## Installation

You can download a build of Ximian (just a binary) here [[]]

or you can clone the repository and build it yourself.

## Usage

```
Usage: ../DerivedData/Ximian/Build/Products/Debug/Ximian [options]
  -s, --swinsian:
      The path to the Swinsian sql file. Defaults to ~/Library/Application Support/Swinsian/Library.sqlite
  -x, --xml:
      The path to the iTunes XML file. Defaults to ~/Music/iTunes/iTunes Library.xml
  -m, --music:
      The path to the iTunes Music Folder. Defaults to ~/Music/iTunes/iTunes Media
```


## Author

[Maarten Engelen](mailto:maarten@iridia.nl)

## Contribute

Your code contributions are welcome. Please fork and open a pull request.
