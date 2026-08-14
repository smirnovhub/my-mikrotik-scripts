:global RunAllArrayStrTests2
:global CompareStrTest
:global ReverseStrTest
:global IsPrintableStrTest
:global ExtractFileNameTest
:global ContainsStrTest
:global StartsWithStrTest
:global EndsWithStrTest
:global CleanStrTest

:set RunAllArrayStrTests2 do={
    :global InitTestCaseState
    :global CompareStrTest
    :global ReverseStrTest
    :global IsPrintableStrTest
    :global ExtractFileNameTest
    :global ContainsStrTest
    :global StartsWithStrTest
    :global EndsWithStrTest
    :global CleanStrTest

    :put "\1B[35m=== STARTING ALL ARRAY AND STRING TESTS 2 ===\1B[0m"

    :local res [$InitTestCaseState $1]

    # Execute all test suites sequentially, passing and updating the same accumulator array
    :set res [$CompareStrTest $res]
    :set res [$ReverseStrTest $res]
    :set res [$IsPrintableStrTest $res]
    :set res [$ExtractFileNameTest $res]
    :set res [$ContainsStrTest $res]
    :set res [$StartsWithStrTest $res]
    :set res [$EndsWithStrTest $res]
    :set res [$CleanStrTest $res]

    :put "\1B[35m=== ALL ARRAY AND STRING TESTS 2 COMPLETED ===\1B[0m"

    :return $res
}

:set CompareStrTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global CompareStr

    :local res [$InitTestCaseState $1]

    :put "Starting CompareStr tests..."

    # Edge Cases & Basics
    :set res [$RunGenericTestCase $res $CompareStr "" "" "nothing" 0 "Both empty"]
    :set res [$RunGenericTestCase $res $CompareStr "a" "" "nothing" 1 "First non-empty, second empty"]
    :set res [$RunGenericTestCase $res $CompareStr "" "a" "nothing" -1 "First empty, second non-empty"]
    :set res [$RunGenericTestCase $res $CompareStr "identical" "identical" "nothing" 0 "Identical long strings"]

    # Case Sensitivity (ASCII orders uppercase before lowercase)
    :set res [$RunGenericTestCase $res $CompareStr "Apple" "apple" "nothing" -1 "Uppercase vs Lowercase start"]
    :set res [$RunGenericTestCase $res $CompareStr "apple" "Apple" "nothing" 1 "Lowercase vs Uppercase start"]
    :set res [$RunGenericTestCase $res $CompareStr "aPple" "apple" "nothing" -1 "Difference in middle (caps first)"]
    :set res [$RunGenericTestCase $res $CompareStr "apple" "aPple" "nothing" 1 "Difference in middle (lowercase first)"]
    :set res [$RunGenericTestCase $res $CompareStr "A" "a" "nothing" -1 "Single char Uppercase vs Lowercase"]
    :set res [$RunGenericTestCase $res $CompareStr "a" "A" "nothing" 1 "Single char Lowercase vs Uppercase"]
    :set res [$RunGenericTestCase $res $CompareStr "WORD" "word" "nothing" -1 "All caps vs all lowercase"]

    # Length & Prefixes
    :set res [$RunGenericTestCase $res $CompareStr "test" "testing" "nothing" -1 "Short prefix vs long string"]
    :set res [$RunGenericTestCase $res $CompareStr "testing" "test" "nothing" 1 "Long string vs short prefix"]
    :set res [$RunGenericTestCase $res $CompareStr "abc" "abcdefgh" "nothing" -1 "Very short vs very long prefix"]
    :set res [$RunGenericTestCase $res $CompareStr "abcdefgh" "abc" "nothing" 1 "Very long vs very short prefix"]

    # Standard Alphabetical
    :set res [$RunGenericTestCase $res $CompareStr "abc" "abd" "nothing" -1 "Last char smaller"]
    :set res [$RunGenericTestCase $res $CompareStr "abd" "abc" "nothing" 1 "Last char larger"]
    :set res [$RunGenericTestCase $res $CompareStr "absolute" "abstract" "nothing" -1 "Divergence in middle (o vs r)"]

    # Numbers & Numeric Strings (ASCII order: '0'-'9')
    :set res [$RunGenericTestCase $res $CompareStr "123" "123" "nothing" 0 "Identical numbers"]
    :set res [$RunGenericTestCase $res $CompareStr "123" "124" "nothing" -1 "Numbers standard order"]
    :set res [$RunGenericTestCase $res $CompareStr "2" "10" "nothing" 1 "ASCII comparison vs numeric value (2 > 1)"]
    :set res [$RunGenericTestCase $res $CompareStr "01" "1" "nothing" -1 "Leading zero comparison"]

    # Special Characters & Spaces (ASCII order: space=32, symbols vary)
    :set res [$RunGenericTestCase $res $CompareStr " " "" "nothing" 1 "Space vs empty"]
    :set res [$RunGenericTestCase $res $CompareStr "a b" "ab" "nothing" -1 "Space vs no space (space is smaller than 'b')"]
    :set res [$RunGenericTestCase $res $CompareStr "abc" "abc " "nothing" -1 "String vs string with trailing space"]
    :set res [$RunGenericTestCase $res $CompareStr "abc!" "abc?" "nothing" -1 "Special chars (! is 33, ? is 63)"]
    :set res [$RunGenericTestCase $res $CompareStr "abc" "abc_def" "nothing" -1 "String vs string with underscore"]

    :put "Testing completed."
    :return $res
}

