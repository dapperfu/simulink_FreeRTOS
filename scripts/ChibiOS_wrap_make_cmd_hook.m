function makeCmd = ChibiOS_wrap_make_cmd_hook(args)
% ChibiOS_wrap_make_cmd_hook - Issue make command

numProcessors = str2double(getenv('NUMBER_OF_PROCESSORS'));
switch mexext
    case 'mexw32'
        args.make=ChibiOS_getShortName(fullfile(matlabroot,'bin','win32','gmake.exe'));
    case 'mexw64'
        args.make=ChibiOS_getShortName(fullfile(matlabroot,'bin','win64','gmake.exe'));
end
makeFile = [args.modelName, '.mk'];
makeCmd =  sprintf('"%s" -j %d simulink', args.make, numProcessors);
