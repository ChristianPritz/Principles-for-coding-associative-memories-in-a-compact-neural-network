function showPlates(data,labels,dates,conditions)
    
    
    figure(), 
    
    hold on
    fs = {};
    xs = {};
    colors = [];
    
    for i = 1:numel(dates) 
       [dx,lx] = fetchData(data,labels,dates{i},conditions{i},'.');
       color = findColor(conditions{i}); 
       colors = [colors;color];
       color = [color,0.09];
       ys = [];
       for j=1:numel(dx)
          h = plot(dx{j}(:,1),dx{j}(:,2),'color',color); 
          ys = vertcat(ys,dx{j}(:,2));
           
       end
        
       [fs{i},xs{i}] = ksdensity(ys);
        
    end
    h = plot([0 0],[1, -8],':','Color',[0 0 0 ]);
    h = drawCircle(0,0,1);
    h.LineWidth = 1; 
    h.LineStyle = ':'; 
    h.Color = [1, 0, 0];
    h = drawCircle(0,-3.5,4.5);
    h.LineWidth = 3; 
    h.Color = [0, 0, 0];
    scatter([0 0 0],[0, -3.5, -7],300,'.');
    text(-.3, 0.3,'BUT','FontSize',14,'FontWeight','bold');
    text(-.3, -7.3,'DA','FontSize',14,'FontWeight','bold');
    plot([3 4], [-7.5 -7.5],'LineWidth',5,'color',[0 0 0]); 
    hold off
    xlim([-4.5 4.5]);
    ylim([-8 1]);
    pbaspect([1,1,1]);
    ax = gca; 
    ax.XAxis.Visible = 'off';
    ax.YAxis.Visible = 'off';
    
    fig = gcf; 
    fig.Name = conditions{i};
    fig.Position = [418.6000  258.6000  432.8000  420.0000];
    
    figure(); 
    for i = 1:numel(dates) 
    hold on
    plot(xs{i},fs{i},'LineWidth',2,'color',colors(i,:));     
    
    end
    ax =gca;
    YL = ax.YLim;
    ax.YLim = YL;
    h = plot([0 0],YL,':','Color',[0 0 0 ]);
    h = plot([-7 -7],YL,':','Color',[0 0 0 ]);
    text(-.3, YL(2)-(YL(2)-YL(1))*0.1,'BUT','FontSize',14,'FontWeight','bold');
    text(-7.3, YL(2)-(YL(2)-YL(1))*0.1,'DA','FontSize',14,'FontWeight','bold');
    hold off
    ax.XLim = [-8 1];
    ax.LineWidth = 2; 
    ax.FontSize= 14; 
    ax.XTick = [-7:1:0];
    ax.FontWeight = 'bold';
    ylabel('Norm. animal density')

end


function color = findColor(condition)
    conds = {'STAVT';       
            'STAVM';
            'NAIVEM3';
            'STAPT';       
            'STAPM';
            'NAIVEM1'};

%     [1,0.501960784313726,0.501960784313726;
%         0.588235294117647,0,0;0,0.901960784313726,0;
%         0.196078431372549,0.517647058823530,0.227450980392157;
%         0.701960784313725,0.701960784313725,0.701960784313725;
%         0.333333333333333,0.600000000000000,1]
    
    colors = [1,0.501960784313726,0.501960784313726;
    0.5 0.5 0.5;
    0.333333333333333,0.600000000000000,1;
    0,0.901960784313726,0;
    0.5 0.5 0.5;
    0.333333333333333,0.600000000000000,1;];
    
    [~,loc] = ismember(condition,conds);
    color= colors(loc,:);     
end


function h = drawCircle(cx,cy,r)
ang = 0:pi/100:2*pi;
x = r * cos(ang) + cx;
y = r * sin(ang) + cy;
h = plot(x, y);

end