:set ReverseStrTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global ReverseStr

    :local res [$InitTestCaseState $1]

    :put "Starting ReverseStr tests..."

    # Base & Standard Cases

    # Standard word reversal
    :set res [$RunGenericTestCase $res $ReverseStr "hello" "nothing" "nothing" "olleh" "Standard word reversal"]

    # Multi-word string reversal
    :set res [$RunGenericTestCase $res $ReverseStr "hello world" "nothing" "nothing" "dlrow olleh" "Multi-word string reversal"]

    # Palindrome reversal
    :set res [$RunGenericTestCase $res $ReverseStr "radar" "nothing" "nothing" "radar" "Palindrome reversal"]

    # Edge Cases & Boundaries

    # Empty string
    :set res [$RunGenericTestCase $res $ReverseStr "" "nothing" "nothing" "" "Empty string"]

    # Single character string
    :set res [$RunGenericTestCase $res $ReverseStr "a" "nothing" "nothing" "a" "Single character string"]

    # Two character string
    :set res [$RunGenericTestCase $res $ReverseStr "ab" "nothing" "nothing" "ba" "Two character string"]

    # Formatting & Special Characters

    # Mixed case string
    :set res [$RunGenericTestCase $res $ReverseStr "RouterOS" "nothing" "nothing" "SOretuoR" "Mixed case string"]

    # File path reversal
    :set res [$RunGenericTestCase $res $ReverseStr "flash/backups/cfg.rsc" "nothing" "nothing" "csr.gfc/spukcab/hsalf" "File path reversal"]

    # String with spaces and tabs
    :set res [$RunGenericTestCase $res $ReverseStr ("a b\tc") "nothing" "nothing" ("c\tb a") "String with spaces and tabs"]

    # Punctuation and symbols
    :set res [$RunGenericTestCase $res $ReverseStr "192.168.88.1/24" "nothing" "nothing" "42/1.88.861.291" "Punctuation and symbols"]

    # Non-string Parameters

    # Non-string parameters (Numeric types)
    :set res [$RunGenericTestCase $res $ReverseStr 12345 "nothing" "nothing" "54321" "Non-string parameters (Numeric types)"]

    # Boolean parameter
    :set res [$RunGenericTestCase $res $ReverseStr true "nothing" "nothing" "eurt" "Boolean parameter"]

    # IP address type parameter
    :set res [$RunGenericTestCase $res $ReverseStr 10.0.0.1 "nothing" "nothing" "1.0.0.01" "IP address type parameter"]

    :put "Testing completed."
    :return $res
}

