# VigenereCipher

A small program for a cryptography course in uni written in Elixir.

Encrypt and decrypt plaintext in the Swedish alphabet (superset of Latin, with åäö) with the [Vigenère Cipher (Wikipedia)](https://en.wikipedia.org/wiki/Vigen%C3%A8re_cipher) by providing your own key.

Before running the program, compile it first by running `mix` in your terminal.
This will build the `vcipher` binary.
You need to have Elixir (and Mix) and Erlang OTP installed.

## Usage

We encrypt and decrypt the `example_message.txt` file found in the repo's root folder.

```
This example paragraph was written by a real human. Oh it is a great paragraph. Certainly worth reading again, and again, and again.
```

Encoding a message:

`./vcipher --encode --key "thisisakey" < example_message.txt`

or with shorthand `./vcipher -e -k thisisakey < example_message.txt`
will output the ciphertext in a new file called `ciphertext_output.txt`:

```
joqhmmawtgxwigiyrktcmhålzåtaiiucigmslryhtuwzqiiöebhliixsrkkmtwpumgtkmibcbdzihäiywpvyiyasrydkiyiånkrätniåv
```

Decoding a ciphertext:

`./vcipher --decode --key "thisisakey" < ciphertext_output.txt`

or with shorthand `./vcipher -d -k thisisakey < ciphertext_output.txt`
will output the decoded message in a new file called `message_output.txt`:

```
thisexampleparagraphwaswrittenbyarealhumanohitisagreatparagraphcertainlyworthreadingagainandagainandagain
```
