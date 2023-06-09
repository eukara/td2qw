void() player_gaxe1;
void()	player_pain1;
void()	player_axpain1;
void () PainSound;

// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void() player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;
void (entity client, float fragval) client_frag; // ELOHIM_MOD

//matador - fly - start
float (entity me) fly_waterlevel =
   {
      local float pc;

      if (me == world)
         return 0;

      pc = pointcontents (me.origin + me.view_ofs);

      if (pc == CONTENT_WATER || pc == CONTENT_SLIME || pc == CONTENT_LAVA)
      {
         me.watertype = pc;
         me.waterlevel = 3;
         return 3; // liquid is at eye/head level, above mouth/nose
      }

      // check at waist level
      pc = pointcontents (me.origin + '0 0 6');

      if (pc == CONTENT_WATER || pc == CONTENT_SLIME || pc == CONTENT_LAVA)
      {
         me.watertype = pc;
         me.waterlevel = 2;
         return 2; 
      }

      // check at leg level
      pc = pointcontents (me.origin - '0 0 20');
      
      if (pc == CONTENT_WATER || pc == CONTENT_SLIME || pc == CONTENT_LAVA)
      {
         me.watertype = pc;
         me.waterlevel = 1;
         return 1;  // liquid covers legs
      }


      // check at feet
      pc = pointcontents (me.origin - '0 0 24');
      
      if (pc == CONTENT_WATER || pc == CONTENT_SLIME || pc == CONTENT_LAVA)
      {
         me.watertype = pc;
         me.waterlevel = 1;
         return 1;  // liquid covers legs
      }
      
      me.watertype = 0;
      me.waterlevel = 0;
      return 0; 
   };
//matador - fly - end

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float	intermission_running;
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
};

void() SetNewParms2;

void() SetChangeParms =
{
	if (self.health <= 0)
	{
        SetNewParms2 ();
		return;
	}

// remove items
        // PATCH nao remove IT_KEYS (artefatos)
	self.items = self.items - (self.items &
	(IT_EXTRA_WEAPON | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD | IT_STUNNED | IT_BURNING) );

// cap super health
	parm1 = self.items;
	parm2 = 150;
	parm3 = self.armorvalue;
	if (self.ammo_shells < 50)
		parm4 = 50;
	else
		parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
        if ((self.weapon == IT_AXE) || (self.weapon == IT_EXTRA_WEAPON))
           self.weapon = IT_SHOTGUN;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;

    // ELOHIM_MOD - parms10-13 contains elohim player flags
    parm10 = self.style;    // player flags
    parm11 = self.state;    // player ID
    parm12 = self.lip;      // ID of player being watched in observer mode
    // END_MOD

	parm13 = self.pow;
};

//
// ELOHIM_MOD
//
// Created SetNewParms2 and changed all SetNewParms references to
// SetNewParms2.  SetNewParms is called by Quake.exe when a client
// first connects; SetNewParms2 is called thereafter by the QuakeC
// code every time the client is reinserted into the server (respawn,
// level change, etc.)
//
// Also created SetPracticeParms which is called for practice mode
//

void() SetPracticeParms =
{
    parm1 = IT_SHOTGUN | IT_AXE | IT_ROCKET_LAUNCHER | IT_ARMOR3 |
            IT_SUPER_SHOTGUN | IT_NAILGUN | IT_GRENADE_LAUNCHER |
            IT_LIGHTNING | IT_SUPER_NAILGUN;
    parm2 = 100;
    parm3 = 200;
    parm4 = 100;
    parm5 = 200;
    parm6 = 100;
    parm7 = 100;
    parm8 = 32;
    parm9 = 80;
	parm13 = 0;         // pow flags
};

//
//  Called by Quake server when a new client connects
//
void() SetNewParms =
{
	parm1 = IT_SHOTGUN | IT_AXE;
	parm2 = 150;
	parm3 = 50;
	parm4 = 50;
	parm5 = 0;
	parm6 = 0;
	parm7 = 10;
	parm8 = 1;
	parm9 = 0.2;
    parm10 = ELOHIM_NEW_CLIENT; // elohim player flags
    parm11 = 0; // player ID.. will be set by elohim_client_connect
    parm12 = 0; // ID of player being watched in observer mode
	parm13 = 0;         // pow flags
    if (elohim_playmode & ELOHIM_PRACTICE_MODE)
        SetPracticeParms();
};

//
//  Called by QuakeC to reset a clients parameters
//
void() SetNewParms2 =
{
	parm1 = IT_SHOTGUN | IT_AXE | IT_ARMOR1;  // itens iniciais
	parm2 = 150;    // 150 health max
	parm3 = 50;     // NEW PATCH : soh 50 armor green de comeco
	parm4 = 50;     // 50 shells inicio
	parm5 = 0;
	parm6 = 0;
	parm7 = 10;     // BONUS: 10 CELLS
	parm8 = IT_SHOTGUN; // arma inicial
	parm9 = 30;         // green armor
    parm10 = self.style; // elohim player flags
    parm11 = self.state; // player ID
    parm12 = self.lip;   // ID of player being watched in observer mode
    if (elohim_playmode & ELOHIM_PRACTICE_MODE)
        SetPracticeParms();
	parm13 = 0;         // pow flags
};
// END_MOD

void() DecodeLevelParms =
{
    //
    // ELOHIM_MOD
    //
    // First restore player elohim flags *then* check to see if level = start.
    // Also, reset player status at start level even if serverflags = 0.
    // Changed SetNewParms to SetNewParms2.
    self.style = parm10;
    self.state = parm11;
    self.lip = parm12;
    if (world.model == "maps/start.bsp")
        SetNewParms2 ();   // take away all stuff on starting new episode

    // END_MOD
	
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weapon = parm8;
	self.armortype = parm9 * 0.01;
        self.pow = parm13;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
	return world; // keep the compiler happy
};


//string nextmap; // ELOHIM_MOD - moved this to elohim.qc
void() GotoNextMap =
{
	if (cvar("samelevel") & 1)  // if samelevel is set, stay on same level
		changelevel (mapname);
	else
	{
		localcmd("nextmap\n"); 
	}
};


void() ExitIntermission =
{
        GotoNextMap ();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

    // ELOHIM_MOD - make sure we've finished looking through levels.cfg
    if (elohim_levelcount)
        return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;

	ExitIntermission ();
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;

// enforce a wait time before allowing changelevel
		intermission_exittime = time + 5;

       pos = FindIntermission ();

// play intermission music
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);

       WriteByte (MSG_ALL, SVC_INTERMISSION);
       WriteCoord (MSG_ALL, pos.origin_x);
       WriteCoord (MSG_ALL, pos.origin_y);
       WriteCoord (MSG_ALL, pos.origin_z);
       WriteAngle (MSG_ALL, pos.mangle_x);
       WriteAngle (MSG_ALL, pos.mangle_y);
       WriteAngle (MSG_ALL, pos.mangle_z);

	other = find (world, classname, "player");
	while (other != world)
	{
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		other = find (other, classname, "player");
	}
};


// PATCH v2.063
// entrar no EXIT da fase da' help
void() ntouch;
void() IMPULSES_1xx_HELP =
{
	if (other.classname != "player")
		return;

        other.statustime = 0;
        other.messagetxt = "Para trocar de mapa, baixe o console\ne digite o nome do mapa desejado\n\nex: e1m1";
        other.messagebreaks = 3;
        other.messagetime = time + 10;

        self.touch = SUB_Null;
        self.nextthink = time + 5;
        self.think = ntouch;
};
void() ntouch =
{
        self.touch = IMPULSES_1xx_HELP;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
        objerror ("changelevel trigger doesn't have map");
	
	InitTrigger ();

        // PATCH v2.063 - impossivel sair da fase de agora
        // em diante
	//self.touch = changelevel_touch;
        self.touch = IMPULSES_1xx_HELP;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
        // make a copy of the dead body for appearances sake
	CopyToBodyQue (self);
    // ELOHIM_MOD - changed SetNewParms to SetNewParms2
	// set default spawn parms
    SetNewParms2 ();
    // END_MOD
	// respawn
	PutClientInServer ();

};


/*
============
ClientKill

Player entered the suicide command
============
*/