:set IsPrintableStrTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global IsPrintableStr
    :global DecToChar

    :local res [$InitTestCaseState $1]

    :put "Starting IsPrintableStr tests..."

    # Standard Printable Strings
    :set res [$RunGenericTestCase $res $IsPrintableStr ("Hello World") "nothing" "nothing" true "Standard text with space"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ("RouterOS-123!") "nothing" "nothing" true "Alphanumeric and standard punctuation"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ("~`@#\$%^&*()_+{}|:<>?-=[]\\;',./") "nothing" "nothing" true "All standard keyboard symbols"]

    # Edge Cases (Empty and Short)
    :set res [$RunGenericTestCase $res $IsPrintableStr ("") "nothing" "nothing" true "Empty string is technically free of control characters"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ("A") "nothing" "nothing" true "Single printable character"]

    # Low Control Characters (0x00 - 0x1F)
    :set res [$RunGenericTestCase $res $IsPrintableStr ("Line1" . [$DecToChar 10] . "Line2") "nothing" "nothing" false "String containing Line Feed (LF, 0x0A)"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ("Data" . [$DecToChar 13]) "nothing" "nothing" false "String ending with Carriage Return (CR, 0x0D)"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ("Text" . [$DecToChar 9] . "Aligned") "nothing" "nothing" false "String containing Tab character (0x09)"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ([$DecToChar 0] . "NullStart") "nothing" "nothing" false "String starting with Null character (0x00)"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ([$DecToChar 31]) "nothing" "nothing" false "Boundary low control character (0x1F)"]

    # High Control and Extended Characters (0x7F - 0xFF)
    :set res [$RunGenericTestCase $res $IsPrintableStr ("CleanText" . [$DecToChar 127]) "nothing" "nothing" false "String containing Delete character (DEL, 0x7F)"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ([$DecToChar 128] . "Extended") "nothing" "nothing" false "Boundary extended ASCII character (0x80)"]
    :set res [$RunGenericTestCase $res $IsPrintableStr ("BadChar_" . [$DecToChar 255]) "nothing" "nothing" false "Max ASCII range character (0xFF)"]

    :put "Testing completed."
    :return $res
}

:set ExtractFileNameTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global ExtractFileName

    :local res [$InitTestCaseState $1]

    :put "Starting ExtractFileName tests..."

    # Standard path with extension (Strip extension)
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/backups/router-config.rsc" "nothing" "nothing" "router-config" "Standard path with extension (Strip extension)"]

    # Standard path with extension (Keep extension)
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/backups/router-config.rsc" true "nothing" "router-config.rsc" "Standard path with extension (Keep extension)"]

    # File in root directory (Strip extension)
    :set res [$RunGenericTestCase $res $ExtractFileName "system.backup" "nothing" "nothing" "system" "File in root (Strip extension)"]

    # File in root directory (Keep extension)
    :set res [$RunGenericTestCase $res $ExtractFileName "system.backup" true "nothing" "system.backup" "File in root (Keep extension)"]

    # Path with no extension
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/backups/my-file" "nothing" "nothing" "my-file" "Path with no extension"]

    # Dot inside directory name, but no extension in file
    :set res [$RunGenericTestCase $res $ExtractFileName "flash.backups/my-folder/script" "nothing" "nothing" "script" "Dot in directory name, file has no extension"]

    # Dot inside directory name, and file has extension
    :set res [$RunGenericTestCase $res $ExtractFileName "flash.backups/my-folder/script.txt" "nothing" "nothing" "script" "Dot in directory name, file has extension (Strip)"]

    # File starting with dot (Hidden style)
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/configs/.env" "nothing" "nothing" "nil" "Hidden style file starting with dot (Strip extension)"]

    # File starting with dot (Hidden style, Keep extension)
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/configs/.env" true "nothing" ".env" "Hidden style file starting with dot (Keep extension)"]

    # File with multiple dots (Strip extension)
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/archive/router.config.backup" "nothing" "nothing" "router.config" "Multiple dots in file name (Strip extension)"]

    # File with multiple dots (Keep extension)
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/archive/router.config.backup" true "nothing" "router.config.backup" "Multiple dots in file name (Keep extension)"]

    # File ending with a dot
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/test/file." "nothing" "nothing" "file" "File ending with dot"]

    # File consisting only of an extension separator
    :set res [$RunGenericTestCase $res $ExtractFileName "." "nothing" "nothing" "nil" "Single dot as file name"]

    # File consisting of two dots
    :set res [$RunGenericTestCase $res $ExtractFileName ".." "nothing" "nothing" "nil" "Double dot as file name"]

    # Empty path
    :set res [$RunGenericTestCase $res $ExtractFileName "" "nothing" "nothing" "nil" "Empty path"]

    # Path ending with slash
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/backups/" "nothing" "nothing" "nil" "Path ending with slash"]

    # Root slash only
    :set res [$RunGenericTestCase $res $ExtractFileName "/" "nothing" "nothing" "nil" "Root slash only"]

    # Multiple consecutive slashes
    :set res [$RunGenericTestCase $res $ExtractFileName "flash//configs///script.rsc" "nothing" "nothing" "script" "Multiple consecutive slashes"]

    # Hidden file with multiple dots
    :set res [$RunGenericTestCase $res $ExtractFileName ".config.json" "nothing" "nothing" ".config" "Hidden file with multiple dots"]

    # Directory names containing many dots
    :set res [$RunGenericTestCase $res $ExtractFileName "dir.v1/archive.v2/file.txt" "nothing" "nothing" "file" "Directories containing dots"]

    # File without path and without extension
    :set res [$RunGenericTestCase $res $ExtractFileName "README" "nothing" "nothing" "README" "Root file without extension"]

    # File with trailing spaces
    :set res [$RunGenericTestCase $res $ExtractFileName "flash/file.txt " "nothing" "nothing" "file" "Trailing spaces in file name"]

    :put "Testing completed."
    :return $res
}

