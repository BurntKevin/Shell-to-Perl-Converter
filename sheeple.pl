#!/usr/bin/perl

# Runs sheeple
main();

# Runs the converter from shell to perl
sub main() {
    # Obtaining file data
    my @lines = obtainFileToConvert();

    # Going through all lines in shell for conversion
    for (my $i = 0, my $inFunction = 0; $i < scalar @lines; $i++) {
        # Parsing input for useful information
        my $line = $lines[$i];
        my $indent = getIndent($line);
        $inFunction = inFunctionCheck($line, $inFunction);

        # Splitting lines with multiple statements
        my @sections = lineCommentSections($line);

        # Handling one segment of the line at a time
        foreach $section (@sections) {
            transformSingleLine($section, $inFunction, $indent);
        }
    }
}

# Splits lines which have a comment in them
# Does not factor in comments in strings, assumes all instaces of #
# are comments
sub lineCommentSections() {
    # Obtaining data
    my $line = $_[0];

    # Spitting by comment
    my @sections = split " #", $line;

    # Separating comments where the first section is the code section
    $sections[0] =~ s/[ ]+$//;
    for (my $i = 1; $i < scalar @sections; $i++) {
        # Removing trailing spaces
        $sections[$i] =~ s/[ ]+$//;

        # Adding comment back
        $sections[$i] =~ s/^/#/;
    }

    return @sections;
}

# Checks the current state is still in a function
sub inFunctionCheck() {
    # Obtaining input
    my $line = $_[0];
    my $inFunction = $_[1];

    # Updates if it is in a function
    if ($line =~ /() {/) {
        # Currently starting into a function
        return 1;
    } elsif ($inFunction == 1 && $line =~ /[ ]*}[ ]*/) {
        # Reached ending of a function
        return 0;
    }

    # State is still maintained
    return $inFunction;
}

# Reads a file into an array
sub obtainFileToConvert() {
    # Reading file
    open my $FP, "<", $ARGV[0] or die "Could not open $ARGV[0]";

    # Reading file lines into an array
    my @lines = <$FP>;

    return @lines;
}

# Handles the transformation of each line of perl into shell
sub transformSingleLine() {
    # Obtaining input
    my $line = $_[0];
    my $inFunction = $_[1];
    my $indent = $_[2];
    my $endNewLine = ($line =~ /\n$/) ? 1 : 0;

    # Cleaning input
    $line = cleanLine($line, $inFunction);

    # Finds the correct method which is able to handle input
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
    } elsif (handleTestStatement($line, $indent)) {
    } elsif (handleClosingCurlyBracket($line, $indent)) {
    } elsif (handleLs($line, $indent)) {
    } else { handleSystem($line, $indent); }
}

# Handles a test function - is buggy, does not consider both && and || case
# And cases where there are more than two chaining statements
sub handleTestStatement() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the command is a test command
    if ($line =~ /^test /) {
        my @sections = splitByAnd($line);
        @sections = splitByOr($line) if scalar @sections == 1;

        my @test = split " ", $sections[0];
        handleCondition(@test);
        for (my $i = 1; $i < scalar @sections; $i++) {
            print " and ";

            # Finds the correct method which is able to handle input
            if (handleEcho($sections[$i], $endNewLine, $indent)) {
            } elsif (handleAssignment($sections[$i], $indent, $indent)) {
            } elsif (handleCd($sections[$i], $indent)) {
            } elsif (handleExit($sections[$i], $indent)) {
            } elsif (handleComment($sections[$i], $indent)) {
            } elsif (handleFunction($sections[$i], $indent)) {
            } elsif (handleLocal($sections[$i], $indent)) {
            } elsif (handleReturn($sections[$i], $indent)) {
            } elsif (handleLs($sections[$i], $indent)) {
            } else { handleSystem($sections[$i], $indent); }
        }

        return 1;
    }
}

# Helper function to split a string by &&
sub splitByAnd() {
    # Obtaining input
    my $line = $_[0];

    # Splits by &&
    my @sections = split " && ", $line;

    return @sections;
}

