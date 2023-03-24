void() GrenadeTouch;
void() GrenadeExplode;
void(vector org, float damage, float timed) makeboom;
void(entity inflictor, entity attacker, float radius, float damage, entity ignore) T_FlameRadiusDamage;
void (vector direcao_do_caralho) spawn_dog;

entity cometa;  // p/ magia 20

void(vector org, float damage) SpawnBlood;
void(vector org) spawn_tfog;
void(vector org, entity death_owner) spawn_tdeath;
void() GrenadeExplode;
void(entity inflictor, entity attacker, float damage, entity ignore, string dtype) T_RadiusDamage;

//
//  MAGIC.QC -- poderes do machado (antigo w_fireaxe)
//

//
//  MagicOf() --> funcao para saber qual a magica do jogador
//     NAO USAR self.magic pois essa variavel tem outras coisas
//     dentro
//
float() selfmagic =
{
        return self.magic & 127;
};

// mstateof() --> retorna o estado da magica (boolean)
float() mstate =
{
        if ((self.magic & 128) == 0) return 0;
        return 1;
};
void() mstateoff =
{
        self.magic = self.magic - (self.magic & 128);
};
void() mstateon =
{
        self.magic = self.magic | 128;
};

//
// MAGIA 12 - TELEPORT
//
void() player_run;
void() Magic_Teleport =
{
        self.owner.flags = self.owner.flags - (self.owner.flags & FL_ONGROUND);
        self.owner.attack_finished = time + 0.4;

        setorigin (self.owner, self.origin);

        self.owner.think = player_run;
        self.owner.nextthink = time;

        remove(self);
};
//
// FIM MAGIA 12 - TELEPORT
//

//
// MAGIA 13 - AMIGO
//
void(float f1, float f2) anima =
{
        if (self.frame < f1) self.frame = f1;
        else if (self.frame > f2) self.frame = f1;      // ajusta se fora da animacao
        else self.frame = self.frame + 1;         // anima

        if (self.frame > f2) self.frame = f1;   // frame loop
};

void() DeathSound;
void() player_die_ax1;
void() player_diea1;
void() player_dieb1;
void() player_diec1;
void() player_died1;
void() player_diee1;
void(string gibname, float dm) ThrowGib;

void() Amigo_Die =
{
        // amigo: aargghhhhh!!
        sound (self, CHAN_AUTO, "misc/talk.wav", 1, ATTN_NONE);
        bprint("Áíéçïº ááááòçççèèèèè¡\n");

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

        if (self.health < -40)
           {
	        ThrowGib ("progs/h_player.mdl", self.health);
	        ThrowGib ("progs/gib1.mdl", self.health);
	        ThrowGib ("progs/gib2.mdl", self.health);
	        ThrowGib ("progs/gib3.mdl", self.health);

	        if (random() < 0.5)
		   sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	        else
		    sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);

                remove(self);
                return;
           }

	DeathSound();

	self.angles_x = 0;
        self.angles_z = 0;

	if (self.weapon == IT_AXE) { player_die_ax1 (); return; }

        local float i;
	i = random() * 5;
	if (i < 1) player_diea1();
	else if (i < 2) player_dieb1();
	else if (i < 3) player_diec1();
	else if (i < 4) player_died1();
	else player_diee1();
};

void() Amigo_MissileTouch =
{
	if (other == self.owner) return; // don't explode no PLAYER(OWNER)
        if (other == self.goalentity) return; // don't explode no AMIGO

	if (pointcontents(self.origin) == CONTENT_SKY) { remove(self); return; }

        if (other.health)
           {
                T_Damage (other, self, self.goalentity, self.health);
                // PATCH 2.04 attacker=amigo, conserta msg
           }

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.goalentity, self.health, other, "amigo");
        // PATCH 2.04 attacker=amigo, conserta msg

	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
        multicast (self.origin, MULTICAST_PHS);

	BecomeExplosion ();
};

void() Amigo_GetEnemy =
{
        local entity targ;

        targ = findradius (self.origin, 1000);

        while (targ)
         {
                if (targ.takedamage == DAMAGE_AIM)
                if (targ.health > 0)
                if (targ != self)
                if (targ != self.owner)
                if (targ.owner != self.owner) // v2.06: amigos do mesmo dono nao se matam mais
                if (!(targ.effects & EF_BRIGHTFIELD))   // v2.07: amigos nao atiram em gente com mirror (de proposito pelo menos)
		if (!teamplay || (teamplay && self.owner.qw_team != "none" && ((targ.classname == "player" && targ.qw_team != self.owner.qw_team) || (targ.classname != "player" && targ.owner.qw_team != self.owner.qw_team))))
		if (targ.classname != "player" || (targ.classname == "player" && !(targ.style & ELOHIM_OBSERVER)))
                   {
                        traceline(self.origin, targ.origin + '0 0 16', FALSE, self);

                        if (trace_ent == targ)
                           {
                                self.enemy = targ;
                                return;
                           }
                   }

                targ = targ.chain;
         }
};

