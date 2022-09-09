classdef mOP2block < handle
	%MOP2BLOCK Reads the blocks of a NASTRAN Output 2 Binary file
	%   This superclass and its subclasses contain the following property:
	%
	%   BLOCKINFO    See MOP2BLOCK
	%   DATA         [Only the subclasses have this property]
	%   INTERPRETER  Name of the interpreting function.
	%                'GENERIC' means that no suitable subclass has been found
	%
	%   See also MOP2READ, MOP2INFO, MOP2BLOCK_*.

	%   $Revision: 1.1.0 $  $Date: 2022/09/08 $

	%% Disclaimer
	%   Copyright (c) 2022 Giulio Molinari
	%
	%   This file is part of mOP2.
	%   mOP2 is free software: you can redistribute it and/or modify
	%   it under the terms of the GNU General Public License as published by
	%   the Free Software Foundation, either version 3 of the License, or
	%   any later version. Also see the file "LICENSE".

	properties
	end % properties
	properties(SetAccess=private)
		blockInfo
	end % properties(SetAccess=private)
	properties(Access=protected)
		interpreter
		fid
		tableFmt
	end % properties(Access=protected)
	methods
		function block = mOP2block(blockInfo, fid, tableFmt)
			if nargin ~= 0
				block.blockInfo = blockInfo;
				block.fid = fid;
				block.interpreter = 'GENERIC';
				block.tableFmt = tableFmt;
			end
		end % mOP2block
	end % methods
	methods(Access=protected)
		function dataOut = readMatrix(blockInfo, blockRecord, dataRecord, format)
			%READMATRIX reads a matrix from the currently loaded OP2
			%   DATAOUT = READMATRIX(BLOCKRECORD, DATARECORD, FORMAT) reads
			%   the matrix pointed by BLOCKRECORD (TABLESSTART, TABLESLENGTH),
			%   of the dimensions specified by DATARECORD (NUMWDE, NUM_ENTRIES),
			%   with the given data FORMAT.

			%   $Revision: 1.1.0 $  $Date: 2022/09/08 $

			if exist('OCTAVE_VERSION', 'builtin') ~= 0
				% Running Octave
				warning('off', 'Octave:num-to-str');
			end

			TablesLength = blockRecord.TablesLength;

			% Seek to starting position
			fseek(blockInfo.fid, blockRecord.TablesStart(1), -1);
			fseek(blockInfo.fid, 1*4, 0);

			% Read data
			dataOut = [];
			for i = 1:length(TablesLength)
				if (strcmp(format, 'char') || strcmp(format, 'int8=>char') || strcmp(format, 'int8'))
					% read blocks of 4 CHARs
					dataTemp = fread(blockInfo.fid, [1, 4*TablesLength(i)], format);
				else
					% read blocks of FLOAT32s/INT32s
					dataTemp = fread(blockInfo.fid, [1, TablesLength(i)], format);
				end
				fseek(blockInfo.fid, 20, 0);
				dataOut = [dataOut, dataTemp];
			end

			% Reshape output to expected dimensions
			if (strcmp(format, 'char') || strcmp(format, 'int8=>char') || strcmp(format, 'int8'))
				% blocks of 4 CHARs
				dataOut = reshape(dataOut', dataRecord.NUMWDE*4, dataRecord.num_entries)';
			elseif strcmp(format, 'AAAint8=>char')
				% blocks of 4 CHARs
				%%% Transforming in a cell array: SUPER SLOW!
				dataOut = mat2cell(reshape(dataOut', dataRecord.NUMWDE*4, dataRecord.num_entries)', ones(1, dataRecord.num_entries), 4*ones(1, dataRecord.NUMWDE));
			else
				% blocks of FLOAT32s/INT32s
				dataOut = reshape(dataOut', dataRecord.NUMWDE, dataRecord.num_entries)';
			end
		end % readMatrix

		function outData = buildTable(blockInfo, fmt, IntData, FloatData, CharData)
			% BUILDTABLE creates the output table based on the specific format
			%
			%   OUTDATA = BUILDTABLE(FMT, INTDATA, FLOATDATA, CHARDATA, OUTTYPE)
			%   builds a data table of OUTTYPE type, with columns format FMT based on INTDATA, FLOATDATA, CHARDATA
			%   FMT          list of chars (i, f, c, n) specifying whether each column is of type Integer, Float, 4*Char, or Not to be considered
			%   *DATA        table with raw read data
			%   OUTTYPE      'cell' or 'mat', whether the output should be a row of cells (each cell contains a 1D column array), or a matrix.

			%   $Revision: 1.1.0 $  $Date: 2022/09/08 $

			switch blockInfo.tableFmt
				case 'mat'
					outCols = sum(fmt == 'i')+sum(fmt=='f')+sum(fmt=='c')*4;
					outData = nan(size(IntData,1), outCols);
					curCol = 1;
					for iFmt = 1:numel(fmt)
						if fmt(iFmt) == 'n'
						elseif fmt(iFmt) == 'i'
							outData(:,curCol) = IntData(:, iFmt);
							curCol = curCol + 1;
						elseif fmt(iFmt) == 'f'
							outData(:,curCol) = FloatData(:, iFmt);
							curCol = curCol + 1;
						elseif fmt(iFmt) == 'c'
							outData(:,curCol+(0:3)) = mOP2block.getCharData(CharData, iFmt);
							curCol = curCol + 4;
						end
					end
				case 'cell'
					outCols = sum(fmt == 'i')+sum(fmt=='f')+sum(fmt=='c');
					outData = cell(1, outCols);
					curCol = 1;
					for iFmt = 1:numel(fmt)
						if fmt(iFmt) == 'n'
							curCol = curCol - 1;
						elseif fmt(iFmt) == 'i'
							outData{curCol} = IntData(:, iFmt);
						elseif fmt(iFmt) == 'f'
							outData{curCol} = FloatData(:, iFmt);
						elseif fmt(iFmt) == 'c'
							outData{curCol} = mOP2block.getCharData(CharData, iFmt);
						end
						curCol = curCol + 1;
					end
			end
		end % buildTable
	end % methods (Access=protected)

	methods(Static)
		function retval = functionCodes(item_name, func_code)
			%FUNCTIONCODES Perform NASTRAN functions on DATABLK values
			%   RETVAL = FUNCTIONCODES(ITEM_NAME, FUNC_CODE) performs function
			%   FUNC_CODE on the value referenced by ITEM_NAME.
			%
			%   Used by: READBLOCK*.
			%
			%   See also:
			%   - MD Nastran 2006 DMAP Programmer's Guide, page 840
			%   - NX Nastran DMAP Programmer's Guide 2007, page 2-5

			%   $Revision: 1.1.0 $  $Date: 2022/09/08 $

			switch func_code
				case 1
					% guides differ
					switch floor(item_name/1000)
						case {2 3 4 6}
							retval = 2;
						otherwise
							retval = 1;
					end
				case 2
					retval = mod(item_name, 100);
				case 3
					% guides differ
					retval = mod(item_name, 1000);
				case 4
					retval = floor(item_name/10);
				case 5
					retval = mod(item_name, 10);
				case 6
					if bitand(item_name, 8) ~= 0
						retval = 0;
					else
						retval = 1;
					end
				case 7
					% guides differ
					switch floor(item_name/1000)
						case {0, 2}
							retval = 0;
						case {1, 3}
							retval = 1;
						otherwise
							retval = 2;
					end
				case 8
					retval = bitand(131071, item_name);
				otherwise
					if func_code > 65535
						retval = bitand(item_name, bitand(func_code, 65535));
					else
						error('functionCodes: Wrong func_code');
					end
			end
			return
		end % functionCodes

		function outData = getCharData(inData, locations)
			% Helper for converting the location of four-chars words to bytes

			%   $Revision: 1.1.0 $  $Date: 2022/09/08 $

			locations_char = (repmat((locations-1)*4,4,1)+[1;2;3;4]);
			outData = inData(:, locations_char(:)');
		end
	end % methods(Static)
end