# Helper function to split a string by ||
sub splitByOr() {
    # Obtaining input
    my $line = $_[0];

    # Splits by &&
    my @sections = split " || ", $line;

    return @sections;
}

# Handles a shell call to check for files
sub handleLs() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the command is an ls command
    if ($line =~ /^ls /) {
        # Setting up string to use
        my $string = "system \"";
        my @words = split " ", $line;

        # Parsing command
        foreach $word (@words) {
            $string = "$string" . convertString($word) . " ";
        }
        # Removing trailing space
        $string =~ s/ $//;

        print "$string\";\n";
    }
}

# General helper function which cleans a line into perl
sub cleanLine() {
    # Obtaining input
    my $line = $_[0];
    my $inFunction = $_[1];

    # Removing trailing spaces and converts special shell variables into perl
    $line = removeIndent($line);
    $line = convertShorthands($line, $inFunction);
    chomp $line;

    return $line;
}

# Handles the return statement of shell to perl
sub handleReturn() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the line is a return statement
    if ($line =~ /^return /) {
        # Printing corresponding return statement in perl
        print $indent . "$line;\n";
    }
}

# Handles the closing brackets of a function in shell to perl
sub handleClosingCurlyBracket() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the line is a closing bracket
    if ($line eq "}") {
        # Printing corresponding closing function statement in perl
        print "$indent}";
    }
}

# Handles the local variable in shell to perl
sub handleLocal() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the conversion is a local request
    if ($line =~ /^local /) {
        # Manipulating input for analysis
        my @words = split " ", $line;
        shift @words;

        # Preparing string
        my $string = "my (";

        # Parsing string into perl
        foreach $word (@words) {
            $string = $string . "\$$word, ";
        }
        # Removing trailing characters added
        $string =~ s/, $//g;

        print $indent . "$string);\n";

    }
}

# Handles the function conversion from shell to perl
sub handleFunction() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if the request is a shell function
    if ($line =~ /() {/) {
        # Removing shell function formatting
        $line =~ s/() {.*//g;

        print $indent . "sub $line {\n";
    }
}

# Handles the while conversion from shell to perl
sub handleWhile() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if the line given is a while
    if ($line =~ /^while /) {
        # Obtaining useful data
        my @words = split " ", $line;
        shift @words;

        # Printing while section
        print $indent . "while (";

        # Using a common handler for condition statements
        handleCondition(@words);

        # Finishing while section
        print ")";
    }
}

# Converts shell comments to perl
sub handleComment() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if the line is a comment
    if ($line =~ /^[\s]*#/) {
        # Shell and perl comments are the same
        print $indent . "$line\n";
    }
}

# Handles end of condition statement conversion
sub handleFi() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Check if it is the end of a condition statement
    if ($line eq "fi") {
        print $indent . "}\n";
    }
}

# Handles else condition statement
sub handleElse() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if it is an else condition statement
    if ($line eq "else") {
        print "$indent} else {\n";
    }
}

# Handles elif condition statement
sub handleElif() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if it is an else if condition statement
    if ($line =~ /^elif /) {
        # Obtaining useful data
        my @words = split " ", $line;
        shift @words;

        # Handling start of condition statement
        print "$indent} elsif (";

        # Using a generic function to handle conditions
        handleCondition(@words);

        # Handling the end of an elif statement
        print ") ";
    }
}

# Handles the conversion of a then statement
sub handleThen() {
    # Obtaining input
    my $line = $_[0];

    # Checks if the statement is a then statement
    if ($line eq "then") {

        print "{ \n";
    }
}

# Handles the conversion of a then statement
sub handleIf() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if the statement is an if statement
    if ($line =~ /^if /) {
        # Obtaining useful data of the condition
        my @words = split " ", $line;
        shift @words;

        # Printing start of if statement
        print $indent . "if (";

        # Handles the middle condition section
        handleCondition(@words);

        # Printing end of if statement
        print ") ";
    }
}