void() Amigo_Think =
{
        // morreu o dono
        // PATCH TD 2.07 Spinal 22/07/2001 -- amigo fica quando dono morre
        //
        /*
        if (self.owner.health <= 0)
           {
                T_Damage(self, self, self, 50000);
                return;
           }
        */

        self.nextthink = time + 0.1;

        if (self.ltime < time)
           {
                // amigo: bye bye...
                sound (self, CHAN_AUTO, "misc/talk.wav", 1, ATTN_NONE);
                bprint("Áíéçïº âùå âùå®®®\n");

                bprint("AMIGO do ");
                bprint(self.owner.netname);
                bprint(" removido\n");

                sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);

                remove(self);
           }

        if (self.enemy == world)
           {
                anima (12, 16);

                if (self.yaw_speed < time)
                   {
                        Amigo_GetEnemy ();

                        if (self.enemy != world)
                           {
                                if (self.enemy.classname == "player")
                                   {
                                        sound (self, CHAN_AUTO, "misc/talk.wav", 1, ATTN_NONE);
                                        bprint("Áíéçïº áôáãáîäï ");
                                        bprint(self.enemy.netname);
                                        bprint("¡\n");
                                   }
                           }

                        self.yaw_speed = time + 0.3;
                   }
           }

        if (self.enemy != world)
           {
                if ((self.enemy.health <= 0) || (self.enemy.deadflag != DEAD_NO))
                   {
                        sound (self, CHAN_AUTO, "misc/talk.wav", 1, ATTN_NONE);
                        bprint("Áíéçïº Áìöï åøôåòíéîáäï¡\n");
                        self.enemy = world;
                        return;
                   }

                if (self.yaw_speed < time)
                   {
                        traceline(self.origin + '0 0 16', self.enemy.origin + '0 0 16', FALSE, self);

                        if ((trace_ent != self.enemy) && (self.enemy != self.owner))
                           {
                                local float r;
                                r = random();

                                // perdi o alvo de vista
                                sound (self, CHAN_AUTO, "misc/talk.wav", 1, ATTN_NONE);
                                if (r < 0.25)
                                   bprint("Áíéçïº Äåóçòáãáäï¬ öïìôá áñõé¡\n");
                                else if (r < 0.5)
                                     bprint("Áíéçïº Ðåòäé åìå äå öéóôá¡\n");
                                else if (r < 0.75)
                                     bprint("Áíéçïº Æõêáï¡\n");
                                else
                                    bprint("Áíéçïº Ãáçáìèáï¡ Öïìôá áñõé¡\n");

                                self.enemy = world;
                                return;
                           }
                        else
                            self.yaw_speed = time + 0.5;
                   }

                local vector dir;

                dir = self.enemy.origin - self.origin;
                self.angles = vectoangles(dir);

                anima (107, 112);

                if (self.frame == 107)
                //TD2.08: amigo suspende ataque quando inimigo ativa mirror
                if (self.enemy.effects & EF_BRIGHTFIELD) {
                   self.enemy = world;
                }
                else
                   {
	                local	entity missile;

	                sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

                        //TD
	                //self.punchangle_x = -2;
                        //msg_entity = self;
                        //WriteByte (MSG_ONE, SVC_SMALLKICK);

	                missile = spawn ();

                        // ignora estes
	                missile.owner = self.owner;  // owner = player
                        missile.goalentity = self;   // goalentity = amigo

	                missile.movetype = MOVETYPE_FLYMISSILE;
	                missile.solid = SOLID_BBOX;
	                missile.classname = "missile";

                        // set missile speed

	                missile.velocity = normalize(dir) * 700;
                        missile.angles = vectoangles(missile.velocity);
                        missile.health = 120 + random() * 20; // Eluan - TD 2.12 - dobra o dano do amigo
	                missile.touch = Amigo_MissileTouch;

                        // set missile duration
	                missile.nextthink = time + 5;
	                missile.think = SUB_Remove;

	                setmodel (missile, "progs/missile.mdl");
	                setsize (missile, '0 0 0', '0 0 0');
	                setorigin (missile, self.origin + v_forward*8 + '0 0 16');
                   }
           }
};

//
// FIM MAGIA 13 - AMIGO
//


