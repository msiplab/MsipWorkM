%[text] # 例9.1（ベクトル量子化）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2026a
%[text] ## 準備
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example09_01"; % mfilename

rng(0)
close all
%%
%[text] ## データ集合の生成
nDim = 2;
nClusters = 4;

% クラスタ中心・サンプル数・広がりに偏りをつける
means = [3.5 1.5; -0.5 3; -2.5 -0.5; 1 -3];
sigmas = [0.5 0.8 0.6 0.4];
nSamples = [80 130 60 110];

X = [];
trueLabels = [];
for k = 1:nClusters
    X = [X; means(k,:) + sigmas(k) * randn(nSamples(k), nDim)]; %#ok<AGROW>
    trueLabels = [trueLabels; k * ones(nSamples(k), 1)]; %#ok<AGROW>
end
%%
%[text] ## ベクトル量子化（k-means）
nCodeVectors = nClusters;
[clusterIdx, codeVectors] = kmeans(X, nCodeVectors);
%%
%[text] ## 描画
grayLevels = linspace(0.1, 0.7, nCodeVectors);
markerStyles = {'o', 's', '^', 'd'};
axLim = [-5 5 -5 5];

figure(1)
ax1 = axes;
hold on
for k = 1:nCodeVectors
    mask = clusterIdx == k;
    g = grayLevels(k);
    scatter(X(mask,1), X(mask,2), 15, [g g g], 'filled', ...
        'MarkerFaceAlpha', 0.5, 'Marker', markerStyles{k})
end
scatter(codeVectors(:,1), codeVectors(:,2), 100, 'k', 'x', 'LineWidth', 2)
hold off
xlabel('x_1')
ylabel('x_2')
legend([arrayfun(@(k) sprintf('クラスタ%d',k), 1:nCodeVectors, 'UniformOutput', false), {'コードベクトル'}], ...
    'Location','best')
axis equal
axis(axLim)
ax1.FontSize = 12;
exportgraphics(ax1, fullfile(resfolder,'fig09-01a.png'))

figure(2)
ax2 = axes;
hold on
[vx, vy] = voronoi(codeVectors(:,1), codeVectors(:,2));
plot(vx, vy, 'Color', [0.3 0.3 0.3], 'LineWidth', 1)
for k = 1:nCodeVectors
    mask = clusterIdx == k;
    g = grayLevels(k);
    scatter(X(mask,1), X(mask,2), 15, [g g g], 'filled', ...
        'MarkerFaceAlpha', 0.5, 'Marker', markerStyles{k})
end
scatter(codeVectors(:,1), codeVectors(:,2), 100, 'k', 'x', 'LineWidth', 2)
hold off
xlabel('x_1')
ylabel('x_2')
axis equal
axis(axLim)
ax2.FontSize = 12;
exportgraphics(ax2, fullfile(resfolder,'fig09-01b.png'))
