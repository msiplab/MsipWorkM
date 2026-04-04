%[text] # 例6.12（2次DBFB）
%[text] 村松正吾　「多次元信号・画像処理の基礎と展開」
%[text] 動作確認： MATLAB R2025b
%[text] ## 準備
isVerbose = false;
prj = matlab.project.currentProject;
prjroot = prj.RootFolder;
datfolder = fullfile(prjroot,"data");
resfolder = fullfile(prjroot,"results");
myfilename = "example06_12"; % mfilename

%%
%[text] ## 多相行列の準備
Phi0 = zeros(2);
Phi1 = zeros(2);
s3 = sqrt(3);
% Phi0
Phi0(1,1) = 1-s3;
Phi0(1,2) = -1-s3;
Phi0(2,1) = 3-s3;
Phi0(2,2) = 3+s3;
Phi0 = 2^(-5/2)*Phi0 %[output:147c1170]
% Phi0
Phi1(1,1) = 3+s3;
Phi1(1,2) = -3+s3;
Phi1(2,1) = 1+s3;
Phi1(2,2) = 1-s3;
Phi1 = 2^(-5/2)*Phi1 %[output:75568f0c]
%%
%[text] ## 直交性の確認
Phi0*Phi0'+Phi1*Phi1' %[output:50453b66]
Phi0*Phi1' %[output:10df463c]
Phi1+Phi0' %[output:3736adb6]
%%
%[text] ## 多相行列の設定
%[text] 因果性を満たすように  $k\_f=-2$ とする。
%[text] $\\mathbf{f}^\\top(z)=(1 \\quad z^{1})\\left(\\begin{array}{ll} 0 & 1 \\\\ 1 & 0\\end{array}\\right)\\left(\\mathbf{\\Phi}\_1z^{2}+\\mathbf{\\Phi}\_0\\right)z^{-4}=(z^{-1} \\quad z^{-2})\\left(\\mathbf{\\Phi}\_1+\\mathbf{\\Phi}\_0z^{-2}\\right)$
dm = zeros(2,1,3);
dm(1,1,2) = 1;
dm(2,1,3) = 1;
dm = msip.ppmatrix(dm) %[output:59ab67f0]

R = zeros(2,2,2);
R(:,:,1) = Phi1;
R(:,:,2) = Phi0;
R = msip.ppmatrix(R);
upsample(R,2) %[output:822dd899]

f = dm.'*upsample(R,2) %[output:1e31a915]
%%
%[text] ## 合成フィルタの抽出
%f0 = 2^(-5/2)*[1+sqrt(3) 3+sqrt(3) 3-sqrt(3) 1-sqrt(3)]
%f1 = 2^(-5/2)*[1-sqrt(3) -3+sqrt(3) 3+sqrt(3) -1-sqrt(3)]

f0 = double(f(:,1)) %[output:4d1529f3]
f1 = double(f(:,2)) %[output:22a5f69d]