// PATCH
void() ClientKill =
{
    // ELOHIM_MOD
    // if intermission, do nothing
    if (gameover)
        return;

    // observers can't suicide
    if (self.style & ELOHIM_OBSERVER)
        return;

    // check for maximum number of suicides
    if (elohim_client_suicide() == ELOHIM_TOO_MANY_SUICIDES)
        return;
    // END_MOD

	bprint (self.netname);
	bprint (" suicides\n");
//	set_suicide_frame ();
	self.modelindex = model_player;

    // ELOHIM_MOD
    //
    // - use client_frag so that penalty will be added to team score
    // - changed penalty to -1
    // - no penalty during pre-match
    // - add suicide to stats
    //
    //self.frags = self.frags - 2;    // extra penalty
    if (!(elohim_playmode & ELOHIM_MATCH_MODE) || elohim_state & ELOHIM_MATCH_STARTED)
    {
        client_frag(self, -1);
        self.mangle_x = self.mangle_x + 1;
    }
    // END_MOD

//	respawn ();
        T_Damage (self, self, self, 666666);
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local	entity thing;
	local	float  pcount;

        // ELOHIM_MOD
        //
        // replaced this whole section with code to find a random
        // spawn point. 
        //
        pcount = random() * (elohim_num_spawns - 0.001);
        pcount = floor(pcount);
        spot = find(world, classname, "info_player_deathmatch");
        while (pcount > 0)
        {
            spot = find(spot, classname, "info_player_deathmatch");
            pcount = pcount - 1;
        }
        lastspawn = spot;
		while (1)
		{
			if (spot != world)
			{
                if (spot == self.trigger_field)
                    pcount = 1;
                else
                {
                    thing = findradius(spot.origin, 64); // ELOHIM_MOD 32 => 64
                    while(thing)
                    {
                        if (thing.classname == "player")
                            pcount = 1;
                        thing = thing.chain;
                    }
                }
				if (pcount == 0)
					return spot;
				pcount = 0;
			}
			spot = find(spot, classname, "info_player_deathmatch");
            if (spot == lastspawn)
            {
                // Can't find a spot!
                return lastspawn;
            }
		}
        // END_MOD
	error ("couldn't find a spawn point\n");
	return world; // keep the compiler happy
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;


void() PutClientInServer =
{
	local	entity spot;

	spot = SelectSpawnPoint ();
    self.trigger_field = spot;  // ELOHIM_MOD

	if (self.hook & HOOK_ON)
		self.hook = self.hook - HOOK_ON; // Eluan - why was the hook not being retracted automatically? Were we respawning too fast?

        // PATCH player status

        self.player_force_respawn = 0;  //set when Killed()

        self.tknight = world;       //set when using throwing knight

        self.statustime = 0;
        self.yaw_speed = time + 1;  // ticker de regeneracao
        self.pow = 0;            // poderes zerados, mas tem o decodexxx() la embaixo
        self.sitems = 0;         // comeca SEM RUNAS e SEM ARMAS ESP.
        self.enemy = world;      // lightning(arma 8), ..?
        self.tesla = 0;          // p/ SW4

        // PATCH
        self.touch = SUB_Null;

	if (self.style & ELOHIM_OBSERVER || // for observers, will also be cleared in observer_start()
		(elohim_playmode & ELOHIM_MATCH_MODE && !(self.style & ELOHIM_READY)) || 
		(elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED)))
	{
		self.magic = 0;
		self.ltime   = 0;   // magic charge
		self.magicstr = "        ";
	}
	else
	{
		local float repete;

		do { repete = 0;

		// PATCH -- TD CLASSICO
	//        if (config_CLASSICO == 0)
		   self.magic   = random() * 30;
	//        else
	//            self.magic   = random() * 40;  // inclui armas especiais no sorteio

		//self.magic = 5;

		//if (random() <= 0.2)
		// self.magic = 26;

		/*
		local float r;
		r = random();
		if (r < 0.25) self.magic = 19; else
		if (r < 0.50) self.magic = 24; else
		if (r < 0.75) self.magic = 13; else
		self.magic = 13;
		*/

		self.magic   = ceil (self.magic);
		self.ltime   = 0;   // magic charge

		// nomes das magias

		// MENORES QUE 10: MACHADOS MAGICOS
		if      (self.magic ==  1)  { self.magicstr = "  Gibber"; }
		else if (self.magic ==  2)  { self.magicstr = " Fragger"; }
		else if (self.magic ==  3)  { self.magicstr = " Stunner"; }
		else if (self.magic ==  4)  { self.magicstr = "   Fiend"; }

		//EX:td2.09: knight spell
		//else if (self.magic ==  5)  { self.magicstr = "  Knight"; }

		// 10 OU MAIS: MAGIAS MESMO (de teclar 1 e ativar)
		else if (self.magic == 10)  { self.magicstr = "     666"; }
		else if (self.magic == 11)  { self.magicstr = "    Quad"; }
		else if (self.magic == 12)  { self.magicstr = "Teleport"; }
		else if (self.magic == 13)  { self.magicstr = "   Amigo"; }
		else if (self.magic == 14)  { self.magicstr = "Disfarce"; }

		// PATCH -- luz tem q ser habilitada
	//        else if ((self.magic == 15) && (config_LUZ > 0)) { self.magicstr = "     Luz"; }

		else if (self.magic == 16)  { self.magicstr = "   Invis"; }
		else if (self.magic == 17)  { self.magicstr = " Levitar"; }
		else if (self.magic == 18)  { self.magicstr = "  Mirror"; }
		else if (self.magic == 19)  { self.magicstr = "  Sucker"; }
		else if (self.magic == 20)  { self.magicstr = "Fireball"; }
		else if (self.magic == 21)  { self.magicstr = "Doberman"; }
		//else if (self.magic == 21)  { self.magicstr = "    Nuke"; }
		//else if (self.magic == 22)  { self.magicstr = "  Gaiola"; }
		//else if (self.magic == 22)  { self.magicstr = "    Hook"; } // gancho
		else if (self.magic == 23)  { self.magicstr = " Nukebox"; }
		else if (self.magic == 24)  { self.magicstr = "   Minas"; }
		//else if (self.magic == 25)  { self.magicstr = "    Voar"; }

		// 26..30  ARMAS MAGICAS
		//
		else if (self.magic == 26)  { self.magicstr = "   Virus"; }
		else if (self.magic == 27)  { self.magicstr = "XShotgun"; }

		// 31+ ARMAS ESPECIAIS (se o server for configurado
		// para TD CLASSICO)
	//        else if (self.magic == 31)  { self.magicstr = "Morteiro"; }
	//        else if (self.magic == 32)  { self.magicstr = "Pipebomb"; }
	//        else if (self.magic == 33)  { self.magicstr = "   Smart"; }
	//        else if (self.magic == 34)  { self.magicstr = "   Tesla"; }
	//        else if (self.magic == 35)  { self.magicstr = "Chaingun"; }

		else
		    repete = 1;

		} while (repete);

		// ENDPAT
	}

 	self.classname = "player";
	self.health = 150;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 150;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;

	DecodeLevelParms ();

        // PATCH -- MUNICOES MINIMAS

        if (self.magic == 26) { self.ammo_nails =  200; } else
        if (self.magic == 27) { self.ammo_shells =  60; } else
        if (self.magic == 31) { self.ammo_rockets = 15; } else
        if (self.magic == 32) { self.ammo_rockets = 15; } else
        if (self.magic == 33) { self.ammo_rockets = 20; } else
        if (self.magic == 34) { self.ammo_cells =   20; } else
        if (self.magic == 35) { self.ammo_shells = 100; }

        //CAMERA_ON();

	W_SetCurrentAmmo ();

        // PATCH v2.05
	//self.attack_finished = time;
        self.attack_finished = time + 0.3;

	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	
	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
//  self.pausetime = 0; // ELOHIM_MOD - unused
	
//	spot = SelectSpawnPoint ();

	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately
    self.velocity = '0 0 0'; // ELOHIM_MOD - bugfix

// oh, this is a hack!

	// ELUAN - TD 2.11 - consertado o bug de o zumbi travar em engines novas
	setmodel (self, "progs/zombie.mdl");
	model_zombie = self.modelindex;
        // PATCH -- model_player, model_eyes, model_head e model_null, sao globais
        model_null = 0;
	setmodel (self, "progs/h_player.mdl");
	model_head = self.modelindex;
	setmodel (self, "progs/eyes.mdl");
	model_eyes = self.modelindex;
	setmodel (self, "progs/demon.mdl");
	model_fiend = self.modelindex;
	setmodel (self, "progs/player.mdl");
	model_player = self.modelindex;
        // ENDPAT

	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
	
	self.view_ofs = '0 0 22';

	player_stand1 ();
	
    makevectors(self.angles);
    spawn_tfog (self.origin + v_forward*20);

    // spawn_tdeath (self.origin, self); // ELOHIM_MOD - moved to Elohim.qc

    // ELOHIM_MOD
    // Add elohim specific stuff
    elohim_put_client_in_server();
    // END_MOD
};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
    elohim_num_spawns = elohim_num_spawns + 1;  // ELOHIM_MOD
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
    remove(self);   // ELOHIM_MOD - coop not supported
};