# Handles the conversion of a condition
sub handleCondition() {
    # Obtaining input
    my @words = @_;

    # Checking type of condition used
    if ($words[1] =~ /^\$\(\(/) {
        # A test in using expression
        shift @words;
        handleExpressionTest(@words);
    } elsif ($words[0] eq "test") {
        # A test in shell
        shift @words;
        handleTest(@words);
    } elsif ($words[0] eq "true") {
        # An special loop in shell - infinite loop
        handleTrueCondition();
    } elsif ($words[0] eq "[") {
        # A square bracket test
        shift @words;
        pop @words;

        handleSquareBracketTest(@words);
    } else {
        # A system test
        handleSystemTest(@words);
    }
}

# Handles a test which uses expression
sub handleExpressionTest() {
    # Obtaining input
    my @lines = @_;

    # Obtaining expression segment
    my $joinedLines = join " ", @lines;
    my @tmp = split /\)\)/, $joinedLines;
    $joinedLines = @tmp[0];

    # Handling expression segment
    print convertExpression($joinedLines);

    # Handing rest of condition
    shift @tmp;
    my $joinedLines = join " ", @tmp;
    @lines = split " ", $joinedLines;
    handleTest(@lines);
}

# Handles a test run by the command line
sub handleSystemTest() {
    # Obtaining input
    my @lines = @_;

    # Setting up printing string
    my $string = "system \"";

    # Obtaining data for the string
    foreach $line (@lines) {
        $string = $string . "$line ";
    }
    # Removing trailing space
    $string =~ s/ $//;

    # Printing line and quoting off string
    print "$string\"";
}

# Handles the special while loop - infinite loop
sub handleTrueCondition() {
    print "1";
}

# Handles the conversion of test strings
sub handleTest() {
    # Obtaining input
    my @words = @_;

    # Parsing string from shell to perl
    # Comparison operators, logic operators and variables
    my $string = "";
    foreach $word (@words) {
        if ($word eq "=") {
            $string = "$string eq";
        } elsif ($word eq "-r") {
            $string = "$string $word";
        } elsif ($word eq "!") {
            $string = "$string not";
        } elsif ($word eq "-d") {
            $string = "$string $word";
        } elsif ($word eq "-le") {
            $string = "$string <="
        } elsif ($word eq "-lt") {
            $string = "$string <";
        } elsif ($word eq "-ge") {
            $string = "$string >=";
        } elsif ($word eq "-gt") {
            $string = "$string >";
        } elsif ($word eq "-eq") {
            $string = "$string ==";
        } elsif ($word eq "-ne") {
            $string = "$string !=";
        } elsif ($word eq "-o" || $word eq "||") {
            $string = "$string ||";
        } elsif ($word eq "-a" || $word eq "&&") {
            $string = "$string &&";
        } elsif ($word =~ /^\$/) {
            $string = "$string $word";
        } elsif ($word =~ /^\d+$/ || $word =~ /^\$/ || $word =~ /^\@/) {
            # Word is not a condition, checking if it has to be quoted
            # Digits, variables and arrays do not need to be quoted
            $string = "$string $word";
        } else {
            $string = "$string '$word'";
        }
    }
    # Removing starting space
    $string =~ s/^ //;

    print $string;
}

# Handles square bracket tests
sub handleSquareBracketTest() {
    # Obtaining input
    my @words = @_;

    # Checking type of variable
    if ($word =~ /^\d+$/) {
        # A number does not need to be quoted
        print "$word";
    } else {
        # A string needs to be quoted
        print "$words[0] '$words[1]'";
    }
}

# Obtains the amount of spaces infront of a string
sub getIndent() {
    # Obtaining input
    my $line = $_[0];

    # Obtains spaces in front of the string
    $line =~ /^(\s*)/;
    return $1;
}

# Handles the conversion of the read shell command
sub handleRead() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the command is a read
    if ($line =~ /^read /) {
        # Parsing input for data
        @words = split " ", $line;

        # Printing conversion of read into <STDIN> and chomp
        print $indent . "\$$words[1] = <STDIN>;\n";
        print $indent . "chomp \$$words[1];\n";
    }
}

# Handles exit conversion from shell to perl
sub handleExit() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the command is an exit command
    if ($line =~ /^exit /) {
        # Shell and perl have the same exit command
        print $indent . "$line;\n";
    }
}

