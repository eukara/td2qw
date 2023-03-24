//
// Elohim.qc
//
// Elohim clan server mod V2.2a
//
// Developed Nov '97 - Jan '98 by J.P. Grossman (a.k.a. ùMephistopheles)
//
// Fields used:
//
// General:
//
// .style           - Elohim player flags
// .count           - used for entering password / ghostcode
// .cnt             - number of suicides remaining
// .wait            - time to do periodic checks
// .state           - unique player id
// .finaldest_y     - used for pinging
// .height          - used to store player team
// .finaldest_x     - used to test for disconnected players
// .use             - pointer to function to call when a number is entered
// .finaldest_z     - the number that was entered
// .owner           - players's ghost entity
// .enemy           - stores last spawn point/camera location for admins
//
// Statistics:
//
// .dest1_x         - damage fired from bullets
// .dest2_x         - damage done from bullets
// .dest1_y         - damage fired from nails
// .dest2_y         - damage done from nails
// .dest1_z         - damage fired from lightning gun
// .dest2_z         - damage done from lightning gun
// .dest_x          - damage fired from rockets
// .dest_y          - damage done from rockets
// .mangle_x        - number of times killed self
// .mangle_y        - number of times killed teammate
// .mangle_z        - number of times was killed
//
// Observer mode:
//
// .trigger_field   - closest teleport when observing, last spawn if playing
// .t_width         - activation radius for closest teleport
// .dest            - stores destination for popping forward through doors
// .dest1           - stores velocity for popping forward through doors
// .delay           - time to refresh head's up display for observing
// .speed           - z component of velocity from previous frame (for fly)
// .movetarget      - player being watched in observer mode (world if none)
// .lip             - id of player being watched (0 if none)
//
// Used for setting options:
//
// .delay     - time to update display (shared with observer.qc)
// .pos1_x    - timelimit
// .pos1_y    - fraglimit
// .pos1_z    - mode
// .pos2_x    - gibs
// .pos2_y    - teamplay
// .pos2_z    - noexit
// .worldtype - sys_ticrate
// .aflag     - pausable/quad/pent/ring/mode vote
// .t_length  - which option is currently selected
//
// Console variables used:
//
// samelevel    - server flags
// v_kicktime   - level number
// localinfo temp1  - console commands
//

// function declarations
void () elohim_load_entities;
void (float vlaue) elohim_set_teamplay;
void () elohim_reset_stats;
void (float command) console_command;
void () console_set_aliases;
void () admin_send_aliases1;
void () admin_impulse;
void () admin_start_code;
void (float fDoKick) admin_confirm_kick_response;
void (entity player) admin_disconnect_notify;
void () observer_impulse;
void () observer_start;
void (float response) observer_confirm_leave_response;
void () match_show_timelimit;
void () match_impulse;
void (entity player) match_verify_team;
void (entity player) match_disconnect_notify;
void () vote_impulse;
void () execute_changelevel;
void () NextLevel;
void (vector org, entity death_owner) spawn_tdeath;
void () admin_logout;

// constants
float ELOHIM_SUICIDE_OK = 0;
float ELOHIM_TOO_MANY_SUICIDES = 1;

// client styles
float ELOHIM_NEW_CLIENT = 1;         // set when a client first connects
float ELOHIM_ADMINISTRATOR = 2;      // set if the client is an admin
float ELOHIM_OBSERVER = 4;           // set if the client is an observer
float ELOHIM_READY = 128;            // ready to play in match
float ELOHIM_YES = 256;              // used for voting
float ELOHIM_HEADS_UP = 512;         // enable heads up display
float ELOHIM_SETTING_OPTIONS = 1024; // set when setting options
float ELOHIM_OK_TO_SHOOT = 2048;     // don't fire after options/respawn
float ELOHIM_KICK_CONFIRM = 4096;    // used to confirm a kick
//float ELOHIM_CONNECTED = 8192;     // client has been put in server
//^^^^^^^^^^^^^^^^^^^^^^ - moved to utils.qc
float ELOHIM_FOUND_BINDINGS = 16384; // used to check for bindings
float ELOHIM_CONFIRM_LEAVE = 32768;  // confirmation for leaving match

// server mode - stored in cvar 'samelevel' and preserved across levels
float ELOHIM_SAME_LEVEL = 1;
float ELOHIM_MATCH_MODE = 2;
float ELOHIM_PRACTICE_MODE = 4;
float ELOHIM_SERVER_INITIALIZED = 8;
float ELOHIM_NO_GIBS = 16;
float ELOHIM_LOW_GIBS = 32;
float ELOHIM_NO_QUAD = 64;
float ELOHIM_NO_PENT = 128;
float ELOHIM_NO_RING = 256;
float ELOHIM_MODE_VOTE = 512;

