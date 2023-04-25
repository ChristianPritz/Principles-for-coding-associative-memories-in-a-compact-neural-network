function addresshandles(handle,io_mat)
    %Restore original state from backup
    
    quivs = findq(handle);
    daQuiv = quivs(1);
    butQuiv = quivs(2);
    daErr = daQuiv+1:butQuiv-1;
    butErr = butQuiv+1:butQuiv+numel(daErr);
    counter = 1;
    butErr = fliplr(butErr);
    daErr = fliplr(daErr);
    
    handle.Children(butQuiv).VData = handle.Children(butQuiv).VData .* io_mat(:,1:2:size(io_mat,2));
    handle.Children(daQuiv).VData = handle.Children(daQuiv).VData .* io_mat(:,2:2:size(io_mat,2));
                
    for i=1:2:size(io_mat,2)
        for j=1:size(io_mat,1)
            if io_mat(j,i) == 0
                handle.Children(butErr(counter)).FaceAlpha = 0;
                
            end
             
            
            if io_mat(j,i+1) == 0
               handle.Children(daErr(counter)).FaceAlpha = 0;
            end
             
            counter = counter + 1;
        end
    end
        
end

function quivs = findq(handle)
    quivs = [];
    for i=1:numel(handle.Children)
       if strcmp(handle.Children(i).Type,'quiver')
        quivs = [quivs,i];
       end
    end
end