# Handles the case of shell to perl for done
sub handleDone() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if the given input is an exit
    if ($line eq "done") {
        # Concluding the loop as done
        print $indent . "} \n";
    }
}

# Starts the loop for perl
sub handleDo() {
    # Obtaining input
    my $line = $_[0];

    # Checking if the given input is a start
    if ($line eq "do") {
        # Starting the loop
        print " {\n";
    }
}

# Handles the for loop conversion
sub handleFor() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the given line is a for loop
    if ($line =~ /^for /) {
        # Parsing input into useful sections
        $line =~ s/for //;
        my @words = split " ", $line;

        # Obtaining in arguments
        if (scalar @words == 3 && $words[2] =~ /.*\..*/) {
            # Obtaining arguments for a file search
            $inArguments = "glob(\"$words[2]\")";
            print $indent . "foreach \$$words[0] ($inArguments)";
        } elsif ($words[2] eq "\$(seq" && scalar @words == 4) {
            # A sequence scan from 0 to a custom end
            $words[3] =~ s/\)$//;

            print $indent . "for (\$i = 1; \$i <= $words[3]; \$i++)";
        } elsif ($words[2] eq "\$(seq" && scalar @words == 5) {
            # A sequence scan from a custom start to a custom end
            $words[4] =~ s/\)$//;

            print $indent . "for (\$i = $words[3]; \$i <= $words[4]; \$i++)";
        } else {
            # Obtaining arguments for a range
            for ($j = 2; $j < scalar @words; $j++) {
                if ($words[$j] =~ /^\d+$/) {
                    $inArguments = "$inArguments, $words[$j]";
                } else {
                    $inArguments = "$inArguments, '$words[$j]'";
                }
            }
            $inArguments =~ s/, //;
            print $indent . "foreach \$$words[0] ($inArguments)";
        }
    }
}

# Handles empty lines
sub handleEmptyLine() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if the line is empty
    if ($line eq "") {
        print $indent . "\n";
    }
}

# Handles a change in directory
sub handleCd() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checking if it is a cd request
    if ($line =~ /^cd /) {
        # Removing cd marking
        $line =~ s/cd //;
        print $indent . "chdir '$line';\n";
    }
}