/*
===============================================================================

RULES

===============================================================================
*/

//
// ELOHIM_MOD
//
// Fixed the bug that causes the start level to loop.  Changed the sequence
// of levels to:
//
// start->episode1->start->episode2->start->episode3->start->episode4->
// start->end->deathmatch->deathmatch->deathmatch->deathmatch->start
//
// (one big loop.. first start = last start).
// (of course, deathmatch = dm1->dm2->dm3->dm4->dm5->dm6)
//
// Included the Underearth in episode 2, but NOT Ziggurat Vertigo in e1.
//

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "aerowalk")
	{
		if (!cvar("registered"))
		{
			mapname = "ultrav";
		}
		else if (!(serverflags & 1))
		{
			mapname = "ztndm6";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "dm7";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "monsoon";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "rwild";
            serverflags = serverflags | 8;
		}
        else
            mapname = "dad2";

		o = spawn();
		o.map = mapname;
	}
    else if (mapname == "dad2")
    {
        o = spawn();
        o.map = "dm1";
    }
    else if (mapname == "ztndm3")
    {
        o = spawn();
        serverflags = (serverflags & 14) / 2;
        if (serverflags > 0)
            o.map = "hex";
        else
            o.map = "aerowalk";
    }
    else if (mapname == "ava")
    {
        o = spawn();
        o.map = "rash";
    }
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "aerowalk";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;

    // check to see if there is a user-specified level sequence
    console_get_user_nextlevel();

    o.think = execute_changelevel;
    o.nextthink = time + 0.1;
};
// END_MOD

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
// ELOHIM_MOD - this function was removed for efficiency
/*
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}	
};
*/

//============================================================================

void() PlayerDeathThink =
{
	local entity	old_self;
	local float		forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	respawn();
};


void() PlayerJump =
{
	local vector start, end;

	if (self.flags & FL_WATERJUMP)
		return;

       if (self.waterlevel == 1)
         if ((runeof(self) == 3) || (self.pow == -666))
                 {
                         self.velocity_z = 480;
                         return;
                 }


	if (self.waterlevel >= 2)
	{
                // PATCH -- RUNA 3 -- TURBO
                if ((runeof(self) == 3) || (self.pow == -666))
                   self.velocity_z = 250;
                else
                    {
		        if (self.watertype == CONTENT_WATER)
			   self.velocity_z = 100;
		        else if (self.watertype == CONTENT_SLIME)
			    self.velocity_z = 80;
		        else
			    self.velocity_z = 50;
                    }

// play swiming sound
                if (runeof(self) != 3) // PATCH NOVO TURBO SEM SOM NAS AGUA
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

        // PATCH -- pulo invertido
        // MAGIA LEVITAR (17)

        if (selfmagic() == 17)
        if (mstate() == 1)
        if (self.velocity_z >= 0)
             {
                self.velocity_z = -70;  //self.velocity_z - 175;
             }

	if (!(self.flags & FL_ONGROUND))
		return;

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk

	self.button2 = 0;
// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
 
         // PATCH -- RUNA 3 -- TURBO
         if ((runeof(self) == 3) || (self.pow == -666))
             self.velocity_z = self.velocity_z + 480;
         else
	self.velocity_z = self.velocity_z + 270;
};


/*
===========
WaterMove

============
*/
.float	dmgtime;

void() WaterMove =
{
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

   if (self.flags & FL_FLY)
      self.waterlevel = fly_waterlevel (self);

        // patch 2.063 - novo TURBO: sem dano e sem barulho nenhum na agua!
        //
        if (runeof(self) != 3)
        {
	if (self.waterlevel != 3)
	{
        // ELOHIM_MOD - don't play sounds for observers
        if (!(self.style & ELOHIM_OBSERVER))
        {
            if (self.air_finished < time)
                sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
            else if (self.air_finished < time + 9)
                sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
        }
        // END_MOD

		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}

	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{
            // ELOHIM_MOD - don't play sounds for observers
			// play leave water sound
            if (self.style & ELOHIM_OBSERVER == 0)
                sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
            // END_MOD

			self.flags = self.flags - FL_INWATER;
		}
		return;
	}
        }

        // patch V2.063 - turbo nao da dmg em lava (lava vira slime)
       	if ((self.watertype == CONTENT_LAVA) && (runeof(self) != 3))
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, world, 10*self.waterlevel);
		}
	}
        // PATCH v2.07 -- turbo NAO SOFRE DANO NA LAVA!
	//else if (((self.watertype == CONTENT_SLIME) && (runeof(self) != 3)) || ((self.watertype == CONTENT_LAVA) && (runeof(self) == 3)))
	else if ((self.watertype == CONTENT_SLIME) && (runeof(self) != 3))
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world, world, 4*self.waterlevel);
		}
	}

	if ( !(self.flags & FL_INWATER) )
	{

// player enter water sound

        // ELOHIM_MOD - don't play sounds for observers
        if (!(self.style & ELOHIM_OBSERVER))
        {
            if (self.watertype == CONTENT_LAVA)
                sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
                // patch NOVO TURBO v2.063
                // nao da barulho de in water ou slime
                if (runeof(self) != 3)
                {
            if (self.watertype == CONTENT_WATER)
                sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
            if (self.watertype == CONTENT_SLIME)
                sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);
				}
        }
        // END_MOD

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}

	if (! (self.flags & FL_WATERJUMP) )
	   self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};

