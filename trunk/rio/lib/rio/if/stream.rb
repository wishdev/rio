#--
# =============================================================================== 
# Copyright (c) 2005, Christopher Kleckner
# All rights reserved
#
# This file is part of the Rio library for ruby.
#
# Rio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Rio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rio; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# =============================================================================== 
#++
#
# To create the documentation for Rio run the command
#  rake rdoc
# from the distribution directory. Then point your browser at the 'doc/rdoc' directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Rio
#
# <b>Rio is pre-alpha software. 
# The documented interface and behavior is subject to change without notice.</b>


module RIO
  class Rio
    # Calls IO#gets
    #
    # Reads the next line from the Rio; lines are separated by sep_string. 
    # A separator of nil reads the entire contents, and a zero-length separator reads 
    # the input a paragraph at a time (two successive newlines in the input separate paragraphs). 
    #
    # Returns nil if called at end of file.
    # 
    #  astring  = rio('afile.txt').gets # read the first line of afile.txt into astring
    #
    def gets(sep_string=$/) target.gets(sep_string) end

    # Slurps the contents of the rio into a string. See also Rio#contents
    #
    #  astring = rio('afile.txt').slurp # slurp the entire contents of afile.txt into astring
    # 
    # Alpha Note: Considering removing Rio#contents and Rio#slurp in favor of +to_string+. Is 
    # this the Ruby way? Is it too confusing with a +to_s+ and +to_str+ already? Is it a good idea?
    def slurp() target.slurp() end

    # Returns the contents of the rio as a string. See also Rio#slurp 
    #
    #  astring = rio('afile.txt').contents # copies the entire contents of afile.txt into astring
    #
    # Alpha Note: Considering removing Rio#contents and Rio#slurp in favor of +to_string+. Is 
    # this the Ruby way? Is it too confusing with a +to_s+ and +to_str+ already? Is it a good idea?
    def contents() target.contents() end



    # Rio#each_record
    # 
    #
    #def each_record(&block) target.each_record(&block); self end


    # Rio#each_row
    #
    #
    #def each_row(&block) target.each_row(&block); self end


    # Calls IO#lineno
    #
    # Returns the current line number of a Rio.
    #
    # The Rio will be opened for reading if not already.
    # lineno counts the number of times gets is called, rather than the number of newlines encountered --
    # so lineno will only be accurate if the file is read exclusively with line-oriented methods 
    # (Rio#readline, Rio#each_line, Rio#gets etc.)
    # 
    # See also the $. variable and Rio#recno
    #  f = rio("testfile")
    #  f.lineno   #=> 0
    #  f.gets     #=> "This is line one\n"
    #  f.lineno   #=> 1
    #  f.gets     #=> "This is line two\n"
    #  f.lineno   #=> 2
    def lineno() target.lineno() end

    # Calls IO#lineno=
    #      ario.lineno = integer    => integer
    # Manually sets the current line number to the given value. +$.+ is
    # updated only on the next read.
    #
    # f = rio("testfile")
    # f.gets                     #=> "This is line one\n"
    # $.                         #=> 1
    # f.lineno = 1000
    # f.lineno                   #=> 1000
    # $. # lineno of last read   #=> 1
    # f.gets                     #=> "This is line two\n"
    # $. # lineno of last read   #=> 1001
    #
    #
    def lineno=(integer) target.lineno = integer end

    # Returns the current record number of a Rio. The +recno+ is the index 
    # used by the grande selection methods. It represents the zero-based index of the
    # last record read. Returns nil until a record has been read.
    # 
    # see Rio#lines Rio#bytes and Rio#records
    #
    # To illustrate: Given a file containing three lines "L0\n","L1\n","L2\n"
    # and a Range (0..1)
    # Each of the following would fill ay with ["L0\n", "L1\n"]
    # 
    #  ay = []
    #  range = (0..1)
    #  ain = rio('afile').readlines
    #  ain.each_with_index do |line,i|
    #    ay << line if range === i
    #  end
    # 
    #  ay = rio('afile').lines[0..1]
    #  
    # +recno+ counts the number of times Rio#getrec or Rio#each is used to get a record. 
    # so +recno+ will only concern parts of the file read with grande methods 
    # Rio#each, Rio#[], Rio#getrec 
    # 
    # See also Rio#lineno
    #  f = rio("afile")
    #  r1 = (0..1)
    #  r2 = (100..101)
    #
    #  aout1 = []
    #  f.each { |rec|
    #    aout << rec if r1 === f.recno or r2 === f.recno
    #  }
    #
    #  aout2 = f[r1,r2]
    #
    #  aout1 == aout2 # true
    #
    def recno() target.recno() end


    # Calls IO#binmode
    #
    # Puts rio into binary mode. This is useful only in MS-DOS/Windows environments. 
    # Once a stream is in binary mode, it cannot be reset to nonbinary mode.    
    # 
    # Returns the Rio.
    #
    #  rio('afile.exe').binmode.bytes(512).to_a # read a file in 512 byte blocks
    #
    def binmode() target.binmode(); self end


    # Calls IO#flush
    #  ario.flush    => ario
    # Flushes any buffered data within _ario_ to the underlying operating
    # system (note that this is Ruby internal buffering only; the OS may
    # buffer the data as well).
    #
    def flush() target.flush(); self end


    # Calls IO#each_byte
    #  ario.each_byte {|byte| block }  => ario
    # Calls the given block once for each byte (0..255) in _ario_, passing
    # the byte as an argument.
    #
    def each_byte(*args,&block) target.each_byte(*args,&block); self end


    # Rio#each_bytes
    #
    #
    #def each_bytes(nb,*args,&block) target.each_bytes(nb,*args,&block); self end


    # Calls IO#each_line
    #  ario.each_line(sep_string=$/) {|line| block }  => ario
    # Executes the block for every line in _ario_, where lines are
    # separated by _sep_string_.
    #
    def each_line(*args,&block) target.each_line(*args,&block); self end


    # Calls IO#readlines
    #
    # Reads all of the lines in a Rio, and returns them in anArray. 
    # Lines are separated by the optional aSepString. 
    # The stream must be opened for reading or an IOerror will be raised.
    #
    #  an_array = rio('afile.txt').readlines # read afile.txt into an array
    #  an_array = rio('afile.txt').chomp.readlines # read afile.txt into an array with each line chomped
    #
    def readlines(*args,&block) target.readlines(*args,&block) end
    
    # Calls IO#readline
    #  ario.readline(sep_string=$/)   => string
    # Reads a line as with +IO#gets+, but raises an +EOFError+ on end of
    # file.
    #
    def readline(*args) target.readline(*args) end


    # Calls IO::print
    #
    # Writes the given object(s) to the Rio.  If the output record separator ($\) is not nil, 
    # it will be appended to the output. If no arguments are given, prints $_. 
    # Objects that aren't strings will be converted by calling their to_s method. 
    # Returns the Rio.
    #
    #  rio('f.txt').print("Hello Rio\n") # print the string to f.txt
    #  rio(?-).print("Hello Rio\n") # print the string to stdout
    # 
    def print(*args,&block) target.print(*args,&block); self end

    # Writes the given objects to the rio as with Rio#print and then closes the Rio. 
    # Returns the Rio.
    #
    # Equivalent to rio.print(*args).close
    #
    #  rio('f.txt').print!("Hello Rio\n") # print the string to f.txt then close it
    #
    def print!(*args,&block) target.print!(*args,&block); self end


    # Writes the given objects to the rio as with Rio#printf and then closes the rio. 
    # Returns the rio.
    #
    # Equivalent to rio.printf(*args).close
    #
    def printf!(*argv) target.printf!(*argv); self end


    # Calls IO#printf
    #  ario.printf(format_string [, obj, ...] )   => ario
    # Formats and writes to _ario_, converting parameters under control of
    # the format string. See +Kernel#sprintf+ for details.
    #
    def printf(*argv) target.printf(*argv); self end


    # Writes the given objects to the rio as with Rio#putc and then closes the rio. 
    # Returns the rio.
    #
    # Equivalent to rio.putc(*args).close
    #
    def putc!(*argv) target.putc!(*argv); self end


    # Calls IO#putc
    #  ario.putc(obj)    => ario
    # If _obj_ is +Numeric+, write the character whose code is _obj_,
    # otherwise write the first character of the string representation of
    # _obj_ to _ario_.
    #
    #  stdout = rio(?-)
    #  stdout.putc "A"
    #  stdout.putc 65
    #
    # _produces:_
    #
    #  AA
    #
    def putc(*argv) target.putc(*argv); self end


    # Calls IO#puts
    #
    # Writes the given objects to the rio as with  Rio#print  . 
    # Writes a record separator (typically a newline) after any that do not already end with a newline sequence. 
    # If called with an array argument, writes each element on a new line. 
    # If called without arguments, outputs a single record separator.
    # Returns the rio.
    def puts(*args) target.puts(*args); self end

    # Writes the given objects to the rio as with Rio#puts and then closes the rio. 
    # Returns the rio.
    #
    # Equivalent to rio.puts(*args).close
    #
    #  rio('f.txt').puts!('Hello Rio') # print the string to f.txt then close it
    #
    def puts!(*args) target.puts!(*args); self end


    # Writes the given objects to the rio as with Rio#write and then closes the rio. 
    #
    # Equivalent to
    #  ario.write(*args)
    #  ario.close
    #
    def write!(*argv) target.write!(*argv); self end


    # Calls IO#write
    #  ario.write(string)    => integer
    # Writes the given string to _ario_. If the argument is not a string, 
    # it will be converted to a
    # string using +to_s+. Returns the number of bytes written.
    #
    def write(*argv) target.write(*argv); self end


    # Calls IO#eof?
    #  ario.eof     => true or false
    # Returns true if _ario_ is at end of file. The stream must be opened
    # for reading or an +IOError+ will be raised.
    #
    def eof?() target.eof? end

    # Provides direct access to the IO handle (as would be returned by ::IO#new) *with* filtering. 
    # Reading from and writing to this handle will be affected
    # by such things as Rio#gzip and Rio#chomp if they were specified for the Rio. 
    # 
    # Compare this with Rio#ios
    #
    def ioh(*args) target.ioh() end

    # Provides direct access to the IO handle (as would be returned by ::IO#new) 
    # Reading from and writing to this handle 
    # is *not* affected by such things as Rio#gzip and Rio#chomp.
    #
    # Compare this with Rio#ioh
    #
    def ios(*args) target.ios() end

    #def open(m,*args) target.open(m,*args); self end

    # Explicitly set the mode with which a Rio will be opened.
    #   ario.mode('r+')   => ario
    # Normally one needs never open a Rio or specify its mode -- the mode is determined by the
    # operation the Rio is asked to perform. (i.e. Rio#print requires write access, Rio#readlines requires
    # read access). However there are times when one wishes to be specific about the mode with which a Rio
    # will be opened. Note that explicitly setting the mode overrides all of Rio's internal mode
    # logic. If a mode is specified via Rio#mode or Rio#open that mode will be used. Period.
    #
    # Returns the Rio.
    #
    # See also Rio#mode?
    # 
    # If the mode is given as a String, it must be one of the values listed in the following table.
    #
    #   Mode |  Meaning
    #   -----+--------------------------------------------------------
    #   "r"  |  Read-only, starts at beginning of file  (default mode).
    #   -----+--------------------------------------------------------
    #   "r+" |  Read-write, starts at beginning of file.
    #   -----+--------------------------------------------------------
    #   "w"  |  Write-only, truncates existing file
    #        |  to zero length or creates a new file for writing.
    #   -----+--------------------------------------------------------
    #   "w+" |  Read-write, truncates existing file to zero length
    #        |  or creates a new file for reading and writing.
    #   -----+--------------------------------------------------------
    #   "a"  |  Write-only, starts at end of file if file exists,
    #        |  otherwise creates a new file for writing.
    #   -----+--------------------------------------------------------
    #   "a+" |  Read-write, starts at end of file if file exists,
    #        |  otherwise creates a new file for reading and
    #        |  writing.
    #   -----+--------------------------------------------------------
    #    "b" |  (DOS/Windows only) Binary file mode (may appear with
    #        |  any of the key letters listed above).
    #
    #  ario = rio('afile').mode('r+').nocloseoneof # file will be opened in r+ mode
    #                                             # don't want the file closed at eof
    #  ario.seek(apos).gets # read the string at apos in afile
    #  ario.rewind.gets # read the string at the beginning of the file
    #  ario.close
    #
    # TODO:
    # * Add support for integer modes
    #
    def mode(m,*args) target.mode(m,*args); self end

    # Query a Rio's mode
    #    ario.mode?      #=> a mode string
    #
    # See Rio#mode
    #
    #  ario = rio('afile')
    #  ario.puts("Hello World") 
    #  ario.mode?      #=> 'w' Rio#puts requires write access
    #
    #  ario = rio('afile')
    #  ario.gets
    #  ario.mode?      #=> 'r' Rio#gets requires read access
    #
    #  ario = rio('afile').mode('w+').nocloseoneof
    #  ario.gets
    #  ario.mode?      #=> 'w+' Set explictly
    #
    def mode?() target.mode?() end



    # Calls IO#close
    #      ario.close   => nil
    # Closes _ario_ and flushes any pending writes to the operating
    # system. The stream is unavailable for any further data operations;
    # an +IOError+ is raised if such an attempt is made. I/O streams are
    # automatically closed when they are claimed by the garbage
    # collector.
    #
    def close() target.close(); self end

    # Calls IO#fcntl
    #      ario.fcntl(integer_cmd, arg)    => integer
    # Provides a mechanism for issuing low-level commands to control or
    # query file-oriented I/O streams. Arguments and results are platform
    # dependent. If _arg_ is a number, its value is passed directly. If
    # it is a string, it is interpreted as a binary sequence of bytes
    # (+Array#pack+ might be a useful way to build this string). On Unix
    # platforms, see +fcntl(2)+ for details. Not implemented on all
    # platforms.
    #
    #
    def fcntl(integer_cmd,arg) target.fcntl(integer_cmd,arg) end

    # Calls IO#ioctl
    #      ario.ioctl(integer_cmd, arg)    => integer
    # Provides a mechanism for issuing low-level commands to control or
    # query I/O devices. Arguments and results are platform dependent. If
    # _arg_ is a number, its value is passed directly. If it is a string,
    # it is interpreted as a binary sequence of bytes. On Unix platforms,
    # see +ioctl(2)+ for details. Not implemented on all platforms.
    #
    #
    def ioctl(integer_cmd,arg) target.ioctl(integer_cmd,arg) end

    # Calls IO#fileno
    #      ario.fileno    => fixnum
    #      ario.to_i      => fixnum
    # Returns an integer representing the numeric file descriptor for
    # _ario_.
    #
    def fileno() target.fileno() end


    # Calls IO#fsync
    #      ario.fsync   => ario
    # Immediately writes all buffered data in _ario_ to disk and
    # return _ario_. 
    # Does nothing if the underlying operating system does not support
    # _fsync(2)_. Note that +fsync+ differs from using Rio#sync. The
    # latter ensures that data is flushed from Ruby's buffers, but
    # doesn't not guarantee that the underlying operating system actually
    # writes it to disk.
    #
    def fsync() target.fsync end

    # Calls IO#pid
    #  ario.pid    => fixnum
    # Returns the process ID of a child process associated with _ario_.
    # This will be set by +IO::popen+.
    #
    # pipe = IO.popen("-")
    # if pipe
    # $stderr.puts "In parent, child pid is #{pipe.pid}"
    # else
    # $stderr.puts "In child, pid is #{$$}"
    # end
    #
    # _produces:_
    #
    # In child, pid is 26209
    # In parent, child pid is 26209
    #
    #


    # Calls IO#putc
    #      ario.putc(obj)    => obj
    # If _obj_ is +Numeric+, write the character whose code is _obj_,
    # otherwise write the first character of the string representation of
    # _obj_ to _ario_.
    #
    # $stdout.putc "A"
    # $stdout.putc 65
    #
    # _produces:_
    #
    # AA
    #
    #


    # Calls IO#getc
    #      ario.getc   => fixnum or nil
    # Gets the next 8-bit byte (0..255) from _ario_. Returns +nil+ if
    # called at end of file.
    #
    # f = File.new("testfile")
    # f.getc   #=> 84
    # f.getc   #=> 104
    #
    #

    # Calls IO#readchar
    #      ario.readchar   => fixnum
    # Reads a character as with +IO#getc+, but raises an +EOFError+ on
    # end of file.
    #
    #

    # Calls IO#reopen
    #      ario.reopen(other_IO)         => ios 
    #      ario.reopen(path, mode_str)   => ios
    # Reassociates _ario_ with the I/O stream given in _other_IO_ or to a
    # new stream opened on _path_. This may dynamically change the actual
    # class of this stream.
    #
    # f1 = File.new("testfile")
    # f2 = File.new("testfile")
    # f2.readlines[0]   #=> "This is line one\n"
    # f2.reopen(f1)     #=> #<File:testfile>
    # f2.readlines[0]   #=> "This is line one\n"
    #
    #

    # Calls IO#stat
    #      ario.stat    => stat
    # Returns status information for _ario_ as an object of type
    # +File::Stat+.
    #
    # f = File.new("testfile")
    # s = f.stat
    # "%o" % s.mode   #=> "100644"
    # s.blksize       #=> 4096
    # s.atime         #=> Wed Apr 09 08:53:54 CDT 2003
    #
    #

    # Calls IO#tell
    #      ario.pos     => integer
    #      ario.tell    => integer
    # Returns the current offset (in bytes) of _ario_.
    #
    # f = rio("testfile")
    # f.pos    #=> 0
    # f.gets   #=> "This is line one\n"
    # f.pos    #=> 17
    #
    #

    # Calls IO#to_i
    #   to_i()
    # Alias for #fileno
    #
    #

    # Calls IO#to_io
    #  ario.to_io -> ios
    # Returns _ario_.
    #
    #

    # Calls IO#tty?
    #  ario.tty?     => true or false
    # Returns +true+ if _ario_ is associated with a terminal device (tty),
    # +false+ otherwise.
    #
    #  rio("testfile").tty?   #=> false
    #  rio("/dev/tty").tty?   #=> true
    #
    #
    def tty?() target.tty?() end

    # Calls IO#ungetc
    #  ario.ungetc(integer)   => ario
    # Pushes back one character (passed as a parameter) onto _ario_, such
    # that a subsequent buffered read will return it. Only one character
    # may be pushed back before a subsequent read operation (that is, you
    # will be able to read only the last of several characters that have
    # been pushed back).
    #
    #  f = rio("testfile")        #=> #<Rio:testfile>
    #  c = f.getc                 #=> 84
    #  f.ungetc(c).getc           #=> 84
    #
    def ungetc(*args) target.ungetc(*args); self end
    
  end
end
