state("MudRunner")
{
	//float levelTimer : 0xB99020; // Time after loaded in (but seems to get reset sometimes?)
	float levelTimer : 0xBA40BC; //Time which was played on a map, pesistent even after loading a game
	float globalTimer : 0xBA4A60; // Total time since loading game
	bool finished : 0xB990AC; // Have all the logs on the current level been delivered?
	bool paused : 0xB99EFD; // Is the pause screen open?
	bool loadedIn : 0xB9C9D5; // Has the game loaded in?
}

startup
{
    print("MudRunner Autosplitter v0.1");
	
	settings.Add("debug", false, "Debug?");
	settings.SetToolTip("debug", "Log variables to the DebugView");

	vars.loadedPrev = false;
}

init 
{
	// Hacky lambda stuff to define custom logging.
	Action<string> debugPrinter = (string msg) => {if (settings["debug"]){print(msg);}}; 
	vars.debugPrinter = debugPrinter;
	
}

start 
{
    return current.loadedIn;
}

split 
{
    return current.finished;
}

reset 
{
    return old.loadedIn == current.loadedIn;
}

update 
{
	//Pls add interpolated strings devs thx
    vars.debugPrinter("Loaded? " + current.loadedIn + ", Current Time: " + current.levelTimer + ", isPaused? " + current.paused + ", isFinished? " + current.finished);
}


isLoading 
{
    return current.paused //|| current.levelTimer == old.levelTimer; Ends up being constantly paused at high FPS
}
