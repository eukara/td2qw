void (entity client, float fragval) client_frag; // eluan
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;
void(entity inflictor, entity attacker, float damage, entity ignore, string dtype) T_RadiusDamage;

void() monster_death_use; // ELOHIM_MOD - no monsters in clan server

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
void(entity targ, entity attacker) Killed =
{
	local entity oself;

    //TD2.08 PATCH: respawner
    if (targ.classname == "player")
       targ.player_force_respawn = time + 20;

        // PATCH 2.06: amigo vale 1 fragz tambem!
        if (targ.classname == "td_temp")
        if (targ.magic == 13)
           {
                if (attacker.classname == "td_temp") // amigos, dogs, etc.
                   attacker = attacker.owner;

                if (attacker.classname == "player")
                if (attacker != targ.owner)
                {
			if (teamplay && attacker.qw_team != "none" && attacker.qw_team == targ.owner.qw_team)
			{
				bprint(attacker.netname);
				bprint(" matou o amigo de ");
				bprint(targ.owner.netname);
				bprint("!(\n");
			}
			else
			{
				bprint(attacker.netname);
				bprint(" matou o amigo de ");
				bprint(targ.owner.netname);
				bprint("! (+1 FRAG)\n");
				client_frag(attacker, 1); // bonus
			}
		}
           }

        // PATCH: dog vale 1 fragz
        if (targ.classname == "td_temp")
        if (targ.magic == 21)
           {
                if (attacker.classname == "td_temp") // amigos, dogs, etc.
                   attacker = attacker.owner;

                if (attacker.classname == "player")
                if (attacker != targ.owner)
                {
			if (teamplay && attacker.qw_team != "none" && attacker.qw_team == targ.owner.qw_team)
			{
				bprint(attacker.netname);
				bprint(" matou o cachorro de ");
				bprint(targ.owner.netname);
				bprint("!\n");
			}
			else
			{
				bprint(attacker.netname);
				bprint(" matou o cachorro de ");
				bprint(targ.owner.netname);
				bprint("! (+1 FRAG)\n");
				client_frag(attacker, 1); // bonus
			}
		}
           }

	oself = self;
	self = targ;

	if (self.health < -99)
		self.health = -99;		// don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}

	self.enemy = attacker;

	ClientObituary(self, attacker);

	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

        monster_death_use(); // ELOHIM_MOD - no monsters in clan server
	self.th_die ();

	self = oself;
};


