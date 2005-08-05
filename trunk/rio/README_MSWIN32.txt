Copyright (c) 2005, Christopher Kleckner
All rights reserved

This file is part of the Rio library for ruby.

Rio is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

Rio is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Rio; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA


<b>Rio is pre-alpha software. 
The documented interface and behavior is subject to change without notice.</b>

Currently support for MSWin paths involves simply ignoring the drive portion (C: etc)
of paths returned by by the underlying ruby libraries (that's right, it just
lopps that sob right off) While this is clearly unacceptable behavior, it is unclear
to the author whether support for paths that can not be represented per RFC1738 is
a feature of interest to anyone.

There is a relatively small amount of code that would have to change to add this
support in the future, and such support may be included in a future release.

For the time being, the subset of tests in 'test/mswin32.rb' do pass when running 
under the mswin32 port of ruby. By far the majority of the tests that are excluded
are excluded because they use symlinks, not because of the differences in path
representations.



