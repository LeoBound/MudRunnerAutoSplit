state("MudRunner")
{
    //float levelTimer : 0xB99020; // Time after loaded in (but seems to get reset sometimes?)
    float levelTimer : 0xBA40BC; //Time which was played on a map, pesistent even after loading a game
    float globalTimer : 0xBA4A60; // Total time since loading game
    bool finished : 0xB990AC; // Have all the logs on the current level been delivered?
    bool guiOpen : 0xB9A0BD; // Seems to be if a GUI is open?
    bool paused : 0xBA3F5D; // Is the pause screen open or has a challenge been completed?
    bool paused2 : 0xB99EFD; // Another paused address.
    bool loadedIn : 0xB9C9D5; // Has the game loaded in?
    byte challengeOverlayOpen: 0xB990D5; // Tutorial or finish screen overlay state (0=overlay not visible, known other states: 1,2) 
}

startup
{
    print("MudRunner Autosplitter v0.1");

    settings.Add("debug", false, "Debug?");
    settings.SetToolTip("debug", "Log variables to the DebugView");

    settings.Add("autoreset", true, "Automatic reset?");
    settings.SetToolTip("autoreset", "If true the timer will be automatically reset after a restart or leaving a level");
    
    vars.loadedPrev = false;
}

init 
{
    // Hacky lambda stuff to define custom logging.
    Action<string> debugPrinter = (string msg) => {if (settings["debug"]){print(msg);}}; 
    vars.debugPrinter = debugPrinter;
    vars.lastSplitTime = DateTime.UtcNow;
}

start 
{
    return current.loadedIn;
}

split 
{
    // return current.finished; // Code splits way to often at finish screen, this is problematic if you try to run multiple maps
    
    if ( // Split if:
        (current.finished || current.challengeOverlayOpen != 0) // map or challenge is finished ...
        && current.loadedIn // ... and map is loaded (prevents accidental splits at the start of the next level after finishing a map)...
        && !(current.paused || current.paused2) // ... and game is not paused (prevents accidental splits at the menu screen after finishing a level) ...
        && vars.lastSplitTime.AddMinutes(1) < DateTime.UtcNow // ... and the last split was not done within the last minute (prevents multiple splits at the finish screen for 1 minute)
    ){
        vars.lastSplitTime = DateTime.UtcNow;
        return true;
    }
}

reset 
{
    if (settings["autoreset"]){
        return old.loadedIn != current.loadedIn;
    }
}

update 
{
    vars.debugPrinter("Loaded? " + old.loadedIn + current.loadedIn + ", Current Time: " + current.levelTimer + ", isPaused? " + current.paused + ", isFinished? " + current.finished);   //Pls add interpolated strings devs thx
}


isLoading 
{
    //Note: current.levelTimer == old.levelTimer ends up being constantly paused at high FPS
    return current.paused || current.paused2 || current.finished || current.challengeOverlayOpen != 0; 
}
