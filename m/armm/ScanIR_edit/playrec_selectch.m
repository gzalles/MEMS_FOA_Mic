function signal = playrec_selectch (out_signal, srate, out_ch, in_ch, rec_len)

% signal:
% - the recorded signal
% - an [M x N] matrix where each row specifies one sound
%   channel and each column contains one sample per channel

% out_signal:
% - the signal to be output
% - an [M x N] matrix where each row specifies one sound
%   channel and each column contains one sample per channel
% - samples need to be within -1 to +1

% srate:
% - the sample rate

% out_ch:
% - an array of output channels

% in_ch:
% - the number of input channels
% - each channel up to in_ch will be active for recording
% - must be an integer
%
% e.g. y = playrec_selectch(mysignal, 44100, 1, 1, 3); plays mysignal on
% channel 1, and records a 3-sec signal

% rec_len
% - how long to record, in seconds


[M N] = size(out_signal);


% check arguments; provide default values for those not given
% out_signal must be passed, so an error is thrown if it is not
if (nargin < 1) error('Must provide an output signal'); end
if (nargin < 2) srate = 44100; end
if (nargin < 3) out_ch = [1:M]; end
if (nargin < 4) in_ch = 1; end
if (nargin < 5) rec_len = N / srate;
elseif (nargin > 5) error('Too many inputs to function'); end


% the total number of output channels
num_out_ch = max(out_ch);

% a zero matrix of size: num_out_ch x N
out_matrix = zeros(num_out_ch, N);

% the channels specified by the array out_ch will be replaced with
% audio data; the rest will be left as silence. this is a work-around
% because the 'selectchannels' option provided by PsychAudioPort is
% only supported for MS-Windows
%
% out_signal[i] will be played through out_ch[i]
for i=1:length(out_ch)
    out_matrix(out_ch(i),1:N) = out_signal(i,1:N);
end


% if the number of output channels as specified implicitly by out_signal
% exceeds the explicit number of output channels specified by out_ch,
% throw an error
if (M ~= length(out_ch))
    disp(M);
    disp(out_ch);
    error('Number of channels in out_signal must equal length of out_ch');
end

% if the duration of out_signal is less than the specified record duration,
% zero-pad the end of out_signal to achieve the correct duration
if (N < (rec_len*srate))
    pad = zeros(num_out_ch,round(rec_len*srate) - N);
    out_matrix = [out_matrix, pad];
end

if (num_out_ch == 1)
    out_matrix = [ out_matrix; zeros( 1, length(out_matrix) ) ];
    num_out_ch = 2;
end

InitializePsychSound;
PsychPortAudio('GetDevices');
pahandle = PsychPortAudio('Open', [], 3, 0, srate, [num_out_ch, in_ch]);
PsychPortAudio('FillBuffer', pahandle, out_matrix);
PsychPortAudio('GetAudioData', pahandle, rec_len);
PsychPortAudio('Start', pahandle);
WaitSecs(rec_len);
PsychPortAudio('Stop', pahandle,1);
[signal] = PsychPortAudio('GetAudioData', pahandle);
PsychPortAudio('Close');
