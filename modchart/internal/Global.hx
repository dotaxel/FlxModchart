package modchart.internal;

import ICompat.MusicSync;

class Global {
    private static var _nextActorID:Int = 0;

    public static var musicSync:MusicSync;
    
    public function updateVariables() {

    }

    macro public static function log(message:String)
    {
        #if !FLX_MODCHART_NO_LOGS
        return macro {};
        #else
        return macro {trace("[ FunkinModchart ] " + message )};
        #end
    }
}