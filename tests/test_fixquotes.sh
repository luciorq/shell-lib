cp tests/test_fixquotes.txt tests/test-quotes.txt
bash ./fixquotes.sh tests/test-quotes.txt
cat tests/test-quotes.txt
rm -f tests/test-quotes.txt