// server state - not preserved across level changes
float ELOHIM_TIMER_STARTED = 1;
float ELOHIM_MATCH_STARTED = 2;
float ELOHIM_MATCH_PAUSED = 4;
float ELOHIM_MATCH_OVER = 8;
float ELOHIM_MATCH_WAIT = 16;   // 5 second delay after match ends
float ELOHIM_KICKING = 32;

// elohim global variables
float elohim_player_ids; // used for assigning unique player ID's
float elohim_password;   // used to store the administrator password
float elohim_devparam;   // used for development
float elohim_playmode;   // current play mode (non volatile flags)
float elohim_state;      // server state (volatile flags)
float elohim_timelimit;  // timelimit for matches (default 20 minutes)
float elohim_nextcheck;  // used for periodic checks
entity elohim_request;   // used to control voting
float elohim_level;      // number of level in user level order
float elohim_levelcount; // used to scan through list in levels.cfg
float elohim_lastcount;  // used to detect end-of-file in levels.cfg
float elohim_num_spawns; // number of deathmatch spawn points
float elohim_num_starts; // number of match extra start points
string elohim_version;   // used for motd and help-server
string elohim_version_info; // text info including rev. and compile time
entity elohim_debug_client; // used for debugging

// other global variables
string nextmap;  // moved here from client.qc
float timelimit; // this used to be local in CheckRules in Client.qc        
float fraglimit; // this used to be local in CheckRules in Client.qc        

//
//  I N I T  W O R L D
//
//  Called from InitWorld in World.qc
//
void () elohim_init_world =
{
    local float temp;

    elohim_version = "TD2.11";
//    elohim_version_info = "by Campaum\nhttp://arenacamper.125mb.com";

    // Initialize user map names and MOTD
    userdefs_init_world();

    // Precache sound used when players connect
    precache_sound("wizard/wsight.wav");

    // Get/set console variables
    elohim_playmode = cvar("samelevel");
    if (elohim_playmode & ELOHIM_MATCH_MODE)
        teamplay = 2;
    else
        teamplay = cvar("teamplay");
    elohim_set_teamplay(-1);
    elohim_level = cvar("v_kicktime");
    cvar_set("v_kicktime", "0");

    // Check to see if we need to initialize the server
    if (!(elohim_playmode & ELOHIM_SERVER_INITIALIZED))
    {
        cprint("Initializing server...\n");

        // Set aliases for console commands
        console_set_aliases();

        // Initialize global variables
        cvar_set("v_kicktime", "0");
        serverflags = 0;
        elohim_playmode = elohim_playmode | ELOHIM_SERVER_INITIALIZED;
        utils_set_cvar("samelevel", elohim_playmode);
    }

    // Set global variables                        
    elohim_player_ids = 1;
    elohim_devparam = 0;
    elohim_nextcheck = time;
    elohim_request = world;
    elohim_levelcount = 0;
    elohim_lastcount = 0;
    elohim_state = 0;
    elohim_num_spawns = 0;
    elohim_num_starts = 0;
    elohim_debug_client = world;

    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
        elohim_timelimit = cvar("timelimit");
        if (elohim_timelimit == 0)
            elohim_timelimit = 20;
        if (elohim_timelimit < 2)
            elohim_timelimit = 2;
        match_show_timelimit();
    }
    else
        elohim_timelimit = 20;

    localcmd("exec senha.cfg\n");

    // schedule the ents for a bit later so that they don't
    // interfere with the password
        utils_make_scheduled_event(elohim_load_entities, 0.2);
};

//
//  E L O H I M  L O A D  E N T I T I E S
//
void () elohim_load_entities =
{
    localcmd3("exec entities/", mapname, ".ent;wait\n");
    remove(self);
};

//
//  S E T  T E A M P L A Y
//
//  Sets the teamplay server variable to show teamplay, "Elohim2.0",
//  and either "FFA", "Practice" or "Match" depending on the current mode.
//  If value = -1 then the teamplay variable is preserved; otherwise it
//  is changed to 'value'.
//
void (float value) elohim_set_teamplay =
{
    local string temp;

    if (value != -1)
        teamplay = value;
    temp = ftos(teamplay);
    localcmd3("teamplay \"", temp, " : TD2.11 ");
    if (elohim_playmode & ELOHIM_MATCH_MODE)
        localcmd("Match\"\n");
    else if (elohim_playmode & ELOHIM_PRACTICE_MODE)
        localcmd("Practice\"\n");
    else
        localcmd("FFA\"\n");
};

