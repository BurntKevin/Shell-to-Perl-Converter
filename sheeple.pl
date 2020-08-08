#!/usr/bin/perl

# Look at converstring and see if you nede them all

# Obtaining file data
my @lines = obtainFileToConvert();

# Going through all lines in shell for conversion
for (my $i = 0, my $inFunction = 0; $i < scalar @lines; $i++) {
    # Parsing input
    my $line = $lines[$i];
    my $indent = getIndent($line);
    $inFunction = inFunctionCheck($line, $inFunction);

    my @sections = lineCommentSections($line);

    foreach $section (@sections) {
        transformSingleLine($section, $inFunction, $indent);
    }
}

sub lineCommentSections() {
    my $line = $_[0];

    my @sections = split " # ", $line;

    $sections[0] =~ s/[ ]+$//;
    for (my $i = 1; $i < scalar @sections; $i++) {
        $sections[$i] =~ s/[ ]+$//;
        $sections[$i] =~ s/^/# /;
    }

    return @sections;
}

sub inFunctionCheck() {
    my $line = $_[0];
    my $inFunction = $_[1];

    if ($line =~ /() {/) {
        return 1;
    } elsif ($inFunction == 1 && $line =~ /[ ]*}[ ]*/) {
        return 0;
    }

    return $inFunction;
}

sub obtainFileToConvert() {
    open my $FP, "<", $ARGV[0] or die "Could not open $ARGV[0]";
    my @lines = <$FP>;

    return @lines;
}

sub transformSingleLine() {
    my $line = $_[0];
    my $inFunction = $_[1];
    my $indent = $_[2];
    my $endNewLine = ($line =~ /\n$/) ? 1 : 0;

    $line = cleanLine($line, $inFunction);

    if (handleFileType($line, $indent)) {
    } elsif (handleEcho($line, $endNewLine, $indent)) {
    } elsif (handleAssignment($line, $indent, $indent)) {
    } elsif (handleCd($line, $indent)) {
    } elsif (handleEmptyLine($line, $indent)) {
    } elsif (handleFor($line, $indent)) {
    } elsif (handleDo($line)) {
    } elsif (handleDone($line, $indent)) {
    } elsif (handleExit($line, $indent)) {
    } elsif (handleRead($line, $indent)) {
    } elsif (handleIf($line, $indent)) {
    } elsif (handleThen($line)) {
    } elsif (handleElif($line, $indent)) {
    } elsif (handleElse($line, $indent)) {
    } elsif (handleFi($line, $indent)) {
    } elsif (handleComment($line, $indent)) {
    } elsif (handleWhile($line, $indent)) {
    } elsif (handleFunction($line, $indent)) {
    } elsif (handleLocal($line, $indent)) {
    } elsif (handleClosingCurlyBracket($line, $indent)) {
    } elsif (handleReturn($line, $indent)) {
    } elsif (handleFunctionCall($line, $indent)) {
    } else { handleSystem($line, $indent); }
}

sub handleFunctionCall() {
    my $line = $_[0];
    my $indent = $_[1];


}

sub cleanLine() {
    my $line = $_[0];
    my $inFunction = $_[1];

    $line = removeIndent($line);
    $line = convertShorthands($line, $inFunction);
    chomp $line;

    return $line;
}

sub handleReturn() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /^return /) {
        print $indent . "$line;\n";
    }
}

sub handleClosingCurlyBracket() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line eq "}") {
        print "$indent}";
    }
}

sub handleLocal() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /^local/) {
        my @words = split " ", $line;

        my $string = "my (";

        shift @words;
        foreach $word (@words) {
            $string = $string . "\$$word, ";
        }

        $string =~ s/, $//g;

        $string = "$string);\n";

        print $indent . $string;

    }
}

sub handleFunction() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /() {/) {
        $line =~ s/() {.*//g;

        print $indent . "sub $line {\n";
    }
}

sub handleWhile() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /while /) {
        my @words = split " ", $line;

        print $indent . "while (";

        shift @words;

        handleCondition(@words);

        print ")";
    }
}

sub handleComment() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /^[\s]*#/) {
        print $indent . "$line\n";
    }
}

sub handleFi() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line eq "fi") {
        print $indent . "}\n";
    }
}

sub handleElse() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line eq "else") {
        print "$indent} else {\n";
    }
}

sub handleElif() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /elif /) {
        my @words = split " ", $line;

        print "$indent} elsif (";

        shift @words;

        handleCondition(@words);

        print ") ";
    }
}

sub handleThen() {
    my $line = $_[0];

    if ($line eq "then") {
        my @words = split " ", $line;

        print "{ \n";
    }
}

sub handleIf() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /^if /) {
        my @words = split " ", $line;

        print $indent . "if (";

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
    } elsif ($words[0] eq "true") {
        handleTrueCondition();
    } elsif ($words[0] eq "[") {
        shift @words;
        pop @words;

        handleSquareBracketTest(@words);
    } else {
        handleSystemTest(@words);
    }
}

sub handleSystemTest() {
    my @line = @_;

    my $string = "system \"";

    foreach $line (@line) {
        $string = $string . "$line ";
    }
    $string =~ s/ $//;

    $string = "$string\"";

    print $string;
}

sub handleTrueCondition() {
    print "1";
}

