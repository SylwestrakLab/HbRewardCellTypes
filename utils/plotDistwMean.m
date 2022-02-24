function plotDistwMean(x,colors,varargin)
 
    y=nanmean(x,1);
    err = std(x,[],1);
    hold on
    
    
    for i=1:numel(y)
       %if ischar(colors)
       %     plot([i-.2 i+.2],[y(i) y(i)],'Color',colors,'LineWidth',5);
       %else
       
       if ~isempty(varargin)
           if strcmp(varargin,'std')
           bar(i,y(i),.6,'FaceColor',colors(i,:),'EdgeColor','none')
           errorbar(i,y(i),[],err(i),'vertical','Color',colors(i,:),'LineWidth',2)
           elseif strcmp(varargin,'SEM')
                bar(i,y(i),.6,'FaceColor',colors(i,:),'EdgeColor','none')
           errorbar(i,y(i),err(i)./sqrt(numel(err)),'vertical','Color',colors(i,:),'LineWidth',2)
           end
           
       else
           
           bar(i,y(i),.6,'FaceColor',colors(i,:),'EdgeColor','none')
           
       end
       
       %plot([i-.2 i+.2],[y(i) y(i)],'Color',colors(i,:),'LineWidth',5);
       %end
    end
    %if isempty(varargin)
    plot(x','-','Color',[.7 .7 .7 .8],'LineWidth',1);
    
    %end
end