//
//  I N T R O  T H I N K
//
//  Display the message of the day.
//
void () elohim_intro_think =
{
    if (self.attack_finished < time)
        remove (self);
    else
    {

        centerprint4(self.owner, "\n\n\n\n\n\n", elohim_version,
            "\n Bem vindo(a) \ntype ÈÅÌÐ­ÓÅÒÖÅÒ in console for help\n\n",
             USER_MOTD);

        self.nextthink = time + 0.5; //matador - tira logo pq a do td e' melhor
    }
};

//
//  M A K E  I N T R O
//
//  Create an entity to display the MOTD for 5 seconds (plus a bit).
//
void () elohim_make_intro =
{
    local entity intro;
    intro = utils_make_scheduled_event(elohim_intro_think, 0.2);
    intro.attack_finished = time + 0.5;
};

//
//  S E T  A L I A S E S
//
//  This is scheduled using a temporary entity; the client
//  is stored in self.owner.
//
void () elohim_set_aliases =
{
    local entity temp;

    // Remove the temporary entity
    temp = self.owner;
    remove(self);
    self = temp;

    // Check for binds
    if (self.style & ELOHIM_FOUND_BINDINGS)
        return;

    sprint(self, "Sending bindings\n");

    // Set aliases
    stuffcmd(self, "alias help-server impulse 100\n");
//    stuffcmd(self, "alias help-elohim impulse 102\n");
    stuffcmd(self, "alias help-misc impulse 105\n");
    stuffcmd(self, "alias commands impulse 106\n");
    stuffcmd(self, "alias levels impulse 107\n");
    stuffcmd(self, "alias warp impulse 107\n");
    stuffcmd(self, "alias admin impulse 108\n");
    stuffcmd(self, "alias logout impulse 102\n");
    stuffcmd(self, "alias motd impulse 109\n");
    stuffcmd(self, "alias killstats impulse 110\n");
    stuffcmd(self, "alias efficiency impulse 111\n");
    stuffcmd(self, "alias stats impulse 112\n");
    stuffcmd(self, "alias vinfo impulse 117\n");
    stuffcmd(self, "alias ignore-this impulse 119\n");
    stuffcmd(self, "alias yes impulse 120\n");
    stuffcmd(self, "alias no impulse 121\n");
    stuffcmd(self, "alias ready impulse 130\n");
    stuffcmd(self, "alias notready impulse 131\n");
    stuffcmd(self, "alias unlock impulse 132\n");
    stuffcmd(self, "alias ready? impulse 133\n");
    stuffcmd(self, "alias timerstop impulse 134\n");
    stuffcmd(self, "alias timerstart impulse 135\n");
    stuffcmd(self, "alias ghostcode impulse 136\n");
    stuffcmd(self, "alias ghost impulse 137\n");
    stuffcmd(self, "alias score impulse 138\n");
    stuffcmd(self, "alias help-match impulse 139\n");
    stuffcmd(self, "alias observer impulse 140\n");

    utils_make_scheduled_event(admin_send_aliases1, 0.5);
};

//
//  I N I T  T H I N K
//
//  Called 0.2 seconds after a client connects.  Plays the wizard sound
//  and schedules the aliases to be sent.
//
void () elohim_init_think =
{
    local entity temp;
    temp = self;
    self = self.owner;
    if (!(elohim_playmode & ELOHIM_MATCH_MODE) ||
        !(elohim_state & ELOHIM_MATCH_STARTED))
        sound(self, CHAN_AUTO, "wizard/wsight.wav", 1, ATTN_NONE);
    if (self.netname == "" || self.netname == "unconnected")
        stuffcmd(self, "name player\n");
    sprint(self, "Searching for bindings...\n");
    stuffcmd(self, "ignore-this\n"); // test for binds
    self = temp;
    self.think = elohim_set_aliases;
    self.nextthink = time + 3; // wait 3 seconds for the "ignore-this" result
};

//
//  S H O W  M O D E
//
//  Show mode and help info to a player after they connect.
//
void () elohim_show_mode =
{
    sprint2(self.owner, elohim_version, "\n");
    if (elohim_playmode & ELOHIM_MATCH_MODE)
        sprint(self.owner, "match mode - help-match for help\n");
    else if (elohim_playmode & ELOHIM_PRACTICE_MODE)
        sprint(self.owner, "practice mode\n");
    else
        sprint(self.owner, "FFA mode\n");
    remove(self);
};