//
// MAGIA 15 - BOMBA DE LUZ
//
void()   Executa_Clarao =
{
        local   string  g;

        if (self.owner.health <= 0)
           {
                stuffcmd(self.owner, "gamma 0.8\n");
                self.effects = self.effects - (self.effects & (EF_BRIGHTLIGHT | EF_DIMLIGHT));
                self.think = SUB_Remove;
                self.nextthink = time + 0.1;
                return;
           }

        self.health = self.health + 0.02;

        stuffcmd(self.owner, "gamma ");

        if (self.health < 0)
           { g = "0"; self.owner.effects = self.owner.effects | EF_BRIGHTLIGHT; }
        else if (self.health <= 0.02)
           { g = "0.02"; self.owner.effects = self.owner.effects | EF_BRIGHTLIGHT; }
        else if (self.health <= 0.04)
           { g = "0.04"; self.owner.effects = self.owner.effects | EF_BRIGHTLIGHT; }
        else if (self.health <= 0.06)
           { g = "0.06"; self.owner.effects = self.owner.effects | EF_BRIGHTLIGHT; }
        else if (self.health <= 0.08)
           { g = "0.08"; self.owner.effects = self.owner.effects | EF_BRIGHTLIGHT; }
        else if (self.health <= 0.10)
           { g = "0.1"; self.owner.effects = self.owner.effects | EF_BRIGHTLIGHT; }
        else if (self.health <= 0.12)
           { g = "0.12";
             self.owner.effects = self.owner.effects - (self.owner.effects & EF_BRIGHTLIGHT);
             self.owner.effects = self.owner.effects | EF_DIMLIGHT;
           }
        else if (self.health <= 0.14)
           { g = "0.14"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.16)
           { g = "0.16"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.18)
           { g = "0.18"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.20)
           { g = "0.2"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.22)
           { g = "0.22"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.24)
           { g = "0.24"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.26)
           { g = "0.26"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.28)
           { g = "0.28"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.30)
           { g = "0.3"; self.owner.effects = self.owner.effects | EF_DIMLIGHT; }
        else if (self.health <= 0.32)
           { g = "0.32"; self.owner.effects = self.owner.effects - (self.owner.effects & EF_DIMLIGHT); }
        else if (self.health <= 0.34)
             g = "0.34";
        else if (self.health <= 0.36)
             g = "0.36";
        else if (self.health <= 0.38)
             g = "0.38";
        else if (self.health <= 0.40)
             g = "0.4";
        else
            {
                g = "0.5";
                self.effects = self.effects - (self.effects & (EF_BRIGHTLIGHT | EF_DIMLIGHT));
                self.think = SUB_Remove;
            }

        stuffcmd(self.owner, g);
        stuffcmd(self.owner, "\n");

        self.nextthink = time + 0.2;
};
//
// FIM MAGIA 15 - BOMBA DE LUZ
//


//
// MAGIA 19 - SUCKER BALL
//

void()muzzleflash;

void() Sucker_Suck =
{
        if (self.ltime < time)
           {
                self.health = 200;
                self.owner = self.goalentity; // REMENDO
                GrenadeExplode ();
                return;
           }

        if (self.frags < 525)
           self.frags = self.frags + 10;

        local entity e;

        e = findradius(self.origin, 400);

        while (e)
         {
                if (((e.classname == "player") && !(e.style & ELOHIM_OBSERVER)) ||
                   (e.classname == "missile") ||
                   (e.classname == "grenade") ||
                   (e.classname == "spike") ||
                   (e.classname == "gib") ||
                   (e.classname == "item_backpack") || // elohim classname
                   (e.classname == "rune") ||
                   (e.classname == "sw") ||  // ELUAN - TD2.12 - porque nao armas esp tambem?
                   ((e.classname == "td_temp") && (e.magic == 102)) || // pipebombs
                   ((e.classname == "td_temp") && (e.magic == 24))     // trappacks
                   )
                     {
                        traceline(self.origin, e.origin, FALSE, self);

                        if ((trace_ent == e) || (trace_fraction == 1.0))
                           {
                                e.flags = e.flags - (e.flags & FL_ONGROUND);

                                local vector vd;

                                vd = self.origin - e.origin;

                                // impedir stuck de itens
                                vd_x = vd_x + crandom() * 32;
                                vd_y = vd_y + crandom() * 32;
                                vd_z = vd_z + crandom() * 32;

                                vd = normalize (vd);
                                vd = vd * self.frags;

                                if (e.classname != "player")
                                   e.velocity = e.velocity + vd * (2 + random());  //random=impedir stuck de itens
                                else
                                   e.velocity = e.velocity + vd;
                           }
                     }

                e = e.chain;
         }

        //TD
        //self.effects = self.effects | EF_MUZZLEFLASH;
        muzzleflash();

        self.nextthink = time + 0.1;
};

void() Sucker_Start =
{
        self.think = Sucker_Suck;
        self.nextthink = time + 0.1;

        self.effects = self.effects | EF_BRIGHTLIGHT;

        self.ltime = time + 8;  // duracao da bola
        self.frags = 200;
};

//
// FIM MAGIA 19 - SUCKER BALL
//


//
// MAGIA 20 - COMETA
//

