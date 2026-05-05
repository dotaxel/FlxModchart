package modchart.impl.components;

import flixel.FlxSprite;

enum ArrowState {
    Idle;
    Hit;
    Miss;
    Held;
}

enum ArrowType {
    /**
     * `Decorator` and `Receptor` take almost the same treat in the renderer.
     */
    Decorator;
    Receptor;

    Tap;

    HoldBody;
    HoldEnding;
}

enum abstract ArrowFlags(Int) from Int to Int
{
    public var NONE = 0;

    public var HOLDING = 1 << 0;

    public var JUST_HIT = 1 << 1;
    public var JUST_MISS = 1 << 2;
    public var JUST_HELD = 1 << 3;
}

typedef ArrowQueueList = {

    /**
     * The arrow `FlxSprite`.
     * 
     * Used for get:
     * - Arrow texture (`FlxGraphic`).
     * - Sprite transformations:
     *  - `offset` and `origin`.
     *  - `scale` and `angle`.
     *  - `colorTransform` (this one includes alpha).
     *  - `flipX` and `flipY`.
     * - Sprite shader (if it does have one).
     * 
     * - Animation frame transformations and UVs (`FlxFrame`):
     *  - `uv`.
     *  - `angle`.
     * 
     * If your game doesnt use FlxSprite for rendering you may 
     */
    // The arrow FlxSprite.
    // If your game doesnt really use FlxSprites
    arrow: Array<FlxSprite>,

    // The desired tap time in miliseconds.
    hitTime:Array<Float>,

    // The start time of the hold (if it is) in miliseconds.
    // Used for either hold scaling or just modifiers that can need it.
    parentTime:Array<Float>,
    
    // The length of the hold (if it is) in miliseconds.
    length:Array<Float>,

    lane:Array<Int>,
    player:Array<Int>,

    // Used for `HOLD` arrow type.
    // Change this every hold for adaptive subdivisions.
    subdivisions:Array<Int>,
    downscroll:Array<Bool>,

    arrowType:Array<ArrowType>,

    state:Array<ArrowState>,
    flags:Array<ArrowFlags>
}