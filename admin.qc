//
// Admin.qc
//
// Administrative functions for the Elohim server mod.
//
// Fields used:
//
// .count           - used for entering password
//

// function declarations
void () admin_cancel_kick;
void () admin_confirm_kick;
void () admin_do_kick;
void () options_start_setting;
float () options_get_mode;

// constants
float ADMIN_NORMAL_MODE = 0;
float ADMIN_PRACTICE_MODE = 1;
float ADMIN_MATCH_MODE = 2;

// global variables
string request_mapname;     // Used for requesting a new level
float request_timelimit;    // Used for requesting a new time limit
float request_gibs;         // Used to set gib level
float request_mode;         // Used to request a new mode
entity kick_target;         // Player to kick

//
//  S E N D  A L I A S E S 1
//
//  Stuffs aliases for votable commands and numbers.
//
void () admin_send_aliases1 =
{
    local entity tempent;

    // Remove the temporary entity
    tempent = self.owner;
    remove(self);
    self = tempent;

    //
    // maps
    //
    // e.g.:   alias start impulse 150
    //
    local float temp;
    local string szTemp;
    temp = 150;
    while (temp < 200)
    {
        szTemp = strings_get_mapname(temp - 150);
        if (szTemp != "")
        {
            stuffcmd(self, "alias ");
            stuffcmd(self, szTemp);
            stuffcmd(self, " impulse ");
            szTemp = ftos(temp);
            stuffcmd(self, szTemp);
            stuffcmd(self, "\n");
        }
        temp = temp + 1;
    }

    // timelimit aliases
    stuffcmd(self, "alias timelimit5 impulse 215\n");
    stuffcmd(self, "alias timelimit10 impulse 216\n");
    stuffcmd(self, "alias timelimit15 impulse 217\n");
    stuffcmd(self, "alias timelimit20 impulse 218\n");
    stuffcmd(self, "alias timelimit25 impulse 219\n");
    stuffcmd(self, "alias timelimit30 impulse 220\n");

    // Quad, Pent, Ring aliases
    stuffcmd(self, "alias setquad impulse 221\n");
    stuffcmd(self, "alias setpent impulse 222\n");
    stuffcmd(self, "alias setring impulse 223\n");

    // gib aliases
    stuffcmd(self, "alias nogibs impulse 225\n");
    stuffcmd(self, "alias lowgibs impulse 226\n");
    stuffcmd(self, "alias highgibs impulse 227\n");

    // playmode aliases
    stuffcmd(self, "alias normal impulse 208\n");
    stuffcmd(self, "alias practice impulse 209\n");
    stuffcmd(self, "alias match impulse 210\n");

    // number aliases
    stuffcmd(self, "alias 0 impulse 230\n");
    stuffcmd(self, "alias 1 impulse 231\n");
    stuffcmd(self, "alias 2 impulse 232\n");
    stuffcmd(self, "alias 3 impulse 233\n");
    stuffcmd(self, "alias 4 impulse 234\n");
    stuffcmd(self, "alias 5 impulse 235\n");
    stuffcmd(self, "alias 6 impulse 236\n");
    stuffcmd(self, "alias 7 impulse 237\n");
    stuffcmd(self, "alias 8 impulse 238\n");
    stuffcmd(self, "alias 9 impulse 239\n");
    stuffcmd(self, "alias 10 impulse 240\n");
    stuffcmd(self, "alias 11 impulse 241\n");
    stuffcmd(self, "alias 12 impulse 242\n");
    stuffcmd(self, "alias 13 impulse 243\n");
    stuffcmd(self, "alias 14 impulse 244\n");
    stuffcmd(self, "alias 15 impulse 245\n");
};

//
//  S E N D  A L I A S E S 2
//
//  Stuffs admin-only aliases into the administrators console.  Called
//  when a player becomes an administrator.
//
void () admin_send_aliases2 =
{
    // kick a player
    stuffcmd(self, "alias kick! impulse 213\n");

    // stop match
    stuffcmd(self, "alias abortmatch impulse 214\n");

    // list ghosts
    stuffcmd(self, "alias ghostlist impulse 212\n");

    // help
    stuffcmd(self, "alias help-admin impulse 224\n");
    stuffcmd(self, "alias skick impulse 224\n"); // for CR junkies

    // enable/disable mode voting
    stuffcmd(self, "alias modevote impulse 228\n");

    // set options
    stuffcmd(self, "alias options impulse 229\n");

    // spawn point editing
    stuffcmd(self, "alias nextspawn impulse 246\n");
    stuffcmd(self, "alias makespawn impulse 247\n");
    stuffcmd(self, "alias nextcam impulse 248\n");
    stuffcmd(self, "alias makecam impulse 249\n");
    stuffcmd(self, "alias spot impulse 250\n");
};