void() Cometa_Touch =
{
	local vector org;

	if (other == self.owner)
		return;		// don't explode on owner
		
	if (other.classname == "player" && (other.style & ELOHIM_OBSERVER))
		return;

        if ((elohim_playmode & ELOHIM_MATCH_MODE) && (other.qw_team == self.owner.qw_team))
           return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

        self.origin = self.origin - 8*normalize(self.velocity);
        org = self.origin;

	if (other.health)
	{
		SpawnBlood (org, self.health);
		T_Damage (other, self, self.owner, self.health);
	}

        T_FlameRadiusDamage(self, self.owner, self.max_health, self.health, other);

        // PATCH bugfix 2.03 - poe fogo no cara que toma direct hit
        // ignora o flameradius mas pega fogo igual
        if (other.classname == "player")
           {
                ceprint(other, "Voce esta' pegando\nÆÏÇÏ!\n\n\n\nProcure Agua!", 5, 3);
                other.items = other.items | IT_BURNING; // voce esta pegando fogo
                other.goalentity = self.owner; // o cara que te acendeu
           }

       WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
       WriteByte (MSG_MULTICAST, TE_EXPLOSION);
       WriteCoord (MSG_MULTICAST, self.origin_x);
       WriteCoord (MSG_MULTICAST, self.origin_y);
       WriteCoord (MSG_MULTICAST, self.origin_z);
        multicast (self.origin, MULTICAST_PHS);

        makeboom(self.origin + '0 40 0', 0, 0);
        makeboom(self.origin - '0 40 0', 0, 0);
        makeboom(self.origin + '40 0 0', 0, 0);
        makeboom(self.origin - '40 0 0', 0, 0);
        makeboom(self.origin + '0 0 40', 0, 0);
        makeboom(self.origin - '0 0 40', 0, 0);

        BecomeExplosion();
};

