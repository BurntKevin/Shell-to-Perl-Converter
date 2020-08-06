#!/usr/bin/perl

# Look at converstring and see if you nede them all

# Obtaining file data
my @lines = obtainFileToConvert();

# Going through all lines in shell for conversion
for (my $i = 0; $i < scalar @lines; $i++) {
    # Parsing input
    my $line = $lines[$i];
    my $indent = getIndent($line);
    my $endNewLine = ($line =~ /\n$/) ? 1 : 0;
    $line = cleanLine($line);



    transformSingleLine($line, $indent, $endNewLine);
}

sub cleanLine() {
    my $line = @_[0];

    $line = removeIndent($line);
    $line = convertShorthands($line);
    chomp $line;

    return $line;
}


sub obtainFileToConvert() {
    open my $FP, "<", $ARGV[0] or die "Could not open $ARGV[0]";
    my @lines = <$FP>;

    return @lines;
}

sub transformSingleLine() {
    my $line = @_[0];
    my $indent = @_[1];
    my $endNewLine = @_[2];

    print $indent;

    if (handleFileType($line)) {
    } elsif (handleEcho($line, $endNewLine)) {
    } elsif (handleAssignment($line)) {
    } elsif (handleCd($line)) {
    } elsif (handleEmptyLine($line)) {
    } elsif (handleFor($line)) {
    } elsif (handleDo($line)) {
    } elsif (handleDone($line)) {
    } elsif (handleExit($line)) {
    } elsif (handleRead($line, $indent)) {
    } elsif (handleIf($line)) {
    } elsif (handleThen($line)) {
    } elsif (handleElif($line)) {
    } elsif (handleElse($line)) {
    } elsif (handleFi($line)) {
    } elsif (handleComment($line)) {
    } elsif (handleWhile($line)) {
    } else {
        handleSystem($line);
    }
}

sub handleWhile() {
    my $line = @_[0];

    if ($line =~ /while /) {
        my @words = split " ", $line;

        print "while (";

        shift @words;

        handleCondition(@words);

        print ") ";
    }
}

sub handleComment() {
    my $line = @_[0];

    if ($line =~ /^[\s]*#/) {

        print "$line\n";
    }
}

sub handleFi() {
    my $line = @_[0];

    if ($line eq "fi") {
        print "}\n";
    }
}

sub handleElse() {
    my $line = @_[0];

    if ($line eq "else") {
        print "} else {\n";
    }
}

sub handleElif() {
    my $line = @_[0];

    if ($line =~ /elif /) {
        my @words = split " ", $line;

        print "} elsif (";

        shift @words;

        handleCondition(@words);

        print ") ";
    }
}

sub handleThen() {
    my $line = @_[0];

    if ($line eq "then") {
        my @words = split " ", $line;

        print "{ \n";
    }
}

sub handleIf() {
    my $line = @_[0];

    if ($line =~ /^if /) {
        my @words = split " ", $line;

        print "if (";

        shift @words;

        handleCondition(@words);

        print ") ";
    }
}

sub handleCondition() {
    my @words = @_;
    
    if ($words[0] eq "test") {
        shift @words;
        handleTest(@words);
    } else {
        shift @words;
        pop @words;
        handleSquareBracketTest(@words);
    }
}

# fix to adjust for issue with types i.e. = and eq
sub handleTest() {
    my @words = @_;

    my $string;
    foreach $word (@words) {
        if ($word eq "=") {
            $string = "$string eq";
        } elsif ($word eq "-r") {
            $string = "$string $word";
        } elsif ($word eq "-le") {
            $string = "$string <="
        } else {
            $string = "$string '$word'";
        }
    }
    $string =~ s/ //;

    print "$string"
}

sub handleSquareBracketTest() {
    # Removing square brackets
    @words = @_;

    print("$words[0] '$words[1]'")
}

sub getIndent() {
    my $line = @_[0];

    $line =~ /^(\s*)/;
    return $1;
}

sub handleRead() {
    my $line = @_[0];
    my $indent = @_[1];

    if ($line =~ /^read /) {
        $line = @_[0];

        @words = split " ", $line;

        print "\$$words[1] = <STDIN>;\n";
        print $indent . "chomp \$$words[1];\n";
    }
}

sub handleExit() {
    my $line = @_[0];

    if ($line =~ /^exit /) {
        print "$line;\n";
    }
}

sub handleDone() {
    my $line = @_[0];

    if ($line eq "done") {
        print "} \n";
    }
}

sub handleDo() {
    my $line = @_[0];

    if ($line eq "do") {
        print (" {\n");
    }
}

sub handleFor() {
    my $line = @_[0];

    if ($line =~ /^[ ]*for /) {
        $line =~ s/for //;
        my @words = split " ", $line;


        # Obtaining in arguments
        if (scalar @words == 3 && $words[2] =~ /.*\..*/) {
            $inArguments = "glob(\"$words[2]\")";
        } else {
            for ($j = 2; $j < scalar @words; $j++) {
                if ($words[$j] =~ /\d/) {
                    $inArguments = "$inArguments, $words[$j]";
                } else {
                    $inArguments = "$inArguments, '$words[$j]'";
                }
            }
            $inArguments =~ s/, //;
        }

        print "foreach \$$words[0] ($inArguments)";
    }
}

sub handleEmptyLine() {
    my $line = @_[0];

    if ($line eq "") {
        print "\n";
    }
}

sub handleCd() {
    my $line = @_[0];

    if ($line =~ /^cd /) {
        $line =~ s/cd //;
        print "chdir '$line';\n";
    }
}

sub handleAssignment() {
    my $line = @_[0];

    if ($line =~ /[^ ]+=[^ ]+/) {
        my @words = split "=", $line;

        if ($words[1] =~ /^\$/) {
            print "\$$words[0] = $words[1];\n";
        } elsif ($words[1] =~ /^`/) {
            $words[1] =~ s/^`expr //g;
            $words[1] =~ s/`//;

            print "\$$words[0] = $words[1];\n";
        } else {
            print "\$$words[0] = " . "'" . convertString($words[1]) . "';\n";
        }
    }
}

sub handleFileType() {
    my $line = @_[0];

    if ($line eq "#!/bin/dash") {
        print "#!/usr/bin/perl -w\n";
    }
}

sub handleEcho() {
    my $line = @_[0];
    my $endNewLine = @_[1];

    if ($line =~ /^echo /) {
        $line = convertString($line);

        $line =~ s/echo /print \"/;
        $line = "$line\\n" if $endNewLine;
        print "$line\";\n";
    }
}

sub removeIndent() {
    my $line = @_[0];

    $line =~ s/^[ ]+//;

    return $line;
}

sub handleSystem() {
    my $line = @_[0];

    print "system \"$line\";\n";
}


sub convertString() {
    my $line = @_[0];

    # Removing optional quotes placed by user
    $line =~ s/'|"//m;
    $line =~ s/'|"$//;

    # Escaping quotes
    $line =~ s/"/\\"/g;

    return $line;
}

sub convertShorthands() {
    my $line = @_[0];

    # Changing ${number} variables
    for ($j = 0; $j < 10; $j++) {
        $correspondingArgumentNumber = $j - 1;
        $line =~ s/\$$j/\$ARGV[$correspondingArgumentNumber]/g;
    }

    # Obtaining argv arguments
    $line =~ s/\$@/\@ARGV/g;

    return $line;
}
