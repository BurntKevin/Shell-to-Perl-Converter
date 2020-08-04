#!/usr/bin/perl

#TODO: Look at sample tests and use them too

# Obtaining file data
open FP, $ARGV[0] or die "Could not open $ARGV[0]";
@lines = <FP>;

# Adding header to perl program
print "#!/usr/bin/perl -w\n\n";

# Going through all lines in shell for conversion
for($i = 0; $i < scalar @lines; $i++) {
    # Obtaining new line
    $line = $lines[$i];
    $endNewLine = ($line =~ /\n$/) ? 1 : 0;
    chomp $line;

    if (!transformSingleLine($line, $endNewLine)) {
        if ($line =~ /^for/) {
            $line =~ s/for //;
            @words = split " ", $line;

            # Obtaining in arguments
            for ($j = 2; $j < scalar @words; $j++) {
                if ($words[$j] =~ /\d/) {
                    $inArguments = "$inArguments, $words[$j]";
                } else {
                    $inArguments = "$inArguments, '$words[$j]'";
                }
            }
            $inArguments =~ s/, //;

            print "foreach \$$words[0] ($inArguments) {\n";

            $i += 2;
            $line = $lines[$i];
            until ($line =~ /done/) {
                chomp $line;

                transformSingleLine($line, $endNewLine);
                $i++;
                $line = $lines[$i];
            }

            print "}";
        }
    }
}

print "\n";

# Transforms single line
sub transformSingleLine() {
    $line = @_[0];
    $endNewLine = @_[1];

    if ($line =~ /^*=.*/) {
        printAssignment($line);
        return 1;
    } elsif ($line =~ /^[\s]*echo /) {
        printEcho($line, $endNewLine);
        return 1;
    } elsif ($line =~ /^[\s]*cd/) {
        printCd($line);
        return 1;
    } elsif ($line =~ /^[\s]*pwd/) {
        printPwd($line);
        return 1;
    } elsif ($line =~ /^[\s]*exit/) {
        printExit($line);
        return 1;
    } elsif ($line =~ /^[\s]*read/) {
        printRead($line);
        return 1;
    }

    return 0;
}

sub printAssignment() {
    $line = @_[0];

    $line =~ s/=/ = \"/;
    print "\$$line\";\n";
}

sub printEcho() {
    $line = @_[0];
    $endNewLine = @_[1];

    $line =~ s/echo /print \"/;
    $line = "$line\\n" if $endNewLine;
    print "$line\";\n";
}

sub printCd() {
    $line = @_[0];

    $line =~ s/cd //;
    print "chdir '$line';\n";
}

sub printPwd() {
    print "system \"pwd\";\n";
}

sub printExit() {
    $line = @_[0];

    print "$line;\n";
}

sub printRead() {
    $line = @_[0];

    @words = split " ", $line;
    $indent = getSpaces($line);

    print "$indent\$$words[1] = <STDIN>;\n";
    print "$indent" . "chomp \$$words[1];\n";
}









sub getSpaces() {
    $line = @_[0];

    $line =~ /^(\s*)/;
    return $1;
}
