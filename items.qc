void() W_SetCurrentAmmo;
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */


void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};



/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
/*
void() noclass =
{
	dprint ("noclass spawned at");
	dprint (vtos(self.origin));
	dprint ("\n");
	remove (self);
};

*/

/*
============
PlaceItem

plants the object on the floor
============
*/
void() PlaceItem =
{
	local float	oldz;

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	oldz = self.origin_z;
	if (!droptofloor())
	{
		dprint ("Bonus item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
		return;
	}

    // ELOHIM_MOD - check for noquad, nopent, and noring
	if (self.classname == "item_artifact_super_damage")
    {
        if (elohim_playmode & ELOHIM_NO_QUAD)
            admin_disable_item();
    }
    if (self.classname == "item_artifact_invulnerability")
    {
        if (elohim_playmode & ELOHIM_NO_PENT)
            admin_disable_item();
    }
    if (self.classname == "item_artifact_invisibility")
    {
        if (elohim_playmode & ELOHIM_NO_RING)
            admin_disable_item();
    }
    // END_MOD
};

// ELOHIM_MOD - need these prototypes
void () weapon_touch;
void () ammo_touch;
// END_MOD

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void() StartItem =
{
    // ELOHIM_MOD - no weapons or ammo in practice mode
    if (elohim_playmode & ELOHIM_PRACTICE_MODE)
    {
        if (self.touch == weapon_touch || self.touch == ammo_touch)
        {
            remove(self);
            return;
        }
    }
    // END_MOD

	self.nextthink = time + 0.2;	// items start after other solids
	self.think = PlaceItem;
};

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal =
{
	if (e.health <= 0)
		return 0;
	if ((!ignore) && (e.health >= other.max_health))
		return 0;
	healamount = ceil(healamount);

	e.health = e.health + healamount;
	if ((!ignore) && (e.health >= other.max_health))
		e.health = other.max_health;
		
	if (e.health > 250)
		e.health = 250;
	return 1;
};

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

float	H_ROTTEN = 1;
float	H_MEGA = 2;
.float	healamount, healtype;
void() health_touch;

// PATCH -- SEM ROT
//void() item_megahealth_rot;

void() item_health =
{	
	self.touch = health_touch;

	if (self.spawnflags & H_ROTTEN)
	{
		precache_model("maps/b_bh10.bsp");

		precache_sound("items/r_item1.wav");
		setmodel(self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.healamount = 20;  // PATCH
		self.healtype = 0;
	}
	else
	if (self.spawnflags & H_MEGA)
	{
		precache_model("maps/b_bh100.bsp");
		precache_sound("items/r_item2.wav");
		setmodel(self, "maps/b_bh100.bsp");
		self.noise = "items/r_item2.wav";
		self.healamount = 100;
		self.healtype = 2;
	}
	else
	{
		precache_model("maps/b_bh25.bsp");
		precache_sound("items/health1.wav");
		setmodel(self, "maps/b_bh25.bsp");
		self.noise = "items/health1.wav";
		self.healamount = 30;  // PATCH
		self.healtype = 1;
	}
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


void() health_touch =
{
	local	float amount;
	local	string	s;

    local float takeit;
    takeit = 0;
    local float donttake;
    donttake = 0;
    local float megahealth;
    megahealth = (self.healtype == 2); // Megahealth?  Ignore max_health...

    // ELOHIM_MOD
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return;
    // END_MOD
	
	if (other.classname != "player")
	   return;
    if (other.pow == -666)
	   return;

    //always take if burning
    //
    if (other.items & IT_BURNING) {
        // PATCH -- retira queimando, 20% de chance
        if ((random() < 0.20) || (self.healtype == 2))
           other.items = other.items - (other.items & IT_BURNING);

        //take it - pegou health pra queimadura, nao pra saude
        takeit = 1;
    }

    //don't take megahealth if not 999powerup && health at max (250)
	if (megahealth)
    if (self.healamount < 999) //TD 2.08 fix: nao pegava superhealth se tava com 250
	if (other.health >= 250)
       donttake = 1;

    //if can take, take it and check if health applied
    if (!donttake)
	if (!T_Heal(other, self.healamount, megahealth))
	   donttake = 1;

    //MAGIC health message
    if (self.healtype == 2)
    if (self.healamount >= 999)
    {
        sprint(other, "You got Óðéîáì§ó Õìôòá Èåáìôè!\n");
        other.health = 999; //td2.08: supersuper health
    }

    //check if item is removed, sound played, etc.
    if (!takeit)   //nao queimando
    if (donttake)  //nao precisa da health
       return;

// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	stuffcmd (other, "bf\n");

	self.model = string_null;
	self.solid = SOLID_NOT;

    // patch -- 40s pro 100H
    if (self.healtype == 2)
       self.nextthink = time + 40;
    else
	   self.nextthink = time + 20; // normal

    if (self.healamount >= 999)
       self.think = SUB_Remove;
    else
	   self.think = SUB_regen;

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};

// PATCH -- REMOVIDO
/*
void() item_megahealth_rot =
{
	other = self.owner;

	if (other.health > other.max_health)
	{
		other.health = other.health - 1;
		self.nextthink = time + 1;
		return;
	}

// it is possible for a player to die and respawn between rots, so don't
// just blindly subtract the flag off
	other.items = other.items - (other.items & IT_SUPERHEALTH);
	
	if (deathmatch == 1)	// deathmatch 2 is silly old rules
	{
		self.nextthink = time + 20;
		self.think = SUB_regen;
	}
};
*/
/*
===============================================================================

ARMOR

===============================================================================
*/

void() armor_touch =
{
	local	float	type, value, bit;
	
    // ELOHIM_MOD
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return;
    // END_MOD
	
	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;
    if (other.pow == -666)
		return;

	if (self.classname == "item_armor1")
	{
		type = 0.3;
		value = 100;
		bit = IT_ARMOR1;
	}
	if (self.classname == "item_armor2")
	{
		type = 0.6;
		value = 150;
		bit = IT_ARMOR2;
	}
	if (self.classname == "item_armorInv")
	{
		type = 0.8;
		value = 200;
		bit = IT_ARMOR3;
	}
	if (self.classname == "item_armorSUPER")
	{
		type = 0.9;
		value = 250;
		bit = IT_ARMOR3;
                sprint(other, "You got Óðéîáì§ó Óåãòåô Áòíïò!\n");
	}
	if (other.armortype*other.armorvalue >= type*value)
		return;

	other.armortype = type;
	other.armorvalue = value;
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;

	self.solid = SOLID_NOT;
	self.model = string_null;
	if (deathmatch == 1)
		self.nextthink = time + 20;

        // PATCH -- remove dragon
        if (self.classname == "item_armorSUPER")
           self.think = SUB_Remove;
        else
	   self.think = SUB_regen;

        // PATCH -- SEM MSG ARMOR
	// sprint(other, "You got armor\n");

// armor touch sound
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor1 =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 0;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor2 =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 1;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armorInv =
{
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 2;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

void() bound_other_ammo =
{
	if (other.ammo_shells > 100)
		other.ammo_shells = 100;
	if (other.ammo_nails > 200)
		other.ammo_nails = 200;
	if (other.ammo_rockets > 100)
		other.ammo_rockets = 100;		
        if (other.ammo_cells > MAX_CELLS)
                other.ammo_cells = MAX_CELLS;  
};


float(float w) RankForWeapon =
{
	if (w == IT_LIGHTNING)
		return 1;
	if (w == IT_ROCKET_LAUNCHER)
		return 2;
	if (w == IT_SUPER_NAILGUN)
		return 3;
	if (w == IT_GRENADE_LAUNCHER)
		return 4;
	if (w == IT_SUPER_SHOTGUN)
		return 5;
	if (w == IT_NAILGUN)
		return 6;
	return 7;
};

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/
void(float old, float new) Deathmatch_Weapon =
{
	local float or, nr;

        // PATCH 2.04
        // TESLA ATIVA NAO TROCA DE ARMA PORRA
        if (self.tesla > 0) return;

// change self.weapon if desired
	or = RankForWeapon (self.weapon);
	nr = RankForWeapon (new);
	if ( nr < or )
    {
        // ELOHIM_MOD - if underwater, don't switch to LG
        if (nr == 1)
        {
            if (self.waterlevel > 1)
                return;
        }
        // END_MOD
		self.weapon = new;
    }
};

/*
=============
weapon_touch
=============
*/
float() W_BestWeapon;

void() weapon_touch =
{
// ELUAN - TD 2.11 - corrige o bug de trocar de arma automaticamente
//	local	float	hadammo, best, new, old;
	local float new, old;
	local	entity	stemp;
	local	float	leave, p, p2;

    // ELOHIM_MOD
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return;
    // END_MOD
	
	if (!(other.flags & FL_CLIENT))
		return;
    if (other.pow == -666)
		return;
    if (other.health <= 0) //TD2.08: nao pega arma se morto
       return;

// if the player was using his best weapon, change up to the new one if better
// ELUAN - TD 2.11 - corrige o bug de trocar de arma automaticamente
//	stemp = self;
//	self = other;
//	best = W_BestWeapon();
//	self = stemp;

    if (deathmatch == 2) // ELOHIM_MOD '|| coop' removed
		leave = 1;
	else
		leave = 0;

	if (self.classname == "weapon_nailgun")
	{
		if (leave && maxpower(other, IT_NAILGUN))
			return;
		new = IT_NAILGUN;
		other.ammo_nails = other.ammo_nails + 50;
	}
	else if (self.classname == "weapon_supernailgun")
	{
		if (leave && maxpower(other, IT_SUPER_NAILGUN))
			return;
		new = IT_SUPER_NAILGUN;
		other.ammo_nails = other.ammo_nails + 50;
	}
	else if (self.classname == "weapon_supershotgun")
	{
		if (leave && maxpower(other, IT_SUPER_SHOTGUN))
			return;

		new = IT_SUPER_SHOTGUN;
		other.ammo_shells = other.ammo_shells + 20;
	}
	else if (self.classname == "weapon_rocketlauncher")
	{
		if (leave && maxpower(other, IT_ROCKET_LAUNCHER))
			return;

		new = IT_ROCKET_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 10;
	}
	else if (self.classname == "weapon_grenadelauncher")
	{
		if (leave && maxpower(other, IT_GRENADE_LAUNCHER))
			return;

		new = IT_GRENADE_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 10;
	}
	else if (self.classname == "weapon_lightning")
	{
		if (leave && maxpower(other, IT_LIGHTNING))
			return;

		new = IT_LIGHTNING;
		other.ammo_cells = other.ammo_cells + 25;
	}
	else
		objerror ("weapon_touch: unknown classname");


// weapon touch sound
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	bound_other_ammo ();

// change to the weapon
	old = other.items;

        // PATCH power up (.pow)

        if (!(other.items & new)) // nao tinha
	   other.items = other.items | new;
        else
            {
                // patch 2.05
                // caso  2. pego do ponto e ja tinha
                //   se tava no MAX, fica quieto
                //   senao avisa qual nivel foi
                p = getpow(other, new);
                pow_upgrade(other, new);
                if (p != 3) // nao ESTAVA no 3
                   {
                        p = getpow(other, new);
                        if (p == 1) sprint (other, "Power 2 "); else
                        if (p == 2) sprint (other, "Power 3 "); else
                        if (p == 3) sprint (other, "POWER MAX ");
	                sprint (other, self.netname);
                        if (p == 3) sprint (other, "!!");
                        sprint (other, "\n");
                   }
            }

        // ENDPAT

	stemp = self;
	self = other;


        //refresha statusbar
        self.statustime = time;

	self = stemp;

	if (leave)
        if (self.magic != 666)
		return;

// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch == 1)
		self.nextthink = time + 30;
	self.think = SUB_regen;

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supershotgun =
{
	precache_model ("progs/g_shot.mdl");
	setmodel (self, "progs/g_shot.mdl");
	self.weapon = IT_SUPER_SHOTGUN;
	self.netname = "Double-barrelled Shotgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_nailgun =
{
	precache_model ("progs/g_nail.mdl");
	setmodel (self, "progs/g_nail.mdl");
	self.weapon = IT_NAILGUN;
	self.netname = "Flame Gun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_supernailgun =
{
	precache_model ("progs/g_nail2.mdl");
	setmodel (self, "progs/g_nail2.mdl");
	self.weapon = IT_SUPER_NAILGUN;
	self.netname = "Super Nailgun";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_grenadelauncher =
{
	precache_model ("progs/g_rock.mdl");
	setmodel (self, "progs/g_rock.mdl");
	self.weapon = 3;
	self.netname = "Grenade Launcher";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_rocketlauncher =
{
	precache_model ("progs/g_rock2.mdl");
	setmodel (self, "progs/g_rock2.mdl");
	self.weapon = 3;
	self.netname = "Rocket Launcher";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_lightning =
{
	precache_model ("progs/g_light.mdl");
	setmodel (self, "progs/g_light.mdl");
	self.weapon = 3;
	self.netname = "Thunderbolt";
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};


/*
===============================================================================

AMMO

===============================================================================
*/

void() ammo_touch =
{
local entity	stemp;
local float		best;

    // ELOHIM_MOD
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return;
    // END_MOD
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
    if (other.pow == -666)
		return;

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;


// shotgun
	if (self.weapon == 1)
	{
		if (other.ammo_shells >= 100)
			return;
		other.ammo_shells = other.ammo_shells + self.aflag;
	}

// spikes
	if (self.weapon == 2)
	{
		if (other.ammo_nails >= 200)
			return;
		other.ammo_nails = other.ammo_nails + self.aflag;
	}

//	rockets
	if (self.weapon == 3)
	{
		if (other.ammo_rockets >= 100)
			return;
		other.ammo_rockets = other.ammo_rockets + self.aflag;
	}

//	cells
	if (self.weapon == 4)
	{
                if (other.ammo_cells >= MAX_CELLS)
			return;
		other.ammo_cells = other.ammo_cells + self.aflag;
	}

	bound_other_ammo ();
	
        // PATCH - sem msg para municao
	//sprint (other, "You got the ");
	//sprint (other, self.netname);
	//sprint (other, "\n");

// ammo touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// if changed current ammo, update it
	stemp = self;
	self = other;
	W_SetCurrentAmmo();
	self = stemp;

// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch == 1)
		self.nextthink = time + 30;
	self.think = SUB_regen;

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};




float WEAPON_BIG2 = 1;

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_shells =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_shell1.bsp");
		setmodel (self, "maps/b_shell1.bsp");
		self.aflag = 40;
	}
	else
	{
		precache_model ("maps/b_shell0.bsp");
		setmodel (self, "maps/b_shell0.bsp");
		self.aflag = 20;
	}
	self.weapon = 1;
	self.netname = "shells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_spikes =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_nail1.bsp");
		setmodel (self, "maps/b_nail1.bsp");
		self.aflag = 50;
	}
	else
	{
		precache_model ("maps/b_nail0.bsp");
		setmodel (self, "maps/b_nail0.bsp");
		self.aflag = 25;
	}
	self.weapon = 2;
	self.netname = "nails";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_rockets =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_rock1.bsp");
		setmodel (self, "maps/b_rock1.bsp");
		self.aflag = 10;
	}
	else
	{
		precache_model ("maps/b_rock0.bsp");
		setmodel (self, "maps/b_rock0.bsp");
		self.aflag = 5;
	}
	self.weapon = 3;
	self.netname = "rockets";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_cells =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_BIG2)
	{
		precache_model ("maps/b_batt1.bsp");
		setmodel (self, "maps/b_batt1.bsp");
                // PATCH BIG CELLS + 25c
		self.aflag = 25;
	}
	else
	{
		precache_model ("maps/b_batt0.bsp");
		setmodel (self, "maps/b_batt0.bsp");
                // PATCH SMALL CELLS + 15c
		self.aflag = 15;
	}
	self.weapon = 4;
	self.netname = "cells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_weapon (0 .5 .8) (0 0 0) (32 32 32) shotgun rocket spikes big
DO NOT USE THIS!!!! IT WILL BE REMOVED!
*/

float WEAPON_SHOTGUN = 1;
float WEAPON_ROCKET = 2;
float WEAPON_SPIKES = 4;
float WEAPON_BIG = 8;
void() item_weapon =
{
	self.touch = ammo_touch;

	if (self.spawnflags & WEAPON_SHOTGUN)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_shell1.bsp");
			setmodel (self, "maps/b_shell1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_shell0.bsp");
			setmodel (self, "maps/b_shell0.bsp");
			self.aflag = 20;
		}
		self.weapon = 1;
		self.netname = "shells";
	}

	if (self.spawnflags & WEAPON_SPIKES)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_nail1.bsp");
			setmodel (self, "maps/b_nail1.bsp");
			self.aflag = 40;
		}
		else
		{
			precache_model ("maps/b_nail0.bsp");
			setmodel (self, "maps/b_nail0.bsp");
			self.aflag = 20;
		}
		self.weapon = 2;
		self.netname = "spikes";
	}

	if (self.spawnflags & WEAPON_ROCKET)
	{
		if (self.spawnflags & WEAPON_BIG)
		{
			precache_model ("maps/b_rock1.bsp");
			setmodel (self, "maps/b_rock1.bsp");
			self.aflag = 10;
		}
		else
		{
			precache_model ("maps/b_rock0.bsp");
			setmodel (self, "maps/b_rock0.bsp");
			self.aflag = 5;
		}
		self.weapon = 3;
		self.netname = "rockets";
	}
	
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{
local entity	stemp;
local float		best;

    // ELOHIM_MOD
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return;
    // END_MOD
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
    if (other.pow == -666)
		return;

	centerprint (other, "You got the rune!");	

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = "";		// so rune doors won't find it
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void() item_sigil =
{
	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}
	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}
	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}
	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch =
{
local entity	stemp;
local float		best;

    // ELOHIM_MOD
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return;
    // END_MOD
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
    if (other.pow == -666)
		return;

        //v2.05 - tirei isso tb
	//sprint (other, "You got the ");
	//sprint (other, self.netname);
	//sprint (other,"\n");
	if (deathmatch)
	{
		self.mdl = self.model;
		
		if ((self.classname == "item_artifact_invulnerability") ||
			(self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 60*5;
		else
			self.nextthink = time + 60;
		
		self.think = SUB_regen;
	}	

	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;
	self.model = string_null;

// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}

	if (self.classname == "item_artifact_invulnerability")
	{
		other.invincible_time = 1;
		other.invincible_finished = time + 30;
	}

	if (self.classname == "item_artifact_invisibility")
	{
		other.invisible_time = 1;
		other.invisible_finished = time + 30;

                // PATCH -- muda model do jogador
                // OUTRO BUG!! se tiver camuflado, nao muda
                if (other.modelindex != model_null)
                   {
                        other.frame = 0;
	                other.modelindex = model_eyes;
                   }
	}

	if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
		other.super_damage_finished = time + 30;
	}

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};



/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/
void() item_artifact_invulnerability =
{
	self.touch = powerup_touch;

	precache_model ("progs/invulner.mdl");
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;

	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/
void() item_artifact_invisibility =
{
	self.touch = powerup_touch;

	precache_model ("progs/invisibl.mdl");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};


/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/
void() item_artifact_super_damage =
{
	self.touch = powerup_touch;

	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};



/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void() BackpackTouch =
{
	local string	s;
	local	float	best, old, new;
	local		entity	stemp;
	local	float	acount;
	
    // ELOHIM_MOD
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return;
    // END_MOD
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
    if (other.pow == -666)
		return;

	acount = 0;

// if the player was using his best weapon, change up to the new one if better
	stemp = self;
	self = other;
	best = W_BestWeapon();
	self = stemp;

// change weapons
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	new = self.items;
	if (!new)
		new = other.weapon;
	old = other.items;
	other.items = other.items | new;

	bound_other_ammo ();

// backpack touch sound
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// remove the backpack, change self to the player
	remove(self);
	self = other;

        // PATCH
        self.statustime = time;
};

// PATCH
// joga o saco com municao, mas as armas voam por fora!
float() crandom;

/*
===============
DropBackpack
===============
*/

void() upgrade_touch =   // idem a weapon_touch mas sem respawn
                         // v2.05: upgrade pode ter 'quantos powerups vale'
{
// ELUAN - TD 2.11 - corrige o bug de trocar de arma automaticamente
//	local	float	hadammo, best, new, old, p;
	local float new, old, p;
	local	entity	stemp;

    // ELOHIM_MOD
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return;
    // END_MOD
	
	if (!(other.flags & FL_CLIENT))
		return;
    if (other.classname != "player")
       return;
    if (other.pow == -666)
		return;

// if the player was using his best weapon, change up to the new one if better
// ELUAN - TD 2.11 - corrige o bug de trocar de arma automaticamente
//	stemp = self;
//	self = other;
//	best = W_BestWeapon();
//	self = stemp;

	local float leave;

    if (deathmatch == 2) // ELOHIM_MOD '|| coop' removed
		leave = 1;
	else
		leave = 0;	

	if (self.classname == "weapon_nailgun")
	{
		if (leave && (other.items & IT_NAILGUN) )
			return;
		new = IT_NAILGUN;
		other.ammo_nails = other.ammo_nails + 50;
	}
	else if (self.classname == "weapon_supernailgun")
	{
		if (leave && (other.items & IT_SUPER_NAILGUN) )
			return;
		new = IT_SUPER_NAILGUN;
		other.ammo_nails = other.ammo_nails + 50;
	}
	else if (self.classname == "weapon_supershotgun")
	{
		if (leave && (other.items & IT_SUPER_SHOTGUN) )
			return;
		new = IT_SUPER_SHOTGUN;
		other.ammo_shells = other.ammo_shells + 10;
	}
	else if (self.classname == "weapon_rocketlauncher")
	{
		if (leave && (other.items & IT_ROCKET_LAUNCHER) )
			return;
		new = IT_ROCKET_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 10;
	}
	else if (self.classname == "weapon_grenadelauncher")
	{
		if (leave && (other.items & IT_GRENADE_LAUNCHER) )
			return;
		new = IT_GRENADE_LAUNCHER;
		other.ammo_rockets = other.ammo_rockets + 10;
	}
	else if (self.classname == "weapon_lightning")
	{
		if (leave && (other.items & IT_LIGHTNING) )
			return;
		new = IT_LIGHTNING;
		other.ammo_cells = other.ammo_cells + 30;
	}
	else
		objerror ("weapon_touch: unknown classname");


// weapon touch sound
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	bound_other_ammo ();

        // PATCH power up (.pow)
        // MODIFICADO v2.05 para funcionar com N.os de powerup

        //local string ss;
        //ss = ftos (self.frags);
        //bprint("self.frags = ");
        //bprint(ss);
        //bprint(" ; ");
        //bprint(self.classname);
        //bprint("\n");

        // adiciona se nao tinha E JA POE POW, BURRO!
        if (!(other.items & new))
           {
                p = 0; // pow "antigo"
                other.items = other.items | new;
                self.frags = self.frags - 1;
           }
        else
                p = getpow(other, new);  // pega pow antigo p/ ver se manda msg

        local float pup;
        pup = self.frags; // numero de powerups;
        while (pup > 0)
        {
                pow_upgrade(other, new);
                pup = pup - 1;
        }

        if (p != 3) // nao ESTAVA no 3
           {
                p = getpow(other, new);
                if (p != 0)  // se o upgrade e' +1 e vc estava sem arma, vale
                             // por pickup e vc fica no nivel 1, e por isso nao
                             // mostra mensagem
                {
                        if (p == 1) sprint (other, "Power 2 "); else
                        if (p == 2) sprint (other, "Power 3 "); else
                        if (p == 3) sprint (other, "POWER MAX ");
	                sprint (other, self.netname);
                        if (p == 3) sprint (other, "!!");
                        sprint (other, "\n");
                }
           }

        // ENDPAT



// change to the weapon
	old = other.items;
	stemp = self;
	self = other;

        //refresha statusbar
        self.statustime = time;

	self = stemp;

	if (leave)
		return;

// remove it in single player, or setup for respawning in deathmatch

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets

        remove(self);   // bye bye
};

// upgrades q valem + de 1 powerup 'apodrecem'
// ate desaparecer
void() Upgrade_Rot =
{
        if (self.frags > 1)
           {
                self.frags = self.frags - 1;
                self.nextthink = time + 12;
           }
        else
            remove(self);
};

void(float it, float powerups) Throw_Weapon =
{
        local entity wpn;
        wpn = spawn();
        wpn.origin = self.origin - '0 0 24';
        wpn.touch = upgrade_touch;  // idem a weapon_touch, mas p/ nao respawnar
	wpn.flags = FL_ITEM;		// make extra wide
        wpn.solid = SOLID_TRIGGER;
	wpn.movetype = MOVETYPE_TOSS;
	wpn.velocity_x = crandom() * 200;
	wpn.velocity_y = crandom() * 200;
        wpn.velocity_z = 300;

        // patch v2.05 -> powerups que vale
        wpn.frags = powerups;

        if (it == IT_SUPER_SHOTGUN)
           {
                wpn.classname = "weapon_supershotgun";
	        wpn.netname = "Double-barrelled Shotgun";
                setmodel (wpn, "progs/g_shot.mdl");
           }
        else if (it == IT_NAILGUN)
           {
                wpn.classname = "weapon_nailgun";
	        wpn.netname = "Flame Gun";
                setmodel (wpn, "progs/g_nail.mdl");
           }
        else if (it == IT_SUPER_NAILGUN)
           {
                wpn.classname = "weapon_supernailgun";
	        wpn.netname = "Super Nailgun";
                setmodel (wpn, "progs/g_nail2.mdl");
           }
        else if (it == IT_GRENADE_LAUNCHER)
           {
                wpn.classname = "weapon_grenadelauncher";
	        wpn.netname = "Grenade Launcher";
                setmodel (wpn, "progs/g_rock.mdl");
           }
        else if (it == IT_ROCKET_LAUNCHER)
           {
                wpn.classname = "weapon_rocketlauncher";
	        wpn.netname = "Rocket Launcher";
                setmodel (wpn, "progs/g_rock2.mdl");
           }
        else if (it == IT_LIGHTNING)
           {
                wpn.classname = "weapon_lightning";
	        wpn.netname = "Thunderbolt";
                setmodel (wpn, "progs/g_light.mdl");
           }

        //bprint("THROW FRAG=");
        //local string ss;
        //ss = ftos (wpn.frags);
        //bprint(ss);
        //bprint(" ");
        //bprint(wpn.netname);
        //bprint("\n");

        setsize (wpn, '-16 -16 0', '16 16 56');
        wpn.think = Upgrade_Rot;
        wpn.nextthink = time + 30;
};

void(float ITE) Throw_Quant_Upgrades =
{
        local float r, p, p2;

        if (self.items & ITE)
           {
                r = random();
                p = getpow(self, ITE);

                if ((ITE == IT_GRENADE_LAUNCHER) || (ITE == IT_ROCKET_LAUNCHER))
                   {
                        // 3 e MAX = +2
                        // 1 e 2   = +1
                        if (p >= 2) p2 = 2; else p2 = 1;
                   }
                else
                    {
                        // 1 = +1
                        // 2 = +2
                        // 3 = 50%+2, 50%+3
                        // MAX = 25%+2, 50%+3, 25%+4
                        if (p < 2)
                           p2 = p + 1;
                        else if (p == 2)
                             {
                                if (r < 0.5) p2 = 2;
                                   else      p2 = 3;
                             }
                        else // max
                             {
                                if (r < 0.25) p2 = 2; else
                                if (r < 0.75) p2 = 3;
                                   else       p2 = 4;
                             }
                    }
                Throw_Weapon(ITE, p2);
           }
};


void() DropBackpack =
{
	local entity	item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item = spawn();
	item.origin = self.origin - '0 0 24';
    item.classname = "item_backpack";    // ELOHIM_MOD
	
        // MODIFICADO V2.05
        // jogador joga "todas" as armas que possui
        Throw_Quant_Upgrades (IT_SUPER_SHOTGUN);  // v2.063 organizado
        Throw_Quant_Upgrades (IT_NAILGUN);
        Throw_Quant_Upgrades (IT_SUPER_NAILGUN);
        Throw_Quant_Upgrades (IT_GRENADE_LAUNCHER);
        Throw_Quant_Upgrades (IT_ROCKET_LAUNCHER);
        Throw_Quant_Upgrades (IT_LIGHTNING);

	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);

	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;

	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};