/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage=
{
	local	vector	dir;
	local	entity	oldself;
	local	float	save;
	local	float	take;
	local   string  s;
	local   string  attackerteam, targteam;

	if (!targ.takedamage)
		return;

// team play damage avoidance
    // ELOHIM_MOD - nested the ifs
        if (damage != 666666)
    if (teamplay == 1 || (elohim_playmode & ELOHIM_MATCH_MODE))
    {
    	local entity a, b;
    	if (targ.classname == "player")
		a = targ;
	else
		a = targ.owner;
	if (attacker.classname == "player")
		b = attacker;
	else
		b = attacker.owner;
        if ((a != b) && (a.qw_team != "none") && (a.qw_team == b.qw_team) )
            return;
    }
    // END_MOD

        // PATCH:zumbi
        if (damage != 666666)
        if (targ.pow == -666)
           damage = 0;

        // PATCH - protecao MIRROR SHIELD
        if (targ.effects & EF_BRIGHTFIELD) // MIRROR
        if (targ.classname == "player")    // num player
        if (attacker.pow != -666)          // v2.06 ATACANTE != ZUMBI
           {
                if (attacker.classname != "player")  // um td_temp talvez..
                   {
                        attacker = attacker.owner;
                        // e, por seguranca...:
                        if (attacker.classname != "player")
                           return;
                   }

                if ((attacker.health <= 0) || (attacker.deadflag != DEAD_NO))
                   return;   // jah morreu...

                // PATCH: momentum pro cara do mirror tambem...
                // figure momentum add
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir*damage*8;

                // troca targ/attacker
                local entity temp;
                temp = attacker;
                attacker = targ;
                targ = temp;
           }

        // PATCH v2.07 -- amigos e dogs e wizards ficam 2x mais resistentes
        // se o dono tem a runa da resistencia!
        if (damage != 666666)
        if (targ.classname == "td_temp")
        if ((targ.magic == 13) || (targ.magic == 21) || (targ.magic == 226))
        if (runeof(targ.owner) == 2)
        {
                damage = damage / 2;
                damage = ceil (damage);
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
        }

        // PATCH - CABECA, fica 2x mais vulneravel
        //TD2.08 -- removido, ninguem usa essa magia assim
        //if (damage != 666666)
        //if (targ.size_z < 50)
        //   damage = damage * 2;

        // PATCH - RUNA 2 (ARMADURA)
        // toma soh 1/2 damage
        if (damage != 666666)
        if (runeof(targ) == 2)
           {
                damage = damage / 2;
                damage = ceil (damage);
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
           }
        // ENDPAT

    // ELOHIM_MOD - stats
    if (attacker.classname == "player" && targ != attacker)
    {
        if (targ.classname != "player" || attacker.qw_team != targ.qw_team || !teamplay)
        {
            if (inflictor == attacker)
            {
                if (attacker.weapon == IT_SHOTGUN || attacker.weapon == IT_SUPER_SHOTGUN)
                    attacker.dest2_x = attacker.dest2_x + damage;
                else if (attacker.weapon == IT_LIGHTNING)
                    attacker.dest2_z = attacker.dest2_z + damage;                    
            }
            else if (inflictor.classname == "missile")
                attacker.dest_y = attacker.dest_y + damage;
            else if (inflictor.classname == "spike")
                attacker.dest2_y = attacker.dest2_y + damage;
        }
    }                        
    // END_MOD

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

// check for quad damage powerup on the attacker
        if (damage != 666666)
	if ((attacker.super_damage_finished > time) && (inflictor.classname != "door"))
		damage = damage * 4;

// save damage based on the target's armor level

	save = ceil(targ.armortype*damage);
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;	// lost all armor
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}

	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage-save);

        // patch 2.07 - vampirismo armadura runa camo
        if (attacker.health > 0) // ta vivo ainda??
        if (attacker != targ) // nao vai dar steal de si mesmo!!
        if (attacker.classname == "player") // eh player?
        if (targ.classname == "player") // alvo eh player?
        if (runeof(attacker) == 1) // tem camo?
        if (save > 0) // dmgeou armadura de targ?
        {
            local float ma, bonus;
            ma = MaxArmorForType(attacker);
            bonus = ceil(0.30 * save); // 30% armor steal

            // se ja tinha armadura, soma aos pts
            if (attacker.armorvalue > 0)
            {
                attacker.armorvalue = attacker.armorvalue + bonus;
            }
            // senao, da uma armor green
            else
            {
                 // retira armor flags velhas
                 attacker.items = attacker.items - (attacker.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)); // ELUAN - TD 2.12 - bugfix 
                 // da green
                 attacker.items = attacker.items | IT_ARMOR1;
                 attacker.armortype = 0.3;
                 attacker.armorvalue = ceil(0.30 * save); // 30% armor steal
            }

            // nao deixa exceder os pts de armadura
            if (attacker.armorvalue > ma)
               attacker.armorvalue = ma;
        }


// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	damage_inflictor = inflictor;

// figure momentum add
	if ((targ.flags & FL_FLY) && (targ.classname == "player"))
      targ.movetype = MOVETYPE_WALK;

	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		// Set kickback for smaller weapons
//Zoid -- use normal NQ kickback
//		// Read: only if it's not yourself doing the damage
//		if ( (damage < 60) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname != targ.netname)) 
//			targ.velocity = targ.velocity + dir * damage * 11;
//		else                        
		// Otherwise, these rules apply to rockets and grenades                        
		// for blast velocity
		targ.velocity = targ.velocity + dir*damage*8;
		
		// Rocket Jump modifiers
		if ( (rj > 1) & ((attacker.classname == "player") & (targ.classname == "player")) & ( attacker.netname == targ.netname)) 
			targ.velocity = targ.velocity + dir * damage * rj;

	}

    // ELOHIM_MOD - print info for practice mode; check for pre-match
    if (elohim_playmode & ELOHIM_PRACTICE_MODE)
    {
        if (targ.classname == "player" && attacker.classname == "player"
            && targ != attacker)
        {
            local string tempp;
            tempp = ftos(damage);
            centerprint4(attacker, targ.netname, ": ", tempp, "\n\n\n\n\n\n\n\n");
        }
    }
    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
        if (!(elohim_state & ELOHIM_MATCH_STARTED))
            return;
    }
    // END_MOD

// check for godmode or invincibility
        if (damage != 666666)
	if (targ.flags & FL_GODMODE)
		return;

        if (damage != 666666)
	if (targ.invincible_finished >= time)
	{
		if (self.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			self.invincible_sound = time + 2;
		}
		return;
	}

