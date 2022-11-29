function [results,revRes] = doStats(paths,labels,interval,refPoint)
    
        results = nan(numel(paths)*30,18);
        revRes = nan(numel(paths)*30,13);
        aLast = 1;
        rLast = 1;
        for i=1:numel(paths)
            % deviation angle and speed
            iRes = pathStats( paths{i},labels(i,:), refPoint,interval);
            [~,numDay] = limDays(labels(i,1),'01-Jan-2000');
            iRes(:,18) = repmat(numDay,size(iRes,1),1); 
            results(aLast(1):aLast(1)+size(iRes,1)-1,:) = iRes; 

            % reversals
            iRev = reversals( paths{i},refPoint);
            iRev(:,13) = repmat(numDay,size(iRev,1),1);
            revRes(rLast(1):rLast(1)+size(iRev,1)-1,:) = iRev;
    
            aLast = find(sum(isnan(results),2) == size(results,2) ==1);
            rLast = find(sum(isnan(revRes),2) == size(revRes,2) ==1);
        end
        results(sum(isnan(results),2) == size(results,2),:) = [];
        revRes(sum(isnan(revRes),2) == size(revRes,2),:) = [];
end

function [ results ] = pathStats( path,labels, refPoint, bin )
   
    frameRate = 3.6; %hardcoded since static
    results = nan(ceil(size(path,1)/24),18);
    path(sum(isnan(path),2) > 0,:) = [];
    time = path(:,3);
    path = path(:,[1,2]);
    rp = refPoint;
    showTrack = false;
    
    if showTrack 
       figure();
       plot(path(:,1),path(:,2),'LineWidth',5) 
       pbaspect([1,1,1]);
       hold on 
       scatter(path(1,1),path(1,2),200,'LineWidth',2)
       scatter(path(size(path,1),1),path(size(path,1),2),400,'+','LineWidth',2)
    end
    
    TID = str2double(labels{3}); 
    refPoint = refPoint(1,:);
    counter = 1;
    for i=1:bin:size(path,1)
      
      startPPath = path(i,:);
      startTime = time(i,:);
      if i+bin <= size(path,1)
        segment = path(i+1:i+bin,:);
      else
        segment = path(i+1:size(path,1),:);
      end
      
      eP = [mean(segment(:,1)),mean(segment(:,2))];
      trackV = eP-startPPath;
      homeV =  refPoint - startPPath;
      relP = startPPath - refPoint;
      if showTrack
        localHV = homeV * (0.1/(abs(sum(homeV))));
      end
      projV = projection(trackV,homeV);
      ang = acosd(dot(homeV,trackV)/(norm(homeV)*norm(trackV)));
      d = diff(segment);
      L = sum(sqrt(sum(d.*d,2)));
      vel = L/(size(segment,1)/frameRate); 
      relPor = norm(projV)/norm(trackV);
      if isempty(segment)
        detour1 = nan;
        detour2 = nan;
      else   
          sVec= segment(size(segment,1),:) - startPPath;
          detour1 = L/norm(sVec);
          detour2 = L/norm(trackV);
      end
      if ang > 90
        relPor = relPor * -1;
      end
      %results structure:
      % [relPor(1),ang(2),x(3),y(4),dist(5),trackVx(6),trackVy(7),vel(8),L(9),
      % rP1x(10),rP1y(11),rP2x(12),rP2y(13),detour1(14),detour2(15),startTime(16),trackID(17),
      % dayIndicatorPlacholder(18)];
      results(counter,:) = [relPor,ang,relP,pdist([startPPath;refPoint]),trackV,vel,L,rp(1,:),...
          rp(2,:),detour1,detour2,startTime,TID,nan];
      counter = counter + 1; 
      if showTrack
        
        subTrack = [startPPath;segment];
        plot(subTrack(:,1),subTrack(:,2));
        
        quiver(startPPath(1),startPPath(2),localHV(1),localHV(2),0,'k','LineWidth',2);
        quiver(startPPath(1),startPPath(2),trackV(1),trackV(2),0,'r','LineWidth',2);
        quiver(startPPath(1),startPPath(2),projV(1),projV(2),0,'g','LineWidth',2);
        
      end

      
    end
    if showTrack
        
        hold off
        ax = gca;
        xl = ax.XLim;
        yl = ax.YLim;
        
        yl = yl(2)-yl(1);
        xl = xl(2)-xl(1);
        pbaspect([xl/xl,yl/xl,1]);
   end
    
end

function [P] = projection(A,B)
    P= (dot(A,B)/norm(B)^2)*B;
end

function [days,cDays] = limDays(days,dDay)
    
    dDay = date2num(dDay);
    cDays = cellfun(@date2num, days,'UniformOutput',false);
    cDays = cell2mat(cDays);
    days = days(cDays >= dDay); 
end



function [num] = date2num(day)

    months ={'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov',...
        'Dec'};
    start = regexp(day,'\d');
    
    days = str2double(day(start(1)))*10 + str2double(day(start(2)));
    year =  str2double(day(start(3)+2))*10 + str2double(day(start(3)+3)) - 19;
    
    start = regexp(day,'-');
    month = day(start(1)+1:start(2)-1);
    
    mScore = [];
    for i=1:numel(months)
       if strcmp(month,months{i})
        mScore = (i-1)*30;
       end 
    end
    score = days + mScore;
    if year == -1
        num = score;
    else 
        num = 365 + score;
    end
         
