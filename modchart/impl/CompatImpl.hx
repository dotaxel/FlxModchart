package modchart.impl;

import modchart.impl.components.RenderQueue;
import modchart.impl.components.MusicSync;
import haxe.exceptions.NotImplementedException;

@:inheritDoc(modchart.impl.ICompat)
@:nullSafety(Strict)
abstract class CompatImpl implements ICompat 
{
    public function create():Void {}
    public function dispose():Void {}
    
    public function uploadMusicSync(data:Null<MusicSync>):Void
    {
        if (data == null)
        {
            ModchartLog("Failed to upload music sync: the data is null, keeping last data samples.");
            return;
        }
        Global.musicSync = data;
    }

    public function getBeatFromStep(step:Float):Float
    {
        throw new NotImplementedException();
        return 0;
    }

    public function getMeasureFromBeat(beat:Float):Float
    {
        throw new NotImplementedException();
        return 0;
    }

    /**
     * Upload the render queue.
     * Should be called after your arrows, receptors and holds are up to date.
     * @param data 
     */
    public function uploadQueue():Null<RenderQueue>
    {
        throw new NotImplementedException();
        return null;
    }
}