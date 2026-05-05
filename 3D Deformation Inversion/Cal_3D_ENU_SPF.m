clc
clear
close all

%%
%%% Load LOS deformation point data for three tracks.
data_P26 = load('');
data_P128 = load('');
data_P62 = load('');

%%
% Sample incidence-angle and azimuth rasters at each LOS point location.
%%P26
[Z, R] = readgeoraster('inc_P26.tif');
data_P26(:,4) = NaN; % Initialize incidence-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P26,1)
    lon = data_P26(i,1); % Longitude
    lat = data_P26(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P26(i,4) = pi/2 -  Z(row, col);
    end
end

[Z, R] = readgeoraster('Az_P26.tif');
data_P26(:,5) = NaN; % Initialize azimuth-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P26,1)
    lon = data_P26(i,1); % Longitude
    lat = data_P26(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P26(i,5) = pi - Z(row, col);
    end
end

%%P128
[Z, R] = readgeoraster('inc_P128.tif');
data_P128(:,4) = NaN; % Initialize incidence-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P128,1)
    lon = data_P128(i,1); % Longitude
    lat = data_P128(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P128(i,4) = pi/2 -  Z(row, col);
    end
end

[Z, R] = readgeoraster('Az_P128.tif');
data_P128(:,5) = NaN; % Initialize azimuth-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P128,1)
    lon = data_P128(i,1); % Longitude
    lat = data_P128(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P128(i,5) = pi - Z(row, col);
    end
end


%%P62
[Z, R] = readgeoraster('inc_P62.tif');
data_P62(:,4) = NaN; % Initialize incidence-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P62,1)
    lon = data_P62(i,1); % Longitude
    lat = data_P62(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P62(i,4) =  pi/2 -  Z(row, col);
    end
end

[Z, R] = readgeoraster('Az_P62.tif');
data_P62(:,5) = NaN; % Initialize azimuth-angle column with NaN.
% Convert geographic coordinates to raster row/column indices.
for i = 1:size(data_P62,1)
    lon = data_P62(i,1); % Longitude
    lat = data_P62(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P62(i,5) = pi - Z(row, col);
    end
end
clear  col i inc_P62 lat lon R row Z

%%
% Sample slope and aspect rasters at each LOS point location.

% Slope
data_P26(:,6) = NaN; 
data_P128(:,6) = NaN; 
data_P62(:,6) = NaN; 

[Z, R] = readgeoraster('Slope_BHT.tif');
% P26
for i = 1:size(data_P26,1)
    lon = data_P26(i,1); % Longitude
    lat = data_P26(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P26(i,6) = Z(row, col);
    end
end
data_P26(:,6) = deg2rad( data_P26(:,6) );

%P128
for i = 1:size(data_P128,1)
    lon = data_P128(i,1); % Longitude
    lat = data_P128(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P128(i,6) = Z(row, col);
    end
end
data_P128(:,6) = deg2rad( data_P128(:,6) );

%P62
for i = 1:size(data_P62,1)
    lon = data_P62(i,1); % Longitude
    lat = data_P62(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P62(i,6) = Z(row, col);
    end
end
data_P62(:,6) = deg2rad( data_P62(:,6) );

%%Aspect
data_P26(:,7) = NaN; 
data_P128(:,7) = NaN; 
data_P62(:,7) = NaN; 

[Z, R] = readgeoraster('Aspect_BHT.tif');
% P26
for i = 1:size(data_P26,1)
    lon = data_P26(i,1); % Longitude
    lat = data_P26(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P26(i,7) = Z(row, col);
    end
end
data_P26(:,7) = deg2rad( data_P26(:,7) );

%P128
for i = 1:size(data_P128,1)
    lon = data_P128(i,1); % Longitude
    lat = data_P128(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P128(i,7) = Z(row, col);
    end
end
data_P128(:,7) = deg2rad( data_P128(:,7) );

%P62
for i = 1:size(data_P62,1)
    lon = data_P62(i,1); % Longitude
    lat = data_P62(i,2); % Latitude
    
    % Find the raster pixel corresponding to the point coordinate.
    [col, row] = geographicToIntrinsic(R, lat, lon);
    row = round(row);
    col = round(col);
    
    if row >= 1 && row <= size(Z,1) && col >= 1 && col <= size(Z,2)
        data_P62(i,7) = Z(row, col);
    end
end
data_P62(:,7) = deg2rad( data_P62(:,7) );

clear   col i inc_P62 lat lon R row Z



%%
%%%%%%%%%%%% Build matched point neighborhoods around the reference track.
base_data = data_P128;  % Use P128 as the reference track.
other_data1 = data_P26;
other_data2 = data_P62;

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
        % Accept the first radius containing points from P26 and P62.
        if any(distances1 <= radius) && any(distances2 <= radius)
            min_radii(i) = radius;
            break;  % Stop once the minimum valid radius is found.
        end
    end
end
clear i min_radius max_radius step  distances1 distances2 base_point radius

%%
% Average the matched P26 and P62 observations within each P128 neighborhood.
mean_P26 = nan(size(base_data, 1), 5); 
mean_P62 = nan(size(base_data, 1), 5);
other1_values = cell(size(base_data, 1), 1); % Store matched P26 points for each reference point.
other2_values = cell(size(base_data, 1), 1); % Store matched P62 points for each reference point.

for i = 1:size(base_data, 1)
    
    base_point = base_data(i, 1:2);
    radius = min_radii(i);

    % Compute distances to P26 points.
    distances1 = sqrt((other_data1(:,1)-base_point(1)).^2 + ...
                    (other_data1(:,2)-base_point(2)).^2);

    % Select P26 points inside the matched radius.
    idx = distances1 <= radius;
    points_in_radius = other_data1(idx, :);

    % Save the selected P26 points.
    other1_values{i} = points_in_radius;

    % Average LOS, incidence, azimuth, slope, and aspect values for P26.
    if size(points_in_radius, 1) > 0
        mean_P26(i,1) = mean(points_in_radius(:, 3), 'all');
        mean_P26(i,2) = mean(points_in_radius(:, 4), 'all');
        mean_P26(i,3) = mean(points_in_radius(:, 5), 'all');
        mean_P26(i,4) = mean(points_in_radius(:, 6), 'all');
        mean_P26(i,5) = mean(points_in_radius(:, 7), 'all');
    end
    
     % Compute distances to P62 points.
    distances2 = sqrt((other_data2(:,1)-base_point(1)).^2 + ...
                    (other_data2(:,2)-base_point(2)).^2);

    % Select P62 points inside the matched radius.
    idx = distances2 <= radius;
    points_in_radius = other_data2(idx, :);

    % Save the selected P62 points.
    other2_values{i} = points_in_radius;

    % Average LOS, incidence, azimuth, slope, and aspect values for P62.
    if size(points_in_radius, 1) > 0
        mean_P62(i,1) = mean(points_in_radius(:, 3), 'all');
        mean_P62(i,2) = mean(points_in_radius(:, 4), 'all');
        mean_P62(i,3) = mean(points_in_radius(:, 5), 'all');
        mean_P62(i,4) = mean(points_in_radius(:, 6), 'all');
        mean_P62(i,5) = mean(points_in_radius(:, 7), 'all');
    end
    
end

clear i distances1 distances2 base_point points_in_radius  radius idx

%%
%% Invert East-North-Up deformation from P128, P26, and P62 observations.
     
%% Compute ENU components with the slope-parallel flow constraint.

result = nan(size(base_data, 1), 5);

for i = 1:size(base_data, 1)
    % LOS projection factors for the three tracks.
    Factor_U_P26 = cos(	mean_P26(i,2)	);
    Factor_E_P26 = -1 * sin(	mean_P26(i,2)	) * cos(	mean_P26(i,3)   );
    Factor_N_P26 = sin( mean_P26(i,2)   ) * sin(    mean_P26(i,3)   );

    Factor_U_P128 = cos(    base_data(i,4)  );
    Factor_E_P128 = -1 * sin(   base_data(i,4)  ) * cos(    base_data(i,5)	);
    Factor_N_P128 = sin(    base_data(i,4)  ) * sin(    base_data(i,5)  );

    Factor_U_P62 = cos( mean_P62(i,2)   );
    Factor_E_P62 = -1 * sin(    mean_P62(i,2)   ) * cos(    mean_P62(i,3)   );
    Factor_N_P62 = sin( mean_P62(i,2)   ) * sin(    mean_P62(i,3)   );
    
    Se = tan( base_data(i,6) ) * cos(pi/2 - base_data(i,7) );
    Sn = tan( base_data(i,6) ) * sin(pi/2 - base_data(i,7) );

    Factor = [  %Factor_U_P26	,Factor_E_P26	,Factor_N_P26;
                Factor_U_P128	,Factor_E_P128	,Factor_N_P128;
                Factor_U_P62	,Factor_E_P62	,Factor_N_P62;   
                1               ,Se             ,Sn          ;   ] ;

    V_LOS = [%mean_P26(i,1); 
            base_data(i,3); 
            mean_P62(i,1); 
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