//
//  C R E A T E
//
//  Turn 'self' into an administrator.
//
void () admin_create =
{
    self.style = self.style | ELOHIM_ADMINISTRATOR;
    self.use = SUB_Null;
    ccenterprint(self, "Voce agora e' um administrador!", 0);
    bprint2(self.netname, " virou administrador\n");
    admin_send_aliases2();
};

//
//  L O G O U T
//
//  Turn 'self' into a normal player.
//
void () admin_logout =
{
    if (!(self.style & ELOHIM_ADMINISTRATOR))
    {
        sprint(self, "Voce nao e' um administrador\n");
        return;
    }
    self.style = self.style - (self.style & ELOHIM_ADMINISTRATOR);

    ccenterprint(self, "Voce nao e' mais um administrador!", 0);
    bprint2(self.netname, " nao e' mais administrador\n");
};

//
//  E N T E R  C O D E
//
//  Enter another code digit.
//  The digit being entered is stored in self.finaldest_z.
//  The digits that are entered are accumulated by self.count;
//  when self.count == elohim_password the client is made into an
//  administrator.
//
void () admin_enter_code = 
{
    if (self.finaldest_z > 9)
	return;

    self.count = self.count * 10 + self.finaldest_z;
    if (self.count >= 10000000)
    {
        sprint(self, "Codigo invalido\n");
        self.use = SUB_Null;
        return;
    }
    if (self.count == elohim_password)
        admin_create();
    else
        sprint(self, "Entre com o proximo digito do codigo:\n");
};

//
//  S T A R T  C O D E
//
//  Initiate the admin code sequence.
//
void () admin_start_code =
{
    if (self.style & ELOHIM_ADMINISTRATOR)
    {
        sprint(self, "Voce ja' e' um administrador\n");
        return;
    }
    sprint(self, "Entre com o primeiro digito do codigo:\n");
    self.count = 0;
    self.use = admin_enter_code;
};

//
//  C H A N G E  L E V E L
//
//  Called when a request to change level passses.  The level name is
//  stored in request_mapname.
//
void () admin_change_level =
{
    //localcmd3("changelevel ", request_mapname, "\n");
	// matador, pra aparecer rankings:
	nextmap = request_mapname;
	gameover = TRUE;
	execute_changelevel();
	bprint("Trocando de mapa...\n");
};

//
//  R E Q U E S T  C H A N G E  L E V E L
//
//  Called when a player requests a new level.
//
void (float level) admin_request_change_level =
{
    local string newmap;

    if (elohim_state & ELOHIM_MATCH_STARTED)
    {
        sprint(self, "Cannot change level while match is\nin progress.");
        return;
    }

    newmap = strings_get_mapname(level);

    // Do it right away if we're an administrator, otherwise vote
    if (self.style & ELOHIM_ADMINISTRATOR)
    {
        request_mapname = newmap;
        admin_change_level();
    }
    else if (vote_init("mudar mapa para ", newmap, admin_change_level))
    {
        request_mapname = newmap;
        vote_yes();
    }
};

//
//  P H A T T E N  P L A Y E R
//
//  Phatten up players when entering practice mode.
//
void () admin_phatten_player =
{
    self.items = IT_SHOTGUN | IT_AXE | IT_ROCKET_LAUNCHER | IT_ARMOR3 |
	    IT_SUPER_SHOTGUN | IT_NAILGUN | IT_GRENADE_LAUNCHER |
	    IT_LIGHTNING | IT_SUPER_NAILGUN;
    self.health = 100;
    self.armorvalue = 200;
    self.ammo_shells = 100;
    self.ammo_nails = 200;
    self.ammo_rockets = 100;
    self.ammo_cells = 100;
    self.weapon = 32;
    self.armortype = 0.8;    
    self.weaponmodel = "progs/v_rock2.mdl";
    self.weaponframe = 0;
};

