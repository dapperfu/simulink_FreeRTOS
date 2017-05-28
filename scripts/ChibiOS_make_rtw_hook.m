function ChibiOS_make_rtw_hook(hookMethod,modelName,rtwroot,templateMakefile,buildOpts,buildArgs)
% ERT_MAKE_RTW_HOOK - This is the standard ERT hook file for the build
% process (make_rtw), and implements automatic configuration of the
% models configuration parameters.  When the buildArgs option is specified
% as 'optimized_fixed_point=1' or 'optimized_floating_point=1', the model
% is configured automatically for optimized code generation.
%
% This hook file (i.e., file that implements various codegen callbacks) is
% called for system target file ert.tlc.  The file leverages
% strategic points of the build process.  A brief synopsis of the callback
% API is as follows:
%
% ert_make_rtw_hook(hookMethod, modelName, rtwroot, templateMakefile,
%                   buildOpts, buildArgs)
%
% hookMethod:
%   Specifies the stage of the build process.  Possible values are
%   entry, before_tlc, after_tlc, before_make, after_make and exit, etc.
%
% modelName:
%   Name of model.  Valid for all stages.
%
% rtwroot:
%   Reserved.
%
% templateMakefile:
%   Name of template makefile.  Valid for stages 'before_make' and 'exit'.
%
% buildOpts:
%   Valid for stages 'before_make' and 'exit', a MATLAB structure
%   containing fields
%
%   modules:
%     Char array specifying list of generated C files: model.c, model_data.c,
%     etc.
%
%   codeFormat:
%     Char array containing code format: 'RealTime', 'RealTimeMalloc',
%     'Embedded-C', and 'S-Function'
%
%   noninlinedSFcns:
%     Cell array specifying list of non-inlined S-Functions.
%
%   compilerEnvVal:
%     String specifying compiler environment variable value, e.g.,
%     D:\Applications\Microsoft Visual
%
% buildArgs:
%   Char array containing the argument to make_rtw.  When pressing the build
%   button through the Configuration Parameter Dialog, buildArgs is taken
%   verbatim from whatever follows make_rtw in the make command edit field.
%   From MATLAB, it's whatever is passed into make_rtw.  For example, its
%   'optimized_fixed_point=1' for make_rtw('optimized_fixed_point=1').
%
%   This file implements these buildArgs:
%     optimized_fixed_point=1
%     optimized_floating_point=1
%
% You are encouraged to add other configuration options, and extend the
% various callbacks to fully integrate ERT into your environment.

% Copyright 1996-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2011/10/31 06:09:30 $

fprintf('###########################################################################\n');
fprintf('#### %s: %s\n',mfilename,hookMethod);
fprintf('###########################################################################\n');
switch hookMethod
    case 'error'
        % Called if an error occurs anywhere during the build.  If no error occurs
        % during the build, then this hook will not be called.  Valid arguments
        % at this stage are hookMethod and modelName. This enables cleaning up
        % any static or global data used by this hook file.
        msg = DAStudio.message('RTW:makertw:buildAborted', modelName);
        disp(msg);
        
        
    case 'entry'
        % Called at start of code generation process (before anything happens.)
        % Valid arguments at this stage are hookMethod, modelName, and buildArgs.
        msg = DAStudio.message('RTW:makertw:enterRTWBuild', modelName);
        disp(msg);
        
    case 'before_tlc'
        % Called just prior to invoking TLC Compiler (actual code generation.)
        % Valid arguments at this stage are hookMethod, modelName, and
        % buildArgs
        
    case 'after_tlc'
        % Called just after to invoking TLC Compiler (actual code generation.)
        % Valid arguments at this stage are hookMethod, modelName, and
        % buildArgs
        
    case 'before_make'
        % Called after code generation is complete, and just prior to kicking
        % off make process (assuming code generation only is not selected.)  All
        % arguments are valid at this stage.
        fid=fopen('Makefile','w');
        fprintf(fid,'include %s.mk\n\n',modelName);
        fprintf(fid,'simulink: all\n');
        fprintf(fid,'\t### Created and Compiled %s',modelName);
        fclose(fid);
        
    case 'after_make'
        % Called after make process is complete. All arguments are valid at
        % this stage.
    case 'exit'
        % Called at the end of the build process.  All arguments are valid
        % at this stage.
        if (strcmp(get_param(modelName,'STLink_Flash'),'on') && ...
                strcmp(get_param(modelName,'GenCodeOnly'),'off'))
            STLink_Protocol=get_param(modelName,'STLink_Protocol');
            switch get_param(modelName,'STLink_Connection');
                case 'Hotplug'
                    STLink_Connection='HOTPLUG';
                case 'Reset'
                    STLink_Connection='UR';
            end
            switch get_param(modelName,'STLink_Erase')
                case 'on'
                    STLink_Erase='-ME';
                case 'off'
                    STLink_Erase='';
            end
            switch get_param(modelName,'STLink_Verify')
                case 'on'
                    STLink_Verify='-V';
                case 'off'
                    STLink_Verify='';
            end
            STLink_CMD=get_param(modelName,'STLink_CMD');
            cmd=sprintf('"%s" -c %s %s %s %s -P "build/%s.hex" %s',get_param(modelName,'Alt_STLink'), ...
                STLink_Protocol, ...
                STLink_Connection, ...
                STLink_Erase, ...
                STLink_Verify, ...
                modelName, ...
                STLink_CMD);
            if strcmp(get_param(modelName,'RTWVerbose'),'on')
                fprintf('\n\n%s\n\n',cmd);
            end
            fprintf('#### Flashing to board...');
            [s,m]=dos(cmd);
            fprintf(m);
            if s==0
                fprintf('... Succeeded.\n\n');
            else
                fprintf('... Failed.\n\n');
                error('CHIBIOS:FLASHFAILED', 'Flashing failed');
            end
        end
        
        if strcmp(get_param(modelName,'GenCodeOnly'),'off')
            msgID = 'RTW:makertw:exitRTWBuild';
        else
            msgID = 'RTW:makertw:exitRTWGenCodeOnly';
        end
        msg = DAStudio.message(msgID,modelName);
        disp(msg);
end