:set ContainsStrTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global ContainsStr

    :local res [$InitTestCaseState $1]

    :put "Starting ContainsStr tests..."

    # Substring exists in the middle
    :set res [$RunGenericTestCase $res $ContainsStr "hello world" "lo wo" "nothing" true "Substring exists in the middle"]

    # Substring does not exist
    :set res [$RunGenericTestCase $res $ContainsStr "hello world" "abc" "nothing" false "Substring does not exist"]

    # Empty search string
    :set res [$RunGenericTestCase $res $ContainsStr "hello world" "" "nothing" true "Empty search string"]

    # Search string matches target string completely
    :set res [$RunGenericTestCase $res $ContainsStr "exact" "exact" "nothing" true "Search string matches target string completely"]

    # Substring at the very beginning
    :set res [$RunGenericTestCase $res $ContainsStr "start of text" "start" "nothing" true "Substring at the very beginning"]

    # Substring at the very end
    :set res [$RunGenericTestCase $res $ContainsStr "end of text" "text" "nothing" true "Substring at the very end"]

    # Both parameters are empty strings
    :set res [$RunGenericTestCase $res $ContainsStr "" "" "nothing" true "Both parameters are empty strings"]

    # Target string is empty, search string is not
    :set res [$RunGenericTestCase $res $ContainsStr "" "abc" "nothing" false "Target string is empty, search string is not"]

    # Case sensitivity check
    :set res [$RunGenericTestCase $res $ContainsStr "Hello World" "hello" "nothing" false "Case sensitivity check"]

    # Non-string parameters (Numeric types)
    :set res [$RunGenericTestCase $res $ContainsStr 12345 "23" "nothing" true "Non-string parameters (Numeric types)"]

    # Special characters in string
    :set res [$RunGenericTestCase $res $ContainsStr "flash/backups/file.rsc" "/backups/" "nothing" true "Special characters in string"]

    :put "Testing completed."
    :return $res
}

:set StartsWithStrTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global StartsWithStr

    :local res [$InitTestCaseState $1]

    :put "Starting StartsWithStr tests..."

    # Standard matching prefix
    :set res [$RunGenericTestCase $res $StartsWithStr "hello world" "hello" "nothing" true "Standard matching prefix"]

    # Non-matching prefix
    :set res [$RunGenericTestCase $res $StartsWithStr "hello world" "world" "nothing" false "Non-matching prefix"]

    # Empty prefix
    :set res [$RunGenericTestCase $res $StartsWithStr "hello world" "" "nothing" true "Empty prefix"]

    # Prefix equals target string
    :set res [$RunGenericTestCase $res $StartsWithStr "exact" "exact" "nothing" true "Prefix equals target string"]

    # Prefix longer than target string
    :set res [$RunGenericTestCase $res $StartsWithStr "short" "shorter" "nothing" false "Prefix longer than target string"]

    # Both parameters are empty strings
    :set res [$RunGenericTestCase $res $StartsWithStr "" "" "nothing" true "Both parameters are empty strings"]

    # Target string is empty, prefix is not
    :set res [$RunGenericTestCase $res $StartsWithStr "" "prefix" "nothing" false "Target string is empty, prefix is not"]

    # Case sensitivity check
    :set res [$RunGenericTestCase $res $StartsWithStr "Hello world" "hello" "nothing" false "Case sensitivity check"]

    # Non-string parameters (Numeric types)
    :set res [$RunGenericTestCase $res $StartsWithStr 12345 12 "nothing" true "Non-string parameters (Numeric types)"]

    # Special characters in path prefix
    :set res [$RunGenericTestCase $res $StartsWithStr "flash/backups/file.rsc" "flash/" "nothing" true "Special characters in path prefix"]

    # Single character match
    :set res [$RunGenericTestCase $res $StartsWithStr "router" "r" "nothing" true "Single character match"]

    :put "Testing completed."
    :return $res
}