//
//  S E T  M O D E
//
//  Called when a request to set the mode passes.
//
void () admin_set_mode =
{
    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
        if (elohim_state & ELOHIM_TIMER_STARTED)
        {
            sprint(self, "Timer has started; cannot change mode\n");
            return;
        }
        elohim_playmode = elohim_playmode - ELOHIM_MATCH_MODE;
    
        // Reset teamplay to 0
        cvar_set("teamplay", "0");
    
        // Get rid of observers
        utils_do_players(observer_end);
    }

    // Set the default timelimit if it was not set by options
    if (!(self.style & ELOHIM_SETTING_OPTIONS) ||
        (self.pos1_x != cvar("timelimit")))
    {
        if (request_mode == ADMIN_NORMAL_MODE)
            cvar_set("timelimit", "30");
        else if (request_mode == ADMIN_PRACTICE_MODE)
            cvar_set("timelimit", "0");
    }

    elohim_playmode = elohim_playmode - (elohim_playmode & ELOHIM_PRACTICE_MODE);

    if (request_mode == ADMIN_PRACTICE_MODE)
    {
        elohim_playmode = elohim_playmode | ELOHIM_PRACTICE_MODE;
        utils_do_players(admin_phatten_player);
    }
    else if (request_mode == ADMIN_MATCH_MODE)
    {
        elohim_playmode = elohim_playmode | ELOHIM_MATCH_MODE;
        utils_set_cvar("timelimit", elohim_timelimit);
    }

    local string mode;
    mode = strings_get_mode(request_mode);
    bprint3("playmode set to '", mode, "'\n");
    utils_set_cvar("samelevel", elohim_playmode);
    changelevel(mapname);
};

//
//  R E Q U E S T  S E T  M O D E
//
//  Request to change to the mode indicated by 'newmode':
//
//      0   -   normal
//      1   -   practice
//      2   -   match
//
void (float newmode) admin_request_set_mode =
{
    local string mode;

    mode = strings_get_mode(newmode);
    if (newmode == options_get_mode())
    {
        sprint3(self, "Already in ", mode, " mode\n");
        return;
    }

    if ((elohim_playmode & ELOHIM_MATCH_MODE) &&
        (elohim_state & ELOHIM_TIMER_STARTED))
    {
        sprint(self, "Timer has started; cannot change mode\n");
        return;
    }

    // Do it right away if we're an administrator, otherwise vote
    if (self.style & ELOHIM_ADMINISTRATOR)
    {
        request_mode = newmode;
        admin_set_mode();
    }
    else if (elohim_playmode & ELOHIM_MODE_VOTE)
    {
        if (vote_init("mudar modo para ", mode, admin_set_mode))
        {
            request_mode = newmode;
            vote_yes();
        }
    }
    else
        sprint(self, "Mode voting has been disabled\n");
};

//
//  S E T  T E A M P L A Y
//
//  Set teamplay to 'value' if playmode is not 'match'.
//
void (float value) admin_set_teamplay =
{
    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
        sprint(self, "Teamplay cannot be set in match mode.\n");
        return;
    }
    elohim_set_teamplay(value);
};

//
//  S E T  T I M E L I M I T
//
//  Called when a request to change the timelimit passes.  The new
//  timelimit is stored in the global variable request_timelimit.
//
void () admin_set_timelimit =
{
    local string temp;

    elohim_timelimit = request_timelimit;
    temp = ftos(elohim_timelimit);
    bprint3("Match length changed to ", temp, " minutes\n");
    if (elohim_playmode & ELOHIM_MATCH_MODE)
        match_show_timelimit();
};

//
//  R E Q U E S T  S E T  T I M E L I M I T
//
//  Called when a player requests a new timelimit.
//
void (float newlimit) admin_request_set_timelimit =
{
    local string temp;

    if (elohim_state & ELOHIM_MATCH_STARTED)
    {
        sprint(self, "Cannot change time limit while match\nis in progress.");
        return;
    }

    // Do it right away if we're an administrator, otherwise vote
    if (self.style & ELOHIM_ADMINISTRATOR)
    {
        request_timelimit = newlimit;
        admin_set_timelimit();
    }
    else
    {
        temp = strings_ftos(newlimit);
        if (vote_init("mudar tempo da partida para ", temp, admin_set_timelimit))
        {
            request_timelimit = newlimit;
            vote_yes();
        }
    }
};

