---@class AudioManager
AudioManager = {}
local audioObject = {};         --音乐gameObject对象
-- TODO: Unity 5.3.5 Bug: 音效不能释放www, 即不能 "assetbunle.unload(false)",所以需要给音效保留assetobj.
-- 因此加载目前调用的是 ResourceLoader.LoadRawAsset
local _unity_audio_bug_fixed = false; 
--作用：播放UI音效
--path：音效路径
--说明：3d音效为了保证及时性，可以提前进行加载
--      未进行预加载的音效会到时候再加载
function AudioManager.PlayAudio(path)
    local asset = ResourceManager.GetRes(path);
    if(asset ~= nil)then
        local audioRealObject = audioObject[path];
        if audioRealObject == nil then
            audioRealObject = asset_game_object.create_unsave(asset.obj);
            audioRealObject:set_parent(AudioManager.GetAudioSourceNode());
            audioObject[path] = audioRealObject;
        end
        local audiosource = audioRealObject:get_component_audio_source();
        audiosource:set_mute(false);
        audiosource:set_volume(1);
        audiosource:set_pan_level(0);
        audiosource:play();        
    else
        AudioManager.LoadAndPlayAudio(path, false);
    end
end
--作用：播放背景音效
--path：音效路径
--说明：3d音效为了保证及时性，可以提前进行加载
--      未进行预加载的音效会到时候再加载
function AudioManager.PlayBackgroundAudio(path)
    local asset = ResourceManager.GetRes(path);
    if(asset ~= nil)then
        local audioRealObject = audioObject[path];
        if audioRealObject == nil then
            audioRealObject = asset_game_object.create_unsave(asset.obj);
            audioRealObject:set_parent(AudioManager.GetAudioSourceNode());
            audioObject[path] = audioRealObject;
        end
        local audiosource = audioRealObject:get_component_audio_source();
        audiosource:set_mute(false);
        audiosource:set_volume(0.5);
        audiosource:set_pan_level(0);
        audiosource:play();        
    else
        AudioManager.LoadAndPlayAudio(path, true);
    end
end

-----加载UI音效，完成后播放---
function AudioManager.LoadAndPlayAudio(path, isBackground)
    if _unity_audio_bug_fixed then
        ResourceLoader.LoadAsset(path, Utility.create_callback_ex(AudioManager.on_load_and_play_ui_audio, true, 4, path, isBackground), "audio_"..path)
    else
        ResourceLoader.LoadRawAsset(path, Utility.create_callback_ex(AudioManager.on_load_and_play_ui_audio, true, 4, path, isBackground), "audio_"..path)
    end
end

function AudioManager.on_load_and_play_ui_audio(pid, filepath, asset_obj, error_info, path, isBackground)
    -- ResourceManager.AddPermanentReservedRes(path);
    if isBackground then
        AudioManager.PlayBackgroundAudio(path);
    else
        AudioManager.PlayAudio(path);
    end
end

function AudioManager.GetAudioSourceNode()
    if(not AudioManager.audioSourceNode)then
        AudioManager.audioSourceNode = asset_game_object.find("audio_source_node");
    end
    return AudioManager.audioSourceNode;
end

function AudioManager.GetAudioObject(path)
    return audioObject[path];
end

function AudioManager.DelAudioObject(path)
    audioObject[path] = nil;
end

function AudioManager.StopAudio(path)
    ResourceLoader.ClearGroupCallBack("audio_"..path);
    local audioObject = AudioManager.GetAudioObject(path);
    if audioObject then
        local audiosource = audioObject:get_component_audio_source();
        if audiosource then
            audiosource:stop();
        end
    end
end

function AudioManager.ClearAudio()
    for k, v in pairs(audioObject) do
        local audiosource = v:get_component_audio_source();
        if audiosource then
            audiosource:stop();
        end
    end
    audioObject = {};
end