# fix to adjust for issue with types i.e. = and eq
sub handleTest() {
    my @words = @_;

    my $string = "";
    foreach $word (@words) {
        if ($word eq "=") {
            $string = "$string eq";
        } elsif ($word eq "-r") {
            $string = "$string $word";
        } elsif ($word eq "-d") {
            $string = "$string $word";
        } elsif ($word eq "-le") {
            $string = "$string <="
        } elsif ($word eq "-lt") {
            $string = "$string <";
        } elsif ($word eq "-gt") {
            $string = "$string >";
        } elsif ($word eq "-eq") {
            $string = "$string ==";
        } elsif ($word eq "-o") {
            $string = "$string ||";
        } elsif ($word =~ /^\$/) {
            $string = "$string $word";
        } elsif ($word =~ /\d/ || $word =~ /^\$/ || $word =~ /^\@/) {
            $string = "$string $word";
        } else {
            $string = "$string '$word'";
        }
    }
    $string =~ s/ //;

    print $string;
}

sub handleSquareBracketTest() {
    # Removing square brackets
    my @words = @_;

    if ($word =~ /\d/) {
        print "$word";
    } else {
        print "$words[0] '$words[1]'";
    }
}

sub getIndent() {
    my $line = $_[0];

    $line =~ /^(\s*)/;
    return $1;
}

sub handleRead() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /^read /) {
        $line = $_[0];

        @words = split " ", $line;

        print $indent . "\$$words[1] = <STDIN>;\n";
        print $indent . "chomp \$$words[1];\n";
    }
}

sub handleExit() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /^exit /) {
        print $indent . "$line;\n";
    }
}

sub handleDone() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line eq "done") {
        print $indent . "} \n";
    }
}

sub handleDo() {
    my $line = $_[0];

    if ($line eq "do") {
        print " {\n";
    }
}

sub handleFor() {
    my $line = $_[0];
    my $indent = $_[1];

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

        print $indent . "foreach \$$words[0] ($inArguments)";
    }
}

sub handleEmptyLine() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line eq "") {
        print $indent . "\n";
    }
}

sub handleCd() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /^cd /) {
        $line =~ s/cd //;
        print $indent . "chdir '$line';\n";
    }
}

sub handleAssignment() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line =~ /[^ ]+=[^ ]+/) {
        my @words = split "=", $line;

        print $indent;

        print "\$" if ! $line =~ /^$/;

        if ($words[1] =~ /\$\(\(/) {
            print "$words[0] = " . convertExpression($words[1]) . ";\n";
        } elsif ($words[1] =~ /^\d+$/) {
            $words[1] = convertString($words[1]);
            print "$words[0] = $words[1];\n";
        } elsif ($words[1] =~ /^`expr/) {
            $words[1] =~ s/^`expr //g;
            $words[1] =~ s/`//;

            print "$words[0] = " . convertExpression($words[1]) . ";\n";
        } elsif ($words[1] =~ /$/) {
            print "$words[0] = $words[1];\n";
        } else {
            print "$words[0] = '" . convertString($words[1]) . "';\n";
        }
    }
}

sub convertExpression() {
    my $line = $_[0];

    $line =~ s/^\$\(\(//;
    $line =~ s/\)\)$//;

    my @variables = split " ", $line;

    my $string = "";
    foreach $variable (@variables) {
        if ($variable =~ /\d+/) {
            $string = $string . $variable;
        } elsif ($variable eq "+" || $variable eq "'+'") {
            $string = "$string + ";
        } elsif ($variable eq "-" || $variable eq "'-'") {
            $string = "$string - ";
        } elsif ($variable eq "*" || $variable eq "'*'") {
            $string = "$string * ";
        } elsif ($variable eq "/" || $variable eq "'/'") {
            $string = "$string / ";
        } elsif ($variable =~ /^\$/) {
            $string = $string . $variable;
        } else {
            $string = $string . "\$" . $variable;
        }
    }

    return $string;
}

sub handleFileType() {
    my $line = $_[0];
    my $indent = $_[1];

    if ($line eq "#!/bin/dash") {
        print $indent . "#!/usr/bin/perl -w\n";
    }
}

sub handleEcho() {
    my $line = $_[0];
    my $endNewLine = $_[1];
    my $indent = $_[2];

    if ($line =~ /^echo /) {
        if ($line =~ />>\$/) {
            my @items = split ">>", $line;

            my $finalIndex = scalar @words - 1;
            print $indent . "open F, '>>', $items[$finalIndex] or die;\n";
            $line =~ s/echo //;
            $line =~ s/ .*$//;
            print $indent . "print F \"$line\"\n";
            print $indent . "close F;\n";
        } else {
            $line = convertString($line);

            $line =~ s/echo /print \"/;
            $line = "$line\\n" if $endNewLine;
            print $indent . "$line\";\n";
        }
    }
}

sub removeIndent() {
    my $line = $_[0];

    $line =~ s/^[ ]+//;

    return $line;
}

sub handleSystem() {
    my $line = $_[0];
    my $indent = $_[1];

    print $indent . "system \"$line\";\n";
}


sub convertString() {
    my $line = $_[0];

    # Removing optional quotes placed by user
    $line =~ s/'|"//m;
    $line =~ s/'|"$//;

    # Escaping quotes
    $line =~ s/"/\\"/g;

    return $line;
}

sub convertShorthands() {
    my $line = $_[0];
    my $inFunction = $_[1];

    # Changing ${number} variables
    for ($j = 0; $j < 10; $j++) {
        $correspondingArgumentNumber = $j - 1;

        $line =~ s/\$$j/\$ARGV[$correspondingArgumentNumber]/g if !$inFunction;
        $line =~ s/\$$j/\$_[$correspondingArgumentNumber]/g if $inFunction;
    }

    # Obtaining argv arguments
    $line =~ s/\$@/\@ARGV/g;

    $line =~ s/\$#/\@ARGV/g;

    return $line;
}
