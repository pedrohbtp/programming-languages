# Regex used for parsing the input

## For IAMAT
IAMAT kiwi.cs.ucla.edu +34.068930-118.445127 1400794645.392014450
^[\s]*([a-zA-Z]+)[\s]+([^\s\t\n\v\f\r]+)[\s]+([+|-][0-9]+[.][0-9]+)([+|-][0-9]+[.][0-9]+)[\s]+([0-9]+[.][0-9]+)[\s]*$

## For WHATSAT
WHATSAT kiwi.cs.ucla.edu 10 5
^[\s]*([a-zA-Z]+)[\s]+([^\s\t\n\v\f\r]+)[\s]+([0-9]+)[\s]+([0-9]+)[\s]*$

## For AT - Should be matched last
AT Alford +0.563873386 kiwi.cs.ucla.edu +34.068930-118.445127 1400794699.108893381
^[\s]*([a-zA-Z]+)[\s]+([a-zA-Z]+)[\s]+([+|-][0-9]+[.][0-9]+)[\s]+([^\s\t\n\v\f\r]+)[\s]+([+|-][0-9]+[.][0-9]+)([+|-][0-9]+[.][0-9]+)[\s]+([0-9]+[.][0-9]+)[\s]*$