end

function [ results ] = reversals(path,refPoint )

    
    %results are strucktured as follows
    threshold = 140;%140; % hardcoded
    path(sum(isnan(path),2) > 0,:) = [];
    time = path(:,3);
    path = path(:,[1,2]);
    %rotate the tracks ----------------------------------------------------
    rP = refPoint;
    %----------------------------------------------------------------------
    [path,time] =  elimHolds(path,time);
    path = [smooth(path(:,1),3),smooth(path(:,2),3)];
    d = diff(path);
    L = sum(sqrt(sum(d.*d,2)));
    vel = L/(size(path,1)/3.6); %hardcoded
    [dAng,pos,time] = detectReversals(path,time,threshold,L);
    idx = dAng<threshold;
    dAng(idx) = [];
    pos(idx,:) = [];
    time(idx) = [];
    dis = pdist([0,0;pos]);
    dis = dis(1:size(pos,1));
    uniqueIdx = rand(1,1)*10^6;
    %r1 = repmat(rP(1,:),size(dAng,1),1);
    %r2 = repmat(rP(2,:),size(dAng,1),1);
    x = nanmean(pos(:,1));
    y = nanmean(pos(:,2));
    dis = nanmean(dis);
    den = numel(dAng)/L;
    time = nanmean(time);
    results = [den,x,y,dis',time,L,vel,uniqueIdx,rP(1,:),rP(2,:),nan];

end


function [dAng,pos,timeOut] = detectReversals(tracks,time,threshold,L)
    showTrack = false;
    if showTrack
    %plot----------------------------------------------------------------------    
        figure();
        subplot(2,1,1), hold on 

         for i=2:size(tracks,1) 

             plot([tracks(i,1),tracks(i-1,1)],[tracks(i,2),tracks(i-1,2)],'color','b')
             pbaspect([1 1 1])
         end
    %plot----------------------------------------------------------------------
    end
    dAng = nan(size(tracks,1)-2,1);
    counter = 1; 
    for i=3:size(tracks,1) 
        x1 = tracks(i,1)-tracks(i-1,1);
        y1 = tracks(i,2)-tracks(i-1,2);
        trackV = [x1,y1];
        x2 = tracks(i-1,1)-tracks(i-2,1);
        y2 = tracks(i-1,2)-tracks(i-2,2);
        homeV = [x2,y2];
        if sum(abs(trackV - homeV)) < 10^-5
            ang = 0;
        else 
            CosTheta = dot(homeV,trackV)/(norm(homeV)*norm(trackV));
            ang = acosd(CosTheta);
        end
        if ~isreal(ang)
           ang = acosd(round(CosTheta));
        end
        dAng(counter) = ang;
        counter = counter +1;
    end
        %dAng = diffAng(angs);
    pos = tracks(2:size(tracks,1)-1,:);
    timeOut = time(2:size(time,1)-1,:);
    %this filters flickering-----------------------------------------------
    % a minimum of 3 frames backward movement.....
    ups = dAng>threshold;
    pLocs = strfind(ups',[1 0 0 0]);
    %check if there are peaks within the last 6 frames and add it back...
    lp = dAng(end-2:end) > threshold;
    lp = find(lp == 1);
    k = numel(dAng)-3;
    if ~isempty(lp)
        pLocs = [pLocs,k+lp(1)];
    end
    idces = 1:length(ups);
    idces(pLocs) = [];
    
    if showTrack
%plot----------------------------------------------------------------------    
        idx = round(dAng*64/180);
        idx(idx == 0) = 1;
        try
            colors = cmap(idx,:); 
        catch
            colors = [0 0 0]
        end
        scatter(pos(:,1),pos(:,2),10,colors,'filled'); 
        scatter(pos(pLocs,1),pos(pLocs,2),100,'o'); 
        hold off
        subplot(2,1,2),plot(dAng);
        hold on
        plot([1,numel(dAng)],[threshold,threshold],'color','r');
        scatter(1:numel(dAng),dAng,25,colors,'filled');
        scatter(pLocs,repmat(185,1,numel(pLocs)),100,'v','filled','MarkerFaceColor',[0 0 0]);
        hold off
        ups(idces) = 0;
        txt = ['length is : ',num2str(L),' rev. rate is: ',num2str(numel(pLocs)/L)];
        ax = gca;
        x = ax.XLim(1) + (ax.XLim(2) - ax.XLim(1))*0.10;
        y = ax.YLim(2) - (ax.YLim(2) - ax.YLim(1))*0.05;
        text(x,y,txt);
        title('repetitive reversals within a few frames are ignored to filter segmentation wobble',...
            'FontSize',10);
       
%plot---------------------------------------------------------------------
    end
 dAng(idces) = 0;
end

function [track,time] =  elimHolds(track,time)
    
    d = diff(track);
    idx = d(:,1) == 0 & d(:,2) == 0;
    trackb = track(2:size(track,1),:);
    trackb(idx,:) = [];
    track = [track(1,:);trackb];
    
    timeb = time(2:numel(time));
    timeb(idx) = [];
    time = [time(1,:);timeb];
    
    
end
