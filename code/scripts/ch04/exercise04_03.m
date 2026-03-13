isVerbose = false;
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example04_03"; % mfilename

%%
figure(1)
N = [2 1; 0 2];
idx = 1;
for ellh = -2:2
    for ellv = -2:2
        Y(idx) = N(1,:)*[ellv;ellh];
        X(idx) = N(2,:)*[ellv;ellh];
        idx = idx + 1;
    end
end
h = plot(X(:),Y(:),'o');
h.MarkerFaceColor = 'k';
h.MarkerEdgeColor = 'k';
h.MarkerSize = 10;
grid on
axis square
ax = gca;
ax.TickLabelInterpreter = 'latex';
ax.XTick = [ 0 1 2 3 4 ];
ax.YTick = [ 0 1 2 3 4 ];
ax.XLim = [-0.8 4.8];
ax.YLim = [-0.8 4.8];
ax.FontSize = 18;
ax.YDir = 'reverse';
xl = xlabel(' $n_\mathrm{h}$','Interpreter','latex');
yl = ylabel(' $n_\mathrm{v}$','Interpreter','latex');
xl.FontSize = 18;
yl.FontSize = 18;

% move the ylabel slightly to the left of its default position
xl.Position = [4.8 -0.8 0 ];
yl.Position = [-0.8 4.2 0 ];

ax.XAxisLocation = 'origin';
ax.YAxisLocation = 'origin';
text(-0.3,-0.3, '$0$','Interpreter','latex','FontSize',18)


% draw the vector [2 0] from the origin
hold on

n2 = [1; 2];
quiver(0,0,n2(2),n2(1),0,'k','LineWidth',2,'MaxHeadSize',0.5)
text(n2(2)/2+1.05,n2(1)/2+.4, ' $\mathbf{n}_2$','Interpreter','latex','FontSize',18,'VerticalAlignment','bottom')

n1 = [2; 0];
quiver(0,0,n1(2),n1(1),0,'k','LineWidth',2,'MaxHeadSize',0.5)
text(n1(2)/2+0.05,n1(1)/2+1.4, ' $\mathbf{n}_1$','Interpreter','latex','FontSize',18,'HorizontalAlignment','left')


pgon = polyshape([0 N(2,1) sum(N(2,:)) N(2,2)],[0 N(1,1) sum(N(1,:)) N(1,2)]);
plot(pgon,'FaceColor',0.5*[1 1 1],'FaceAlpha',0.1)


plot(X(:),Y(:)+1,'x','Color','k','MarkerSize',10);
plot(X(:)+1,Y(:)+1,'^','Color','k','MarkerSize',10);
plot(X(:)+1,Y(:)+2,"square",'Color','k','MarkerSize',10);

hold off


ax.Box = 'off';
fg = gcf;
exportgraphics(fg,fullfile(resfolder,"fig04-03.png"),'BackgroundColor','none','ContentType','image','Resolution',300)