//
//  S E T  G I B S
//
//  Called when a request to set gibs passes.  The new setting for gibs
//  is specified by the global variable request_gibs.
//
void () admin_set_gibs =
{
    elohim_playmode = elohim_playmode -
	(elohim_playmode & (ELOHIM_NO_GIBS | ELOHIM_LOW_GIBS));
    if (request_gibs == 0)
    {
        elohim_playmode = elohim_playmode | ELOHIM_NO_GIBS;
        bprint("Gibs disabled\n");
    }
    else if (request_gibs == 1)
    {
        elohim_playmode = elohim_playmode | ELOHIM_LOW_GIBS;
        bprint("Gibs set to 'low'\n");
    }
    else
	bprint("Gibs set to 'high'\n");
    utils_set_cvar("samelevel", elohim_playmode);
};

//
//  R E Q U E S T  S E T  G I B S
//
//  Called when a player requests a new setting for gibs.
//
void (float gibs) admin_request_set_gibs =
{
    if (elohim_playmode & ELOHIM_NO_GIBS)
    {
        if (gibs == 0)
        {
            sprint(self, "Gibs already disabled\n");
            return;
        }
    }
    else if (elohim_playmode & ELOHIM_LOW_GIBS)
    {
        if (gibs == 1)
        {
            sprint(self, "Gibs already set to 'low'\n");
            return;
        }
    }
    else
    {
        if (gibs == 2)
        {
            sprint(self, "Gibs already set to 'high'\n");
            return;
        }
    }

    // Do it right away if we're an administrator, otherwise vote
    if (self.style & ELOHIM_ADMINISTRATOR)
    {
        request_gibs = gibs;
        admin_set_gibs();
    }
    else
    {
        local string gibmode;
        if (gibs == 0)
            gibmode = "'disabled'";
        else if (gibs == 1)
            gibmode = "'low'";
        else
            gibmode = "'high'";
        if (vote_init("mudar gibs para ", gibmode, admin_set_gibs))
        {
            request_gibs = gibs;
            vote_yes();
        }
    }
};

//
//  D I S A B L E  I T E M
//
//  Used to disable quad/pent/ring.  Called with the item as 'self'.
//
void () admin_disable_item =
{
	self.model = string_null;
	self.solid = SOLID_NOT;
    self.nextthink = -1;
};

//
//  S E T  Q U A D
//
//  Enable/disable quad.
//
void () admin_set_quad =
{
    if (elohim_playmode & ELOHIM_NO_QUAD)
    {
        utils_do_item(SUB_regen, "item_artifact_super_damage");
        bprint("Quad enabled\n");
        elohim_playmode = elohim_playmode - ELOHIM_NO_QUAD;
    }
    else
    {
        utils_do_item(admin_disable_item, "item_artifact_super_damage");
        bprint("Quad disabled\n");
        elohim_playmode = elohim_playmode | ELOHIM_NO_QUAD;
    }
    utils_set_cvar("samelevel", elohim_playmode);
};

//
//  R E Q U E S T  S E T  Q U A D
//
//  Request to enable/disable quad.
//
void () admin_request_set_quad =
{
    // Do it right away if we're an administrator, otherwise vote
    if (self.style & ELOHIM_ADMINISTRATOR)
        admin_set_quad();
    else
    {
        local string newstate;
    
        if (elohim_playmode & ELOHIM_NO_QUAD)
            newstate = "ativar";
        else
            newstate = "desativar";
    
        if (vote_init(newstate, " quad", admin_set_quad))
            vote_yes();
    }
};

//
//  S E T  P E N T
//
//  Enable/disable pentagram.
//
void () admin_set_pent =
{
    if (elohim_playmode & ELOHIM_NO_PENT)
    {
        utils_do_item(SUB_regen, "item_artifact_invulnerability");
        bprint("Pentagram enabled\n");
        elohim_playmode = elohim_playmode - ELOHIM_NO_PENT;
    }
    else
    {
        utils_do_item(admin_disable_item, "item_artifact_invulnerability");
        bprint("Pentagram disabled\n");
        elohim_playmode = elohim_playmode | ELOHIM_NO_PENT;
    }
    utils_set_cvar("samelevel", elohim_playmode);
};

//
//  R E Q U E S T  S E T  P E N T
//
//  Request to enable/disable pentagram.
//
void () admin_request_set_pent =
{
    // Do it right away if we're an administrator, otherwise vote
    if (self.style & ELOHIM_ADMINISTRATOR)
        admin_set_pent();
    else
    {
        local string newstate;
    
        if (elohim_playmode & ELOHIM_NO_PENT)
            newstate = "ativar";
        else
            newstate = "desativar";
    
        if (vote_init(newstate, " pentagram", admin_set_pent))
            vote_yes();
    }
};