void() SpawnBurn =
{
                local entity burn;
                burn = spawn();
                burn.solid = SOLID_NOT;
                burn.movetype = MOVETYPE_FLYMISSILE;
                burn.velocity_x = 0;
                burn.velocity_y = 0;
                burn.velocity_z = 55;
                burn.think = s_explode1;
                burn.nextthink = time + 0.05;
	        setmodel (burn, "progs/s_explod.spr");

                local vector org;
                org = self.origin;
                org_x = org_x + crandom() * 25;
                org_y = org_y + crandom() * 25;
                org_z = org_z + crandom() * 25;

                setorigin (burn, org);
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/

void() PlayerPreThink =
{
	local	float	mspeed, aspeed;
	local	float	r;

    // ELOHIM_MOD
    //
    // - moved intermission_running test inside of if (gameover)
    // - go to observer_pre_think when observing
    // - go to options_pre_think when setting options
    // - changed gameover test from (self.view_ofs == '0 0 0') to (gameover)
    // - don't call check rules
    //      - fraglimit, timelimit are set in elohim_start_frame
    //      - timelimit is checked in elohim_start_frame
    //      - fraglimit is checked in client_frag
    // - removed unnecessary makevectors
    // - put dead checks inside a single if statement
    // - removed unused pausetime check
    // - optimized ammo-out check
    // - moved CheckWaterJump to WaterMove

    if (gameover)
    {
        if (intermission_running)
        {
            // otherwise a button could be missed between the think tics
            IntermissionThink ();
        }
		return;		// intermission or finale
    }

	if (!(elohim_playmode & ELOHIM_MATCH_MODE))
	{
		self.qw_team = infokey(self, "team");

		if (self.qw_team == "") // TODO: is it possible to have it set to a empty string? see if something breaks (I mostly only check for "none")
		{
			stuffcmd(self, "team none\n");
			self.qw_team = "none"; // update locally instantly
		}
	}

    if (time > self.wait)
    {
        //elohim_periodic_checks();
        self.wait = self.wait + 1;
    }

    if (self.deadflag != DEAD_NO)
    {
        if (self.style & ELOHIM_SETTING_OPTIONS)
            options_pre_think();
        else if (self.deadflag >= DEAD_DEAD)
		{
			self.movetype = MOVETYPE_TOSS; //matador - fly
            PlayerDeathThink ();
		}
        return;
    }

        // PATCH
        // Update StatusBar

        if (self.messagetime < time)
        if (self.messagetxt != "")
           {
                self.messagetxt = "";
                self.messagebreaks = 0;
                self.statustime = 0;
           }

        if (self.statustime < time)
           StatusThink ();

        // ENDPATCH

    if (self.style & ELOHIM_OBSERVER)
    {
        if (!(self.style & ELOHIM_SETTING_OPTIONS))
        {
            observer_pre_think();
            return;
        }
    }

    if (elohim_state & ELOHIM_MATCH_PAUSED)
    {
        self.velocity = '0 0 0';
        return;
    }

    if (!(self.style & ELOHIM_OBSERVER))
    {
	//matador - fly - start
	if (self.flags & FL_FLY)
	   {
	      self.movetype = MOVETYPE_FLY;
	
	      if ( !(self.flags & FL_ONGROUND) )
	      {
	         self.flags = self.flags + FL_ONGROUND;
	      }
	   }
	   else
	   {
	      self.movetype = MOVETYPE_WALK;
	   }

 // must define variables before using them
   local float vel1, yaw_diff, up_z;
   local vector dir, dir2;

   makevectors (self.v_angle);

   if ( (self.flags & FL_FLY) && (self.velocity_x || self.velocity_y) )
   {
      vel1 = vlen (self.velocity); // its current speed
      dir = self.velocity;
      dir2 = vectoangles (dir);

      // This corrects an ID mistake.  They had the pitch angle in
      // reverse.
      dir2_x = dir2_x * -1;

      yaw_diff = dir2_y - self.v_angle_y;

      if (yaw_diff > 180)
         yaw_diff = yaw_diff - 360;

      if (fabs (self.v_angle_x) > 24)
      {
         up_z = TRUE;  // movement in z direction (up/down)

         if (fabs (fabs (yaw_diff) - 180) < 2)
         {
            dir = v_forward * -1;
         }
         else if (fabs (yaw_diff) < 2)
         {
            dir = v_forward;
         }
         else
         {
            up_z = FALSE;
         }
      }


      self.velocity = normalize (dir) * vel1;

      if (up_z)
      {
         if (vlen (self.velocity) > 10)
         {
            vel1 = cvar ("sv_maxspeed");
            self.velocity = normalize (dir) * vel1;
         }
      }
   }


	//matador - fly - end

        //THROWING KNIGHT:
        if (self.tknight != world) {
           //verifica se trocou de arma: explode
           if (self.weapon != IT_AXE) {
              self.tknight.health = 1;
              makeboom(self.tknight.origin, 50, 0);
              self.tknight = world;  //p/ nao ficar etc.
           }
           else {
                //bprint("AQUI ");
            self.weaponframe = 4; //tira 1000 depois

            if ((!self.button0) && (self.attack_finished < time)) {
               //bprint("SOLTOU ");
              player_gaxe1();
              self.attack_finished = time + 0.5;
            }
           }
        }

        // Verifica desliga mirror-shield (18)

        if (selfmagic() == 18)
           {
                // OBS: assume intervalo de 30 segundos de recarregacao (20 de espera)
                if (self.ltime < time + 20)
		{
                if (self.effects & EF_BRIGHTFIELD)
                self.effects = self.effects - EF_BRIGHTFIELD;
                if (self.effects & EF_BRIGHTLIGHT)
                       self.effects = self.effects - EF_BRIGHTLIGHT;
		}
           }

        // MAGIA LEVITAR (17)

        if (selfmagic() == 17)
        if (mstate() == 1)
           {
                if (self.velocity_x > 20)
                   self.velocity_x = self.velocity_x - 1;
                else if (self.velocity_x < -20)
                   self.velocity_x = self.velocity_x + 1;
                if (self.velocity_y > 20)
                   self.velocity_y = self.velocity_y - 1;
                else if (self.velocity_y < -20)
                   self.velocity_y = self.velocity_y + 1;

        if (!self.button2)
           {
                //local string sss;
                //sss = ftos(GRAVITY);
                //bprint(sss);
                //bprint("\n");

                if (self.velocity_z < 250)
                   self.velocity_z = self.velocity_z + (GRAVITY + 400) * frametime;
                if (fabs(self.velocity_x) < 150)
                   self.velocity_x = self.velocity_x * 1.2;
                if (fabs(self.velocity_y) < 150)
                   self.velocity_y = self.velocity_y * 1.2;

                //if (!(self.flags & FL_ONGROUND))
                //   {
                //        self.velocity_x = self.velocity_x * 3;
                //        self.velocity_y = self.velocity_y * 3;
                //   }
           }
        else //if (!(self.flags & FL_ONGROUND))
            {
                if (self.velocity_z > -250)
                   self.velocity_z = self.velocity_z + (GRAVITY - 400) * frametime;
                else
                    self.velocity_z = self.velocity_z + GRAVITY * frametime;
                if (fabs(self.velocity_x) < 150)
                   self.velocity_x = self.velocity_x * 1.2;
                if (fabs(self.velocity_y) < 150)
                   self.velocity_y = self.velocity_y * 1.2;

            }
            }
    }

	WaterMove ();

    if (self.style & ELOHIM_SETTING_OPTIONS)
    {
        options_pre_think();
        return;
    }

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;


        // PATCH -- jeito melhor de ver se nao tem municao
	//if(time > self.attack_finished && self.currentammo == 0 && self.weapon != IT_AXE)
	//{
	//	self.weapon = W_BestWeapon ();
	//	W_SetCurrentAmmo ();
	//}
        W_CheckNoAmmo ();
    // END_MOD

        // PATCH -- YAW_SPEED (antigo regentime)
        // gera um evento a cada 1s para os jogadores, serve
        // p/ runa 4 (regeneracao) e outras coisas se precisar
        if (self.yaw_speed < time)
           {
                self.yaw_speed = time + 0.5;

                // dragon armor!!
                if (self.armorvalue > 0)
                if (self.armortype >= 0.9)
                   {
                        if (self.armorvalue < 250)
                           self.armorvalue = self.armorvalue + 20;
                        if (self.armorvalue > 250)
                           self.armorvalue = 250;
                   }

                // Pegando Fogo!!
                if (self.items & IT_BURNING)
                   if ((self.waterlevel > 0) && ((self.watertype == CONTENT_WATER) || (self.watertype == CONTENT_SLIME)))
                      self.items = self.items - IT_BURNING;
                   else
                       {
                        SpawnBurn();
                        SpawnBurn();

                        self.pain_finished = 0;

                        if (self.weaponmodel == "progs/v_axe.mdl")
                           player_axpain1();
                        else
                           player_pain1();

                        T_Damage(self, self.goalentity, self.goalentity, 10);

                       }

                // PATCH - zumbi
                if (self.pow == -666)
                   {
                        self.currentammo = self.currentammo - 0.5;
                        self.armorvalue = self.currentammo;

                        if (self.currentammo <= 0)
                           {
                                T_Damage(self, self, self, 666666);
                           }
                   }


                //
                // RUNA 4 REGENERATION
                //
                if (runeof(self) == 4)
                   {
                        local float ma;
                        // regenera health
                        if (self.health < self.max_health)
                           {
                                self.health = self.health + 5;
                                if (self.health > self.max_health)
                                   self.health = self.max_health;
                           }
                        // regenera armor
                        if (self.armorvalue > 0)
                           {
                                // pega max armor dado o armor type
                                //
                                ma = MaxArmorForType(self);

                                if (self.armorvalue < ma)
                                   self.armorvalue = self.armorvalue + 5;
                                if (self.armorvalue > ma)
                                   self.armorvalue = ma;
                           }

                        // PATCH v2.09 Spinal 03/02/2002
                        //-- regenera AMMO!
                        self.light_lev = self.light_lev + 1;
                        if (self.light_lev == 1)
                           self.ammo_shells = self.ammo_shells + 1;
                        else if (self.light_lev == 2)
                           self.ammo_nails = self.ammo_nails + 1;
                        else if (self.light_lev == 3)
                           self.ammo_rockets = self.ammo_rockets + 1;
                        else {
                           self.ammo_cells = self.ammo_cells + 1;
                           self.light_lev = 0;
                        }
                        bound_self_ammo();

                        // PATCH v2.07 Spinal 22/07/2001
                        // procura por spawnings pra regenerar
                        // - dog
                        // - amigo
                        local entity e;
                        e = find (world, classname, "td_temp");
                        while (e) {
                              // heal amiguinho, dog, wizard
                              if (e.owner == self)
                              if ((e.magic == 13) || (e.magic == 21) || (e.magic == 226)) {
                                 e.health = e.health + 10;
                                 if (e.health > e.max_health)
                                    e.health = e.max_health;
                              }

                              e = find(e, classname, "td_temp");
                        }
                   }
           }
        // ENDPAT (regen ticker)

        // PATCH -- RUNAS

	self.oldorigin = self.origin;

        //
        // RUNA 3 -- TURBO
        //
        if ((runeof(self) == 3) || (self.pow == -666))
           {
                  if (self.maxspeed != 480)
                          self.maxspeed = 480;
           }
        // ENDPAT

        // PATCH: MAGIA STUNNER (self vitima)
        else if (self.items & IT_STUNNED)
           {
		if (self.maxspeed != 100)
                    self.maxspeed = 100;
           }
	   else
                 if (self.maxspeed != 320)
                    self.maxspeed = 320;
        // ENDPAT

    if (!(elohim_playmode & ELOHIM_MATCH_MODE))
	{
		if (self.frags >= fraglimit)
		{
		    if (fraglimit)
				NextLevel();
		}
	}

};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
	if (self.health <= 0)
		return;

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
      	//Spinal CRTD2 31/12/2001 - CONSERTADO bug do TD2.07
			//self.items = self.items - IT_INVISIBILITY);
			self.items = self.items - (self.items & IT_INVISIBILITY);
			self.invisible_finished = 0;
			self.invisible_time = 0;

                        // PATCH -- HAHA, NASTY BUG!! DIE!! (SQUISH)
                        if (self.size_z < 50) self.modelindex = model_head; // use a cabeca! ;)
                        else

                        self.modelindex = model_player;	// don't use eyes
		}

        // PATCH -- nananinanao!
	// use the eyes
	//	self.frame = 0;
	//	self.modelindex = modelindex_eyes;
	}
        // PATCH -- aqui nao
	//else
	//	self.modelindex = modelindex_player;	// don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}
			
			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - (self.items & IT_INVULNERABILITY); // ELUAN - TD 2.12 - bug potencial
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}	  

			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - (self.items & IT_QUAD); // ELUAN - TD 2.12 - bug potencial
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// suit	
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - (self.items & IT_SUIT); // ELUAN - TD 2.12 - bug potencial
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}	

};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	local	float	mspeed, aspeed;
	local	float	r;

    // ELOHIM_MOD
    //
    // - don't do post think stuff while observing
    // - don't do post think stuff while setting options
    // - redirect impulses in [20, 250]
    // - changed gameover test from (self.view_ofs == '0 0 0') to (gameover)

    if (self.style & ELOHIM_OBSERVER)
    {
        observer_post_think();
        return;
    }

    if (self.impulse)
    {
        if ((self.impulse >= 100) && (self.impulse <= 250))
            elohim_impulse ();
    }
    if (gameover)
        return;     // intermission or finale

         //
         // RUNA 1 -- CAMUFLAGEM!
         //
         if (runeof(self) == 1)
         {
            if (self.oldorigin == self.origin)
            // spinal patch TD 2.07 patch: runa camo nao revela ataques de virus e machado
            if ((self.camoattack == 1) || (self.attack_finished < time - 1))
            if (self.modelindex != model_null)
               {
                     self.modelindex = model_null;
                     self.items = self.items | IT_INVISIBILITY;
               }

            // spinal patch TD 2.07 patch: runa camo nao revela ataques de virus e machado
            //if ((self.oldorigin != self.origin) || (self.attack_finished > time))
            if ((self.oldorigin != self.origin) || ((self.attack_finished > time) && (runeof(self) != 1)) )
            if (self.modelindex == model_null)
               {
                    if (self.invisible_finished >= time)
                       self.modelindex = model_eyes;
                    else if (self.size_z < 50)
                       {
                           self.modelindex = model_head;
                           self.items = self.items - (self.items & IT_INVISIBILITY);
                       }
                    else
                        {
                           self.modelindex = model_player;
                           self.items = self.items - (self.items & IT_INVISIBILITY);
                        }
               }
         }
         // ENDPAT


    //TD2.08: RESPAWNER
	if (self.pow != -666)
    if (self.player_force_respawn > 0)
    if (self.player_force_respawn < time) {
       //force respawn!
       self.player_force_respawn = 0;
       respawn();
    }

	if (self.deadflag)
	{
		self.movetype = MOVETYPE_TOSS; //matador - fly
        return;
	}
    if (self.style & ELOHIM_SETTING_OPTIONS)
        return;
    if (elohim_state & ELOHIM_MATCH_PAUSED)
        return;
    // END_MOD

    // Don't let clients change team after committing
    match_verify_team(self);

