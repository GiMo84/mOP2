# Overview

mOP2 is a library for reading NASTRAN OP2 binary analysis result files from Matlab or Octave.

It focuses on low-level access to the data, speed, and ease of extensibility, but requires (minimal) understanding of the OP2 output file. It is *strongly* recommended to get a copy of the DMAP Programmer's Guide to understand which output refers to what, and to implement new output types / add support to new element types.

## Usage and concepts

Reading the binary file is performed by using the function `mOP2read(fname)`, which returns an instance of the class `mOP2info`. This instance contains the datablocks found in the file, implemented as derived classes from `mOP2block`.

### Datablock

NASTRAN creates a datablock for each requested output, for each subcase and for each element type. The datablock contains header information defining its type, and one or multiple records (each, for example, representing the various subcases).

### Record

Each record contains header information (e.g. the eigenmode frequency), output values (e.g. nodal displacements, stresses, strains...) and the respective nodes/elements IDs.

## Output values

The output values are returned as an *[m×n]* matrix or an *[1×n]* cell vector of *[m×1]* column vectors, with the number of rows *m* equal to the number of nodes/elements, and the number of columns *n* given by the element type and solution type. As such, the mapping between column and output type is specific to the element type and solution type, and it is specified in the block description, in the DMAP Programmer's Guide.

By default, the library returns the values in an *[m×n]* matrix, for performance reasons. The caveat is the more complex match between the block description and the columns indexing. A matrix cannot contain mixed numeric and character data; however, some entries (words) are four-characters-long, and are stored as their ASCII value. Each word spans therefore four columns.

If the library is told to return the values in an *[1×n]* cell vector of *[m×1]* column vectors, with the syntax `mOP2read(fname, 'cell')`, the mixed data format storage problem does not apply, and the cell pertaining to four-characters-words will contain strings. Consequently, the indexing will resemble closer the numbering from the block description.

## Installation

All files except `test_all.m` and `mOP2_test.m` must be in the path.

## Compatibility

The code has been tested on MATLAB and GNU Octave 7.2.

Octave would complain (correctly) about an implicit conversions from numeric to char, hence this warning has been suppressed in `mOP2block.m`. Caveat emptor.

# News

## v 1.1.0 has been released

This is the first public release of the library.

# License

mOP2 is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. Also see the file `LICENSE`.