//
//  S E T  R I N G
//
//  Enable/disable ring of shadows.
//
void () admin_set_ring =
{
    if (elohim_playmode & ELOHIM_NO_RING)
    {
        utils_do_item(SUB_regen, "item_artifact_invisibility");
        bprint("Ring of shadows enabled\n");
        elohim_playmode = elohim_playmode - ELOHIM_NO_RING;
    }
    else
    {
        utils_do_item(admin_disable_item, "item_artifact_invisibility");
        bprint("Ring of shadows disabled\n");
        elohim_playmode = elohim_playmode | ELOHIM_NO_RING;
    }
    utils_set_cvar("samelevel", elohim_playmode);
};

//
//  R E Q U E S T  S E T  R I N G
//
//  Request to enable/disable ring of shadows.
//
void () admin_request_set_ring =
{
    // Do it right away if we're an administrator, otherwise vote
    if (self.style & ELOHIM_ADMINISTRATOR)
        admin_set_ring();
    else
    {
        local string newstate;
    
        if (elohim_playmode & ELOHIM_NO_RING)
            newstate = "ativar";
        else
            newstate = "desativar";
    
        if (vote_init(newstate, " ring of shadows", admin_set_ring))
            vote_yes();
    }
};

//
//  S E T  M O D E  V O T E
//
//  Enable/disable mode voting
//
void () admin_set_mode_vote =
{
    if (elohim_playmode & ELOHIM_MODE_VOTE)
    {
        bprint("Mode voting disabled\n");
        elohim_playmode = elohim_playmode - ELOHIM_MODE_VOTE;
    }
    else
    {
        bprint("Mode voting enabled\n");
        elohim_playmode = elohim_playmode | ELOHIM_MODE_VOTE;
    }
    utils_set_cvar("samelevel", elohim_playmode);
};

//
//  P R I N T  K I C K  C H O I C E
//
//  Display a choice of players to kick.
//
void () admin_print_kick_choice =
{
    local entity client;
    local float index;
    local string num;

    // Print the choice
    sprint(self, "Which player do you want to kick?\n");
    sprint(self, " 0  cancel\n");
    index = 1;
    while (index <= 15)
    {
        client = array_get_kick(index);
        if (client)
        {
            num = strings_ftos(index);
            sprint5(self, " ", num, " ", client.netname, "\n");
        }
        index = index + 1;
    }
};

//
//  S T A R T  K I C K
//
//  Get a list of players and ask the admin which one to kick.
//
void () admin_start_kick =
{
    if (elohim_state & ELOHIM_KICKING)
    {
        sprint(self, "There is already a kick in progress\n");
        return;
    }

    // Get the list of players
    local entity client;
    local float index;
    index = 1;
    client = find(world, classname, "player");
    while (client)
    {
        if (!(client.style & ELOHIM_ADMINISTRATOR) &&
            (client.style & ELOHIM_CONNECTED))
        {
            array_set_kick(index, client);
            index = index + 1;
        }
        client = find(client, classname, "player");
    }
    if (index == 1)
    {
        sprint(self, "There is no-one to kick\n");
        return;
    }
    while (index <= 15)
    {
        array_set_kick(index, world);
        index = index + 1;
    }

    // Print the choice
    admin_print_kick_choice();

    // Set up the kick
    local entity kick_timeout;
    self.use = admin_confirm_kick;
    kick_timeout = spawn();
    kick_timeout.movetarget = self;
    kick_timeout.classname = "elohim_kick_timeout";
    kick_timeout.think = admin_cancel_kick;
    kick_timeout.nextthink = time + 10;
    elohim_state = elohim_state | ELOHIM_KICKING;
};

//
//  C O N F I R M  K I C K
//
//  Ask for confirmation to kick the selected player.  The index of
//  the player to be kicked is stored in self.finaldest_z.
//
void () admin_confirm_kick =
{
    if (self.finaldest_z == 0)
    {
        // Cancel the kick
        local entity oself;
        oself = self;
        self = find(world, classname, "elohim_kick_timeout");
        admin_cancel_kick();
        self = oself;
        return;
    }

    kick_target = array_get_kick(self.finaldest_z);

    // sanity checks
    if (!kick_target)
    {
        sprint(self, "Invalid\n");
        admin_print_kick_choice();
        return;
    }
    if (kick_target.style & ELOHIM_ADMINISTRATOR)
    {
        sprint2(self, kick_target.netname, " is an administrator\n");
        admin_print_kick_choice();
        return;
    }

    // ask for confirmation
    sprint3(self, "kick ", kick_target.netname, "?\n");
    self.style = self.style | ELOHIM_KICK_CONFIRM;
};