//matador - fly - start
   // must define variables before using them
   local float g;
   g = cvar ("sv_gravity") * frametime;

   if (self.flags & FL_FLY)
   {
      if (self.velocity_z > 0)
      {
         self.velocity_z = self.velocity_z - g;
      }

      if (self.velocity_z < 0)
      {
         self.velocity_z = self.velocity_z + g;
      }

      if (fabs (self.velocity_z) < g)
      {
         self.velocity_z = 0;
      }
   }


//matador - fly - end
    
// do weapon stuff

	W_WeaponFrame ();

// check to see if player landed and play landing sound
    // ELOHIM_MOD - rearranged if clauses for efficiency
	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;
    else if (self.jump_flag < -300)
    {
	if (self.health > 0)
	{
                // PATCHs V2.063 NOVO TURBO etc..
		if (self.watertype == CONTENT_WATER)
                   {
                        if (runeof(self) != 3)
			   sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
                   }
		else if ((self.jump_flag < -650) && (runeof(self) != 3))
		{
			T_Damage (self, world, world, 20); // PATCH v2.063 - falling dmg=20 ao inves de 5.. balaca :)
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
        }
    }
    // END_MOD

	CheckPowerups ();

        // PATCH: MAGIA STUNNER (self vitima)
        if (self.items & IT_STUNNED)
           {
                // retira quando passa o tempo de paralisia
                if (self.attack_finished < time)
                   {
                        sprint(trace_ent, "Voce voltou ao normal\n");
                        self.items = self.items - (self.items & IT_STUNNED);
                   }
           }
        // ENDPAT
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
    // ELOHIM_MOD - do elohim specific stuff
    elohim_client_connect();
    // END_MOD

	bprint (self.netname);
	bprint (" entered the game\n");

// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
        // PATCH -- seja bem vindo ;-)
        else
            {

				// TD ]|[ comentado (um dos caracteres [ ou ] é invisível, pqp)
                //self.messagetxt = "Spinal's\nÔïÔáÌ ÄåÓÔÒõÃÔéïÎ ‘É\n\n                                        \nARENA CAMPER\nSeja bem-vindo(a)!\n                                        \n                                        \n\nhttp://arenacamper.125mb.com\n";
//	self.messagetxt = "\nÔOÔAÌ ÄEÓTÒUÃTÉOÎ 2.11\n\n                                        \nARENA CAMPER\nSeja bem-vindo(a)!\n                                        \nVeja a lista de mapas no site:\n\nhttp://arenacamper.125mb.com\n";
		self.messagetxt = "\nÔOÔAÌ ÄEÓTÒUÃTÉOÎ 2.11\n\n                                        \nhttp://arenacamper.125mb.com\n                                        \nMODO DM: DIGITE normal\n              \nMODO TDM: DIGITE match\n              \nTECLA 1 (impulse 1): USA MAGIA\n          \nTECLA 9 (impulse 20): USA ARMA ESPECIAL\n";
                self.messagetime = 66996699; // codigo pro statusthink
                self.messagebreaks = 11;

            }

};