//
//  C L I E N T  C O N N E C T
//
//  Called from ClientConnect in Client.qc when a client enters the
//  server.  This occurs when the client first connects over the network
//  and every time a new level is started.
//
void () elohim_client_connect =
{
    // Eluan - checar isso sempre, caso contrário os aliases podem não ser enviados
    // ex: ao entrar em um servidor vazio na tela de rankings, o próximo mapa
    // pode ser carregado antes do tempo de espera para enviar os aliases
    utils_make_scheduled_event(elohim_init_think, 0.5);

    if ((parm10 & ELOHIM_NEW_CLIENT) > 0)
    {
        // This is a new client (just connected over the network)

        // Show the MOTD
        elohim_make_intro();
        //utils_make_scheduled_event(elohim_init_think, 0.5);

        // Give the player a unique ID
        parm11 = elohim_player_ids;
        elohim_player_ids = elohim_player_ids + 1;
        if (elohim_player_ids > 65535)
            elohim_player_ids = 1;

        // Get rid of the new client flag
        parm10 = parm10 - ELOHIM_NEW_CLIENT;

        elohim_reset_stats();
    }
    utils_make_scheduled_event(elohim_show_mode, 0.5);
    self.cnt = ELOHIM_MAX_SUICIDES;  // numer of suicides allowed
    self.finaldest_y = 0;    // used for pinging
    self.owner = world;      // no ghost
    self.trigger_field = world; // last spawn point
    self.use = SUB_Null;
    self.style = 0;

    parm10 = parm10 - (parm10 &
        (ELOHIM_READY | ELOHIM_KICK_CONFIRM |
         ELOHIM_SETTING_OPTIONS | ELOHIM_FOUND_BINDINGS));
};

//
//  R E S E T  S T A T S
//
void () elohim_reset_stats =
{
    self.dest1 = self.dest2 = self.dest = self.mangle = '0 0 0';
};

//
//  C L I E N T  D I S C O N N E C T
//
//  Called from ClientDisconnect in Client.qc when a client leaves.
//
void () elohim_client_disconnect =
{
    self.style = self.style - (self.style & ELOHIM_CONNECTED);
    self.finaldest_x = -30;

    // If we're in match mode, then call match_disconnect_notify
    if (elohim_playmode & ELOHIM_MATCH_MODE)
        match_disconnect_notify(self);

    // Let the admin module know in case there's a kick in progress
    admin_disconnect_notify(self);

    // Check to see if we were debugging this client
    if (elohim_debug_client == self)
        elohim_debug_client = world;
};

//
//  H E L P
//
//  Show general help commands.
//
void () elohim_help =
{
    local string numsuicides;

    numsuicides = strings_ftos_gold(ELOHIM_MAX_SUICIDES);

    sprint2(self, elohim_version, "\n");
    sprint(self, "http://www.terra.com.br\n");
    sprint(self, "-\n");
    sprint3(self, "ŽÍáøéíõí ", numsuicides, " óõéãéäåó ðåò ìåöåìŽ\n");
    sprint(self, "Help commands (type in console):\n");
    sprint(self, " help-misc     - misc commands\n");
    sprint(self, " help-match    - match mode help\n");
//    sprint(self, " help-elohim   - Elohim info\n");
    sprint(self, " commands - list commands/impulses\n");
};

//
//  H E L P  C H A N G E
//
//  Show help on how to change levels.
//
void () elohim_help_change =
{
    sprint(self, "\n");
    sprint(self, "Ôï ãèáîçå ìåöåìó¬ åîôåò ôèå îáíå ïæ\n");
    sprint(self, "ôèå ìåöåì éî ôèå ãïîóïìå®\n");
};

//
//  H E L P  M I S C
//
//  Show misc commands.
//
void () elohim_help_misc =
{
    sprint(self, " admin    - enter admin code\n");
    sprint(self, " logout   - sai do modo admin\n");
    sprint(self, " setquad  - enable/disable quad\n");
    sprint(self, " setpent  - enable/disable pent\n");
    sprint(self, " setring  - enable/disable ring\n");
    sprint(self, " motd     - show message of the day\n");
    sprint(self, " commands - list commands/impulses\n");
    sprint(self, " observer - toggle observer mode\n");
    sprint(self, " nogibs   - disable gibs\n");
    sprint(self, " lowgibs  - set gibs to 'low'\n");
    sprint(self, " highgibs - set gibs to 'high'\n");
    sprint(self, " levels   - list all server levels\n");
    sprint(self, " stats    - summarize statistics\n");
    sprint(self, " killstats  - list player kill stats\n");
    sprint(self, " efficiency - list player efficiency\n");
};