//
//  C O N F I R M  K I C K  R E S P O N S E
//
//  Called when the administrator enters 'yes' or 'no' in
//  response to the confirmation request.
//  
void (float fDoKick) admin_confirm_kick_response =
{
    if (fDoKick)
        admin_do_kick();
    else
    {
        // Cancel the kick
        local entity oself;
        oself = self;
        self = find(world, classname, "elohim_kick_timeout");
        admin_cancel_kick();
        self = oself;
    }
};

//
//  D O  K I C K
//
//  Kick a player once the admin has confirmed.
//
void () admin_do_kick =
{
    bprint2(kick_target.netname, " kicked by administrator\n");
    elohim_kick_player(kick_target);

    // Clean up
    self.use = SUB_Null;
    kick_target = find(world, classname, "elohim_kick_timeout");
    remove(kick_target);
    elohim_state = elohim_state - ELOHIM_KICKING;
    self.style = self.style - ELOHIM_KICK_CONFIRM;
};

//
//  C A N C E L  K I C K
//
//  Called when the kick times out or is cancelled by the admin.
//
void () admin_cancel_kick =
{
    sprint(self.movetarget, "Kick cancelled\n");
    self.movetarget.use = SUB_Null;
    remove(self);
    elohim_state = elohim_state - ELOHIM_KICKING;
    self.movetarget.style = self.movetarget.style -
        (self.movetarget.style & ELOHIM_KICK_CONFIRM);
};

//
//  L I S T  G H O S T S
//
void () admin_list_ghosts =
{
    local entity e;
    e = find(world, classname, "elohim_ghost");
    if (!e)
    {
        sprint(self, "There are no ghosts\n");
        return;
    }
    sprint(self, "\ncodeü   team   üfragsü     name\n");
    sprint(self, "­­­­«­­­­­­­­­­«­­­­­«­­­­­­­­­­­­­­­\n");
    while (e)
    {
        local string num, szTeam, pad;
        local float frag;
        num = ftos(e.count);
        sprint2(self, num, " ü");
    
        szTeam = strings_get_teamname2(e.height);
        if (e.owner.owner == e)
            frag = e.owner.frags;
        else
            frag = e.frags;
        if (frag < -99)
            pad = "ü";
        else if (frag < -9)
            pad = "ü ";
        else if (frag < 0)
            pad = "ü  ";
        else if (frag < 10)
            pad = "ü   ";
        else if (frag < 100)
            pad = "ü  ";
        else
            pad = "ü ";
        num = ftos(frag);
        if (e.owner.owner == e)
            sprint6(self, szTeam, pad, num, " ü", e.owner.netname, "\n");
        else
            sprint4(self, szTeam, pad, num, " ü Disconnected\n");
    
        e = find(e, classname, "elohim_ghost");
    }
    sprint(self, "\n");
};

//
//  S H O W  S P O T  I N F O
//
//  Display the current position and angle.
//
void () admin_show_spot_info =
{
    local string temp;

    temp = vtos(self.origin);
    sprint3(self, " origin: ", temp, "\n");
    temp = vtos(self.angles);
    sprint3(self, " angles: ", temp, "\n");
};

//
//  N E X T  S P A W N  P O I N T
//
//  If the admin is in walk or fly observer mode, move him to the
//  next spawn point after the one that he's closest to.
//
void () admin_next_spawn_point =
{
    /*if (!(self.style & ELOHIM_OBSERVER) ||
        !(self.style & (ELOHIM_OBSERVER_WALK | ELOHIM_OBSERVER_FLY)))
    {
        sprint(self, "You must be in walk or fly mode\n");
        return;
    }*/
    utils_do_item(match_add_spawn, "elohim_start_point");
    self.owner = find(self.owner, classname, "info_player_deathmatch");
    if (!self.owner)
    {
        self.owner = find(self.owner, classname, "info_player_deathmatch");
        if (!self.owner)
        {
            sprint(self, "No spawn points found\n");
            return;
        }
    }
    utils_do_item(match_remove_start, "info_player_deathmatch");
    setorigin(self, self.owner.origin + '0 0 1');
    self.angles = self.owner.angles;
	self.fixangle = TRUE;           // turn this way immediately
    self.velocity = '0 0 0';
    admin_show_spot_info();
    makevectors(self.angles);
    //observer_spawn_tfog(self.origin + v_forward*20);
};

