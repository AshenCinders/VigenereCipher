# VigenereCipher

Three small programs (`crypt`, `freq`, and `crack`) for a cryptography course in uni written in Elixir.
All programs share a large portion of the code, and are run using mix tasks.

`crypt` lets you encrypt and decrypt plaintext (messages)
in the Swedish alphabet (superset of Latin, with åäö) with the
[Vigenère Cipher (Wikipedia)](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher) by providing your own key.
Unlike other similar programs, `crypt` removes all spacing and punctuation (and other characters not in the alphabet),
which improves the entropy but the decoded text is harder to read.
Note that numbers are not included in the alphabet, so get stripped out also.

`freq` lets you calculate the approximate letter frequency of the Swedish alphabet by supplying a sample text.

`crack` lets you attempt to crack ciphertexts encrypted with `crypt` or equivalent programs.

**To run any of the programs you need to have Elixir and a compatible Erlang OTP version installed.**
**You also need to run `mix deps.get` to install Poison, which is a JSON library used by the `freq` and `crack` programs to handle letter frquency data.**

## Encrypting/decrypting a textfile using `crypt`

We encrypt and decrypt the `example_message.txt` file found in the repo's root folder.

```
This example paragraph was written by a real human. Oh it is a great paragraph. Certainly worth reading again, and again, and again.
```

Encoding a message:

`mix crypt --encode --key "thisisakey" < example_message.txt`

or with shorthand `mix crypt -e -k thisisakey < example_message.txt`
will output the ciphertext in a new file called `ciphertext_output.txt`:

```
joqhmmawtgxwigiyrktcmhålzåtaiiucigmslryhtuwzqiiöebhliixsrkkmtwpumgtkmibcbdzihäiywpvyiyasrydkiyiånkrätniåv
```

Decoding a ciphertext:

`mix crypt --decode --key "thisisakey" < ciphertext_output.txt`

or with shorthand `mix crypt -d -k thisisakey < ciphertext_output.txt`
will output the decoded message in a new file called `message_output.txt`:

```
thisexampleparagraphwaswrittenbyarealhumanohitisagreatparagraphcertainlyworthreadingagainandagainandagain
```

## Calculating letter frequency using `freq`

The repo includes a large textfile in swedish (`frequency_calc_sample.txt`) that has been used to calculate the Swedish letter frequency for generic text.
Its copyright has expired, has been downloaded from https://runeberg.org/resaliten/ and been manually edited to remove metadata and information such as table of contents and page heading that could skew the calculation.

We calculate the approximated letter frequency
(numbers normalized as a floats where all letters sum to 1)
of the Swedish language using this file:

`mix freq < frequency_calc_sample.txt`

This outputs the result in the `fraction_map.json` file, which gets used by the `crack` program.

## Cracking a Swedish Vigenère ciphertext using `crack`

TODO
