load("line33temperaturesHot.mat")
load("locations.mat")
load("networkData.mat")

lon = coordinates(:,2);
lat = coordinates(:,1);
plotNetworkMainLine(mpc,temperatures,lat,lon);