:set EndsWithStrTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global EndsWithStr

    :local res [$InitTestCaseState $1]

    :put "Starting EndsWithStr tests..."

    # Base & Standard Cases

    # Standard matching suffix
    :set res [$RunGenericTestCase $res $EndsWithStr "Hello World" "World" "nothing" true "Standard matching suffix"]

    # Non-matching suffix
    :set res [$RunGenericTestCase $res $EndsWithStr "Hello World" "Hello" "nothing" false "Non-matching suffix"]

    # Empty suffix
    :set res [$RunGenericTestCase $res $EndsWithStr "Hello World" "" "nothing" true "Empty suffix"]

    # Suffix equals target string
    :set res [$RunGenericTestCase $res $EndsWithStr "exact" "exact" "nothing" true "Suffix equals target string"]

    # Suffix longer than target string
    :set res [$RunGenericTestCase $res $EndsWithStr "short" "longer_suffix" "nothing" false "Suffix longer than target string"]

    # Edge Cases & Boundaries

    # Both parameters are empty strings
    :set res [$RunGenericTestCase $res $EndsWithStr "" "" "nothing" true "Both parameters are empty strings"]

    # Target string is empty, suffix is not
    :set res [$RunGenericTestCase $res $EndsWithStr "" "suffix" "nothing" false "Target string is empty, suffix is not"]

    # Single character match at the end
    :set res [$RunGenericTestCase $res $EndsWithStr "router" "r" "nothing" true "Single character match at the end"]

    # Case sensitivity check
    :set res [$RunGenericTestCase $res $EndsWithStr "Hello World" "world" "nothing" false "Case sensitivity check"]

    # Formatting & Path Cases

    # File extension matching
    :set res [$RunGenericTestCase $res $EndsWithStr "flash/backups/script.rsc" ".rsc" "nothing" true "File extension matching"]

    # Matching trailing slash
    :set res [$RunGenericTestCase $res $EndsWithStr "flash/backups/" "/" "nothing" true "Matching trailing slash"]

    # Matching trailing space
    :set res [$RunGenericTestCase $res $EndsWithStr "hello " " " "nothing" true "Matching trailing space"]

    # Partial match before end (should fail)
    :set res [$RunGenericTestCase $res $EndsWithStr "config.rsc.backup" ".rsc" "nothing" false "Partial match before end"]

    # Non-string Parameters

    # Non-string parameters (Numeric types)
    :set res [$RunGenericTestCase $res $EndsWithStr 12345 45 "nothing" true "Non-string parameters (Numeric types)"]

    # IP address object type passed as input
    :set res [$RunGenericTestCase $res $EndsWithStr 192.168.88.1 ".88.1" "nothing" true "IP address type input parameter"]

    :put "Testing completed."
    :return $res
}

