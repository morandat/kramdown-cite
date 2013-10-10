kramdown-cite
=============

This gem extends the default [kramdown][] parser to support citation *a la* [pandoc][]. Citations are rendered by [citeproc-ruby][]. Currently only BibTeX input is supported.

LaTeX output expect the `natbib` package in the template.

Installation
------------

Add this line to your application Gemfile:

    gem `kramdown-cite`

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kramdown-cite

Usage
-----

### Whithin ruby

Just import the Gem and use [kramdown][] normally.

```ruby
require 'kramdown-cite'
Kramdown::Document.new(content).to_html
```

### Whithin nanoc

An helper is provided to use `kramdown-cite` instead of classic [kramdown][] in the helper directory. Drop this helper in your `<site>/helper` directory and *voilà*.

### Withing the command line

The Gem provide a `kramdown-cite` executable. Otherwise add (or replace) `kramdown-cite` in the require section of [kramdown][].

Options
-------

Currently only two options are available:

bib
 : This option allows to override the default bibliography file.

csl
 : This option allows to override the default [csl][] file.

Passing this options to [kramdown][] depends on the context usage :

command line
 : `--option value`

plain ruby
 : `Kramdown::Document.new(content, :option => value).to_html`

[nanoc][]
 : options are normal attributes (activation within a document, through a document meta-data file, or inside nanoc.yaml)

## Syntax

Syntax is currently a small subset of [pandoc][] and exists in two flavor.

inline citation
 : `@citationkey`
Parenthesis citation
 : `[@citation]` or `[@citation1;@citation2]`

Known issuses
-------------

- Currently `kramdown-cite` is not really resilient to bad usage.
- Citation syntax is only limited to basic forms
- [citeproc-ruby][] does not render well multiple citation
- Html output is not perfect

Contributing
------------

1. Fork
2. Create a topic branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

License
-------

I don't really fu**ing mind about license, thus I use the kramdown's one (i.e., I guess MIT). But honestly I don't mind, use it if you like it, claim that's yours, change it ... or don't. Life is too short to fight for useless things.

[kramdown]: http://kramdown.rubyforge.org/
[pandoc]: http://nanoc.ws/
[nanoc]: http://nanoc.ws/
[csl]: http://citationstyles.org/
[citeproc-ruby]: https://github.com/inukshuk/citeproc-ruby
[bibtex-ruby]: http://inukshuk.github.io/bibtex-ruby/
