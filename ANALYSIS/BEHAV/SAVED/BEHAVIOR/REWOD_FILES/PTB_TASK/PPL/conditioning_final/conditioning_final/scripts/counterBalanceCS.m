function [list] = counterBalanceCS(participantID) % modified by Eva 1.05.2015

% This function counterbalance the CS order based on the participantID.
% Attention if the script bugs if it necessary to reset the original names
% of the images through the resetCSnames function.

if participantID == 1 || mod((participantID - 1),6) == 0;
    list = 1;
    movefile('yellow.jpg', 'CSplus.jpg');
    movefile ('green.jpg', 'CSminu.jpg');
    movefile ('red.jpg', 'Baseli.jpg');
elseif participantID == 2 || mod((participantID - 2),6) == 0;
    list = 2;
    movefile('yellow.jpg', 'CSplus.jpg');
    movefile ('green.jpg', 'Baseli.jpg');
    movefile ('red.jpg', 'CSminu.jpg');
elseif participantID == 3 || mod((participantID - 3),6) == 0;
    list = 3;
    movefile('yellow.jpg', 'CSminu.jpg');
    movefile ('green.jpg', 'CSplus.jpg');
    movefile ('red.jpg', 'Baseli.jpg');
elseif participantID == 4 || mod((participantID - 4),6) == 0;
    list = 4;
    movefile('yellow.jpg', 'CSminu.jpg');
    movefile ('green.jpg', 'Baseli.jpg');
    movefile ('red.jpg', 'CSplus.jpg');
elseif participantID == 5 || mod((participantID - 5),6) == 0;
    list = 5;
    movefile('yellow.jpg', 'Baseli.jpg');
    movefile ('green.jpg', 'CSplus.jpg');
    movefile ('red.jpg', 'CSminu.jpg');
elseif participantID == 6 || mod((participantID - 6),6) == 0;
    list = 6;
    movefile('yellow.jpg', 'Baseli.jpg');
    movefile ('green.jpg', 'CSminu.jpg');
    movefile ('red.jpg', 'CSplus.jpg');
end

listWarning = str2num(input(['the list for this participant is ' num2str(list) ' PRESS ENTER TO CONTINUE (or 1 to abort)'],'s'));
if listWarning
    var.list = list;
    resetCSnames(var);
    error ('list balancement was not confirmed for this participat !');
end

end