//
//  I N F O
//
//  Show information on the Elohim.
//
/*
void () elohim_info =
{
    sprint(self, "\n");
    sprint(self, "Åìïèéí - Literally, the shining ones.\n");
    sprint(self, "         Used in ancient texts to\n");
    sprint(self, "         refer to angels.\n\n");
    sprint(self, "http://www.terra.com.br\n\n");
};
*/

//
//  C O M M A N D S
//
//  List all commands and impulses.
//
void () elohim_commands =
{
    // regular user commands
    sprint(self, " help-server®®®®“’’ logout@@@@@®®®“’”\n");
    sprint(self, " help-misc®®®®®®“’— help-match®®®®“•›\n");
    sprint(self, " commands®®®®®®®“’˜ levels®®®®®®®®“’™\n");
    sprint(self, " admin®®®®®®®®®®“’š motd®®®®®®®®®®“’›\n");
    sprint(self, " yes®®®®®®®®®®®®“”’ no®®®®®®®®®®®®“”“\n");
    sprint(self, " ready®®®®®®®®®®“•’ notready®®®®®®“•“\n");
    sprint(self, " ready?®®®®®®®®®“•• unlock®®®®®®®®“•”\n");
    sprint(self, " timerstop®®®®®®“•– timerstart®®®®“•—\n");
    sprint(self, " ghostcode®®®®®®“•˜ ghost®®®®®®®®®“•™\n");
    sprint(self, " score®®®®®®®®®®“•š nogibs®®®®®®®®””—\n");
    sprint(self, " lowgibs®®®®®®®®””˜ highgibs®®®®®®””™\n");
    sprint(self, " setquad®®®®®®®®””“ setpent®®®®®®®”””\n");
    sprint(self, " setring®®®®®®®®””• killstats®®®®®““’\n");
    sprint(self, " efficiency®®®®®“““ stats®®®®®®®®®““”\n");
    sprint(self, " observer®®®®®®®“–’\n");

    // admin commands
    if (self.style & ELOHIM_ADMINISTRATOR)
    {
        sprint(self, " kick!®®®®®®®®®®”“• abortmatch®®®®”“–\n");
        sprint(self, " ghostlist®®®®®®”“” modevote®®®®®®””š\n");
        sprint(self, " nextspawn®®®®®®”–˜ makespawn®®®®®”–™\n");
        sprint(self, " spot®®®®®®®®®®®”—’ options®®®®®®®””›\n");
        sprint(self, " help-admin®®®®®””–\n");
    }

    elohim_help_change();
};

//
//  L E V E L S
//
//  List all levels recognized by the server.
//
void () elohim_levels =
{
    local float index;
    local string name;

    elohim_help_change();
    sprint(self, "\n");

    // standard levels
    sprint(self, " start, start0, start1, end\n");
    sprint(self, " e1m1-e1m8 ¼åðéóïäå ±¾\n");
    sprint(self, " e2m1-e2m7 ¼åðéóïäå ²¾\n");
    sprint(self, " e3m1-e3m7 ¼åðéóïäå ³¾\n");
    sprint(self, " e4m1-e4m8 ¼åðéóïäå ´¾\n");
    sprint(self, " dm1-dm6   ¼äåáôèíáôãè¾\n");

    // user defined levels
    index = 0;
    while (index < 10)
    {
        name = array_get_user_map(index);
        if (name != "")
            sprint3(self, " ", name, "\n");
        index = index + 1;
    }
};

//
//  S H O W  K I L L S T A T S
//
void () elohim_show_killstats =
{
    local entity player;

    sprint(self, "opp - number of opponents killed\n");
    sprint(self, "slf - number of times killed self\n");
    sprint(self, "tm  - number of teammates killed\n");
    sprint(self, "kld - number of times killed by enemy\n");
    sprint(self, "\n");
    sprint(self, "fragsüoppüslfütm ükldü     name\n");
    sprint(self, "­­­­­«­­­«­­­«­­­«­­­«­­­­­­­­­­­­­­­\n");

    player = find(world, classname, "player");
    while (player)
    {
        if ((player.style & ELOHIM_CONNECTED) &&
            !(player.style & ELOHIM_OBSERVER))
        {
            if (player == self)
            {
                sprint(self, "");
                utils_print_int3(player.frags);
                sprint(self, "‘ü");
            }
            else
            {
                sprint(self, " ");
                utils_print_int3(player.frags);
                sprint(self, " ü");
            }
            utils_print_int3(player.frags + player.mangle_x + player.mangle_y);
            sprint(self, "ü");
            utils_print_int3(player.mangle_x);
            sprint(self, "ü");
            utils_print_int3(player.mangle_y);
            sprint(self, "ü");
            utils_print_int3(player.mangle_z);
            sprint3(self, "ü", player.netname, "\n");
        }
        player = find(player, classname, "player");
    }
};

