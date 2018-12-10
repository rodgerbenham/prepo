# About

Prepo is a paper management system I am using to organise my reading based
on recommendations made by Alistair Moffat.

# Install

Requires pdfinfo to export the pdf details. Version 0.26.5 has been tested.
Download and install from here:
https://www.xpdfreader.com/download.html

Run `bundle install` to install the ruby dependencies.
If you don't have bundler installed, `gem install bundler` and try again.

Now add to your bashrc or zshrc where you would like your prepo repo stored:
```
export PREPO_ROOT="$HOME/prepo"
export PATH="$PREPO_ROOT/bin:$PATH"
```

# Usage

## New Papers

Below is a walk-through for adding a new paper to the repository.

You supply a PDF as an argument to prepo, which then is then parsed and stored
in the paper repo, along with a generated bibtex entry and a scratchpad Latex file for 
generating notes on the paper formed via the paper-template directory. 

```
$ prepo.sh rmit-core18.pdf
Which venue code do you want to use for this? (from "XXX/prepo/strings-shrt.bib")
> trec (Note that this supports tab-completion)
Which year was this paper published?
> 2018
What are the page numbers? (Example format: 993--1002, enter nothing to skip)
>
Is this a (c)onference or (j)ournal paper? (j/c)
> c
Parsing paper metadata...
Generated XXX/papers/bgmllsmc18-trec successfully
```

## Searching Existing Papers

An exhaustive search through the repo using grep can search all of the metadata 
and notes by using the `prepo_search.sh` script.

```
$ prepo_search.sh Joel
XXX/papers/bgmllsmc18-trec/meta:4:Author:         Rodger Benham, Luke Gallagher, Joel Mackenzie, Binsheng Liu, Xiaolu Lu, Falk Scholer, Alistair Moffat, and J. Shane Culpepper
XXX/papers/gmc18-adcs/meta:4:Author:         Luke Gallagher, Joel Mackenzie, and J. Shane Culpepper
```

## Generating bib files for your scratchpad 

Change directory into the paper in the repo (e.g. `XXX/papers/bgmllsmc18-trec`) and 
run `prepo_bib_gen.rb`. All `citet` and `cite` references in p.tex with codes matching
the folder names in the parent directory will be parsed and the output will form a 
bib file containing only the entries you reference.

Note that this only supports entries you have stored in prepo and ignores anything else.
For physical assets that do not have a digital PDF resource, form a `this.bib` file
in a folder that matches the author year venue naming convention in your papers folder.

# TODO

- Automatically sync with git.
- Handle resources that don't have pdfs better than manually creating folders for them.

# Attribution

Paper template is adapted/derived from:
https://github.com/hrs/latex-paper-template

# License

This tool is released under the MIT license.

Copyright 2018 Rodger Benham.