void() ClientDropStuff =
{
        // PATCH - larga arma especial
        local float w2os;
        w2os = weapon2of(self);
        if (w2os > 0)
           {
                TossSpecial (w2os, self.origin);
                removeweapon2(self);
           }
        // ENDPATCH

        // PATCH - larga runa
        local float ros;
        ros = runeof(self);
        if (ros > 0)
           {
                TossRune (ros, self.origin);
                removerune(self);
           }
        // ENDPAT

        // PATCH - remove temps
        local entity e;
        e = find(world, classname, "td_temp");
        while (e)
          {
                local entity tmp;
                tmp = e;

                e = find(e, classname, "td_temp");

                if (tmp.owner == self)
                   remove(tmp);
                else
                // OPS! 19 eh suckerball, owner=goalentity
                   {
                        if (tmp.magic == 19)
                        if (tmp.goalentity == self)
                           remove(tmp);
                   }
          }
        // ENDPAT
}

/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving


	ClientDropStuff();
	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);

    // ELOHIM_MOD - play gib sound if client was kicked for suiciding
    if (self.cnt < 0)
        sound(self, CHAN_BODY, "player/gib.wav", 1, ATTN_NONE);
    else
        sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
    // END_MOD

	set_suicide_frame ();

    // ELOHIM_MOD
    elohim_client_disconnect();
    // END_MOD
};

//
// ELOHIM_MOD
//
// Added a bunch of new obituaries; got rid of "can't exist on slime alone"
// (I never much liked that one)
//
// Added a same-team check for telefragging.
//
// Added code to keep track of team scores
//
// Added code to keep track of kill stats
//
// Removed check for killed by monster
//

//
//  F R A G
//
//  Adds/substracts a frag to a client and his team in match mode.
//
void (entity client, float fragval) client_frag =
{
    client.frags = client.frags + fragval;

    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
        if (client.height == elohim_team1)
            elohim_teamfrags1 = elohim_teamfrags1 + fragval;
        else
            elohim_teamfrags2 = elohim_teamfrags2 + fragval;
    }
    else if (client.frags >= fraglimit)
    {
        if (fraglimit)
            NextLevel();
    }
};