//
//  P R I N T  P E R C E N T 3
//
//  Helper function for elohim_show_efficiency.  Prints the percentage
//  100 * (frac / tot) as a 3 character integer, or N/A if tot = 0.
//
void (float frac, float tot) elohim_print_percent3 =
{
    if (tot)
    {
        local float n;
        local string temp;

        n = floor(100 * frac / tot);
        if (n < 10)
            sprint(self, " ");
        temp = ftos(n);
        sprint(self, temp);
        if (n < 100)
            sprint(self, "%");
    }
    else
        sprint(self, "N/A");
};

//
//  S H O W  E F F I C I E N C Y
//
void () elohim_show_efficiency =
{
    local entity player;
    local float tot_fired, tot_done;

    sprint(self, "bul - bullet efficiency\n");
    sprint(self, "nls - nail efficiency\n");
    sprint(self, "rox - rocket efficiency\n");
    sprint(self, "lg  - lightning gun efficiency\n");
    sprint(self, "\n");
    sprint(self, "bulünlsüroxülg ütotalü     name\n");
    sprint(self, "­­­«­­­«­­­«­­­«­­­­­«­­­­­­­­­­­­­­­\n");

    player = find(world, classname, "player");
    while (player)
    {
        if ((player.style & ELOHIM_CONNECTED) &&
            !(player.style & ELOHIM_OBSERVER))
        {
            elohim_print_percent3(player.dest2_x, player.dest1_x);
            sprint(self, "ü");
            elohim_print_percent3(player.dest2_y, player.dest1_y);
            sprint(self, "ü");
            elohim_print_percent3(player.dest_y, player.dest_x);
            sprint(self, "ü");
            elohim_print_percent3(player.dest2_z, player.dest1_z);
            sprint(self, "ü");

            tot_fired = player.dest1_x + player.dest1_y + player.dest1_z +
                        player.dest_x;
            tot_done = player.dest2_x + player.dest2_y + player.dest2_z +
                       player.dest_y;
            if (player == self)
            {
                sprint(self, "");
                elohim_print_percent3(tot_done, tot_fired);
                sprint(self, "‘ü");
            }
            else
            {
                sprint(self, " ");
                elohim_print_percent3(tot_done, tot_fired);
                sprint(self, " ü");
            }
            sprint2(self, player.netname, "\n");
        }
        player = find(player, classname, "player");
    }
};

//
//  S H O W  S T A T S
//
//  Summary: show kill and weapon efficiency for each player.
//
void () elohim_show_stats =
{
    local entity player;
    local float wfrac, wtot, kfrac, ktot;

    sprint(self, "kill  - kill efficiency\n");
    sprint(self, "weapn - weapon efficiency\n");
    sprint(self, "\n");
    sprint(self, "kill üweapnü     name\n");
    sprint(self, "­­­­­«­­­­­«­­­­­­­­­­­­­­­\n");

    player = find(world, classname, "player");
    while (player)
    {
        if ((player.style & ELOHIM_CONNECTED) &&
            !(player.style & ELOHIM_OBSERVER))
        {
            kfrac = player.frags + player.mangle_x + player.mangle_y;
            ktot = kfrac + player.mangle_x + player.mangle_y + player.mangle_z;
            
            wtot = player.dest1_x + player.dest1_y + player.dest1_z +
                   player.dest_x;
            wfrac = player.dest2_x + player.dest2_y + player.dest2_z +
                    player.dest_y;
            if (player == self)
            {
                sprint(self, "");
                elohim_print_percent3(kfrac, ktot);
                sprint(self, "‘ü");
                elohim_print_percent3(wfrac, wtot);
                sprint(self, "‘ü");
            }
            else
            {
                sprint(self, " ");
                elohim_print_percent3(kfrac, ktot);
                sprint(self, " ü ");
                elohim_print_percent3(wfrac, wtot);
                sprint(self, " ü");
            }
            sprint2(self, player.netname, "\n");
        }
        player = find(player, classname, "player");
    }
};

