# About

Prepo is a paper management system I am using to organise my reading based
on recommendations made by Alistair Moffat.

# Install

Requires pdfinfo to export the pdf details. 
Your system might have it already installed. Version 0.26.5 has been tested.
Download and install from here otherwise:
https://www.xpdfreader.com/download.html

Run `bundle install` to install the ruby dependencies.
If you don't have bundler installed, `gem install bundler` and try again.

Now add to your bashrc or zshrc where you would like your prepo repo stored:
```
export PREPO_ROOT="$HOME/prepo"
export PATH="$PREPO_ROOT/bin:$PATH"
```

# Usage

## Adding Existing Papers To The Repo

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

The generated bibtex in `this.bib` now looks like:
```
@inproceedings{bgmllsmc18-trec,
  author = {R. Benham and L. Gallagher and J. Mackenzie and B. Liu and X. Lu and F. Scholer and A. Moffat and J. S. Culpepper},
  title = {RMIT at the 2018 TREC CORE Track},
  booktitle = trec,
  year = {2018}
}
```
Now change directory into this new folder, type some notes about the paper in the pre-filled `p.tex` file and run `make` to generate a "scratchpad" file for your reference later.

Sections inside the `p.tex` file in the format:
```
% PREPO: s1
\citet{bgmllsmc18-trec} produced the second-most effective TREC run for the CORE 2018 exercise using a combination of query variations, fusion and shallow judgments.
% ENDPREPO
```

Can be used later to bootstrap writing background sections in publications. 

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

This is intended to overwrite `p.bib` in the current directory, but I don't want the 
default behaviour to be destructive. Do so with care.

Note that this only supports entries you have stored in prepo and ignores anything else.
For physical assets that do not have a digital PDF resource, form a `this.bib` file
in a folder that matches the author year venue naming convention in your papers folder.

## Generating drafts for new work

To generate a draft for new work, run:

`$ prepo.sh draft <paper_code>`

Where paper code adheres to the normal short name convention (e.g. `bgmllsmc18-trec`).

If you have been using PREPO sections in the format above in your p.tex, you can bootstrap
your writing.

To bootstrap writing a background section, in this directory form a `bootstrap.prepo` file of comma-seperated values matching the form `<paper code>,<section code>` e.g.:
```
bgmllsmc18-trec,s1
gmc18-adcs,para
```
In this example, we want only a sentence on `bgmllsmc18-trec` and a full paragraph on `gmc18-adcs`. These entries must be on new lines and follow the example above verbatim in order to work correctly.

Run `prepo_bootstrap.rb bootstrap.prepo bgtest` to take these sections in place as they appear in their respective
scratchpad file. A `transactions.log` file is added or appended to if it already exists in each of these folders
which will produce a warning next time if you try to re-use this text in another publication (avoiding the issue of self-plagurism).

The log file takes the form `<paper code>,<section name>,<timestamp>,<MD5 signature of the text>`.

An example output:
```
$ prepo_bootstrap.rb bootstrap.prepo bgtest
Previous transactions for these papers:
Transactions for bgmllsmc18-trec before this:
bgmllsmc18-trec,s1,bgtest,2018-12-10 17:53:35 +1100,5eac3b50f2b1868c3ba6d49f1f6ac99f
Transactions for gmc18-adcs before this:
gmc18-adcs,para,bgtest,2018-12-10 17:53:35 +1100,3c6b9944c5ef9a3a3555fd140689caf3


Generating output and recording transactions:
\citet{bgmllsmc18-trec} showed that the blah compression codec could outperform DMX compression.
\citet{gmc18-adcs} is the paper.
```

Add the generated output to the p.tex as normal and generate the bib file for the scratchpad
as described previously to resolve the dependencies in the bootstrap method.

# TODO

- Automatically sync with git.
- Handle resources that don't have pdfs better than manually creating folders for them.

# Attribution

Paper template is adapted/derived from:
https://github.com/hrs/latex-paper-template

# License

This tool is released under the MIT license.

Copyright 2018 Rodger Benham.