:set CleanStrTest do={
    :global InitTestCaseState
    :global RunGenericTestCase
    :global CleanStr

    :local res [$InitTestCaseState $1]

    :put "Starting CleanStr expanded tests..."

    # Base Cases

    # Standard alphanumeric filtering
    :set res [$RunGenericTestCase $res $CleanStr "my-var@name!#123" "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" "nothing" "myvarname123" "Standard alphanumeric filtering"]

    # Only digits allowed (IP/MAC extraction style)
    :set res [$RunGenericTestCase $res $CleanStr "ip: 192.168.88.1" "0123456789" "nothing" "192168881" "Only digits allowed"]

    # Empty allowed characters string
    :set res [$RunGenericTestCase $res $CleanStr "some text" "" "nothing" "" "Empty allowed characters string"]

    # Empty input string
    :set res [$RunGenericTestCase $res $CleanStr "" "abc123" "nothing" "" "Empty input string"]

    # Both parameters empty
    :set res [$RunGenericTestCase $res $CleanStr "" "" "nothing" "" "Both parameters empty"]

    # Edge Cases & Boundaries

    # Single character input (Allowed)
    :set res [$RunGenericTestCase $res $CleanStr "a" "abc" "nothing" "a" "Single character input (Allowed)"]

    # Single character input (Not allowed)
    :set res [$RunGenericTestCase $res $CleanStr "z" "abc" "nothing" "" "Single character input (Not allowed)"]

    # Repeating allowed characters
    :set res [$RunGenericTestCase $res $CleanStr "aaaaabbbbb" "ab" "nothing" "aaaaabbbbb" "Repeating allowed characters"]

    # Allowed set contains duplicate characters
    :set res [$RunGenericTestCase $res $CleanStr "hello-123" "l11l" "nothing" "ll1" "Allowed set contains duplicate characters"]

    # All characters in input are allowed
    :set res [$RunGenericTestCase $res $CleanStr "cleanText" "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" "nothing" "cleanText" "All characters allowed"]

    # No characters in input are allowed
    :set res [$RunGenericTestCase $res $CleanStr "123456" "abcdef" "nothing" "" "No characters allowed"]

    # Whitespaces & Formatting

    # Preserve spaces when space is in allowed characters
    :set res [$RunGenericTestCase $res $CleanStr "hello world 123" "abcdefghijklmnopqrstuvwxyz " "nothing" "hello world " "Preserve spaces when space is allowed"]

    # Strip spaces when space is not in allowed characters
    :set res [$RunGenericTestCase $res $CleanStr "h e l l o" "helo" "nothing" "hello" "Strip spaces when space is not allowed"]

    # Tabs and newlines stripped if not allowed
    :set res [$RunGenericTestCase $res $CleanStr ("line1\nline2\tval") "line12val" "nothing" "line1line2val" "Control characters stripped"]

    # Special Characters & Escaping

    # Double quotes handling in string and allowed set
    :set res [$RunGenericTestCase $res $CleanStr ("text \"with\" quotes") ("abcdefghijklmnopqrstuvwxyz\"") "nothing" ("text\"with\"quotes") "Double quotes handling"]

    # Backslashes filtering
    :set res [$RunGenericTestCase $res $CleanStr ("path\\to\\file") ("abcdefghijklmnopqrstuvwxyz\\") "nothing" ("path\\to\\file") "Backslashes filtering"]

    # Punctuation and network symbols filtering
    :set res [$RunGenericTestCase $res $CleanStr "192.168.88.1/24:80" "0123456789./" "nothing" "192.168.88.1/2480" "Punctuation and network symbols"]

    # File system path cleaning
    :set res [$RunGenericTestCase $res $CleanStr "flash/backups/cfg!.rsc" "abcdefghijklmnopqrstuvwxyz/." "nothing" "flash/backups/cfg.rsc" "File system path cleaning"]

    # Case Sensitivity & Types

    # Strict upper/lower case sensitivity
    :set res [$RunGenericTestCase $res $CleanStr "ABCdef" "abc" "nothing" "" "Case sensitivity in allowed list"]

    # Non-string input parameter (Integer type)
    :set res [$RunGenericTestCase $res $CleanStr 123456 "135" "nothing" "135" "Non-string input parameter (Integer type)"]

    # Non-string allowed parameter (Integer type)
    :set res [$RunGenericTestCase $res $CleanStr "abc123def456" 234 "nothing" "234" "Non-string allowed parameter (Integer type)"]

    # Boolean type parameters passed as input
    :set res [$RunGenericTestCase $res $CleanStr true "tru" "nothing" "tru" "Boolean type input parameter"]

    # IP address object type passed as input
    :set res [$RunGenericTestCase $res $CleanStr 192.168.88.1 "0123456789" "nothing" "192168881" "IP address type input parameter"]

    :put "Testing completed."
    :return $res
}