//
//  D E B U G  I N F O
//
//  Used for development.
//
void () elohim_debug_info =
{
    local entity e;

    if (!(self.style & ELOHIM_ADMINISTRATOR))
        return;

    sprint(self, "clients:\n");
    e = find(world, classname, "player");
    while (e)
    {
        local string temp;
        temp = ftos(e.colormap);
        sprint4(self, temp, " ", e.netname, " - ");
        if (e.style & ELOHIM_CONNECTED)
            sprint(self, "Connected\n");
        else
            sprint(self, "Disconnected\n");
        e = find(e, classname, "player");
    }

    local float f;
    f = cvar("timelimit");
    sprint(self, "timelimit = ");
    utils_print_float(f);
    f = cvar("teamplay");
    sprint(self, "teamplay = ");
    utils_print_float(f);
};

//
//  P I N G  R E P L Y
//
//  Called when a client responds to a manual ping via impulse 103.
//
void () elohim_ping_reply =
{
    cprint3("reply from \"", self.netname, "\"\n");
    self.finaldest_y = time;
};

//
//  B A D  I M P U L S E
//
//  Seems like some people get stuck with clanring bindings (Ack! Gasp!)
//  Let them know that something ain't right.
//
void () elohim_bad_impulse =
{
    sprint(self, "You have entered an invalid impulse.\n");
    sprint(self, "Your bindings may be incorrect - try\n");
    sprint(self, "reconnecting to the server.\n");
};

//
//  V E R S I O N  I N F O
//
void () elohim_vinfo =
{
    sprint3(self, "\n", elohim_version_info, "\n");
};

//
//  I M P U L S E
//
//  Called from elohim_pre_think or observer_pre_think
//
void () elohim_impulse =
{
    if (self == elohim_debug_client)
    {
        local string temp;
        temp = ftos(self.impulse);
        cprint3("elohim impulse ", temp, "\n");
    }

    if (self.impulse < 100)
        elohim_bad_impulse();
    else if (self.impulse >= 150)
        admin_impulse();
    else if (self.impulse >= 130 && self.impulse <= 139)
        match_impulse();
    else if (self.impulse >= 140 && self.impulse <= 149)
        observer_impulse();
    else if (self.impulse == 100)
        elohim_help();
    else if (self.impulse == 102)
        admin_logout();
    else if (self.impulse == 103) // used for sping
        elohim_ping_reply();
    else if (self.impulse == 104) // used for testing for disconnects
        self.finaldest_x = time;
    else if (self.impulse == 105)
        elohim_help_misc();
    else if (self.impulse == 106)
        elohim_commands();
    else if (self.impulse == 107)
        elohim_levels();
    else if (self.impulse == 108)
        admin_start_code();
    else if (self.impulse == 109)
        elohim_make_intro();
    else if (self.impulse == 110)
        elohim_show_killstats();
    else if (self.impulse == 111)
        elohim_show_efficiency();
    else if (self.impulse == 112)
        elohim_show_stats();
    else if (self.impulse == 117)
        elohim_vinfo();
    else if (self.impulse == 118) // used for development
        elohim_debug_info();
    else if (self.impulse == 119)
        self.style = self.style | ELOHIM_FOUND_BINDINGS;
    else if (self.impulse >= 120 && self.impulse <= 121)
    {
        if (self.style & ELOHIM_KICK_CONFIRM)
            admin_confirm_kick_response(121 - self.impulse);
        else if (self.style & ELOHIM_CONFIRM_LEAVE)
            observer_confirm_leave_response(121 - self.impulse);
        else
            vote_impulse();
    }
    else
        sprint(self, "type 'help-server' in console for help\n");

    self.impulse = 0;
};

//
//  B F  T H I N K
//
//  Creates a background flash - used for player spawns.
//
void () elohim_bf_think =
{
    stuffcmd(self.owner, "bf\n");
    remove(self);
};

//
//  O B S E R V E R  S T A R T  T H I N K
//
void () elohim_observer_start_think =
{
    local entity oself;

    oself = self;
    self = self.owner;
    observer_start();
    self = oself;
    remove(self);
};

