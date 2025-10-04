 function digitalTwin()
    clc; clear;

    %% --------------------------
    %% KNOX / Palm scan + Smart Ring simulation
    %% --------------------------
    knoxEnabled = true; 
    if ~knoxEnabled
        disp("KNOX/palm scan locked. Twin inactive."); 
        return;
    end

    %% --------------------------
    %% Devices & Regions
    %% --------------------------
    devices = {'samsung_ring','samsung_watch','samsung_phone'};
    regions = {'North','South','East','West'};

    %% --------------------------
    %% Initialize Device States with Multimodal & Biometric data
    %% --------------------------
    deviceStates = struct();
    emotions = {'happy','neutral','stressed','tired'};
    for i = 1:length(devices)
        dev = devices{i};
        deviceStates.(dev) = struct( ...
            'battery', randi([50 100]), ...
            'signal', randi([-80 -40]), ...
            'temp', 36+rand(), ...
            'heartRate', randi([60 120]), ...
            'steps', randi([0 20000]), ...
            'healthScore', rand()*2, ...
            'stressLevel', rand(), ...        % 0-1 stress indicator
            'emotion', emotions{randi(length(emotions))}, ...
            'voiceActivity', rand()*10, ...   % e.g., mins of voice interaction
            'cameraActivity', rand()*10 ...   % e.g., mins of camera usage
        );
    end

    %% --------------------------
    %% Multi-region mapping
    %% --------------------------
    userRegions = struct();
    for r = 1:length(regions)
        reg = regions{r};
        userRegions.(reg) = devices(r:min(r+1,length(devices)));
    end

    %% --------------------------
    %% Device tests and wellness prediction
    %% --------------------------
    testResults = runDeviceTests(devices, deviceStates);
    wellnessPredictions = struct();
    for i=1:length(devices)
        dev = devices{i};
        % Simple predictive coaching simulation
        if deviceStates.(dev).stressLevel > 0.7
            advice = "Take a short break or practice mindfulness";
        elseif deviceStates.(dev).steps < 5000
            advice = "Consider walking to reach your daily step goal";
        else
            advice = "Keep up the good work!";
        end
        wellnessPredictions.(dev) = advice;
    end

    %% --------------------------
    %% Aggregate user score & predicted wellness
    %% --------------------------
    aggregatedScore = mean(structfun(@(x) x.healthScore, deviceStates));

    %% --------------------------
    %% Generate health & emotion trends and save as base64
    %% --------------------------
    healthImages = struct();
    emotionImages = struct();
    for i=1:length(devices)
        dev = devices{i};
        t = 1:10;
        trend = deviceStates.(dev).healthScore + rand(1,10)*0.5;
        fig = figure('Visible','off');
        plot(t, trend,'-o'); title([dev ' Health Trend']);
        xlabel('Time'); ylabel('Health Score'); grid on;
        fname = [dev '_trend.png'];
        saveas(fig,fname);
        healthImages.(dev) = imageToBase64(fname);
        close(fig);

        % Emotion trend simulation
        emotionTrend = randi([1 4],1,10); % Map to emotions
        fig = figure('Visible','off');
        plot(t, emotionTrend,'-s'); title([dev ' Emotion Trend']); ylim([1 4]);
        yticks(1:4); yticklabels({'happy','neutral','stressed','tired'});
        xlabel('Time'); ylabel('Emotion'); grid on;
        efile = [dev '_emotion.png'];
        saveas(fig,efile);
        emotionImages.(dev) = imageToBase64(efile);
        close(fig);
    end

    %% --------------------------
    %% Battery & Signal Heatmaps
    %% --------------------------
    heatmapImages = struct();
    batteryMatrix = [];
    signalMatrix = [];
    for r = 1:length(regions)
        reg = regions{r};
        devs = userRegions.(reg);
        batteryMatrix(r,1:length(devs)) = cellfun(@(d) deviceStates.(d).battery, devs);
        signalMatrix(r,1:length(devs)) = cellfun(@(d) deviceStates.(d).signal, devs);
    end

    fig = figure('Visible','off');
    heatmap(devices(1:size(batteryMatrix,2)), regions, batteryMatrix); title('Battery % Heatmap');
    batteryFile = 'battery_heatmap.png';
    saveas(fig,batteryFile); heatmapImages.battery = imageToBase64(batteryFile);
    close(fig);

    fig = figure('Visible','off');
    heatmap(devices(1:size(signalMatrix,2)), regions, signalMatrix); title('Signal Strength Heatmap');
    signalFile = 'signal_heatmap.png';
    saveas(fig,signalFile); heatmapImages.signal = imageToBase64(signalFile);
    close(fig);

    %% --------------------------
    %% Simulated Agentic Suggestions
    %% --------------------------
    agenticSuggestions = struct();
    for i=1:length(devices)
        dev = devices{i};
        suggestion = "";
        if deviceStates.(dev).battery < 30
            suggestion = "Charge device soon";
        end
        if deviceStates.(dev).signal < -70
            suggestion = [suggestion + "; Move closer to WiFi/Cell signal"];
        end
        if deviceStates.(dev).stressLevel > 0.8
            suggestion = [suggestion + "; Follow stress-relief advice"];
        end
        agenticSuggestions.(dev) = strtrim(suggestion);
    end

    %% --------------------------
    %% Prepare JSON output
    %% --------------------------
    outputJSON = struct();
    outputJSON.timestamp = string(datetime('now'));
    outputJSON.deviceStates = deviceStates;
    outputJSON.userRegions = userRegions;
    outputJSON.testResults = testResults;
    outputJSON.aggregatedScore = aggregatedScore;
    outputJSON.healthGraphs = healthImages;
    outputJSON.emotionGraphs = emotionImages;
    outputJSON.heatmaps = heatmapImages;
    outputJSON.wellnessPredictions = wellnessPredictions;
    outputJSON.agenticSuggestions = agenticSuggestions;

    %% Output JSON for Flask
    disp(jsonencode(outputJSON));
end

%% --------------------------
%% Device Tests
%% --------------------------
function testResults = runDeviceTests(devices, deviceStates)
    testResults = struct();
    for i=1:length(devices)
        dev = devices{i};
        batteryOK = deviceStates.(dev).battery > 20;
        signalOK = deviceStates.(dev).signal > -75;
        tempOK = deviceStates.(dev).temp < 40;
        hrOK = deviceStates.(dev).heartRate < 130;
        stepsOK = deviceStates.(dev).steps >= 0;

        testResults.(dev) = struct( ...
            'batteryOK', batteryOK, ...
            'signalOK', signalOK, ...
            'tempOK', tempOK, ...
            'heartRateOK', hrOK, ...
            'stepsOK', stepsOK, ...
            'allOK', batteryOK && signalOK && tempOK && hrOK && stepsOK ...
        );
    end
end

%% --------------------------
%% Image to Base64
%% --------------------------
function b64 = imageToBase64(filename)
    fid = fopen(filename,'rb'); bytes = fread(fid); fclose(fid);
    b64 = matlab.net.base64encode(bytes);
end