/*
===========
ClientObituary

called when a player dies
============
*/
void(entity targ, entity attacker) ClientObituary =
{/*
	local	float rnum;
	local	string deathstring, deathstring2;
	rnum = random();

	if (targ.classname == "player")
	{
		if (attacker.classname == "teledeath")
		{
			bprint (targ.netname);
			bprint (" was telefragged by ");
			bprint (attacker.owner.netname);
            bprint ("\n");

            if ( (teamplay == 2) && (targ.qw_team > 0) &&
                (targ.qw_team == attacker.owner.qw_team) )
            {
                // attacker.owner killed teammate
                attacker.owner.mangle_y = attacker.owner.mangle_y + 1;
                client_frag(attacker.owner, -1);
            }
            else
            {
                // targ was killed by enemy
                targ.mangle_z = targ.mangle_z + 1;
                client_frag(attacker.owner, 1);
            }
			return;
		}

        // Never implemented
        /*
		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ");
			bprint (targ.netname);
			bprint ("'s telefrag\n");

			targ.frags = targ.frags - 1;
			return;
		}
        *//*

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
                attacker.mangle_x = attacker.mangle_x + 1;
                client_frag(attacker, -1);
				bprint (targ.netname);
				
				if (targ.weapon == 64 && targ.waterlevel > 1)
				{
                    if (rnum < 0.25)
                        bprint(" fries himself\n");
                    else if (rnum < 0.5)
                        bprint(" checks the batteries on his thunderbolt\n");
                    else if (rnum < 0.75)
                        bprint(" tries to heat the pool\n");
                    else
                        bprint (" discharges into the water.\n");
					return;
				}
				if (targ.weapon == IT_GRENADE_LAUNCHER)
                {
                    if (rnum < 0.33)
                        bprint(" forgot that grenades explode\n");
                    else if (rnum < 0.66)
                        bprint(" tries to play soccer with a grenade\n");
                    else
                        bprint (" tries to put the pin back in\n");
                }
				else
                {
                    if (rnum < 0.5)
                        bprint(" discovers blast radius\n");
                    else
                        bprint (" becomes bored with life\n");
                }
				return;
			}
			else if ( (teamplay == 2) && (targ.qw_team > 0)&&(targ.qw_team == attacker.qw_team) )
			{
                // killed teammate
                attacker.mangle_y = attacker.mangle_y + 1;
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";
				bprint (attacker.netname);
				bprint (deathstring);
                client_frag(attacker, -1);
				return;
			}
			else
			{
                // killed enemy
                targ.mangle_z = targ.mangle_z + 1;
                client_frag(attacker, 1);

                if (attacker.weapon == IT_AXE)
				{
                    if (rnum < 0.5)
                    {
                        deathstring = " was axe-murdered by ";
                        deathstring2 = "\n";
                    }
                    else
                    {
                        deathstring = " was decapitated by ";
                        deathstring2 = "'s axe\n";
                    }
				}
                else if (attacker.weapon == IT_SHOTGUN)
				{
                    if (rnum < 0.5)
                    {
                        deathstring = " chewed on ";
                        deathstring2 = "'s boomstick\n";
                    }
                    else
                    {
                        deathstring = " was disembowled by ";
                        deathstring2 = "'s shotgun\n";
                    }
				}
                else if (attacker.weapon == IT_SUPER_SHOTGUN)
				{
                    if (rnum < 2)
                    {
                        deathstring = " ate 2 loads of ";
                        deathstring2 = "'s buckshot\n";
                    }
				}
                else if (attacker.weapon == IT_NAILGUN)
				{
                    deathstring = " was nailed by ";
                    deathstring2 = "\n";
				}
                else if (attacker.weapon == IT_SUPER_NAILGUN)
				{
                    if (rnum < 0.5)
                    {
                        deathstring = " was punctured by ";
                        deathstring2 = "\n";
                    }
                    else
                    {
                        deathstring = " was ventilated by ";
                        deathstring2 = "\n";
                    }
				}
                else if (attacker.weapon == IT_GRENADE_LAUNCHER)
				{
                    deathstring2 = "'s grenade\n";
                    if (rnum < 0.5)
                    {
                        if (targ.health < -40)
                        {
                            if (elohim_playmode & ELOHIM_NO_GIBS)
                                deathstring = " was destroyed by ";
                            else
                                deathstring = " was gibbed by ";
                        }
                        else
                        {
                            deathstring = " eats ";
                            deathstring2 = "'s pineapple\n";
                        }
                    }
                    else
                    {
                        if (targ.health < -40)
                        {
                            if (elohim_playmode & ELOHIM_NO_GIBS)
                                deathstring = " was annihilated by ";
                            else
                                deathstring = " was blown to chunks by ";
                        }
                        else
                            deathstring = " gets intimate with ";
                    }
				}
                else if (attacker.weapon == IT_ROCKET_LAUNCHER)
				{
                    deathstring2 = "'s rocket\n";
                    if (rnum < 0.5)
                    {
                        if (targ.health < -40)
                        {
                            if (elohim_playmode & ELOHIM_NO_GIBS)
                                deathstring = " was destroyed by ";
                            else
                                deathstring = " was gibbed by ";
                        }
                        else
                            deathstring = " rides ";
                    }
                    else
                    {
                        if (targ.health < -40)
                        {
                            if (elohim_playmode & ELOHIM_NO_GIBS)
                                deathstring = " was annihilated by ";
                            else
                                deathstring = " was blown to chunks by ";
                        }
                        else
                            deathstring = " is butt-fucked by ";
                    }
				}
                else if (attacker.weapon == IT_LIGHTNING)
				{
                    if (rnum < 0.5)
                    {
                        deathstring = " accepts ";
                        if (attacker.waterlevel > 1)
                            deathstring2 = "'s discharge\n";
                        else
                            deathstring2 = "'s shaft\n";
                    }
                    else 
                    {
                        deathstring = " gets a warm fuzzy feeling from ";
                        deathstring2 = "\n";
                    }
				}
                else if (rnum == IT_EXTRA_WEAPON)
                {
                    // PATCH
                    // msgs de armas especiais
                    local float w2;
                    w2 = attacker.has_sw;
                    if (w2 == 1) deathstring = " tomou o morteiro de ";
                    else if (w2 == 2) deathstring = " explodiu com a pipebomb de ";
                    else if (w2 == 3) deathstring = " comeu a smartbomb de ";
                    else if (w2 == 4) deathstring = " foi fritado por ";
                    else if (w2 == 5) deathstring = " foi metralhado por ";
	                deathstring2 = "\n";
                }
                else
                {
                    // This should never happen.. but does it!?!?
                    deathstring = " was massacred by ";
                    deathstring2 = "\n";
                }
				bprint (targ.netname);
				bprint (deathstring);
				bprint (attacker.netname);
				bprint (deathstring2);
			}
			return;
		}
		else
		{
            // targ got himself killed
            targ.mangle_x = targ.mangle_x + 1;
            client_frag(targ, -1);
			bprint (targ.netname);

			// tricks and traps
			if (attacker.classname == "explo_box")
			{
                bprint (" explodiu\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker != world)
			{
                bprint (" was squished\n");
				return;
			}
			if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
                if (rnum < 0.5)
                    bprint (" was spiked\n");
                else
                    bprint (" was impaled\n");
				return;
			}
			if (attacker.classname == "fireball")
			{
                bprint (" ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (" tried to leave\n");
				return;
			}

			// in-water deaths
            if (targ.watertype == -3)
			{
                if (rnum < 0.33)
					bprint (" sleeps with the fishes\n");
                else if (rnum < 0.66)
					bprint (" sucks it down\n");
                else
                    bprint (" realizes he doesn't have gills\n");
				return;
			}
            else if (targ.watertype == -4)
			{
                if (rnum < 0.33)
					bprint (" gulped a load of slime\n");
                else if (rnum < 0.66)
                    bprint (" discovers the hazards of toxic waste\n");
                else
                    bprint (" picked a bad place to swim\n");
				return;
			}
            else if (targ.watertype == -5)
			{
				if (targ.health < -15)
				{
					bprint (" burst into flames\n");
					return;
				}
                if (rnum < 0.5)
					bprint (" turned into hot slag\n");
				else
					bprint (" visits the Volcano God\n");
				return;
			}

			// fell to their death?
			if (targ.deathtype == "falling")
			{
		        targ.deathtype = "";
				bprint (" se espatifou no chao\n");
				return;
			}

			// hell if I know; he's just dead!!!
			bprint (" morreu... hahahahahaha!!\n");
		}
	}*/
	local	float rnum;
	local	string deathstring, deathstring2;
	rnum = random();

        local float virouzumbi;

        virouzumbi = 0;

        // PATCH - Decide se vira Zumbi (pow=-666)
        if (targ.classname == "player")
        if (attacker.classname == "player")
        if (targ != attacker)

        // ve se nao sao teammates
	if ( (teamplay == 0) || (targ.qw_team == "none") || (targ.qw_team != attacker.qw_team) )

        if (targ.pow != -666) // ja era zumbi?
        if (attacker.pow != -666) // atacante era zumbi?
        if (LAST_ZUMBI < time)
        if (random() <= 0.1) // 10% de chance
           {
                virouzumbi = 1;
                LAST_ZUMBI = time + 60*2;

                targ.pow = -666;
                targ.enemy = attacker;
           }

        //
        //  Reescrito
        //

	if (targ.classname != "player")
           return;

        //
        // primeiro: attackers != player, sao obvios
        //

        // PATCH zumbi death
        if (attacker.pow == -666)
        if (attacker != targ)
           {
	        bprint (targ.netname);
		bprint (" sofreu a vinganca de ");
		bprint (attacker.netname);
		bprint ("!!! MWaHaHAhAhAHA!\n");

                client_frag(attacker, 1);
                return;
           }

        // PATCH FRAGGER death
        if (attacker.classname == "td_fragger")
        if (attacker.magic == 2)
           {
	        bprint (targ.netname);
                if (random() < 0.5)
		   bprint (" foi telefuckado por ");
                else
                   bprint (" foi telefragado por ");
		bprint (attacker.owner.netname);
		bprint ("\n");

                if (teamplay && attacker.owner.qw_team != "none" && attacker.owner.qw_team == targ.qw_team)
			client_frag(attacker.owner, -1);
		else
			client_frag(attacker.owner, 1);
                return;
           }
        else if (attacker.magic == 2+666)
           {
		bprint (attacker.owner.netname);
                if (random() < 0.5)
		   bprint (" nao viu o mirror de ");
                else
                   bprint (" se tele-fodeu no mirror de ");
	        bprint (attacker.owner.goalentity.netname); // v2.06 pequeno fix
		bprint ("\n");

                if (teamplay && attacker.owner.qw_team != "none" && attacker.owner.qw_team == targ.qw_team)
			client_frag(attacker.owner, -1);
		else
			client_frag(targ, 1);
                return;
           }

	// essas mortes atrapalham o teamplay porque inflictor == attacker pra mostrar as mensagens de morte bonitinhas...

        // PATCH amigo death
        if (attacker.classname == "td_temp")
        if (attacker.magic == 13)
           {
	        bprint (targ.netname);
                if (attacker.owner == targ) // haha otario..
                   {
                        bprint (" foi traido pelo seu amigo-da-onca!\n");
                        client_frag(attacker.owner, -1);
                        return;
                   }
                if (rnum < 0.25) bprint (" foi assassinado pelo amigo de "); else
                if (rnum < 0.5) bprint (" apanhou do irmao mais velho de "); else
                if (rnum < 0.75) bprint (" levou pedrada do amigo de "); else
                   bprint (" comeu rockets servidos pelo garcom de ");
		bprint (attacker.owner.netname);
		bprint ("\n");

		if (teamplay && attacker.owner.qw_team != "none" && attacker.owner.qw_team == targ.qw_team)
			client_frag(attacker.owner, -1);
		else
			client_frag(attacker.owner, 1);
                return;
           }


        // PATCH TD2.08 VIRUS WIZARD DEATH
        if (attacker.classname == "td_temp")
        if (attacker.magic == 226)
        {
            if (attacker.owner == targ)
            {
                bprint ("A LOMBRIGA de ");
                bprint (targ.netname);
                bprint (" ficou irritada com a mae! HaHaHaHa!!\n");
                client_frag(attacker.owner, -1);
                return;
            }

            bprint (targ.netname);
            if (rnum < 0.25) bprint (" foi melecado pela lombriga de "); else
            if (rnum < 0.50) bprint (" foi envenenado pela lombriga de "); else
            if (rnum < 0.75) bprint (" foi lambuzado pela lombriga de "); else
                             bprint (" comeu a meleca da lombriga de ");
		    bprint (attacker.owner.netname);
		    bprint ("\n");

		if (teamplay && attacker.owner.qw_team != "none" && attacker.owner.qw_team == targ.qw_team)
			client_frag(attacker.owner, -1);
		else
			client_frag(attacker.owner, 1);
            return;
        }

        // PATCH doberman death
        if (attacker.classname == "td_temp")
        if (attacker.magic == 21)
           {
                if (attacker.owner == targ) // haha otario..
                   {
                        bprint ("O DOBERMAN de ");
                        bprint (targ.netname);
                        bprint (" ficou irritado com o dono! HaHaHaHa!!\n");
                        client_frag(attacker.owner, -1);
                        return;
                   }
                bprint (targ.netname);
                if (rnum < 0.25) bprint (" invadiu o canil de "); else

                if (rnum < 0.35) bprint (" foi confundido com FROLIC pelo caozinho de "); else
                if (rnum < 0.4) bprint (" foi confundido com BONZO pelo caozinho de "); else
                if (rnum < 0.45) bprint (" foi confundido com PEDIGREE CHAMP pelo caozinho de "); else
                if (rnum < 0.5) bprint (" foi confundido com FRISKIES pelo caozinho de "); else

                if (rnum < 0.75) bprint (" foi devorado pelo doberman de "); else
                   bprint (" nao viu a placa `cuidado com o cao` de ");
		bprint (attacker.owner.netname);
		bprint ("\n");

                if (teamplay && attacker.owner.qw_team != "none" && attacker.owner.qw_team == targ.qw_team)
			client_frag(attacker.owner, -1);
		else
			client_frag(attacker.owner, 1);
                return;
           }

        // PATCH trappack death
        if (attacker.classname == "td_temp")
        if (attacker.magic == 24)
           {
                bprint (targ.netname);
                if (attacker.owner == targ) // haha otario..
                   {
                        bprint (" foi vitima da sua propria mina! HaHaHaHa!!\n");
                        client_frag(attacker.owner, -1);
                        return;
                   }
                bprint (" pisou na mina de ");
		bprint (attacker.owner.netname);
                bprint ("\n");

                if (teamplay && attacker.owner.qw_team != "none" && attacker.owner.qw_team == targ.qw_team)
			client_frag(attacker.owner, -1);
		else
			client_frag(attacker.owner, 1);
                return;
           }

        // PATCH virus death
        if (attacker.classname == "td_temp")
        if (attacker.magic == 26)
           {
	        bprint (targ.netname);
		bprint (" morreu contaminado pelo virus de ");
		bprint (attacker.owner.netname);
		bprint ("! HaHaHa!\n");

                if (teamplay && attacker.owner.qw_team != "null" && attacker.owner.qw_team == targ.qw_team)
			client_frag(attacker.owner, -1);
		else
			client_frag(attacker.owner, 1);
                return;
           }

	if (attacker.classname == "teledeath")
	   {
	        bprint (targ.netname);
		bprint (" was telefragged by ");
		bprint (attacker.owner.netname);
		bprint ("\n");

		if (teamplay && attacker.owner.qw_team != "none" && attacker.owner.qw_team == targ.qw_team)
			client_frag(attacker.owner, -1);
		else
			client_frag(attacker.owner, 1);
		return;
	   }

	   if (attacker.classname == "teledeath2")
	      {
	        bprint ("Satan's power deflects ");
		bprint (targ.netname);
		bprint ("'s telefrag\n");

		client_frag(targ, -1);
		return;
	      }

           //
           //  Attacker e' player tambem...
           //

	if (attacker.classname == "player")
	   {
                //
                //  Suicidios
                //
	        if (targ == attacker)
		   {
                        bprint (targ.netname);

                        // PATCH -- zumbi death
                        // qdo toca no inimigo ele se suicida
                        //
                        if (virouzumbi != 1)
                        if (targ.pow == -666)
                           {
                                bprint (" descansa em paz\n");
                                targ.pow = 0;
                                return;
                           }
                        else // qualquer outro suicidio tira 1 frag
				client_frag(attacker, -1);

                        //
                        // mensagens de suicidio

                        // PATCH -- SW4 -- Tesla Discharge
                        // arrumado para config classico
                        if (((targ.weapon == IT_EXTRA_WEAPON) && (weapon2of(targ) == 4)) || ((targ.magicstr == "   Tesla") && (targ.weapon == IT_AXE)))
                           {
                                if (targ.waterlevel > 1)
                                   bprint(" descarregou sua Tesla na agua\n");
                                else
                                    bprint(" sobrecarregou sua Tesla (duh)\n");
                                return;
                           }

                           // Discharge
			   if (targ.weapon == 64 && targ.waterlevel > 1)
			      {
			                bprint (" discharges into the water.\n");
					return;
			      }
                           // Grenade
			   if (targ.weapon == IT_GRENADE_LAUNCHER)
                              {
			        bprint (" tries to put the pin back in\n");
                                return;
                              }

                           //
                           // suicidio geral
			   bprint (" becomes bored with life\n");
			   return;
		   } // fim targ==attacker
                //
                // killed teammate em teamplay 2
                //
		else if ( (teamplay == 2) && (targ.qw_team != "none")&&(targ.qw_team == attacker.qw_team) )
		   {
		        if (rnum < 0.25) deathstring = " mows down a teammate\n";
			else if (rnum < 0.50) deathstring = " checks his glasses\n";
			else if (rnum < 0.75) deathstring = " gets a frag for the other team\n";
			else deathstring = " loses another friend\n";
			bprint (attacker.netname);
			bprint (deathstring);
			client_frag(attacker, -1);
			return;
		   }
                //
                //  morte normal (targ killed por attacker)
                //
	        else
		   {
		        client_frag(attacker, 1);

                        deathstring2 = "\n";  // remendex ignorar

			rnum = attacker.weapon;

                        // PATCH: morreu queimado?
                        //
                        if ((targ.items & IT_BURNING) && (attacker == targ.goalentity))
                           {
                                deathstring = " foi torradinho por ";
				deathstring2 = "\n";
                           }
			else if (rnum == IT_AXE)
			{
			        deathstring = " was ax-murdered by ";
				deathstring2 = "\n";
			}
			else if (rnum == IT_SHOTGUN)
			{
			        deathstring = " chewed on ";
				deathstring2 = "'s boomstick\n";
			}
			else if (rnum == IT_SUPER_SHOTGUN)
			{
			        deathstring = " ate 2 loads of ";
				deathstring2 = "'s buckshot\n";
			}
			else if (rnum == IT_NAILGUN)
			{
                                deathstring = " foi incinerado por ";
				deathstring2 = "\n";
			}
			else if (rnum == IT_SUPER_NAILGUN)
			{
			        deathstring = " was punctured by ";
				deathstring2 = "\n";
			}
			else if (rnum == IT_GRENADE_LAUNCHER)
			{
			        deathstring = " eats ";
				deathstring2 = "'s pineapple\n";
				if (targ.health < -40)
				{
				        deathstring = " was gibbed by ";
					deathstring2 = "'s grenade\n";
				}
			}
			else if (rnum == IT_ROCKET_LAUNCHER)
			{
			        deathstring = " rides ";
				deathstring2 = "'s rocket\n";
				if (targ.health < -40)
				{
				        deathstring = " was gibbed by ";
					deathstring2 = "'s rocket\n" ;
				}
			}
			else if (rnum == IT_LIGHTNING)
			{
			        deathstring = " accepts ";
				if (attacker.waterlevel > 1)
				   deathstring2 = "'s discharge\n";
				else
				    deathstring2 = "'s shaft\n";
			}
                        else if (rnum == IT_EXTRA_WEAPON)
                        {
                                // PATCH
                                // msgs de armas especiais
                                local float w2;
                                w2 = weapon2of(attacker);
                                if (w2 == 1) deathstring = " tomou o morteiro de ";
                                else if (w2 == 2) deathstring = " explodiu com a pipebomb de ";
                                else if (w2 == 3) deathstring = " comeu a smartbomb de ";
                                else if (w2 == 4) deathstring = " foi fritado por ";
                                else if (w2 == 5) deathstring = " foi metralhado por ";
                                deathstring2 = "\n";
                        }
			bprint (targ.netname);
			bprint (deathstring);
			bprint (attacker.netname);
			bprint (deathstring2);
		   }
	   }
	else // attacker nao player, world, explobox, etc.
	   {
	        client_frag(targ, -1);
		bprint (targ.netname);

		// tricks and traps
		if (attacker.classname == "explo_box")
		   {
		        bprint (" explodiu\n");
			return;
		   }
		if (attacker.solid == SOLID_BSP && attacker != world)
		   {
		        bprint (" foi esmagado\n");
			return;
		   }
		if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
		   {
		        bprint (" foi espetado\n");
			return;
		   }
	        if (attacker.classname == "fireball")
		   {
		        bprint (" comeu uma bola de fogo\n");
			return;
		   }
		if (attacker.classname == "trigger_changelevel")
		   {
		        bprint (" tentou ir embora\n");
			return;
		   }

		// in-water deaths
		rnum = targ.watertype;
		if (rnum == -3)
		   {
		        if (random() < 0.5)
			   bprint (" dormiu com os peixes\n");
			else
			    bprint (" afogou\n");
			return;
		   }
		else if (rnum == -4)
		     {
		        if (random() < 0.5)
			   bprint (" gulped a load of slime\n");
			else
			    bprint (" can't exist on slime alone\n");
			return;
		     }
		else if (rnum == -5)
		     {
		        if (targ.health < -15)
			   {
			        bprint (" burst into flames\n");
				return;
			   }
			if (random() < 0.5)
			   bprint (" turned into hot slag\n");
			else
			    bprint (" visits the Volcano God\n");
			return;
		     }

		// fell to their death?
		if (targ.deathtype == "falling")
		   {
		        targ.deathtype = "";
			bprint (" se espatifou no chao\n");
			return;
		   }

		// hell if I know; he's just dead!!!
		bprint (" morreu... hahahahahaha!!\n");
	   }
};

// END_MOD
