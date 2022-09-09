clear classes
clc

testPath = 'test';

testFiles = ls([testPath '/*.op2']);

for iTestFile = 1:size(testFiles, 1)
	[~, testFileName, testFileExt] = fileparts(testFiles(iTestFile, :));
	mOP2_test(fullfile(testPath, [testFileName testFileExt]));
end