void(vector org) Cometa =
{
        cometa = spawn ();
	cometa.owner = self;
	cometa.movetype = MOVETYPE_FLYMISSILE;
	cometa.solid = SOLID_BBOX;
        cometa.velocity = v_forward * 700;
	cometa.angles = vectoangles(cometa.velocity);
        cometa.angles_x = cometa.angles_x + 90;
        cometa.frame = 1;
	cometa.touch = SUB_Remove;
	cometa.classname = "cometa";
	cometa.think = SUB_Remove;
	cometa.nextthink = time + 10;
        setmodel (cometa, "progs/flame2.mdl");
	setsize (cometa, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (cometa, org); // - v_forward * 1000
};

//
// FIM MAGIA 20 - COMETA
//



void() Aguarde =
{
        local string s;
        local float  ptime;
        sprint(self, "aguarde ");
        ptime = ceil(self.ltime - time);
        s = ftos(ptime);
        sprint(self, s);
        sprint(self, " seg...\n");
};

/*

void() Scan =
{
        makevectors (self.angles);

        local entity vi;

        vi = findradius (self.origin, 300);

        while (vi)
         {
        if ((vi.classname == "player") && !(vi.style & ELOHIM_OBSERVER))
           {
                //trace_ent = self.owner;

                //local string ss;
                //bprint(vi.owner.classname);
                //bprint("\n");
                //ss = ftos(trace_fraction);
                //bprint(ss);
                //bprint("\n");

                //makeboom(trace_endpos, 0, 0.1);

                traceline(self.origin, vi.origin, FALSE, self);

                if ((trace_ent == vi) || (trace_fraction == 1))
                 {
                local entity e;

                e = findradius (self.origin, 200);
                while (e)
                 {
                        if (e.classname == "td_temp")
                        if (e.magic == 21)
                           {
                                e.movetype = MOVETYPE_TOSS;
                                e.velocity = v_forward * (-32 + crandom() * 32);
                                e.health = 300;
                                e.touch = GrenadeExplode;
                                e.think = SUB_Null;
                           }
                        e = e.chain;
                 }
                return;
                }
           }
           vi = vi.chain;
        }

        self.nextthink = time + 0.5;
};

void() Fallbomb_Hookup =
{
        if (other != world)
           return;

        self.velocity = '0 0 0';
        self.avelocity = '0 0 20';
        self.angles = '270 0 0';

        setorigin(self, self.origin - '0 0 16');
        self.think = Scan;
        self.nextthink = time + 2;
};

void() W_FireMadGrenade =
{
	local	entity missile, mpuff;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.classname = "td_temp";
        missile.magic = 21;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;

	missile.owner = self;

	missile.velocity_x = crandom() * 8;
        missile.velocity_y = crandom() * 8;
        missile.velocity_z = 400;

	missile.angles = vectoangles(missile.velocity);

	missile.touch = Fallbomb_Hookup;
        missile.think = SUB_Null;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	makevectors (self.v_angle);
	setorigin (missile, self.origin);
};

void() box_explode =
{
        self.health = 100;
        self.think = GrenadeExplode;
        self.nextthink = time + 0.1 + random()*0.2;
};

void(vector pos) spawnbox =
{
        local entity box;

        box = spawn();
        box.classname = "explobox";
        box.owner = world; //self.owner;
        box.movetype = MOVETYPE_TOSS;
        box.solid = SOLID_BBOX;

        //box.velocity = '0 0 0';
        //box.avelocity = '0 0 24';
        //box.angles = '0 0 0';

	box.th_die = box_explode;
	box.takedamage = DAMAGE_AIM;

        box.health = 60;
        box.think =  box_explode;
        box.nextthink = time + 6;

        setmodel (box, "maps/b_explob.bsp");
        setorigin (box, pos - '16 16 0');
};

void(entity player) gaiola_engaiola =
{
        spawnbox(player.origin + '-48 -48 32');
        spawnbox(player.origin + '48 -48 32');
        spawnbox(player.origin + '-48 48 32');
        spawnbox(player.origin + '48 48 32');

        spawnbox(player.origin + '48 0 32');
        spawnbox(player.origin + '-48 0 32');
        spawnbox(player.origin + '0 48 32');
        spawnbox(player.origin + '0 -48 32');

        spawnbox(player.origin + '0 0 80');
};

void() gaiola_scan =
{
        local entity e;

        e = findradius (self.origin, 64);

        while (e)
         {
              if ((e.classname == "player") && !(e.style & ELOHIM_OBSERVER))
                 {
                        gaiola_engaiola(e);
                        remove(self);
                        return;
                 }
              e = e.chain;
         }

        self.nextthink = time + 0.3;
};

*/

// MAGIA 23 - NUKE BOX
void() box_explode_explode =
{
        self.origin = self.origin + '0 0 48';
        self.health = 800;
        GrenadeExplode();
};

void() box_explode =
{
        //setorigin(self, self.origin + '0 0 4');
        self.flags = self.flags - (self.flags & FL_ONGROUND);
        self.velocity = '0 0 450';

        self.think = box_explode_explode;

        self.nextthink = time + 1;
};

//
// MAGIA 24 - TRAP PACKS
//
void() W_SetCurrentAmmo; // conserta visor de currentammo se ele tiver mostrando rockets

void() trapack_explode =
{
        // ATTACKER = self
        // assim no obituary pode mostrar a mensagem certa
	T_RadiusDamage (self, self, 300, world, "minas");

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
        multicast (self.origin, MULTICAST_PHS);
	BecomeExplosion ();
};

void() trapack_die =
{
        self.think = trapack_explode;
        self.nextthink = time + random() * 0.3;
};

void() trapack_touch =
{
        if (other.classname != "player" || (other.classname == "player" && (other.style & ELOHIM_OBSERVER)))
           return;
        if ((elohim_playmode & ELOHIM_MATCH_MODE) && (other.qw_team == self.owner.qw_team))
           return;

        self.think = trapack_explode;
        self.nextthink = time + 0.1;
};

//
// FIM MAGIA 24 - TRAP PACKS
//

//
//
//   W_FireMagic ();
//
//    DISPARA MAGIAS
//
//

void() W_FireMagic =
{
        self.statustime = 0;  // bug chato

        local float mag;
        mag = selfmagic();

        //
        //  10 -- 666 10 segundos
        //  adiciona os 10 segundos se ja tiver 666zado
        //
        if (mag == 10)       // 666 - 10s - 40s
             {
                if (self.ltime < time)
                   {
                        ccenterprint(self, "666 ATiVaDo! - 10 segundos", 0);

                        self.ltime = time + 40;

                        sound (self, CHAN_VOICE, "items/protect.wav", 1, ATTN_NORM);

                        if (self.items & IT_INVULNERABILITY) // ja tinha, adiciona 10s
                           self.invincible_finished = self.invincible_finished + 10;
                        else
                           {
                                self.items = self.items | IT_INVULNERABILITY;
		                self.invincible_time = 1;
		                self.invincible_finished = time + 10;
                           }
                   }
                else
                    Aguarde();
             }
        //
        //  11 -- Quad Damage +10s
        //  soma 10s ao quad se ja tiver
        //
        else if (mag == 11)       // Quad - 10s - 40s
             {
                if (self.ltime < time)
                   {
                        ccenterprint(self, "Quad Damage ATiVaDo! - 10 segundos", 0);

                        self.ltime = time + 40;

                        sound (self, CHAN_VOICE, "items/damage.wav", 1, ATTN_NORM);

                        if (self.items & IT_QUAD) // ja tinha, adiciona 10s
                           self.super_damage_finished = self.super_damage_finished + 10;
                        else
                           {
                               self.items = self.items | IT_QUAD;
		               self.super_time = 1;
		               self.super_damage_finished = time + 10;
                           }
                   }
                else
                    Aguarde();
             }
        //
        //  12 -- Teleporter
        //
        else if (mag == 12)
             {
                if (mstate() == 0)
                   {
                        ccenterprint(self, "Teleporter Colocado!", 0);

                        mstateon();

                        // salva posicao
                        self.televec = self.origin;
                        self.attack_finished = time + 0.4;
                        spawn_tfog (self.origin);
                   }
                else
                    {
                        ccenterprint(self, "ZAP!", 0);

                        mstateoff();

                        // procura telepoint
                        spawn_tfog (self.origin);
                        spawn_tfog (self.televec);
                        spawn_tdeath (self.televec, self);

                        local entity telepoint;
                        telepoint = spawn();
                        telepoint.owner = self;
                        setorigin(telepoint, self.televec);
                        telepoint.think = Magic_Teleport;
                        telepoint.nextthink = time + 0.1;
                    }
             }
        //
        //  13 -- Amigo
        //
        else if (mag == 13)
             {
                if (self.ltime < time)
                   {
                        bprint("AMIGO criado por ");
                        bprint(self.netname);
                        bprint("!\n");

                        spawn_tfog (self.origin);

                        self.ltime = time + 60;
                        sound (self, CHAN_VOICE, "dog/dattack1.wav", 1, ATTN_NORM);

                        // amigo: hehehe...
                        sound (self, CHAN_AUTO, "misc/talk.wav", 1, ATTN_NONE);
                        bprint("Áíéçïº èåèåèå®®®\n");

                        local entity amigo;

                        amigo = spawn();
                        amigo.classname = "td_temp";
                        amigo.magic = 13;

                        amigo.owner = self;
                        amigo.enemy = world;  // tem q scanear

	                amigo.takedamage = DAMAGE_AIM;
	                amigo.solid = SOLID_BBOX;
	                amigo.movetype = MOVETYPE_BOUNCE;

                        amigo.angles = self.angles;

                        // spinal patch 2.07 - amigo dura o dobro com runa regen
                        amigo.ltime = time + 18000;  // 3 minutos no TD e mais no tdx
                        if (runeof(self) == 4)
                           amigo.ltime = amigo.ltime + 18000;  // +3 minutos se dono tem runa regen e varias horas no tdx

                        amigo.yaw_speed = 0;

                        amigo.think = Amigo_Think;
                        amigo.nextthink = time + 0.1;

                        // spinal -- PATCH 2.07 - amigos regeneram com runa do dono
                        amigo.max_health = 600; //400 no td e 600 no tdx
                        amigo.health = amigo.max_health;

                        amigo.armorvalue = 0;
                        amigo.th_pain = SUB_Null; // PATCH FIXME Amigo_Pain; // aha!!
	                amigo.th_die = Amigo_Die;

	                setmodel (amigo, "progs/player.mdl");
                        amigo.frame = 12;
                        amigo.colormap = self.colormap;
	                setsize (amigo, VEC_HULL_MIN, VEC_HULL_MAX);
                        setorigin (amigo, self.origin);
                   }
                else
                    Aguarde();
                }
        //
        //  14 -- Disfarce
        //
        else if (mag == 14)   // cabeca
             {
                if (mstate() == 0)
                   {
                        ccenterprint(self, "Disfarce ATIVADO!", 0);

                        mstateon();
                        self.attack_finished = time + 1;

                        stuffcmd (self, "bf\n");

                        // Compativel c/ invisibilidade :)
                        if (self.invisible_finished > time)
                           self.modelindex = model_eyes;
                        else
                           self.modelindex = model_head;

	                setsize (self, '-16 -16 0', '16 16 32');
                   }
                else
                    {
                        ccenterprint(self, "Disfarce DESATIVADO!", 0);

                        mstateoff();
                        self.attack_finished = time + 1;

                        stuffcmd (self, "bf\n");

                        // Compativel c/ invisibilidade :)
                        if (self.invisible_finished > time)
                           self.modelindex = model_eyes;
                        else
                           self.modelindex = model_player;

                        setorigin (self, self.origin + '0 0 32');
                        setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
                    }
             }
        //
        //  15 -- Bomba de Luz
        //
		// TODO: not teammates
        else if (mag == 15)
             {
                if (self.ltime < time)
                   {
                        self.ltime = time + 30;

                        local   entity  vitima, cegador;
                        local   vector  dist;
                        local   float   poww;

                        // explosao de pontinhos e o "bum" (igual `a granada)
                        //
	                WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	                WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	                WriteCoord (MSG_MULTICAST, self.origin_x);
	                WriteCoord (MSG_MULTICAST, self.origin_y);
                        WriteCoord (MSG_MULTICAST, self.origin_z);
                        multicast (self.origin, MULTICAST_PHS);

                        // cega e manda longe os jogadores que estao por perto
                        // (modifique a variavel BL_Radius para obter um raio maior

                        vitima = findradius(self.origin, 600);

                        while (vitima)
                         {
                                if (vitima.classname == "player" && !(vitima.style & ELOHIM_OBSERVER))
                                if (vitima.health > 0)
                                   {
                                        traceline(self.origin, vitima.origin + '0 0 22', TRUE, self);

                                        if (trace_fraction == 1.0)
                                        // se ha linha de visao...
                                           {
                                                local entity luz;

                                                luz = spawn();
                                                stuffcmd(vitima, "gamma 0.15\n");

                                                luz.owner = vitima;

                                                luz.classname = "td_temp";
                                                luz.magic = 15; // luz id

                                                dist = vitima.origin - self.origin;
                                                poww = vlen(dist);
                                                poww = (600 - poww) / 600;
                                                poww = poww * -0.6;
                                                poww = poww + 0.1;

                                                if (poww < -0.3)
                                                   poww = -0.3;

                                                if (vitima == self)
                                                   poww = 0.15;

                                                luz.health = poww;

                                                luz.nextthink = time + 0.1;
                                                luz.think = Executa_Clarao;
                                                luz.owner = vitima;
                                           }
                                   }
                                vitima = vitima.chain;  // procura a proxima vitima
                         }
                   }
                else
                    Aguarde();
             }
        //
        //  16 -- Ring of Shadows 30 segundos
        //  adiciona 30 segundos se ja tiver ringado
        //
        else if (mag == 16)       // invis - 30s - 60s
             {
                if (self.ltime < time)
                   {
                        ccenterprint(self, "Ring of Shadows! - 30 segundos", 0);

                        self.ltime = time + 60;

                        sound (self, CHAN_VOICE, "items/inv1.wav", 1, ATTN_NORM);

                        if (self.invisible_finished > time) // ja tinha, adiciona 30s
                           self.invisible_finished = self.invisible_finished + 30;
                        else
                           {
                                self.items = self.items | IT_INVISIBILITY;
		                self.invisible_time = 1;
		                self.invisible_finished = time + 30;

                                self.frame = 0;
                                if (self.modelindex != model_null)
                                   self.modelindex = model_eyes;
                           }
                   }
                else
                    Aguarde();
             }
        //
        //  17 -- LEVITAR
        //   fixed v2.03
        //
        else if (mag == 17)
             {
                if (mstate() == 0)
                   {
                        ccenterprint(self, "Levitacao ATIVADA!", 0);
                        mstateon();
                   }
                else
                    {
                        ccenterprint(self, "Levitacao DESATIVADA!", 0);
                        mstateoff();
                    }
                self.attack_finished = time + 0.5;
                stuffcmd (self, "bf\n");
             }
        //
        //  18 -- Mirror Shield
        //
        else if (mag == 18)
             {
                if (self.ltime < time)
                   {
                        ccenterprint(self, "ESPELHO PROTETOR! - 10 segundos", 0);
                        self.ltime = time + 30;
                        sound (self, CHAN_VOICE, "items/protect3.wav", 1, ATTN_NORM);
                        self.effects = self.effects | EF_BRIGHTLIGHT;
                   }
                else
                    Aguarde();
             }
        //
        //  19 -- SUCKER BALL
        //
        else if (mag == 19)
             {
                if (self.ltime < time)
                   {
                        ccenterprint(self, "SuckerBall colocada... CORRE!!!", 0);

                        self.ltime = time + 30;

                        sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);

                        // poe a meleka
                        local entity bola;

                        bola = spawn();

                        // REMENDO - p/ traceline depois
                        bola.owner = bola;
                        bola.goalentity = self;

                        bola.classname = "td_temp";
                        bola.magic = 19;

                        bola.movetype = MOVETYPE_NONE;
                        bola.solid = SOLID_NOT;

                        bola.think = Sucker_Start;
                        bola.nextthink = time + 2.5;

                        setmodel(bola, "progs/s_light.spr");
                        setsize(bola, '0 0 0', '0 0 0');
                        setorigin(bola, self.origin);
                   }
                else
                    Aguarde();
             }
        //
        //  20 -- COMETA FIREBALL
        //
        else if (mag == 20)
             {
                if (self.ltime < time)
                   {
                        self.ltime = time + 10;
                        sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

                        makevectors(self.v_angle);

                        Cometa(self.origin + v_forward * 52);
                        cometa.touch = Cometa_Touch;
                        cometa.health = 150;
                        cometa.max_health = 300;

                        Cometa(self.origin + v_forward * 50 + v_up * 4);
                        Cometa(self.origin + v_forward * 50 - v_up * 4);
                        Cometa(self.origin + v_forward * 50 + v_right * 4);
                        Cometa(self.origin + v_forward * 50 - v_right * 4);

                        Cometa(self.origin + v_forward * 40 + v_up * 5);
                        //Cometa(self.origin + v_forward * 40 - v_up * 5);
                        Cometa(self.origin + v_forward * 40 + v_right * 5);
                        Cometa(self.origin + v_forward * 40 - v_right * 5);

                        Cometa(self.origin + v_forward * 30 + v_up * 6);
                        Cometa(self.origin + v_forward * 30 - v_up * 6);
                        //Cometa(self.origin + v_forward * 30 + v_right * 6);
                        Cometa(self.origin + v_forward * 30 - v_right * 6);

                        //Cometa(self.origin + v_forward * 20 + v_up * 7);
                        Cometa(self.origin + v_forward * 20 - v_up * 7);
                        Cometa(self.origin + v_forward * 20 + v_right * 7);
                        //Cometa(self.origin + v_forward * 20 - v_right * 7);

                        Cometa(self.origin + v_forward * 10   + v_up * 8);
                        Cometa(self.origin + v_forward * 10   - v_up * 8);
                        Cometa(self.origin + v_forward * 10   + v_right * 8);
                        Cometa(self.origin + v_forward * 10   - v_right * 8);
                    }
                else
                    Aguarde();
             }
        //
        //  21 -- SUPER DOG
        //
        else if (mag == 21)
             {
                if (self.ltime < time)
                   {
                        bprint("DOBERMAN criado por ");
                        bprint(self.netname);
                        bprint("!\n");

                        spawn_tfog (self.origin);

                        self.ltime = time + 50;  //60 segundos por dog (dura ate 4) no TD e  30 segundos  por dog (dura ate 6) no TDx
                        sound (self, CHAN_VOICE, "dog/dattack1.wav", 1, ATTN_NORM);

                        //makevectors(self.v_angle);
                        spawn_dog(self.origin); // + v_forward * 300
                   }
                else
                    Aguarde();
                }
        //
        //  22 = Hook
        //
	if (mag == 22)
	{
		CheckGrapHook ();
		return;
	}
        //
        //  23 = bait nuke
        //
        else if (mag == 23)
             {
                if (self.ltime < time)
                   {
                        // verifica limite de 50 nukes
                        //
                        local entity e;
                        local float cont;
                        cont = 0;
                        e = find (world, classname, "td_temp");
                        while (e)
                         {
                                if (e.magic == 23)
                                if (e.owner == self)
                                   cont = cont + 1;
                                e = find (e, classname, "td_temp");
                         }
                         if (cont >= 50)
                            {
                                sprint(self, "Voce ja' colocou 50 Nukes!! Chega!\n");
                                return;
                            }

                         // bota nuke
                        ccenterprint(self, "NUKE colocada! - Sai de perto!", 0);

                        self.ltime = time + 30;

                        sound (self, CHAN_VOICE, "weapons/grenade.wav", 1, ATTN_NORM);

                        local entity box;

                        box = spawn();

                        box.classname = "td_temp";
                        box.magic = 23;

                        box.owner = self;
                        box.movetype = MOVETYPE_TOSS;
                        box.solid = SOLID_BBOX;

	                box.th_die = box_explode;
	                box.takedamage = DAMAGE_AIM;
                        box.health    = 18;
                        box.touch     = SUB_Null;
                        box.think     = SUB_Null;
                        setmodel (box, "maps/b_explob.bsp");
                        setorigin (box, self.origin - '16 16 0');
                   }
                else
                    Aguarde();
             }
        //
        // 24 - trap packs
        //
        else if (mag == 24)
             {
                if (self.ltime < time)
                   {
                        if (self.ammo_rockets >= 10)
                           {
                                self.ammo_rockets = self.ammo_rockets - 10;
                                if (self.items & IT_ROCKETS)
                                   W_SetCurrentAmmo (); // conserta visor de currentammo se ele tiver mostrando rockets
                                ccenterprint(self, "Backpack explosiva colocada!\n\n\nusados 10 rockets", 3);
                                self.ltime = time + 0.5;
                           }
                        else
                           {
                                ccenterprint(self, "Backpack explosiva colocada! (20s)\n\n\n", 3);
                                self.ltime = time + 20;
                           }

                        local entity box;

                        box = spawn();

                        box.classname = "td_temp";
                        box.magic = 24;

                        box.owner = self;
                        box.movetype = MOVETYPE_BOUNCE;
                        box.solid = SOLID_BBOX;

	                box.th_die     = trapack_die;
	                box.takedamage = DAMAGE_AIM;
                        box.health     = 1;
                        box.touch      = trapack_touch;
                        box.think      = SUB_Null;
                        setmodel (box, "progs/backpack.mdl");
                        setsize (box, '-16 -16 0', '16 16 56');
                        setorigin (box, self.origin);
                   }
                else
                    Aguarde();
             }
        //
        //  25 = fly
        //
	//matador - fly - start
	 if (mag == 25)
	 {
	      if (self.flags & FL_FLY)
	      {
		 ccenterprint (self, "Voar off",0);
		 self.flags = self.flags - FL_FLY;
	      }
	      else
	      {
		 ccenterprint (self,"Voar on",0);
		 self.flags = self.flags + FL_FLY;
	      }

		return;
	 }
	//matador - fly - end
};
