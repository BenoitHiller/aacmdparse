# aacmdparse

aacmdparse.bash is a bash library that allows your code to parse command line arguments into an associative array.

## Installation

    bpkg install stephenhamilton/aacmdparse

## Usage

First you source the parser in your code or terminal using `source aacmdparse`. This loads in two functions for parsing and sets up the structures for their output.

### aacmdparse

`aacmdparse` parses the arguments passed to it into two variables. The named arguments go into the associative array `argMap`. The remaining positional parameters are placed in `vargs`.

If you want to accept parameters with arguments you can specify which should accept values in an array called `assignableParameters`.

For example:

    declare -a assignableParameters=( s test ) 
    aacmdparse 1 -p -fb 3 -s 5 --test test1 -- -d 
    declare -p argMap
      declare -A argMap='([b]="" [f]="" [test]="test1" [p]="" [s]="5" )'
    declare -p vargs
      declare -a vargs='([0]="1" [1]="3" [2]="-d")'

Note that the function blanks these structures each time it is run.

### aacmdparsesplit

`aacmdparsesplit` is a wrapper around aacmdparse which takes input on stdin, splits it emulating the way bash performs space expansion, then parses the resulting arguments using `aacmdparse`.
