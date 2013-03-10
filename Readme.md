Test speedup by replacing fixtures :all with only the necessary

 - reduces fixtures :all
 - tries common fixtures first before going to one-by-one approach
 - uses zeus if zeus is running (faster)

Install
=======

    gem install fixture_reducer

Usage
=====

    fixture-reducer test/foo_test.rb test/bar_test.rb ...

TODO
====
 - tests + travis (please use rspec)
 - rspec support

Author
======
[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
