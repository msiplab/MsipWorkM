close all

%%
f0 = 2^(-5/2)*[1+sqrt(3) 3+sqrt(3) 3-sqrt(3) 1-sqrt(3)]
f1 = 2^(-5/2)*[1-sqrt(3) -3+sqrt(3) 3+sqrt(3) -1-sqrt(3)]

f3_0 = conv(upsample(f0,4),conv(upsample(f0,2),f0))
f3_1 = conv(upsample(f1,4),conv(upsample(f0,2),f0))
f2_1 = conv(upsample(f1,2),f0)
f1_1 = f1

figure(1)
r = [-22 0 -1 1];
subplot(4,1,1)
stem(-21:0,f3_0(1:22),'filled','black')
axis(r);
ylabel('$f_{3,0}[n]$','Interpreter','latex')
grid on
ax = gca;
ax.FontSize = 12;
ax.XTickLabel = [];

subplot(4,1,2)
stem(-21:0,f3_1(1:22),'filled','black')
axis(r);
ylabel('$f_{3,1}[n]$','Interpreter','latex')
grid on
ax = gca;
ax.FontSize = 12;
ax.XTickLabel = [];

subplot(4,1,3)
stem(-8:0,f2_1(1:9),'filled','black')
axis(r);
ylabel('$f_{2,1}[n]$','Interpreter','latex')
grid on
ax = gca;
ax.FontSize = 12;
ax.XTickLabel = [];

subplot(4,1,4)
stem(-3:0,f1_1,'filled','black')
axis(r);
xlabel('$n$','Interpreter','latex')
ylabel('$f_{1,1}[n]$','Interpreter','latex')
grid on
ax = gca;
ax.FontSize = 12;

%%
hfig = gcf;
figWidth = 400; % 幅（ピクセル）
figHeight = 400; % 高さ（ピクセル）
set(hfig, 'Units', 'pixels', 'Position', [100 100 figWidth figHeight]);

exportgraphics(hfig,fullfile(resfolder,"fig06-13a.png"))

%%

figure(2)
[F3_0,w] = freqz(f3_0);
F3_1 = freqz(f3_1);
F2_1 = freqz(f2_1);
F1_1 = freqz(f1_1);

magF3_0 = 20*log10(abs(F3_0));
magF3_1 = 20*log10(abs(F3_1));
magF2_1 = 20*log10(abs(F2_1));
magF1_1 = 20*log10(abs(F1_1));

plt = plot(w,magF3_0,w,magF3_1,w,magF2_1,w,magF1_1);
styles = {'-','--',':','-.'};
for k = 1:numel(plt)
    plt(k).Color = [0 0 0];
    plt(k).LineStyle = styles{k};
    plt(k).LineWidth = 1.5;
end
grid on
xlabel('$\omega$','Interpreter','latex')
ylabel('$20\log_{10}|F_{j,p}(\mathrm{e}^{\mathrm{j}\omega})|$ [dB]','Interpreter','latex')
legend({'$F_{3,0}(z)$','$F_{3,1}(z)$','$F_{2,1}(z)$','$F_{1,1}(z)$'},...
    'Location','southeast','Interpreter','latex')
ax = gca;
ax.YLim = [-30 10];
ax.XLim = [0 pi];
ax.XTick = [0 pi/2 pi];
ax.XTickLabel = {'0','\pi/2','\pi'};
ax.FontSize = 12;

%%
hfig = gcf;
figWidth = 400; % 幅（ピクセル）
figHeight = 400; % 高さ（ピクセル）
set(hfig, 'Units', 'pixels', 'Position', [100 100 figWidth figHeight]);
hold off

exportgraphics(hfig,fullfile(resfolder,"fig06-13b.png"))