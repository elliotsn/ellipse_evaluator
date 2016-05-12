% Save the plot in the current axes as an image file.
% All the handles in the structure of object handles are copied to the new
% figure. Acceptable fields are: hAx and hLeg.
% Full path to the file and the file extension are passed.
function success = writeAx(h, fpath, ext)
    % There is no direct way to print a specific axes from a 
    % figure window, because the print routine is associated 
    % with the figure window rather than an axes. Use the 
    % COPYOBJ function to copy the required axes to a new 
    % figure and then print that figure window.
    try
        hF =  figure('visible', 'off',...
                     'Units', 'centimeters',...
                     'PaperSize', [14 9.9],...
                     'PaperPositionMode', 'manual',...
                     'PaperPosition',[1 1 12 7.57],...
                     'PaperOrientation','Portrait',...
                     'PaperType', 'A5');
                     
        % Copy axes into the new figure
        hAx = copyobj(h.hAx, hF);
        % If legend exists, copy it too.
        if ~isempty(h.hLeg)
            copyobj(h.hLeg, hF);
        end
        
        % Resize the axes to the full page.
        hAx.Units = 'normalized';
        hAx.Position = [.075 .075 .85 .85];
        saveas(hF, fpath, ext);
        close(hF);
        success = true;
    catch
        success = [];
    end
end