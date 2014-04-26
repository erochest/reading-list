
# reading-list

A system for packaging pages I&#39;ve bookmarked into ebooks.

## Installation

To install this, just download it and use `cabal`:

```bash
cd reading-list
cabal install
```

## Processes

* Starts from a text file listing links.
* Uses `wrex` to download the resources.
* Uses a clone of one of these libraries to get the pages' contents:
  - http://tika.apache.org/ (the HTML parser in this library will probably be
    the best option)
  - https://code.google.com/p/boilerpipe/
* Store metadata about the articles in yaml headers
  - source
  - date accessed
  - date written
  - title
  - author
* Uses topic modeling to divide the articles into pages
* Order by date written
* Bundle only so many (10 or 20) into an epub
  - include the top words for the topic represented by the ebook
* Uses pandoc to convert the articles into epubs
* Uses kindlegen to convert the epubs into mobis

