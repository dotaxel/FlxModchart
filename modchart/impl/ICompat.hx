package;

import modchart.impl.components.*;

interface ICompat
{
    public function create():Void;
    public function dispose():Void;

    /**
     * Upload the music sync variables.
     * Should be called everytime the music position changes (multiple times a frame).
     * @param data 
     */
    public function uploadMusicSync(data:MusicSync):Void;

    // Get beat position from step position.
    public function getBeatFromStep(beat:Float):Float;
    // Get measure position from beat position.
    public function getMeasureFromBeat(beat:Float):Float;

    /**
     * Upload the render queue.
     * Should be called after your arrows, receptors and holds are up to date.
     * @param data 
     */
    public function uploadQueue():RenderQueue;
}