// do the damage
        if (damage == 666666)
           targ.health = -10;
        else
	        targ.health = targ.health - take;

    // patch v2.07 -- runa camo life steal
    if (attacker.health > 0) // ta vivo ainda??
    if (attacker != targ) // nao vai dar steal de si mesmo!!
    if (attacker.classname == "player") // atacante eh player?
    if (targ.classname == "player") // alvo eh player?
    if (runeof(attacker) == 1) // tem camo?
    {
        // calcula bonus
        local float bonus;
        if (targ.health > 0)
           bonus = take;
        else
           bonus = take + targ.health; // tira fora o health negativo

        // da 30% life steal
        attacker.health = attacker.health + (0.30 * bonus);

        // nao deixa passar de 250
        if (attacker.health > 250)
           attacker.health = 250;
    }


	if (targ.health <= 0)
	{
        // ELOHIM_MOD - print info for practice mode
        if (elohim_playmode & ELOHIM_PRACTICE_MODE)
        {
            if (targ.classname == "player" && attacker.classname == "player"
                && targ != attacker)
            {
                local string temppp;
                temppp = ftos(attacker.health);
                centerprint5(targ, "\n\n\n\n", attacker.netname, " has ", temppp, " health");
                sprint5(targ, "\n\n\n\n", attacker.netname, " has ", temppp, " health\n");
            }
        }
        // END_MOD

		Killed (targ, attacker);
		return;
	}

// react to the damage
	oldself = self;
	self = targ;

        // PATCH: monstros removidos
        // RE-PATCH: v2.03 nem todos.. tem o doggie! magia21
    // ELOHIM_MOD - no monsters in server
    /*
	if ( (self.flags & FL_MONSTER) && attacker != world)
	{
	// get mad unless of the same class (except for soldiers)
		if (self != attacker && attacker != self.enemy)
		{
			if ( (self.classname != attacker.classname) 
			|| (self.classname == "monster_army" ) )
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget ();
			}
		}
	}
    */
    // END_MOD

	if ( (self.flags & FL_MONSTER) && attacker != world)
    {
	// get mad unless of the same class (except for soldiers)
		if (self != attacker && attacker != self.enemy && attacker != self.owner)
		{
            //TD2.08: nao fica brabo com quem possui o mesmo dono
            if ((attacker.owner == self.owner) && (attacker.owner.classname == "player"))
            {
                self.health = self.health + 1;
                self.health = self.health - 1;
            }
			else if ((teamplay) && (self.owner.qw_team != "none") && ((attacker.classname == "player" && self.qw_team == attacker.qw_team) || (attacker.classname != "player" && self.owner.qw_team == attacker.owner.qw_team)))
            {
                self.health = self.health + 1;
                self.health = self.health - 1;
            }
            else {
                 if (self.enemy.classname == "player")
		            self.oldenemy = self.enemy;
			     self.enemy = attacker;
			     FoundTarget ();
            }
		}
	}

	if (self.th_pain)
	{
		self.th_pain (attacker, take);

        // ELOHIM_MOD - unused
	// nightmare mode monsters don't go into pain frames often
		if (skill == 3)
			self.pain_finished = time + 5;
        // END_MOD
	}

	self = oldself;
};


/*
============
PATCH - pra flamegun
T_FlameRadiusDamage
============
*/
void(entity inflictor, entity attacker, float radius, float damage, entity ignore) T_FlameRadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, radius);

	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = vlen (inflictor.origin - org);

                                // dentro do alcance radius,
                                // causa de damage*0.5 ate damage*1
                                // pontos de dano
                                points = radius - (points / 2);
                                points = points / radius;

                                points = points * damage;
				if (points < 0)
				   points = 0;
				if (head == attacker)
				   points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{	// shambler takes half damage from all explosions
						if (head.classname == "monster_shambler")
                                                   points = points * 0.5;

						T_Damage (head, inflictor, attacker, points);

                                                // PATCH: incendeia!
                                                if (radius >= 250)
                                                if (points >= 50)
                                                if (head.health > 0)
                                                   {
                                                        ceprint(head, "Voce esta' pegando\nфого!\n\n\n\nProcure Agua!", 5, 3);

                                                        head.items = head.items | IT_BURNING; // voce esta pegando fogo
                                                        head.goalentity = attacker; // o cara que te acendeu
                                                   }
					}
				}
			}
		}
		head = head.chain;
	}
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore, string dtype) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
                // ELOHIM_MOD - this has been optimized
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
                if (points < damage)
                {
                    points = damage - points;
                    if (head == attacker)
                        points = points * 0.5;
					if (CanDamage (head, inflictor))
					{
						head.deathtype = dtype;
                        T_Damage (head, inflictor, attacker, points);
				}
				}
                // END_MOD
			}
		}
		head = head.chain;
	}
};

/*
============
T_BeamDamage
============
*/
// ELOHIM_MOD - unused
/*
void(entity attacker, float damage) T_BeamDamage =
{
	local	float 	points;
	local	entity	head;
	
	head = findradius(attacker.origin, damage+40);
	
	while (head)
	{
		if (head.takedamage)
		{
			points = 0.5*vlen (attacker.origin - head.origin);
			if (points < 0)
				points = 0;
			points = damage - points;
			if (head == attacker)
				points = points * 0.5;
			if (points > 0)
			{
				if (CanDamage (head, attacker))
						T_Damage (head, attacker, attacker, points);
				}
			}
		head = head.chain;
	}
};
*/
// END_MOD