//
//  M A K E  S P A W N  P O I N T
//
//  If the admin is in walk observer mode, standing on the ground and
//  not underwater, then create a new deathmatch spawn point at his
//  location.
//
void () admin_make_spawn_point =
{
    /*if (!(self.style & ELOHIM_OBSERVER) || !(self.style & ELOHIM_OBSERVER_WALK))
    {
        sprint(self, "You must be in walk or fly mode\n");
        return;
    }*/
    if (!(self.flags & FL_ONGROUND))
    {
        sprint(self, "You must be on the ground\n");
        return;
    }
    if (self.waterlevel)
    {
        sprint(self, "Cannot create underwater spawn point\n");
        return;
    }
    if (elohim_num_spawns >= 20)
    {
        sprint(self, "Max. number of spawn points reached\n");
        return;
    }

    self.owner = spawn();
    self.owner.owner = world;
    self.solid = SOLID_NOT;
    self.movetype = MOVETYPE_NONE;
    self.takedamage = DAMAGE_NO;
    self.fixangle = TRUE;
    self.owner.classname = "info_player_deathmatch";
    self.angles_x = 0;
    self.angles_z = 0;
    self.fixangle = TRUE;
    self.owner.angles = self.angles;
    self.owner.origin = self.origin;
    elohim_num_spawns = elohim_num_spawns + 1;
    sprint(self, "Spawn point created\n");
    admin_show_spot_info();
};

//
//  H E L P
//
void () admin_help =
{
    sprint(self, "Admin only commands:\n\n");
	sprint(self, " logout   - sai do modo admin\n");
    sprint(self, " kick!    - kick a player\n");
    sprint(self, " modevote - enable/disable mode votes\n");
    sprint(self, " options  - on-screen options menu\n");
    sprint(self, " abortmatch - abort current match\n");
    sprint(self, " ghostlist  - view list of ghosts\n");
    sprint(self, " nextspawn  - go to next spawn point\n");
    sprint(self, " makespawn  - add spawn point\n");
    sprint(self, " spot       - show location/angles\n");
};

//
//  I M P U L S E
//
//  Called by elohim_impulse in Elohim.qc
//
void () admin_impulse =
{
    // votable commands
    if (self.impulse >= 150 && self.impulse <= 199)
        admin_request_change_level(self.impulse - 150);
    else if (self.impulse >= 208 && self.impulse <= 210)
        admin_request_set_mode(self.impulse - 208);
    else if (self.impulse >= 215 && self.impulse <= 220)
        admin_request_set_timelimit(5 * (self.impulse - 214));
    else if (self.impulse == 221)
        admin_request_set_quad();
    else if (self.impulse == 222)
        admin_request_set_pent();
    else if (self.impulse == 223)
        admin_request_set_ring();
    else if (self.impulse >= 225 && self.impulse <= 227)
        admin_request_set_gibs(self.impulse - 225);
    else if (self.impulse >= 230 && self.impulse <= 245)
    {
        if (self.use)
        {
            self.finaldest_z = self.impulse - 230;
            self.use();
        }
    }

    if (!(self.style & ELOHIM_ADMINISTRATOR))
        return;

    // admin only commands
    if (self.impulse == 212)
        admin_list_ghosts();
    else if (self.impulse == 213)
        admin_start_kick();
    else if (self.impulse == 214)
        match_end();
    else if (self.impulse == 224)
        admin_help();
    else if (self.impulse == 228)
        admin_set_mode_vote();
    else if (self.impulse == 229)
        options_start_setting();
    else if (self.impulse == 246)
        admin_next_spawn_point();
    else if (self.impulse == 247)
        admin_make_spawn_point();
    else if (self.impulse == 250)
        admin_show_spot_info();
};

//
//  D I S C O N N E C T  N O T I F Y
//
//  Remove this player from the list of kickable players.
//
void (entity player) admin_disconnect_notify = 
{
    local float index;

    index = 1;
    while (index < 16)
    {
	if (self == array_get_kick(index))
	    array_set_kick(index, world);
	index = index + 1;
    }
};
