clc
clear
close all

%%
%%% Load LOS deformation point data for three tracks.
data_P1 = load('');
data_P2 = load('');
data_P3 = load('');

%%
% Sample incidence-angle and azimuth rasters at each LOS point location.
%%P1
[Z, R] = readgeoraster('inc_P1.tif');
data_P1(:,4) = NaN; % Initialize incidence-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P1,1)
    lon = data_P1(i,1); % Longitude
    lat = data_P1(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P1(i,4) = pi/2 -  Z(row, col);
    end
end

[Z, R] = readgeoraster('Az_P1.tif');
data_P1(:,5) = NaN; % Initialize azimuth-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P1,1)
    lon = data_P1(i,1); % Longitude
    lat = data_P1(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P1(i,5) = pi - Z(row, col);
    end
end

%%P2
[Z, R] = readgeoraster('inc_P2.tif');
data_P2(:,4) = NaN; % Initialize incidence-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P2,1)
    lon = data_P2(i,1); % Longitude
    lat = data_P2(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P2(i,4) = pi/2 -  Z(row, col);
    end
end

[Z, R] = readgeoraster('Az_P2.tif');
data_P2(:,5) = NaN; % Initialize azimuth-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P2,1)
    lon = data_P2(i,1); % Longitude
    lat = data_P2(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P2(i,5) = pi - Z(row, col);
    end
end


%%P3
[Z, R] = readgeoraster('inc_P3.tif');
data_P3(:,4) = NaN; % Initialize incidence-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P3,1)
    lon = data_P3(i,1); % Longitude
    lat = data_P3(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P3(i,4) =  pi/2 -  Z(row, col);
    end
end

[Z, R] = readgeoraster('Az_P3.tif');
data_P3(:,5) = NaN; % Initialize azimuth-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P3,1)
    lon = data_P3(i,1); % Longitude
    lat = data_P3(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P3(i,5) = pi - Z(row, col);
    end
end
clear  col i inc_P3 lat lon R row Z

%%
% Sample slope and aspect rasters at each LOS point location.

% Slope
data_P1(:,6) = NaN; 
data_P2(:,6) = NaN; 
data_P3(:,6) = NaN; 

[Z, R] = readgeoraster('Slope_BHT.tif');
% P1
for i = 1:size(data_P1,1)
    lon = data_P1(i,1); % Longitude
    lat = data_P1(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P1(i,6) = Z(row, col);
    end
end
data_P1(:,6) = deg2rad( data_P1(:,6) );

%P2
for i = 1:size(data_P2,1)
    lon = data_P2(i,1); % Longitude
    lat = data_P2(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P2(i,6) = Z(row, col);
    end
end
data_P2(:,6) = deg2rad( data_P2(:,6) );

%P3
for i = 1:size(data_P3,1)
    lon = data_P3(i,1); % Longitude
    lat = data_P3(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P3(i,6) = Z(row, col);
    end
end
data_P3(:,6) = deg2rad( data_P3(:,6) );

%%Aspect
data_P1(:,7) = NaN; 
data_P2(:,7) = NaN; 
data_P3(:,7) = NaN; 

[Z, R] = readgeoraster('Aspect_BHT.tif');
% P1
for i = 1:size(data_P1,1)
    lon = data_P1(i,1); % Longitude
    lat = data_P1(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P1(i,7) = Z(row, col);
    end
end
data_P1(:,7) = deg2rad( data_P1(:,7) );

%P2
for i = 1:size(data_P2,1)
    lon = data_P2(i,1); % Longitude
    lat = data_P2(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P2(i,7) = Z(row, col);
    end
end
data_P2(:,7) = deg2rad( data_P2(:,7) );

%P3
for i = 1:size(data_P3,1)
    lon = data_P3(i,1); % Longitude
    lat = data_P3(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P3(i,7) = Z(row, col);
    end
end
data_P3(:,7) = deg2rad( data_P3(:,7) );

clear   col i inc_P3 lat lon R row Z



%%
%%%%%%%%%%%% Build matched point neighborhoods around the reference track.
base_data = data_P2;  % Use P2 as the reference track.
other_data1 = data_P1;
other_data2 = data_P3;

% Search-radius settings for matching points from the other tracks.
min_radius = 0.0001;  
max_radius = 0.02;    
step = 0.0001;  

%% Find the smallest radius that includes points from both other tracks.
min_radii = nan(size(base_data, 1), 1);  % Initialize matched radii with NaN.

for i = 1:size(base_data, 1)
    base_point = base_data(i, 1:2);  % Longitude and latitude of the reference point.
    
    % Compute distances from the reference point to points in the other tracks.
    distances1 = sqrt((other_data1(:,1)-base_point(1)).^2 + ...
                     (other_data1(:,2)-base_point(2)).^2);
    distances2 = sqrt((other_data2(:,1)-base_point(1)).^2 + ...
                     (other_data2(:,2)-base_point(2)).^2);
    
    % Increase the radius until both tracks have at least one neighboring point.
    for radius = min_radius:step:max_radius
        % Accept the first radius containing points from P1 and P3.
        if any(distances1 <= radius) && any(distances2 <= radius)
            min_radii(i) = radius;
            break;  % Stop once the minimum valid radius is found.
        end
    end
end
clear i min_radius max_radius step  distances1 distances2 base_point radius

%%
% Average the matched P1 and P3 observations within each P2 neighborhood.
mean_P1 = nan(size(base_data, 1), 5); 
mean_P3 = nan(size(base_data, 1), 5);
other1_values = cell(size(base_data, 1), 1); % Store matched P1 points for each reference point.
other2_values = cell(size(base_data, 1), 1); % Store matched P3 points for each reference point.

for i = 1:size(base_data, 1)
    
    base_point = base_data(i, 1:2);
    radius = min_radii(i);

    % Compute distances to P1 points.
    distances1 = sqrt((other_data1(:,1)-base_point(1)).^2 + ...
                    (other_data1(:,2)-base_point(2)).^2);

    % Select P1 points inside the matched radius.
    idx = distances1 <= radius;
    points_in_radius = other_data1(idx, :);

    % Save the selected P1 points.
    other1_values{i} = points_in_radius;

    % Average LOS, incidence, azimuth, slope, and aspect values for P1.
    if size(points_in_radius, 1) > 0
        mean_P1(i,1) = mean(points_in_radius(:, 3), 'all');
        mean_P1(i,2) = mean(points_in_radius(:, 4), 'all');
        mean_P1(i,3) = mean(points_in_radius(:, 5), 'all');
        mean_P1(i,4) = mean(points_in_radius(:, 6), 'all');
        mean_P1(i,5) = mean(points_in_radius(:, 7), 'all');
    end
    
     % Compute distances to P3 points.
    distances2 = sqrt((other_data2(:,1)-base_point(1)).^2 + ...
                    (other_data2(:,2)-base_point(2)).^2);

    % Select P3 points inside the matched radius.
    idx = distances2 <= radius;
    points_in_radius = other_data2(idx, :);

    % Save the selected P3 points.
    other2_values{i} = points_in_radius;

    % Average LOS, incidence, azimuth, slope, and aspect values for P3.
    if size(points_in_radius, 1) > 0
        mean_P3(i,1) = mean(points_in_radius(:, 3), 'all');
        mean_P3(i,2) = mean(points_in_radius(:, 4), 'all');
        mean_P3(i,3) = mean(points_in_radius(:, 5), 'all');
        mean_P3(i,4) = mean(points_in_radius(:, 6), 'all');
        mean_P3(i,5) = mean(points_in_radius(:, 7), 'all');
    end
    
end

clear i distances1 distances2 base_point points_in_radius  radius idx

%%
%% Invert East-North-Up deformation from P2, P1, and P3 observations.
     
%% Compute ENU components with the slope-parallel flow constraint.

result = nan(size(base_data, 1), 5);

for i = 1:size(base_data, 1)
    % LOS projection factors for the three tracks.
    Factor_U_P1 = cos(	mean_P1(i,2)	);
    Factor_E_P1 = -1 * sin(	mean_P1(i,2)	) * cos(	mean_P1(i,3)   );
    Factor_N_P1 = sin( mean_P1(i,2)   ) * sin(    mean_P1(i,3)   );

    Factor_U_P2 = cos(    base_data(i,4)  );
    Factor_E_P2 = -1 * sin(   base_data(i,4)  ) * cos(    base_data(i,5)	);
    Factor_N_P2 = sin(    base_data(i,4)  ) * sin(    base_data(i,5)  );

    Factor_U_P3 = cos( mean_P3(i,2)   );
    Factor_E_P3 = -1 * sin(    mean_P3(i,2)   ) * cos(    mean_P3(i,3)   );
    Factor_N_P3 = sin( mean_P3(i,2)   ) * sin(    mean_P3(i,3)   );
    
    Se = tan( base_data(i,6) ) * cos(pi/2 - base_data(i,7) );
    Sn = tan( base_data(i,6) ) * sin(pi/2 - base_data(i,7) );

    Factor = [  %Factor_U_P1	,Factor_E_P1	,Factor_N_P1;
                Factor_U_P2	,Factor_E_P2	,Factor_N_P2;
                Factor_U_P3	,Factor_E_P3	,Factor_N_P3;   
                1               ,Se             ,Sn          ;   ] ;

    V_LOS = [%mean_P1(i,1); 
            base_data(i,3); 
            mean_P3(i,1); 
            0;] ;
    
	V_3D = Factor \ V_LOS;
    result(i,1:2) = base_data(i,1:2);
    result(i,3:5) = V_3D';
end
%%
%% Write inverted components to text files.
fileID = fopen('result_U_SPF.txt', 'w');
% Write longitude, latitude, and Up component.
for i = 1:size(result, 1)
    fprintf(fileID, '%.8f %.8f %.8f\n', result(i, 1), result(i, 2), result(i, 3));
end
% Close output file.
fclose(fileID);



fileID = fopen('result_E_SPF.txt', 'w');
% Write longitude, latitude, and East component.
for i = 1:size(result, 1)
    fprintf(fileID, '%.8f %.8f %.8f\n', result(i, 1), result(i, 2), result(i, 4));
end
% Close output file.
fclose(fileID);


fileID = fopen('result_N_SPF.txt', 'w');
% Write longitude, latitude, and North component.
for i = 1:size(result, 1)
    fprintf(fileID, '%.8f %.8f %.8f\n', result(i, 1), result(i, 2), result(i, 5));
end
% Close output file.
fclose(fileID);

% % % 
% % % fileID = fopen('result_EN_SPF.txt', 'w');
% % % % Optional output containing East and North components plus uncertainty fields.
% % % for i = 1:size(result, 1)
% % %     fprintf(fileID, '%.8f %.8f %.8f %.8f %.8f %.8f %d\n', result(i, 1), result(i, 2), result(i, 4), result(i, 5),0.1,0.1,0);
% % % end
% % % % Close output file.
% % % fclose(fileID);
