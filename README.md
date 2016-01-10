# What is this?

A tool for analyzing and inspecting Ruby heap dump files. Aman Gupta has written
about [dumping heaps](http://tmm1.net/ruby21-objspace/) from the `ObjectSpace`
module. Richard Schneeman has a great writeup in two parts covering what's
inside a heap dump:

* [Part I](https://blog.codeship.com/the-definitive-guide-to-ruby-heap-dumps-part-ii/)
* [Part II](https://blog.codeship.com/the-definitive-guide-to-ruby-heap-dumps-part-i/)

# Is it any good?

Yes.

# How do I run it?

FIXME

# Developing

Clone this repository (or make your own fork) and then run `script/bootstrap` to
install all the necessary dependencies.

```sh
> git clone https://github.com/TwP/heap_hop.git
> cd heap_dump
> script/bootstrap
```

At this point you should be able to run the tests and start adding beautiful new
features.

```sh
> rake test
```

If you want to fix a bug or add a new feature, then create your own fork of the
project and open a pull request on GitHub.
