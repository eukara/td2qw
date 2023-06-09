/* public domain, do whatever you please. */
typedef float filestream;

/* builtins used */
filestream(string filename, float mode) fopen = #110;
void(filestream fhandle) fclose = #111;
string(filestream fhandle) fgets = #112;
string(string, optional string, optional string, optional string, optional string, optional string, optional string, optional string) strcat = #115;
string(string filename, optional enumflags:float{WP_REFERENCEPACKAGE,WP_FULLPACKAGEPATH} flags) whichpack = #503;
void(string text,...) print = #339;
void(string cmd) readcmd = #0:readcmd;
string(string fmt, ...) sprintf = #627;
string(string cvarname) cvar_string = #448;

/* constants */
const float FILE_READ = 0;

void
Mapcycle_Load(string filename)
{
	filestream fs_mapcycle;
	string temp;
	float mapcount = 0;
	string lastmap = "";
	float map_next = 0;

	fs_mapcycle = fopen(filename, FILE_READ);

	if (fs_mapcycle < 0) {
		print(strcat("^1could not load ", filename, "\n"));
		return;
	}

	/* read the lines in, see if the map exists and define an enumerated alias */
	while ((temp = fgets(fs_mapcycle))) {
		if not (whichpack(strcat("maps/", temp, ".bsp")))
			continue;

		readcmd(sprintf("alias m%d \"map %s;alias nextmap m%d\"\n", mapcount, temp, mapcount + 1));

		if (mapname == lastmap)
			map_next = mapcount;

		lastmap = temp;
		mapcount++;
	}

	fclose(fs_mapcycle);

	if (mapcount <= 0)
		return;

	/* override the last map so that it goes back to m0 */
	readcmd(sprintf("alias m%d \"map %s;alias nextmap m0\"\n", mapcount - 1, lastmap));

	/* the current map in the list will decide the nextmap */
	readcmd(sprintf("alias nextmap m%d\n", map_next));

	print(sprintf("mapcycle initialized with %d entries.\n", mapcount));
}

void
Mapcycle_Init(void)
{
	string cycleFile = autocvar(mapcycle_file, "mapcycle.txt");

	/* in case some server admin wants a map to continously loop */
	if not (cycleFile) {
		print("mapcycle disabled via cvar. skipping\n");
		return;
	}

	print("--------- Initializing MapCycle ----------\n");
	Mapcycle_Load(cycleFile);
}