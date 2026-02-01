# VigenereCipher

A small program for a cryptography course in uni written in Elixir.

Encrypt and decrypt plaintext in the Swedish alphabet (superset of Latin, with åäö) with the [Vigenère Cipher (Wikipedia)](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher) by providing your own key.

To run any of the programs you need to have Elixir and a compatible Erlang OTP version installed.

## Usage

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