//
//  P U T  C L I E N T  I N  S E R V E R
//
//  Called from PutClientInServer in Client.qc
//
void () elohim_put_client_in_server =
{
    utils_make_scheduled_event(elohim_bf_think, 0.1);

    if (self.style & ELOHIM_OBSERVER ||
        (elohim_playmode & ELOHIM_MATCH_MODE && !(self.style & ELOHIM_READY)))
    {
        observer_start();

        self.takedamage = DAMAGE_NO;
        self.solid = SOLID_NOT;
        self.movetype = MOVETYPE_NONE;
        self.flags = self.flags - self.flags & FL_ONGROUND;
        self.model = string_null;
        self.weaponmodel = string_null;
        utils_make_scheduled_event(elohim_observer_start_think, 0.6);
    }
    else
        spawn_tdeath (self.origin, self);

    // Prevent fire-on-respawn (in case player used attack button to respawn)
    self.style = self.style - (self.style & ELOHIM_OK_TO_SHOOT);
    self.style = self.style | ELOHIM_CONNECTED;
    self.button0 = 1;
    self.wait = time + 2;    // for periodic checks
    self.finaldest_x = time; // used to check for disconnected clients
};

//
//  K I C K  P L A Y E R
//
void (entity client) elohim_kick_player =
{
    local string temp;
    temp = ftos(client.colormap);
    localcmd3("kick # ", temp, "\n");
};

//
//  C L I E N T  S U I C I D E
//
//  Called from ClientKill in Client.qc.  Checks to see if the player
//  has exceeded their suicide limit and returns either ELOHIM_SUICIDE_OK
//  or ELOHIM_TOO_MANY_SUICIDES accordingly.
//
float () elohim_client_suicide =
{
    local string temp;

    // Always OK for admins or practice mode
    if (self.style & ELOHIM_ADMINISTRATOR || elohim_playmode & ELOHIM_PRACTICE_MODE)
        return ELOHIM_SUICIDE_OK;

    self.cnt = self.cnt - 1;
    if (self.cnt < 0)
    {
        // too many suicides
        if (self.cnt == -1) // only want to do this stuff once
        {
            bprint2(self.netname, " kicked for suiciding\n");
            elohim_kick_player(self);
        }
        return ELOHIM_TOO_MANY_SUICIDES;
    }
    temp = ftos(self.cnt);
    sprint3(self, "you have ", temp, " suicides remaining\n");
    return ELOHIM_SUICIDE_OK;
};

//
//  D I S C O N N E C T  C H E C K
//
//  Check for disconnect once every 5 seconds.  Called from
//  elohim_start_frame.
//
void () elohim_disconnect_check =
{
    if (time <= self.finaldest_x + 30)
        self.style = self.style | ELOHIM_CONNECTED;
    // Eluan: ver porque nÃ£o tava funcionando: Ã© coisa do qw-qn?
    /*
    else if (self.style & ELOHIM_CONNECTED)
    {
        // Automatically kick player
        bprint3("No response from ", self.netname, "\n");
        self.style = self.style - ELOHIM_CONNECTED;
        elohim_kick_player(self);
    }
    */
};

//
//  S T A R T  F R A M E
//
//  Called from StartFrame in World.qc.  This routine performs periodic
//  checks in match mode and checks for server console commands.
//
void () elohim_start_frame =
{
    local float command;
    local string kk;

    if (!(elohim_playmode & ELOHIM_MATCH_MODE))
    {
        if (time >= timelimit)
        {
            if (timelimit && !gameover)
                NextLevel ();
        }
    }

    if (time >= elohim_nextcheck && !gameover)
    {
        // update variables
        timelimit = cvar("timelimit") * 60;
        fraglimit = cvar("fraglimit");
        teamplay = cvar("teamplay");

        // send out ping to test for disconnected players
        if (elohim_playmode & ELOHIM_MATCH_MODE)
        {
            WriteByte(MSG_ALL, SVC_STUFFCMD);
            WriteString(MSG_ALL, "impulse 104\n");

            utils_do_players(elohim_disconnect_check);
        }
        elohim_nextcheck = time + 5;
    }

    if (elohim_levelcount)
    {
        // Check for end of file in levels.cfg.  We assume end of file
        // if it's been 1 second since the last update to levelcount.
        // When end of file is detected, levelcount is reset to 0 to
        // allow players to exit the intermission.
        if (time >= elohim_nextcheck)
        {
            if (elohim_levelcount == elohim_lastcount)
                elohim_levelcount = 0;
            elohim_lastcount = elohim_levelcount;
            elohim_nextcheck = time + 1;
        }
    }

    // Check for a console command
    kk = infokey (world, "temp1");
    command = stof(kk);
    if (command)
    {
        localcmd("localinfo temp1 0\n");
        console_command(command);
    }
};