# Handles an assignment conversion
sub handleAssignment() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if it is an assignment
    if ($line =~ /[^ ]+=[^ ]+/) {
        # Changes the format of the data into a more accessible type
        my @words = split "=", $line;

        # Adding indent
        print $indent;

        # Checking if the variable needs a dollar sign
        print "\$" if ! $line =~ /^$/;

        # Parsing input
        if ($words[1] =~ /\$\(\(/) {
            # A $(()) calculation variable
            print "$words[0] = " . convertExpression($words[1]) . ";\n";
        } elsif ($words[1] =~ /^\d+$/) {
            # A number - does not require quotes
            $words[1] = convertString($words[1]);
            print "$words[0] = $words[1];\n";
        } elsif ($words[1] =~ /^`expr/) {
            # An `expr ` calculation variable
            $words[1] =~ s/^`expr //g;
            $words[1] =~ s/`//;

            print "$words[0] = " . convertExpression($words[1]) . ";\n";
        } elsif ($words[1] =~ /^\$\(/) {
            # A $() conversion
            $words[1] =~ s/^\$\(//g;
            $words[1] =~ s/\)$//;

            print "$words[0] = " . convertExpression($words[1]) . ";\n";
        } elsif ($words[1] =~ /\$/) {
            # Assignment from a variable - do not need to add another $ sign
            print "$words[0] = $words[1];\n";
        } else {
            # A string conversion
            print "$words[0] = '" . convertString($words[1]) . "';\n";
        }
    }
}

# Converts a dash file type to a perl
sub handleFileType() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    # Checks if the header is a dash header
    if ($line eq "#!/bin/dash") {
        # Converts to a perl header
        print $indent . "#!/usr/bin/perl -w\n";
    }
}

# Handles echo conversion
sub handleEcho() {
    # Obtaining input
    my $line = $_[0];
    my $endNewLine = $_[1];
    my $indent = $_[2];

    # Checking if the line is an echo
    if ($line =~ /^echo /) {
        # Normalising echo if it has a -n flag
        if ($line =~ /^echo -n /) {
            # Line cannot end with a new line
            $endNewLine = 0;
            $line =~ s/^echo -n /echo /;
        }

        # Parsing input
        if ($line =~ />>\$/) {
            # A >> file operation
            # Obtaining useful data
            my @items = split ">>", $line;

            # Obtaining file details
            my $finalIndex = scalar @items - 1;
            print $indent . "open F, '>>', $items[$finalIndex] or die;\n";

            # Obtaining text to write
            $line =~ s/echo //;
            $line =~ s/ .*$//;
            print $indent . "print F \"$line\"\n";

            # Closing file
            print $indent . "close F;\n";
        } elsif ($line =~ />\$/) {
            # A > file operation
            # Obtaining useful data
            my @items = split ">", $line;

            # Obtaining file details
            my $finalIndex = scalar @items - 1;
            print $indent . "open F, '>', $items[$finalIndex] or die;\n";

            # Obtaining text to write
            $line =~ s/echo //;
            $line =~ s/ .*$//;
            print $indent . "print F \"$line\"\n";

            # Closing file
            print $indent . "close F;\n";
        } elsif ($line =~ /<\$/) {
            # Obtaining useful data
            my @items = split "<", $line;

            # Opening file
            my $finalIndex = scalar @items - 1;
            print $indent . "open F, '<', $items[$finalIndex] or die;\n";

            # Obtaining text to write
            $line =~ s/echo //;
            $line =~ s/ .*$//;
            print $indent . "print F \"$line\"\n";

            # Closing file
            print $indent . "close F;\n";
        } elsif ($line =~ /\$\(\(/) {
            # Calculation $(()) expression
            # Removing unnecessary information
            $line =~ s/echo //;

            # Converting to perl
            print $indent . "print " . convertExpression($line) . ";\n";
        } else {
            # Normal echo statement
            $line = convertString($line);

            # Converting echo to print
            $line =~ s/echo /print \"/;
            $line = "$line\\n" if $endNewLine;
            print $indent . "$line\";\n";
        }
    }
}

# Removes the indent from a string
sub removeIndent() {
    # Obtaining input
    my $line = $_[0];

    # Removing indent at the start
    $line =~ s/^[ ]+//;

    return $line;
}

# Handles linux commands
sub handleSystem() {
    # Obtaining input
    my $line = $_[0];
    my $indent = $_[1];

    print $indent . "system \"$line\";\n";
}

# Converts standard text into a perl string
sub convertString() {
    my $line = $_[0];

    # Removing optional quotes placed by user
    $line =~ s/'|"//m;
    $line =~ s/'|"$//;

    # Escaping quotes
    $line =~ s/"/\\"/g;

    return $line;
}

# Converts shell shorthands into perl - variables
sub convertShorthands() {
    # Obtaining input
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
    $line =~ s/\$\*/\@ARGV/g;

    return $line;
}

# Converts an expression $(()) into a perl format
sub convertExpression() {
    # Obtaining input
    my $line = $_[0];

    # Removing expression details
    $line =~ s/^\$\(\(//;
    $line =~ s/\)\)$//;

    # Splitting information into a useful format
    my @variables = split " ", $line;

    # Parsing string
    my $string = "";
    foreach $variable (@variables) {
        if ($variable =~ /^\d+$/) {
            # Digits do not need extra information
            $string = $string . $variable;
        } elsif ($variable eq "+" || $variable eq "'+'") {
            $string = "$string + ";
        } elsif ($variable eq "-" || $variable eq "'-'") {
            $string = "$string - ";
        } elsif ($variable eq "*" || $variable eq "'*'") {
            $string = "$string * ";
        } elsif ($variable eq "/" || $variable eq "'/'") {
            $string = "$string / ";
        } elsif ($variable eq "%" || $variable eq "'%'") {
            $string = "$string % ";
        } elsif ($variable =~ /^\$/) {
            # Variables do not need extra information
            $string = $string . $variable;
        } else {
            # Non-digits need a dollar symbol infront of them
            $string = $string . "\$" . $variable;
        }
    }

    return $string;
}