figure(1) %[output:300beeee]
subplot(2,1,1) %[output:300beeee]
stem(-3:0,f0(1:4),'filled') %[output:300beeee]
subplot(2,1,2) %[output:300beeee]
stem(-3:0,f1(1:4),'filled') %[output:300beeee]
%%
%[text] © Copyright, Shogo MURAMATSU, All rights reserved.

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright"}
%---
%[output:147c1170]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"Phi0","rows":2,"type":"double","value":[["-0.1294","-0.4830"],["0.2241","0.8365"]]}}
%---
%[output:75568f0c]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"Phi1","rows":2,"type":"double","value":[["0.8365","-0.2241"],["0.4830","-0.1294"]]}}
%---
%[output:50453b66]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"ans","rows":2,"type":"double","value":[["1.0000","0"],["0","1.0000"]]}}
%---
%[output:10df463c]
%   data: {"dataType":"matrix","outputData":{"columns":2,"exponent":"-16","name":"ans","rows":2,"type":"double","value":[["0.5551","0"],["0","0.5551"]]}}
%---
%[output:3736adb6]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"ans","rows":2,"type":"double","value":[["0.7071","0"],["0","0.7071"]]}}
%---
%[output:59ab67f0]
%   data: {"dataType":"textualVariable","outputData":{"name":"dm","value":"[\n\tz^(-1);\n\tz^(-2)\n]\n"}}
%---
%[output:822dd899]
%   data: {"dataType":"textualVariable","outputData":{"name":"ans","value":"[\n\t0.83652 - 0.12941*z^(-2),\t-0.22414 - 0.48296*z^(-2);\n\t0.48296 + 0.22414*z^(-2),\t-0.12941 + 0.83652*z^(-2)\n]\n"}}
%---
%[output:1e31a915]
%   data: {"dataType":"textualVariable","outputData":{"name":"f","value":"[\n\t0.48296 + 0.83652*z^(-1) + 0.22414*z^(-2) - 0.12941*z^(-3),\t-0.12941 - 0.22414*z^(-1) + 0.83652*z^(-2) - 0.48296*z^(-3)\n]\n"}}
%---
%[output:4d1529f3]
%   data: {"dataType":"matrix","outputData":{"columns":5,"name":"f0","rows":1,"type":"double","value":[["0.4830","0.8365","0.2241","-0.1294","0"]]}}
%---
%[output:22a5f69d]
%   data: {"dataType":"matrix","outputData":{"columns":5,"name":"f1","rows":1,"type":"double","value":[["-0.1294","-0.2241","0.8365","-0.4830","0"]]}}
%---
%[output:300beeee]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAb8AAAEMCAYAAABUTbipAAAAAXNSR0IArs4c6QAAHCZJREFUeF7tnc1rXMm5hytD8AxmFsI4YCHh2PIiY7gLmyCrHRsu5i60m1locdP+DxJdEBgkLeKls5AEBkGc7LJs5S60iHdamQvjsYVJ4sUFJwu3HSOBIcZ4MQyeIcxcqm+Opt0+3aeqTp069VY9BxpsqT6f36v31+\/56P7Bd999953igAAEIAABCGRE4AeYX0Zqs1UIQAACEBgQwPwIBAhAAAIQyI4A5ped5GwYAhCAAAQwP2IAAhCAAASyI4D5ZSc5G4YABCAAAcyPGIAABCAAgewIYH7ZSc6GIQABCEAA8yMGIAABCEAgOwKYX3aSs2EIQAACEMD8iAEIQAACEMiOAOaXneRsGAIQgAAEMD9iAAIQgAAEsiOA+WUnORuGAAQgAAHx5jc3N6f6\/T5KQgACEIAABIwJiDY\/bXz6wPyM9aYhBCAAAQhI\/laHwvgwP+IYAhCAAARsCYiu\/PRmOe1pKzntIQABCEAgG\/M7ODhQ+sUBAQhAAALNEJidnVX6JeHIwvy06a2tramHDx9K0IQ1QgACEBBJoNPpqM3NTREGmIX5adO7fv262traUjMzMyKDan9\/X21vb4veQyzgYelHCTj64ahHSYFlsYder6e0CcZ+ZGV+UkQpC5rCwCXvIZY\/Blj6UQKOfjjqUVJgKW0PmJ+\/+G10JH3qdnd3Vy0tLYk4pdAojJqDw7ImwH91h6MfjnqUFFhifv7iwWgkk7s9pYlitHEaQQACEIiIgLQ8K77yM9Femigme6INBCAAgZgISMuzmF9M0cNaIAABCAglgPlFKJw0USJEmMSSXrx+qzb2nqmdRy8H+zl94iPVnZ9W3flTg39zQAAC7gSk5VkqP3et6SmEgDY9bXja+MYd2gDvdM8L2RHLhEB8BDC\/+DRJ4jbiCLGKWdLG3vOJxldsZH3xrFpfPCNmXywUAjERwPxiUuNfa5EmSoQIxS7p86dv1Kd3\/mK8\/rvLF9XVc1PG7WkIAQj8PwFpeZbTnkRu0gSWd54cXeMz2SinP00o0QYC7xPA\/CKMCmmiRIhQ7JIu3Hqg9DU\/00Pf+PL45mXT5rSDAASEnmGj8iN0kyZw4sY96\/29vn3Nug8dIJA7AWlFBuaXe8Qmvn8qv8QFZnvREMD8opHi+4VIEyVChGKXxDU\/sdKxcGEEpOVZKj9hAcZy7Qhwt6cdL1pDwJUA5udKrsF+0kRpEEWWQ5s+58ednlmGB5v2REBanqXy8yQ8w8RNoMoAecA9bv1YXfwEML8INZImSoQIk1jS6Mec6ccarpybUt1L0zzYnoTCbKJNAtLyLJVfm9HC3K0QKK4D8mkureBn0kQJYH4RCitNlAgRJrUkzC8pOdlMJASk5Vkqv0gCh2WEI4D5hWPNTPkQwPwi1FqaKBEiTGpJmF9ScrKZSAhIy7NUfpEEDssIRwDzC8eamfIhgPlFqLU0USJEmNSSML+k5GQzkRCQlmep\/CIJHJYRjgDmF441M+VDAPOLUGtpokSIMKklYX5JyclmIiEgLc9S+UUSOCwjHAHMLxxrZsqHAOYXodbSRIkQYVJLwvySkpPNREJAWp6l8oskcFhGOAKYXzjWzJQPAcwvQq2liRIhwqSWhPklJSebiYSAtDxL5RdJ4LCMcAQwv3CsmSkfAphfhFpLEyVChEktCfNLSk42EwkBaXmWyi+SwGEZ4QhgfuFYM1M+BDC\/CLWWJkqECJNaEuaXlJxsJhIC0vJslJXf3NzckZz9fr9U2uE2ww3K2ksTZXg\/+gtYN\/aeqZ1HLwc\/1l\/A2p2fVt35U4N\/c9gTwPzsmdEDAlUEpOXZ6MxPm9qwgY3+vxBg3M\/LBJImit7D6LeOl+1LG+Cd7vmqmOT3IwQwP0ICAv4JSMuzUZmfjdGlbn4be88HFV\/Vsb54Vq0vnqlqxu+HCGB+hAME\/BPA\/GowtTW\/qtOdxe8LUVZWVtTCwoKanZ0dvGI9iuRsur67yxfV1XNTps2zb4f5ZR8CAPBI4ODgQOnX4eGhWl1dVb1eT3U6HY8zNDNUMpXfpEqwML8CoTZB\/Yr1WN55cnSNz2SNnP40ofR9G8zPjhetITCJwPb2ttKv4sD8HOLFpvIrG35c\/8L8tra21MzMTPSV34VbDwbX\/EwPfePL45uXTZtn3w7zyz4EAOCRQFH57e\/vD0wQ83OA27T5SRHlxI171vRe375m3SfXDphfrsqz7yYJcM2vBl0b8ytrW1X5STE\/Kr8aQWTQFfMzgEQTCFgSwPwsgY02d33UweSanxTz45pfzSCq6I75NcuX0fMkgPl50H3SQ+7DJmfyMLxejjRRuNvTQxBNGALza5Yvo+dJQFqejepuz6ZCRpoomoPpc37c6WkfNZifPTN6QKCKgLQ8i\/lVKdri76sMkAfc3cTB\/Ny40QsCkwhgfhHGhzRRhhGOfsyZfqzhyrkp1b00zYPtjrGG+TmCoxsEJhCQlmep\/ISEMwnbn1Cw9MeSkSBQEMD8IowFaaKUISRh+wssWPpjyUgQwPwijgHML2JxWlga5tcCdKZMnoC0PMtpTyEhScL2JxQs\/bFkJAhQ+UUcA9LekXDas9lgwvya5cvoeRKQlmep\/ITEKQnbn1Cw9MeSkSBA5RdxDEh7R0Ll12wwYX7N8mX0PAlIy7NUfkLilITtTyhY+mPJSBCg8os4BqS9I6HyazaYML96fPUHL2zsPTv6wmX9wQvd+WmlP2pP\/5sjTwLS8iyVn5A4JWH7EwqWbixHP22obBQ+a9aNbQq9ML8IVZQmCpVfs0GE+bnxrfqs2WJUPnPWja\/0XtLyLJWfkIgjYfsTCpb2LPmaLXtmufXA\/CJUXJooVH7NBhHmZ8+XL1i2Z5ZbD2l5lspPSISSsP0JBUt7lhduPVD6mp\/poW98eXzzsmlz2iVAAPOLUERpolD5NRtEmJ893xM37ll3en37mnUfOsglIC3PUvkJiTUStj+hYGnPksrPnlluPTC\/CBWXJgqVX7NBhPnZ8+Wanz2z3HpIy7NUfkIilITtTyhY2rPkbk97Zrn1wPwiVFyaKFR+zQYR5ufG1\/Q5Px50d+MrvZe0PEvlJyTiSNj+hIKlO8sqA+QBd3e20ntifhEqKE0UKr9mgwjzq8d39GPO9GMNV85Nqe6laXX13FS9wektloC0PEvlJyTUSNj+hIKlH5Zw9MMxlVEwvwiVlCYKlV+zQUTS9sMXjn44pjKKtDxL5Sck8kg0\/oSCpR+WcPTDMZVRML8IlZQmCpVfs0FE0vbDF45+OKYyirQ8S+UnJPJINP6EgqUflnD0wzGVUTC\/CJWUJgqVX7NBRNL2wxeOfjimMoq0PCu+8pubmzuKnX6\/XxpH0kTB\/JpNByRtP3zh6IdjKqNIy7OizU8b37Dhjf6\/CCppomB+zaYDkrYfvnD0wzGVUaTlWbHmN87oyn4uTRTMr9l0QNL2wxeOfjimMoq0PIv5CYk8Eo0\/oWDphyUc\/XBMZRTML5CSLpXfysqKWlhYCLRCv9P8\/euP1S\/++A\/1q59+PfgoKQ53ArB0ZzfcE45+OKYyyuHhoVpdXVW9Xk91Op3ot5VV5Re9GhMW+O3xk+qb01fUsRf31QdfvZK8ldbXDks\/EsDRD0c9SkosMT9\/cVE6kkvlt7W1pWZmZhpeGcNDAAIQsCNw\/+kb9es\/fah+99mP1I8\/\/NKucySt9\/f31fb2NpVf03q4mJ+UdyRNs2N8CEAgLgIpXD\/lml\/AmMrpUYeAWJkKAhAITADzCwxcKSX2ml+BKpeH3MOHBjNCAAJNE9Dfjbix90ztPHo5mEp\/N2J3flp1508N\/i3poPKLUC1pokSIkCVBAAIeCYx+IXDZ0NoA73TPe5y12aGk5VnxlZ+JnNJEMdkTbSAAAbkENvaeDyq+qmN98axaXzxT1SyK30vLs5hfFGFTvYiDgwO1u7urlpaW1OzsbHUHWowlAEs\/wQFHN47F9b3h3vrxpWMvvlDfnP7Z4LGH4ePu8kV1VcCzvZifWzw02kuaKGUwUthDoyJbDA5LC1gTmsLRjePyzpOja3zFCD989Tf18eeb6sura+qfJ3\/yzsBSTn9Ki4esKj\/Jn\/BSfHqC5D24pQr\/vWDphykc3Tj+1x\/+qvQ1v9HK7\/iff6\/efvLZe+an29395QW3yQL24hNeAsI2nUqfnllbW1P6nQkHBCAAAQg0Q0B\/rNnm5qaISzNZVH5aZm2A+sUBAQhAoE0CZZXfpPXoRx5+8\/NP2lyy8dz6fgQp9yRkY37G6tEQAhCAQIMEyq75TZpOyjW\/BpE1MjTm1whWBoUABCBQTqDsbs9JrKTc7SlNb8xPmmKsFwIQEE\/A9Dk\/qr7mpMb8mmPLyBCAAATGEqgyQEkPuEuUGfOTqBprhgAEkiAw+jFn+uYW\/WXV3UvTIh5slywC5idZPdYOAQhAAAJOBDA\/J2ztdhr+Jgu9kn6\/3+6CBM9u8q0ggrcXdOnjvmMz6CIETkYMtiMa5tcOd+dZyxIMSccNp+n3QbqNnlevIoHzRsxOd2LQjpfP1pifT5oBxsL8\/ECGox+OehQqFzeW49608mbWjadtL8zPlliE7fljsRcF87NnVtWDOKwi9O7vMT87Xr5bY36+idYcb\/R63vBww6eUeLc9GbQpx2IUEvd4nqYsYWj3x4\/52fHy3Rrz8020hfFIOvWgw68eP95AuPHD\/Ny4+eqF+fki2eI4JG93+LBzZzfaE5Z2LDE\/O16+W2N+vok2PB7XqvwBJln7Y6lHgqcdT8zPjpfv1pifb6INj4f5+QFMovbDcXgUmNoz5VEHe2a+emB+vkgGHGf0BgSerbKHP+4mDljas+SanzuzomIuRiD+6rG06Y352dCiLQQgAAEIJEEA80tCRjYBAQhAAAI2BDA\/G1q0hQAEIACBJAhgfknIyCYgAAEIQMCGAOZnQ4u2EIAABCCQBAHMLwkZ2QQEIAABCNgQwPxsaNEWAhCAAASSIID5JSEjm4AABCAAARsCmJ8NLdpCAAIQgEASBDC\/JGRkExCAAAQgYEMA87OhRVsIQAACEEiCAOaXhIxsAgIQgAAEbAhgfja0aAsBCEAAAkkQwPySkJFNQAACEICADQHx5sd3iNnITVsIQAACENAERJtf8Z1sfAcWwQwBCEAAAjYExJrf8JeRYn42ktMWAhCAAATEml8hHac9CWIIQAACELAlkI35HRwcKP3igAAEIACBZgjMzs4q\/ZJwZGF+2vTW1tbUw4cPJWjCGiEAAQiIJNDpdNTm5qYIA8zC\/LTpXb9+XW1tbamZmRmRQbW\/v6+2t7dF7yEW8LD0owQc\/XDUo6TAsthDr9dT2gRjP7IyPymilAVNYeCS9xDLHwMs\/SgBRz8c9SgpsJS2B8zPX\/w2OpI+dbu7u6uWlpZEnFJoFEbNwWFZD+CL12\/Vxt4z9d\/\/87\/q2Isv1KkL\/6H+89\/\/TXXnT6nTJz6qN3imvVOIScwvcPCa3O0pTZTACJkOAkYEtOntPHo5ML5xhzbAO93zRuPRKC0C0vKs+MrPJHykiWKyJ9pAIDSBjb3nE42vWM\/64lm1vngm9PKYr2UC0vIs5tdywDA9BCQQ+PzpG\/Xpnb8YL\/Xu8kV19dyUcXsayieA+UWooTRRIkTIkjInsLzzZHDK0\/Tg9KcpqXTaScuzVH7pxB47gUBjBC7ceqD0NT\/TQ9\/48vjmZdPmtEuAAOYXoYjSRIkQIUvKnMCJG\/esCby+fc26Dx3kEpCWZ6n85MYaK4dAMAJUfsFQi50I84tQOmmiRIiQJWVOgGt+mQeAwfal5VkqPwNRaQKB3Alwt2fuEVC9f8yvmlHwFtJECQ6ICSFgQMD0OT\/u9DSAmWATaXmWyi\/BIGRLEGiKQJUB8oB7U+TjHxfzi1AjaaJEiJAlQeCIwOjHnOnHGq6cm1LdS9M82J5xnEjLs1R+GQcrW4dAHQLFdUA+zaUOxXT6Yn4RailNlAgRsiQIvEcA8yMohglIy7NUfsQvBCDgRADzc8KWbCfML0JppYkSIUKWBAEqP2JgIgFpeZbKj4CGAAScCFD5OWFLthPmF6G00kSJECFLggCVHzFA5SctBjA\/aYqxXgkEqPwkqBRujdLyLKc9w8UGM0EgKQKYX1Jy1t4M5lcbof8BpIninwAjQsA\/AczPP1PJI0rLs1FWfnNzc0cx0O\/3S+NhuM1wg7L20kSR\/AfA2vMhgPnlo7XJTqXl2ejMT5vasIGN\/r8QYdzPy0SSJopJoNEGAm0TwPzaViCu+aXl2ajMz8boML+4Ap\/V5EcA88tP80k7xvxqxIOt+VWd7ix+L02UGgjpCoFgBDC\/YKhFTCQtzyZT+U2qBAtRVlZW1MLCgpqdnR28OCAAAXcCmJ87u5R6HhwcKP06PDxUq6urqtfrqU6nE\/0WxZpfGdlxBliYX9FHm6B+cUAAAu4EMD93din13N7eVvpVHJifg7o2pz1dzG9ra0vNzMxQ+TloQxcIjBLA\/IgJTaCo\/Pb39wcmiPk5xIWN+ZW1rar8pIjigI4uEAhOAPMLjjzqCbnmV1Me10cdTK75YX41xaE7BIYIYH6EwzABzM9DPEx6yH3Y5EwehtfLkSaKB4QMAYHGCWB+jSMWNYG0PBvVDS9NKS1NlKY4MC4EfBLA\/HzSlD+WtDyL+cmPOXYAgVYIYH6tYI92UswvQmmkiRIhQpYEgfcIYH4EBdf8Io8BzC9ygVieSAKYn0jZGlu0tDzLac\/GQoGBIZA2AcwvbX1td4f52RIL0F6aKAGQMAUEahPA\/GojTGoAaXmWyi+p8GMzEAhHAPMLx1rCTJhfhCpJEyVChCwJAu8RwPwIimEC0vIslR\/xCwEIOBHA\/JywJdsJ84tQWmmiRIiQJUGAyo8YmEhAWp6l8iOgIQABJwJUfk7Yku2E+UUorTRRIkTIkiBA5UcMUPlJiwHMT5pirFcCASo\/CSqFW6O0PMtpz3CxwUwQSIoA5peUnLU3g\/nVRuh\/AGmi+CfAiBDwTwDz889U8ojS8iyVn+RoY+0QaJEA5tci\/AinxvwQJUICLAkC\/glgfv6ZSh4R84tQPWmiRIiQJUHgPQKYH0ExTEBanuW0J\/ELAQg4EcD8nLAl2wnzi1BaaaJEiJAlQYDKjxiYSEBanqXyI6AhAAEnAlR+TtiS7YT5BZZ2bm7uaMZ+v186uzRRAiNkOgg4EcD8nLAl20lanhVd+WnjGza80f8XUSZNlGT\/OthYUgQwv6TkrL0ZaXlWrPmNM7qyn0sTpXYUMgAEAhDA\/AJAFjSFtDyblfmtrKyohYUFQeHEUiEQL4G\/f\/2x+sUf\/6F+9dOv1ZVzU\/EulJUFIXB4eKhWV1dVr9dTnU4nyJx1JsnK\/OqAarvvt8dPqm9OX1HHXtxXH3z1qu3liJ4fln7kg6MfjnqUlFhifv7ionQkl9OeW1tbamZmpuGVNTP8\/adv1K\/\/9KH63Wc\/Uj\/+8MtmJslkVFhmIrSgbaYQk\/v7+2p7e5vKr+m4czE\/Ke9Ihtm9eP1Wbew9UzuPXg5+fPrER6o7P62686cG\/+awJ8C1Kntm9GiWQAoxyTW\/ZmPkaPTUzU+bnjY8bXzjDm2Ad7rnAxFPZ5oUEk06arATTSCFmMT8AsZyyo86bOw9n2h8Beb1xbNqffFMQOryp0oh0chXgR0ME0ghJjG\/wDGd4kPuxR+CKcq7yxfVVe62M8WVxLts483SUAQBzC+8TGLv9rRBJe0dyfLOk6NrfCb75PSnCaXv26SQaOx2TOvYCaQQk9LyLOYX4V\/FhVsPlL7mZ3roG18e37xs2jz7dikkmuxFTAxACjGJ+UUYlNJEOXHjnjXF17evWffJrQN3zuamuJz9Yn7htaLyC8+8ckYqv0pEVg24c9YKF41bIID5hYeO+YVnXjkj1\/wqEVk14M5ZK1w0boEA5hceOuYXnnnljNztWYnIuAEsjVHRsEUCmF94+JhfeOZGM5pWK9zpORknVbRRuNGoZQKYX3gBML\/wzI1nrDJAHnCvRsn102pGtGifAOYXXgPMLzxzqxlHb9bQjzXor4\/pXprmwXYDktw5awCJJq0TwPzCS4D5hWfOjAEJUPkFhM1UzgQwP2d0zh0xP2d0dJRAgGt+ElRijZhf+BjA\/MIzZ8aABLjbMyBspnImgPk5o3PuiPk5o6OjFAJVNw4V++DOWSmKprdOzC+8pphfeObM2AKBKgPkztkWRGHKIwKYX\/hgwPzCM2fGlghw52xL4Jm2kgDmV4nIewPMzztSBoQABCBgRwDzs+PlozXm54MiY0AAAhCoQQDzqwHPsSvm5wiObhCAAATqEkjpa7akfXUc5lc3eukPAQhAwJJAil+zhflZBkGI5tJECcGEOSAAgfYIVN19XKxM0l3I0vJslJXf3NzcUVT2+\/3SCB1uM9ygrL00Udr7k2RmCECgaQKpfvCCtDwbnflpUxs2sNH\/F4E57udlgStNlLI9HBwcqN3dXbW0tKRmZ2eb\/vtMenxY+pEXjm4cyz5y74OvXqljL75Q35z+mfr2+Ml3Bpby4QvS8mxU5mdjdLmZn7TAcksLYXrB0g9nOLpxLPuw9R+++pv6+PNN9eXVNfXPkz95Z2D9TS6Pb152myxgL2nxINr8qk53Fr8vRFlZWVELCwsBw8HfVIeHh2p1dVVJ3oM\/GvVGgmU9fkVvOLpx\/PS3j9\/rqCu\/43\/+vXr7yWfvmZ9ufPeXF9wmC9iriIder6c6nU7Amd2mCmp+467T6aXrU511Kr9JlaA+PbO2tqa0CXJAAAIQgEAzBLTpbW5uirg0E9T8qnDbmF\/ZWFUGqE2QAwIQgECbBPSdnvefvjFegr7mp18SDn0\/gpR7ErIxPwmBwxohAIH0CaR6t6c05cSaX1mVZ3MTjDShWC8EIJAOAdPn\/KTc6SlRmajMTwN0fdQB45MYfqwZAvkSqDJASQ+4S1QxOvMrDLCAOfrQ+rDJmTwML1EU1gwBCORBgK\/Zak\/nKM2vPRzMDAEIQAACORDA\/HJQmT1CAAIQgMA7BDA\/gQEx+rzkuM8\/Fbi14Evm1Lk\/5Fx3d2NJDLpxq9sL86tLMHB\/7nL1B9z05ip\/M6Y7UpHAeSNmpzExaMfLZ2vMzyfNAGNhfn4gw9EPRz0KlYsby7of6uE2K70KAphfArHA6SZ7ETE\/e2ZVPYjDKkLv\/h7zs+PluzXm55tozfGqPv+0GJ5325NBm3Ic5skpu3KmpiwxP7s\/fszPjpfv1pifb6ItjEfSqQcdfvX48QbCjR\/m58bNVy\/MzxfJFschebvDh507u9GesLRjifnZ8fLdGvPzTbTh8bhW5Q8wydofSz0SPO14Yn52vHy3xvx8E214PMzPD2AStR+Ow6PA1J4pjzrYM\/PVA\/PzRTLgOKM3IHCjhj38cTdxwNKeJdf83JkVFXMxAvFXj6VNb8zPhhZtIQABCEAgCQKYXxIysgkIQAACELAhgPnZ0KItBCAAAQgkQQDzS0JGNgEBCEAAAjYEMD8bWrSFAAQgAIEkCGB+ScjIJiAAAQhAwIYA5mdDi7YQgAAEIJAEAcwvCRnZBAQgAAEI2BDA\/Gxo0RYCEIAABJIggPklISObgAAEIAABGwKYnw0t2kIAAhCAQBIEML8kZGQTEIAABCBgQwDzs6FFWwhAAAIQSILA\/wE6xSJFjYYlJAAAAABJRU5ErkJggg==","height":0,"width":0}}
%---
