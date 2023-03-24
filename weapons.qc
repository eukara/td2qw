entity (vector v) spawn_hell_knight;
void () player_knight_axe; //player.qc
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore, string dtype) T_RadiusDamage;
void(vector org, float damage) SpawnBlood;
void() SuperDamageSound;

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

// PATCH

void() UUURRR_Sound =
{
        if (self.t_width < time)
           {
                sound (self, CHAN_AUTO, "boss1/sight1.wav", 1, ATTN_NORM);
                self.t_width = time + 1.6;
           }
};

// ENDPAT


// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun
	//matador
	precache_model ("progs/missile.mdl");
	precache_model ("progs/s_light.spr");
	precache_sound ("items/protect3.wav");
	precache_sound ("weapons/lhit.wav");
	precache_sound ("boss1/sight1.wav");
	precache_sound ("items/protect2.wav");
	precache_model ("progs/demon.mdl");
	precache_sound ("items/inv3.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("dog/dattack1.wav");

	precache_model ("progs/h_dog.mdl");
	precache_model ("progs/dog.mdl");

                // Tesla
                precache_model ("progs/g_light.mdl");
        // v2.06 VOTACAO
        // sons
	precache_sound ("doors/meduse.wav");
	precache_sound ("doors/runetry.wav");
	precache_sound ("doors/runeuse.wav");
	precache_sound ("doors/basetry.wav");

        //
        // THROWING KNIGHT magia 5
        //
	precache_model2 ("progs/hknight.mdl");
	precache_model2 ("progs/k_spike.mdl");
	precache_model2 ("progs/h_hellkn.mdl");


	precache_sound2 ("hknight/attack1.wav");
	precache_sound2 ("hknight/death1.wav");
	precache_sound2 ("hknight/pain1.wav");
	precache_sound2 ("hknight/sight1.wav");
	precache_sound ("hknight/hit.wav");		// used by C code, so don't sound2
	precache_sound2 ("hknight/slash1.wav");
	precache_sound2 ("hknight/idle.wav");
	precache_sound2 ("hknight/grunt.wav");

	precache_sound ("knight/sword1.wav");
	precache_sound ("knight/sword2.wav");

        //
        // WIZARD do virus magia 26
        //
	precache_model ("progs/wizard.mdl");
	precache_model ("progs/h_wizard.mdl");
	precache_model ("progs/w_spike.mdl");

	precache_sound ("wizard/hit.wav");		// used by c code
	precache_sound ("wizard/wattack.wav");
	precache_sound ("wizard/wdeath.wav");
	precache_sound ("wizard/widle1.wav");
	precache_sound ("wizard/widle2.wav");
	precache_sound ("wizard/wpain.wav");
	precache_sound ("wizard/wsight.wav");

        //
        // DOG magia 21
        //
	precache_model ("progs/h_dog.mdl");
	precache_model ("progs/dog.mdl");

	precache_sound ("dog/dattack1.wav"); // do amigo tb
	precache_sound ("dog/ddeath.wav");
	precache_sound ("dog/dpain1.wav");
	precache_sound ("dog/dsight.wav");
	precache_sound ("dog/idle.wav");
        //

        // explobox magia 22
	precache_model ("maps/b_explob.bsp");
	precache_sound ("weapons/r_exp3.wav");

        // ela mesmo ! a chama!
        precache_model ("progs/flame2.mdl");

        // zumbi mode
        precache_model ("progs/zombie.mdl");
	precache_sound ("zombie/z_idle.wav");
	precache_sound ("zombie/z_idle1.wav");
	precache_sound ("zombie/z_pain.wav");
	precache_sound ("zombie/z_pain1.wav");

        //precache_sound ("boss1/throw.wav");

        // magia FIEND
        precache_sound("demon/djump.wav");
        precache_model("progs/demon.mdl");

        // PATCH -- precache runas
        precache_model("progs/end1.mdl");

        // ground wpns
	precache_model ("progs/g_shot.mdl");
	precache_model ("progs/g_nail.mdl");
	precache_model ("progs/g_nail2.mdl");
	precache_model ("progs/g_rock.mdl");
	precache_model ("progs/g_rock2.mdl");

        // magiks
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");

        // urrr!!
        precache_sound ("boss1/sight1.wav");

        // bola amarela
        precache_model ("progs/s_light.spr");

        // explosao
        precache_model ("progs/s_explod.spr");

        // RUNA 4 - REGENERATION sound
        precache_sound("items/r_item2.wav");

        // END PATCH
        
        // hook
        precache_model ("progs/v_spike.mdl");
};

float() crandom =
{
	return 2*(random() - 0.5);
};

//
//
// ARMA ESPECIAL 1 - MORTEIRO
// SW_FireMorteiro
//
//
void() GrenadeExplode;
void(vector org, float damage, float timed) makeboom =
{
        local   entity  boom;
        boom = spawn();
        boom.owner = self.owner;
        boom.classname = "grenade";
        boom.health = damage;          // health=dano da granada requer GrenadeExplode modificado
        boom.think = GrenadeExplode;
        boom.nextthink = time + timed;
        setorigin(boom, org);
};
void() Morteiro_Touch =
{
        setorigin(self, self.origin + '0 0 24');

        makeboom(self.origin + '50 0 0', 140, 0.1);
        makeboom(self.origin + '-50 0 0', 130, 0.2);
        makeboom(self.origin + '0 50 0', 110, 0.1);
        makeboom(self.origin + '0 -50 0', 125, 0.2);

        makeboom(self.origin + '100 0 0', 70, 0.2);
        makeboom(self.origin + '-100 0 0', 75, 0.3);
        makeboom(self.origin + '0 100 0', 80, 0.4);
        makeboom(self.origin + '0 -100 0', 85, 0.3);

        makeboom(self.origin + '70 70 0', 80, 0.2);
        makeboom(self.origin + '-70 70 0', 65, 0.3);
        makeboom(self.origin + '-70 -70 0', 75, 0.4);
        makeboom(self.origin + '70 -70 0', 70, 0.3);

	T_RadiusDamage (self, self.owner, 180, world, "morteiro");

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
        multicast (self.origin, MULTICAST_PHS);

	BecomeExplosion ();
};
void() Morteiro_Think =
{
        self.angles = vectoangles(self.velocity);
        self.nextthink = time + 0.1;
};

void() SW_FireMorteiro =
{
    local float THRUST; //TD2.09

        self.attack_finished = time + 1;
    if (!(elohim_playmode & ELOHIM_PRACTICE_MODE))
        self.ammo_rockets = self.ammo_rockets - 3;
        self.currentammo = floor (self.ammo_rockets / 3);

	local	entity missile;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

                        //TD
	                msg_entity = self;
	                WriteByte (MSG_ONE, SVC_SMALLKICK);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_TOSS;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";

        // set missile speed

    //TD2.09: turbo morteiro = 2x dist
    if (runeof(self) == 3)
       THRUST = 1.20;
    else
       THRUST = 1;

	makevectors (self.v_angle);
        missile.velocity = v_forward*450 * THRUST + v_up * 250 * THRUST + crandom()*v_right*20 + crandom()*v_up*10;
        missile.velocity_z = missile.velocity_z + 100;
	missile.angles = vectoangles(missile.velocity);

	missile.touch = Morteiro_Touch;

	missile.nextthink = time + 0.1;
	missile.think = Morteiro_Think;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin);
};
//
// FIM SW1 - MORTEIRO
//

//
//
// ARMA ESPECIAL 2 - PIPEBOMB
// SW_FirePipebomb
//
//
void() AXE10_Bomb_Touch =
{
        sound (self, CHAN_WEAPON, "items/protect3.wav", 1, ATTN_NORM);	// bounce sound
};
void() SW_FirePipebomb =
{
        self.attack_finished = time + 1;

        local entity e;
        local float firenew, THRUST;

        firenew = 1;

        e = find(world, classname, "td_temp");
        while (e)
         {
                if (e.owner == self)
                if (e.magic == 102) // pipebomb id
                   {
                        // detona
                        e.health = 300;
                        e.think = GrenadeExplode;
                        e.nextthink = time + 0.1;
                        firenew = 0;
                   }
                e = find(e, classname, "td_temp");
         }

         if (firenew)
            {
                if (self.ammo_rockets < 5)
                   {
                        sprint(self, "Precisa de 5 rockets!\n");
                        return;
                   }
    if (!(elohim_playmode & ELOHIM_PRACTICE_MODE))
                self.ammo_rockets = self.ammo_rockets - 5;
                self.currentammo = floor(self.ammo_rockets / 5);

                //
                // dispara pipebomb
                //
	        sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);
                        //TD
	                msg_entity = self;
	                WriteByte (MSG_ONE, SVC_SMALLKICK);

                local entity pipebomb;

	        pipebomb = spawn ();
	        pipebomb.owner = self;
	        pipebomb.movetype = MOVETYPE_BOUNCE;
	        pipebomb.solid = SOLID_BBOX;
                pipebomb.touch = AXE10_Bomb_Touch;

	        pipebomb.classname = "td_temp";
                pipebomb.magic = 102;

	        makevectors (self.v_angle);

    //TD2.09: turbo pipe = 2x dist
    if (runeof(self) == 3)
       THRUST = 2.0;
    else
       THRUST = 1.0;


		pipebomb.velocity = v_forward * 300 * THRUST + v_up * 100 * THRUST + crandom()*v_right*20 + crandom()*v_up*20;


                // PATCH: temp1 +65536
                //TD2.08: PIPEHEADS e'padrao
                //if (config_PIPEHEADS > 0)
                //   {
                        if (random() < 0.5)
                           setmodel (pipebomb, "progs/backpack.mdl"); // bola
                        else
                            setmodel (pipebomb, "progs/h_player.mdl"); // bola
                //   }
                //else
	            //setmodel (pipebomb, "progs/s_light.spr"); // bola


	        setsize (pipebomb, '0 0 -12', '0 0 12');
	        setorigin (pipebomb, self.origin + '0 0 16');
           }
};
//
// FIM SW2 - PIPEBOMB
//

//
//
// ARMA ESPECIAL 3 - SMARTBOMBS
// SW_FireSmart
//
// OBS: Estes campos estao sendo usados pelas bombas:
// vector movedir    era magicvec
// float  health     era magicstate
// float  frags      era magictime
//

void() BecomeExplosion;
void() MegaOrb_HLV =
{
	T_RadiusDamage (self, self.owner, 100, world, "smartbomb");

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
        multicast (self.origin, MULTICAST_PHS);

	BecomeExplosion ();
};

vector(vector source, vector normal) R_Vector = {
        local vector reflection;
        reflection = source + 2 * normal;
        if (reflection_x > 1) reflection_x = 2 - reflection_x;
        if (reflection_x < -1) reflection_x = -2 - reflection_x;
        if (reflection_y > 1) reflection_y = 2 - reflection_y;
        if (reflection_y < -1) reflection_y = -2 - reflection_y;
        if (reflection_z > 1) reflection_z = 2 - reflection_z;
        if (reflection_z < -1) reflection_z = -2 - reflection_z;
        return reflection;
};

void() MegaOrb_Scan;
void() REFLETE =
{
        local vector p1, p2, v;
        local float oldveloc;
        v = self.movedir;
        oldveloc = vlen(v);
        v = normalize (v);
        p1 = self.origin - 20 * v;
        p2 = self.origin + 20 * v;
        traceline(p1,p2,TRUE,self);
        p1 = R_Vector(v, trace_plane_normal);
        self.flags = self.flags - (self.flags & FL_ONGROUND);
        self.velocity = p1 * oldveloc;

        self.angles = vectoangles(self.velocity);

        self.movedir = self.velocity;

        if (self.health < time)
           {
                MegaOrb_HLV ();
                return;
           }

        self.think = MegaOrb_Scan;
        self.nextthink = time + 0.1;
};

void() MegaOrb_Touch =
{
	local float	damg;

        if ((other.classname == "worldspawn") ||
           (other.classname == "door") ||
           (other.classname == "train") ||
           (other.classname == "plat") ||
           (other.classname == "func_button"))
           {
                self.think = REFLETE;
                self.nextthink = time + 0.1;

	        sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
                return;
           }

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

        MegaOrb_HLV ();
};

void() MegaOrb_GetEnemy =
{
        // obs: self = megaorb
        //      self.owner = megaorb owner (vc mesmo)

        local entity targ;

        targ = findradius (self.origin, 1000);

        while (targ)
         {
                if (targ.takedamage == DAMAGE_AIM)
                if (targ.health > 0)
                if (targ != self)  // ela mesma
                if (targ != self.owner)  // vc
                if (!teamplay || (teamplay && self.owner.team > 0 && ((targ.classname == "player" && targ.team != self.owner.team) || (targ.classname != "player" && targ.owner.team != self.owner.team))))  // matador - do mesmo time n鉶!
                if (targ.classname != "player" || (targ.classname == "player" && !(targ.style & ELOHIM_OBSERVER)))
                if (targ.owner != self.owner) // PATCH v2.05 algo que pertence a vc
                   {
                        traceline(self.origin, targ.origin + '0 0 16', FALSE, self);

                        if ((trace_ent == targ) || (targ == self.owner))
                           {
                                self.enemy = targ;
                                return;
                           }
                   }

                targ = targ.chain;
         }
};

void() MegaOrb_Scan =
{
    local entity missile;

        if (self.health < time)
           {
                MegaOrb_HLV ();
                return;
           }

        self.nextthink = time + 0.1;

        if (self.enemy == world)
           {
                if (self.frags < time)
                   {
                        self.frags = time + 0.3;
                        MegaOrb_GetEnemy();
                   }
           }

        if (self.enemy != world)
           {
                if ((self.enemy.health <= 0) || (self.enemy.deadflag != DEAD_NO))
                   {
                        self.enemy = world;
                        self.frags = 0;
                        return;
                   }

                if (self.frags < time)
                   {
                        self.frags = time + 0.5;

                        traceline(self.origin, self.enemy.origin + '0 0 16', FALSE, self);
                        if (trace_ent != self.enemy)
                           {
                                self.enemy = world;
                                self.frags = 0;
                                return;
                           }
                   }

                local vector dir;

                dir = self.origin - (self.enemy.origin + '0 0 16');
                dir = normalize(dir);
                dir = dir * (random()*350);

                self.velocity = self.velocity - dir;

                //MEGA smartbombs: atiram misseis nos alvos!
                //
                if (self.attack_finished < time)

                {
                    //TD2.09: apenas um missil eh suficiente...
                    self.attack_finished = time + 3 + random(); //reload time
                    /*
                	 if (self.armortype > 0) {
                	 	self.attack_finished = time + 0.6;  //fast twin rocket attack!
                     self.armortype = self.armortype - 1;
                	 }
                   else {
                     self.attack_finished = time + 3 + random(); //reload time
                   	self.armortype = 1;
                   }
                   */
						 sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

						 missile = spawn ();
						 missile.owner = self.owner;
						 missile.movetype = MOVETYPE_FLYMISSILE;
						 missile.solid = SOLID_BBOX;
						 missile.classname = "missile";

        				 missile.velocity = self.enemy.origin - self.origin;
                   missile.velocity = normalize(missile.velocity);
                   missile.velocity = missile.velocity * (200 + vlen(self.velocity));

						 missile.angles = vectoangles(missile.velocity);
        				 missile.health = 40 + random() * 10;
						 missile.touch = T_MissileTouch;

						 missile.nextthink = time + 5;
						 missile.think = SUB_Remove;

						 setmodel (missile, "progs/missile.mdl");
						 setsize (missile, '0 0 0', '0 0 0');
						 setorigin (missile, self.origin + v_forward*8 + '0 0 16');
                }

           }

        local float spd;

        spd = vlen(self.velocity);
        if (spd > 350)
           {
                self.velocity = normalize(self.velocity);

                local float spd2;
                spd2 = spd - 40;
                if (spd2 < 350) spd2 = 350;

                self.velocity = self.velocity * spd2; // 350
           }

        //self.angles = vectoangles(self.velocity);

        self.movedir = self.velocity;
};

// ENDPAT megaorb

void() SW_FireSmart =
{
        self.attack_finished = time + 1;

	    if (!(elohim_playmode & ELOHIM_PRACTICE_MODE))
    	    self.ammo_rockets = self.ammo_rockets - 10;
        self.currentammo = floor (self.ammo_rockets / 10);

	local	entity missile;

	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);
                        //TD
	                msg_entity = self;
	                WriteByte (MSG_ONE, SVC_SMALLKICK);

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";

   //missile attack (testando opcional)
   missile.attack_finished = time + 1;

   //TD2.09: apenas 1 missil eh suficiente
   //missile.armortype = 1;

        // set missile speed

	makevectors (self.v_angle);
	missile.velocity = v_forward * 1000; //600;
        missile.movedir = missile.velocity;

	missile.angles = vectoangles(missile.velocity);

        missile.enemy = world;   // alvo
        missile.frags = 0;  // tempo da ultima escaneada (p/ nao dar lag)
	missile.touch = MegaOrb_Touch; // ricochete, ou BUM
        missile.health = time + 10;  // validade: 10 segundos

        // scan for enemis
	missile.nextthink = time + 0.1;
	missile.think = MegaOrb_Scan;

        setmodel (missile, "progs/s_light.spr"); // bola
        //setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');
};
//
// FIM SW3 - SMARTBOMBS
//

//
//
// ARMA ESPECIAL 4 - TESLA
// SW_FireTesla
//
//
void(vector p1, vector p2, entity from, float damage) LightningDamage;

void(entity attacker, entity targ, float damg) Tesleia =
{
        WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);

        // quad muda a aparencia...
        local float level1 = 80, level2 = 250;
	if (attacker.super_damage_finished > time)
           { level1 = level1 / 4; level2 = level2 / 4; }
        if (damg < level1)
           WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
        else if (damg < level2)
             WriteByte (MSG_MULTICAST, TE_LIGHTNING1);
        else
             WriteByte (MSG_MULTICAST, TE_LIGHTNING3);

	WriteEntity (MSG_MULTICAST, attacker);
	WriteCoord (MSG_MULTICAST, attacker.origin_x);
	WriteCoord (MSG_MULTICAST, attacker.origin_y);
	WriteCoord (MSG_MULTICAST, attacker.origin_z + 16);
	WriteCoord (MSG_MULTICAST, targ.origin_x);
	WriteCoord (MSG_MULTICAST, targ.origin_y);
	WriteCoord (MSG_MULTICAST, targ.origin_z + 16);
        multicast (attacker.origin, MULTICAST_PHS);

        LightningDamage (attacker.origin, targ.origin + '0 0 16', attacker, damg);
};

void() Do_Shock =
{
        Tesleia(self.owner, self.enemy, self.health);

        if (self.goalentity != world)
           {
                self.goalentity.owner     = self.owner;
                self.goalentity.health    = self.health;
                self.goalentity.think     = Do_Shock;
                self.goalentity.nextthink = time + 0.1;
           }

        remove(self);
};

void(float dano) SW_FireTesla =
{
        self.statustime = 0;  // p/ barra de discharge etc.

        local entity targ;
        local float targnum;

        sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);

        targ = findradius (self.origin, 600);
        targnum = 0;

        while (targ)
         {
                if (targ.takedamage == DAMAGE_AIM)
                if (targ.health > 0)
                if (targ != self)
                if (targ.owner != self)
                   {
                        traceline(self.origin, targ.origin + '0 0 16', FALSE, self);
                        if (trace_ent == targ)
                           targnum = targnum + 1;
                      }
                targ = targ.chain;
         }

        if (targnum > 0)
           {
                local float damg;

                if (dano < 10) damg = ceil ((dano *  5) / targnum); else
                if (dano < 20) damg = ceil ((dano * 10) / targnum); else
                if (dano < 30) damg = ceil ((dano * 11) / targnum); else
                if (dano < 40) damg = ceil ((dano * 12) / targnum); else
                if (dano < 50) damg = ceil ((dano * 13) / targnum); else
                if (dano < 55) damg = ceil ((dano * 14) / targnum); else
                if (dano < 65) damg = ceil ((dano * 15) / targnum); else // 55-64 overload (60+)
                               damg = ceil ((dano * (dano - 48)) / targnum);
                               // overload MALUCO 65+, dano cresce muito por cell adicional;
                               // sei lah... pode estar querendo matar 5 ou 6 em fila.. :)

                local float mult = 1;
	        if (self.super_damage_finished > time) mult = 4;
                local string ss;
                sprint (self, "Cells: ");
                ss = ftos(dano);
                sprint (self, ss);
                sprint (self, "; Estrago: ");
                local float tmpf;
                tmpf = ceil (damg * targnum * mult);
                ss = ftos(tmpf);
                sprint (self, ss);
                if (targnum == 1)
                   sprint(self, " em 1 alvo\n");
                else
                   {
                        sprint (self, " em ");
                        ss = ftos(targnum);
                        sprint (self, ss);
                        sprint (self, " alvos (");
                        ss = ftos(damg * mult);
                        sprint (self, ss);
                        sprint (self, " por alvo)\n");
                   }

                local entity shocked, tmp;
                local float num;

                num = 0;

                targ = findradius (self.origin, 600);

                while (targ)
                   {
                        if (targ.takedamage == DAMAGE_AIM)
                        if (targ.health > 0)
                        if (targ != self)
                        if (targ.owner != self)
                           {
                                traceline(self.origin, targ.origin + '0 0 16', FALSE, self);
                                if (trace_ent == targ)
                                   {
                                        num = num + 1;

                                        if (num == 1)
                                           Tesleia(self, targ, damg);
                                        else if (num == 2)
                                           {
                                              shocked = spawn();
                                              shocked.owner = self;
                                              shocked.enemy = targ;
                                              shocked.health = damg;

                                              shocked.goalentity = world; //proximo

                                              shocked.nextthink = time + 0.1;
                                              shocked.think = Do_Shock;
                                           }
                                        else
                                            {
                                                tmp = spawn();
                                                shocked.goalentity = tmp;

                                                shocked = tmp;
                                                shocked.enemy = targ;
                                                shocked.goalentity = world;
                                            }

                                   }
                           }
                        targ = targ.chain;
                   }
           }
};
//
// FIM SW4 - TESLA
//

//
//
// ARMA ESPECIAL 5 - CHAINGUN
// SW_FireChainGun
//
//
void(float damage, float shotcount, vector dir, vector spread) FireBullets_2;
void() SW_FireChaingun =
{
        // modificada v2.05 - nao pifa mais
        local vector dir;

        self.attack_finished = time + 0.1;
        
                        //TD
	                msg_entity = self;
	                WriteByte (MSG_ONE, SVC_BIGKICK);

        makevectors(self.v_angle);

        self.velocity = self.velocity - v_forward * random() * 30 + v_right * crandom() * 30;

        if (self.ammo_shells < 1)
           {
	        self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
           }

        sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
    if (!(elohim_playmode & ELOHIM_PRACTICE_MODE))
        self.currentammo = self.ammo_shells = self.ammo_shells - 1;
        dir = aim (self, 100000);
	FireBullets_2 (9, 5, dir, '0.08 0.06 0');
};
//
// FIM SW5 - CHAINGUN
//

//
//
//  MACHADOS MAGICOS
//  W_FireAxe
//

//
//  MACHADO 2 - FRAGGER
//
void() play_teleport2 =
{
	local	float v;
	local	string tmpstr;

	if (self.health <= 1)
		tmpstr = "misc/r_tele1.wav";
        else if (self.health <= 2)
		tmpstr = "misc/r_tele2.wav";
        else if (self.health <= 3)
		tmpstr = "misc/r_tele3.wav";
        else if (self.health <= 4)
		tmpstr = "misc/r_tele4.wav";
        else
		tmpstr = "misc/r_tele5.wav";

	sound (self, CHAN_VOICE, tmpstr, 1, ATTN_NORM);
	remove (self);
};
void(vector org) spawn_tfog2 =
{
        local entity s;

	s = spawn ();
	s.origin = org;
	s.nextthink = time + 0.2;
        s.health = self.health; // qual som
	s.think = play_teleport2;

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_TELEPORT);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	multicast (org, MULTICAST_PHS);
};
void() tdeath2_touch =
{
	if (other == self.owner)
		return;
        if (!(other.health))
                return;

	if (other.classname == "player")
        if (other.effects & EF_BRIGHTFIELD) // ops... MIRROR!
	   {
                self.goalentity = other; // refletido por quem
                self.magic = 2+666;  // indica:"refletido"
                T_Damage (self.owner, self, self, 50000);
                return;
           }

        // else BUGFIX 2.05 fragger matava soh players
        T_Damage (other, self, self, 50000);
};


void(vector org, entity death_owner) spawn_tdeath2 =
{
local entity	death;

	death = spawn();
	death.classname = "td_fragger";
        death.magic = 2; // indica "nao refletido"
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	death.angles = '0 0 0';
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath2_touch;
	death.nextthink = time + 0.2;
	death.think = SUB_Remove;
	death.owner = death_owner;

	force_retouch = 2;		// make sure even still objects get hit
};
void() TeleFuck =
{
	spawn_tfog2 (self.origin);

	spawn_tdeath2 (self.origin, self.owner);
        remove(self);
};
//
//  FIM MACHADO 2 - FRAGGER
//

//
// Touch p/ machado 4 (fiend)
//
void() FIEND_Touch =
{
	/*
        local float hit_alguem;
	hit_alguem = 1;

        if (time > self.fiend_finished)
           {
                self.touch = SUB_Null;
                return;
           }
        if (self.fiend_finished == 999666999)
        if ((other.takedamage != DAMAGE_NO) || (other.classname == "world"))
           self.fiend_finished = time + 0.6;
	*/

        // pega os perto
        local entity e;

        e = findradius (self.origin, 100);
        while (e)
          {
                //if (e.classname == "player")
                if (e.takedamage != DAMAGE_NO)
                if (e != self)
                if (e.fiend_finished < time)
                   {
	                local	vector	source;
	                local	vector	org;

                        if (e.takedamage == DAMAGE_YES)
                           trace_ent = e;
                        else
	                   traceline (self.origin, e.origin, FALSE, self);

	                if (trace_ent == e)
                           {
                                local float damg;
                                damg = 85 + random() * 55;
                                T_Damage(e, self, self, damg);

                                // paraliza o oponente
                                // ELUAN - TD 2.11 - limpeza geral no c贸digo (esse c贸digo do spinal n茫o fazia nada, mas ningu茅m t谩 acostumado com ele consertado (e.attack_finished = e.attack_finished + 1)
                                //e.attack_finished + 1;
                                // pausa (QW)
                                e.fiend_finished = time + 0.7;

                                // confirma som, se nao morreu ainda
                                // PLAYERS apenas
                                if (e.classname == "player")
                                if (e.health > 0)
                                   sound (e, CHAN_AUTO, "player/axhit1.wav", 1, ATTN_NORM);

                                //hit_alguem = 1;
                           }
                   }
                e = e.chain;
          }

	/*
        if (hit_alguem)
           self.touch = SUB_Null;
	*/
};

void() FIEND_AXE1  = [ 31, FIEND_AXE02] {FIEND_Touch();};
void() FIEND_AXE02 = [ 32, FIEND_AXE03] {FIEND_Touch();};
void() FIEND_AXE03 = [ 33, FIEND_AXE04] {FIEND_Touch();};
void() FIEND_AXE04 = [ 34, FIEND_AXE05] {FIEND_Touch();};
void() FIEND_AXE05 = [ 35, FIEND_AXE06] {FIEND_Touch();};
void() FIEND_AXE06 = [ 36, player_run]
{
        FIEND_Touch();

        if (self.invisible_finished > time)
           self.modelindex = model_eyes;
        else if (self.size_z < 50)
             self.modelindex = model_head;
        else
            self.modelindex = model_player;

        //self.touch = SUB_Null;
};

/*
================
W_FireAxe
================
*/
void() player_pain1;
void() W_FireAxe =
{
        local float mag;
        local string ss;
        mag = selfmagic();

        //bprint("W_FireAxe() mag == ");
        //ss = ftos(mag);
        //bprint(ss);
        //bprint("\n");

        //
        // 1 == GIBBER AXE
        //
        if (mag == 1)
           {
	        local	vector	source;
	        local	vector	org;

	        makevectors (self.v_angle);
	        source = self.origin + '0 0 16';
	        traceline (source, source + v_forward*96, FALSE, self);
	        if (trace_fraction == 1.0)
		   return;

	        org = trace_endpos - v_forward*4;

	        if (trace_ent.takedamage)
	           {
		        trace_ent.axhitme = 1;
		        SpawnBlood (org, 100);
                //TD2.09: 2000 damage mata TUDO, ate dog 600 life x2 da armor rune
                T_Damage (trace_ent, self, self, 2000);
	           }
	        else
	            {	// hit wall
		        sound (self, CHAN_AUTO, "player/axhit2.wav", 1, ATTN_NORM);
		        WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		        WriteByte (MSG_MULTICAST, TE_GUNSHOT);
		        WriteByte (MSG_MULTICAST, 3);
		        WriteCoord (MSG_MULTICAST, org_x);
		        WriteCoord (MSG_MULTICAST, org_y);
		        WriteCoord (MSG_MULTICAST, org_z);
		        multicast (org, MULTICAST_PVS);
	            }
           }
        //
        // 2 == FRAGGER (telefucker)
        //
        else if (mag == 2)
           {
	        local	vector	source;
	        local	vector	org;

	        makevectors (self.v_angle);
                //v_forward_z = 0;

                local float NUM;

                self.attack_finished = time + 1.5;

                local entity fucker;
                local float  fcnt, fsom;
                fcnt = 0;
                fsom = random() * 5; // qual som, todos fogs tem iguais
                while (fcnt < 6)
                 {
                   fucker = spawn();
                   fucker.owner = self;
                   fucker.solid = SOLID_NOT;
                   fucker.movetype = MOVETYPE_NONE;
                   fucker.classname = "telefucker point";
                   fucker.think = TeleFuck;
                   fucker.nextthink = time + 0.1 * fcnt;
                   fucker.health = fsom;
                   setorigin(fucker, self.origin + v_forward * (60 + fcnt * 50));

                   fcnt = fcnt + 1;
                 }
           }
        //
        // 3 == STUNNER - paralizador
        //
        else if (mag == 3)
           {
                makevectors (self.v_angle);		// is this still used

                local vector org;
                org = self.origin + '0 0 16';

                traceline (org, org + v_forward*600, FALSE, self);

	        WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
                WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
	        WriteEntity (MSG_MULTICAST, self);
	        WriteCoord (MSG_MULTICAST, org_x);
	        WriteCoord (MSG_MULTICAST, org_y);
	        WriteCoord (MSG_MULTICAST, org_z);
	        WriteCoord (MSG_MULTICAST, trace_endpos_x);
	        WriteCoord (MSG_MULTICAST, trace_endpos_y);
	        WriteCoord (MSG_MULTICAST, trace_endpos_z);
                multicast (org, MULTICAST_PHS);

		sound (self, CHAN_AUTO, "weapons/lhit.wav", 1, ATTN_NORM);

                T_Damage(trace_ent, self, self, 40);

                // STUN
                if (trace_ent.classname == "player" && !(trace_ent.style & ELOHIM_OBSERVER))
                if (trace_ent.health > 0)
                   {
                        sprint(trace_ent, "Voce foi paralisado!\n");

                        sound (trace_ent, CHAN_AUTO, "player/axhit1.wav", 1, ATTN_NORM);

                        local float rs;

	                rs = rint((random() * 5) + 1);

	                trace_ent.noise = "";
	                if (rs == 1) trace_ent.noise = "player/pain1.wav";
	                else if (rs == 2) trace_ent.noise = "player/pain2.wav";
	                else if (rs == 3) trace_ent.noise = "player/pain3.wav";
	                else if (rs == 4) trace_ent.noise = "player/pain4.wav";
	                else if (rs == 5) trace_ent.noise = "player/pain5.wav";
	                else trace_ent.noise = "player/pain6.wav";
	                sound (trace_ent, CHAN_VOICE, trace_ent.noise, 1, ATTN_NORM);

                        // PARALISA: quando o attack finished
                        // passa o efeito, ele automaticamente
                        // tira a flag
                        trace_ent.attack_finished = time + 5;
                        trace_ent.items = trace_ent.items | IT_STUNNED;

                        trace_ent.velocity_x = 0;
                        trace_ent.velocity_y = 0;
                        trace_ent.velocity_z = 350;

                        // v2.05 bugfix nails continuam apos paralisia
                        local entity oldself;
                        oldself = self;
                        self = trace_ent;
                        player_pain1();
                        self = oldself;
                   }
           }
        //
        // 4 == FIEND!! vira fiend e dmg e tal!!
        //
        else if (mag == 4)
           {
	        if (self.flags & FL_WATERJUMP)
                   return;

                //self.touch = FIEND_Touch;
                //self.attack_finished = time + 0.8;
                //self.fiend_finished = 999666999;

                self.flags = self.flags - (self.flags & FL_ONGROUND);

                makevectors(self.v_angle);

                self.velocity = v_forward * 1000 + v_up * 250 + self.velocity;

                sound(self, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);

                self.attack_finished = time + 0.8;
                self.modelindex = model_fiend;
                FIEND_AXE1();
           }
        //
        // 5 == THROWING KNIGHT v2.09
        //
        else if (mag == 5)
           {
	        local	vector	source;
	        local	vector	org;
            local entity hell;

	        makevectors (self.v_angle);
	        source = self.origin + '0 0 48';

            hell = spawn_hell_knight(self.origin);

            self.tknight = hell;

            hell.flags = hell.flags - (hell.flags & FL_ONGROUND);
            hell.velocity = v_forward * 1000 + v_up * 100;
           }
};
//============================================================================


vector() wall_velocity =
{
	local vector	vel;

	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;
	local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, float damage) SpawnBlood =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_BLOOD);
	WriteByte (MSG_MULTICAST, 1);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	multicast (org, MULTICAST_PVS);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, damage);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

vector  blood_org;
float   blood_count;

vector  puff_org;
float   puff_count;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
	blood_count = 0;
	puff_count = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;

	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

void() Multi_Finish =
{
	if (puff_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_GUNSHOT);
		WriteByte (MSG_MULTICAST, puff_count);
		WriteCoord (MSG_MULTICAST, puff_org_x);
		WriteCoord (MSG_MULTICAST, puff_org_y);
		WriteCoord (MSG_MULTICAST, puff_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}

	if (blood_count)
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_BLOOD);
		WriteByte (MSG_MULTICAST, blood_count);
		WriteCoord (MSG_MULTICAST, blood_org_x);
		WriteCoord (MSG_MULTICAST, blood_org_y);
		WriteCoord (MSG_MULTICAST, blood_org_z);
		multicast (puff_org, MULTICAST_PVS);
	}
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		blood_count = blood_count + 1;
		blood_org = org;
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		puff_count = puff_count + 1;
	}
};

/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
    // makevectors(self.v_angle); // ELOHIM_MOD - not needed

    self.dest1_x = self.dest1_x + 4 * shotcount; // ELOHIM_MOD - stats

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir*2048, FALSE, self);
	puff_org = trace_endpos - dir*4;

	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
};

// PATCH firebullets_2 tem dmg como parametro
//
void(float damage, float shotcount, vector dir, vector spread) FireBullets_2 =
{
	local	vector direction;
	local	vector	src;

	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();

	traceline (src, src + dir*2048, FALSE, self);
	puff_org = trace_endpos - dir*4;

	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (damage, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
	Multi_Finish ();
};

/*
================
W_FireShotgun
================
*/
void() W_FireShotgun =
{
	local vector dir;

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

        // PATCH -- pode atirar sem ammo tb...
        if (self.ammo_shells > 0)
           {
	        self.currentammo = self.ammo_shells = self.ammo_shells - 1;
                sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
           }
        else
            sound (self ,CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);

    // ELOHIM_MOD - infinite ammo in practice mode
    if (!(elohim_playmode & ELOHIM_PRACTICE_MODE))
		if (self.ammo_shells > 0)
	        self.currentammo = self.ammo_shells = self.ammo_shells - 1;
    // END_MOD

    makevectors(self.v_angle); // ELOHIM_MOD - added this
	dir = aim (self, 100000);
	FireBullets_2 (8, 3, dir, '0.04 0.04 0');
};


/*
================
W_FireSuperShotgun
================
*/
void() W_FireSuperShotgun =
{
	local vector dir;

	if (self.currentammo == 1)
	{
		W_FireShotgun ();
		return;
	}

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_BIGKICK);

	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);

        if (self.currentammo < 2) self.currentammo = self.ammo_shells = 0;
                             else self.currentammo = self.ammo_shells = self.ammo_shells - 2;

	dir = aim (self, 100000);

        local float p;

        p = getpow(self, IT_SUPER_SHOTGUN);

        // v2.05 dano igual sempre...
        FireBullets_2 (7, 14, dir, '0.14 0.04 0');

        // ...tempos diferenciados
        if (p == 0)
           self.attack_finished = time + 0.7;
        else if (p == 1)
           self.attack_finished = time + 0.6;
        else if (p == 2)
           self.attack_finished = time + 0.5;
        else
          {
             UUURRR_Sound();
             self.attack_finished = time + 0.4;
          }

    makevectors(self.v_angle); // ELOHIM_MOD - added this
};


/*
==============================================================================

ROCKETS

==============================================================================
*/

//TD
void() BecomeExplosion =
{
	remove(self);
};

void() T_MissileTouch =
{
        // OBS: MODIFICADO!
        // "health" do missil indica o seu dano
        //

	if (other == self.owner) return; // don't explode on owner
	if (self.voided) return;
	self.voided = 1;
	if (pointcontents(self.origin) == CONTENT_SKY) { remove(self); return; }

	if (other.health)
	{
		if (other.classname == "monster_shambler")
			self.health = self.health * 0.5;	// mostly immune
		other.deathtype = "rocket";
		T_Damage (other, self, self.owner, self.health );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other, "rocket");

//  sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove(self);
};

/*
================
W_FireRocket
================
*/
void() W_FireRocket =
{
	local	entity missile, mpuff;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

                        //TD
	                msg_entity = self;
	                WriteByte (MSG_ONE, SVC_SMALLKICK);

	missile = spawn ();
          missile.voided = 0;
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
// set missile speed	

	makevectors (self.v_angle);
        // PATCH -- sem essa de aim!! AIM SUX!!
	//missile.velocity = aim(self, 1000);
        missile.velocity = v_forward;

        // PATCH
        // poder do rocket
        local float p;
        p = getpow(self, IT_ROCKET_LAUNCHER);

        // velo^ do rocket
	missile.velocity = missile.velocity * (1000 + 250*p);
        if (p == 3) UUURRR_Sound();

        // ENDPAT

	missile.angles = vectoangles(missile.velocity);

        missile.health = 100 + random()*20; // PATCH dano
	missile.touch = T_MissileTouch;

// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin + v_forward*8 + '0 0 16');
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

void(entity from, float damage) LightningHit =
{
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNINGBLOOD);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (trace_endpos, MULTICAST_PVS);

	T_Damage (trace_ent, from, from, damage);
};

/*
=================
LightningDamage
=================
*/
// PATCH
// target locking & auto aiming DISABLED v2.03
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity            e1, e2;
	local vector            f;

	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);

	if (trace_ent.takedamage)
	{
		LightningHit (from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;
 
	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		LightningHit (from, damage);
	}
};


void() W_FireLightning =
{
	local	vector		org;
	local	float		cells;

        // v2.05 - raios largos - constantes
        local  float  MAXD = 16;
        local  float  MEDD =  8;

        // AAAAARGHHH
        // BUGFIX MALDITO v2.03
        makevectors(self.v_angle);

	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		W_SetCurrentAmmo ();
        self.dest1_z = self.dest1_z + 35 * cells; // ELOHIM_MOD - stats
		T_RadiusDamage (self, self, 35*cells, world, "selfwater");
		return;
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}

                        //TD
	                msg_entity = self;
	                WriteByte (MSG_ONE, SVC_SMALLKICK);

        local float p;
        p = getpow(self, IT_LIGHTNING);

        // v2.05 - GASTA 1 SEMPRE
        self.ammo_cells = self.ammo_cells - 1;
        if (self.ammo_cells < 0) self.ammo_cells = 0;
        self.currentammo = self.ammo_cells;

        // END PATCH

        // PATCH v2.05 - powerMAX = raio "largo"

        local float damg;
        if (p == 0) damg = 30; else
        if (p == 1) damg = 30; else //  +incr. alcance
        if (p == 2) damg = 35; else //  +5
        if (p == 3) damg = 45;      //  +10 +incr. alcance

	org = self.origin + '0 0 16';
        traceline (org, org + v_forward*600, TRUE, self);

        if (p == 3) // max
           {
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING3);
	WriteEntity (MSG_MULTICAST, self);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (org, MULTICAST_PHS);

                local entity tc, tl, tr, tu;
                local vector p1, p2;
                p1 = self.origin;
                p2 = trace_endpos + v_forward*4;

	        traceline (p1, p2, FALSE, self);
	        if (trace_ent.takedamage)
	        {
                        LightningHit (self, damg);
		        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
                        tc = trace_ent;
                        //bprint("center hit\n");
	        }
	        traceline (p1 + v_right * MAXD, p2 + v_right * MAXD, FALSE, self);
	        if (trace_ent.takedamage)
                if (trace_ent != tc)
	        {
                        LightningHit(self, damg);
		        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
                        tr = trace_ent;
                        //bprint("right hit\n");
	        }
	        traceline (p1 - v_right * MAXD, p2 - v_right * MAXD, FALSE, self);
	        if (trace_ent.takedamage)
                if (trace_ent != tc)
                if (trace_ent != tr)
	        {
                        LightningHit(self, damg);
                        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
                        tl = trace_ent;
                        //bprint("left hit\n");
	        }
	        traceline (p1 + v_up * MEDD, p2 + v_up * MEDD, FALSE, self);
	        if (trace_ent.takedamage)
                if (trace_ent != tc)
                if (trace_ent != tr)
                if (trace_ent != tl)
	        {
                        LightningHit(self, damg);
		        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
                        tu = trace_ent;
                        //bprint("up hit\n");
	        }
	        traceline (p1 - v_up * MEDD, p2 - v_up * MEDD, FALSE, self);
	        if (trace_ent.takedamage)
                if (trace_ent != tc)
                if (trace_ent != tr)
                if (trace_ent != tl)
                if (trace_ent != tu)
	        {
                        LightningHit(self, damg);
                        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
                        //bprint("down hit\n");
	        }
           }
        else if (p != 0) // 1 ou 2
           {
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING1);
	WriteEntity (MSG_MULTICAST, self);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (org, MULTICAST_PHS);

                local entity tc, tl, tr, tu;
                local vector p1, p2;
                p1 = self.origin;
                p2 = trace_endpos + v_forward*4;

	        traceline (p1, p2, FALSE, self);
	        if (trace_ent.takedamage)
	        {
                        LightningHit(self, damg);
		        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
                        tc = trace_ent;
                        //bprint("center hit\n");
	        }
	        traceline (p1 + v_right * MEDD, p2 + v_right * MEDD, FALSE, self);
	        if (trace_ent.takedamage)
                if (trace_ent != tc)
	        {
                        LightningHit(self, damg);
		        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
                        tr = trace_ent;
                        //bprint("right hit\n");
	        }
	        traceline (p1 - v_right * MEDD, p2 - v_right * MEDD, FALSE, self);
	        if (trace_ent.takedamage)
                if (trace_ent != tc)
                if (trace_ent != tr)
	        {
                        LightningHit(self, damg);
		        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
                        tl = trace_ent;
                        //bprint("left hit\n");
	        }
           }
        else    // normal
           {
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_LIGHTNING2);
	WriteEntity (MSG_MULTICAST, self);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	WriteCoord (MSG_MULTICAST, trace_endpos_x);
	WriteCoord (MSG_MULTICAST, trace_endpos_y);
	WriteCoord (MSG_MULTICAST, trace_endpos_z);
	multicast (org, MULTICAST_PHS);

                local vector p1, p2;
                p1 = self.origin;
                p2 = trace_endpos + v_forward*4;

	        traceline (p1, p2, FALSE, self);
	        if (trace_ent.takedamage)
	        {
                        LightningHit(self, damg);
		        //particle (trace_endpos, '0 0 100', 225, damg*4);
		        //T_Damage (trace_ent, self, self, damg);
	        }
                //LightningDamage (self.origin, trace_endpos + v_forward*4, self, damg);
           }
};


//=============================================================================


void() GrenadeExplode =
{
        // OBS: MODIFICADO
        // dano da granada = health
	if (self.voided) {
		return;
	}
	self.voided = 1;

	T_RadiusDamage (self, self.owner, self.health, world, "grenade");

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);

	remove (self);
};

void() GrenadeTouch =
{
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
	local	entity missile;

	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;

	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	missile = spawn ();
          missile.voided = 0;
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";

// set missile speed

	makevectors (self.v_angle);

        // PATCH poder da granada
        local float p;
        p = getpow(self, IT_GRENADE_LAUNCHER);

	if (self.v_angle_x)
		missile.velocity = v_forward*(650 + 50*p) + v_up * 200 + crandom()*v_right*10 + crandom()*v_up*10;
	else
	{
		missile.velocity = aim(self, 10000);
		missile.velocity = missile.velocity * 600;
		missile.velocity_z = 200;
	}

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);

	missile.touch = GrenadeTouch;

// set missile duration
	missile.nextthink = time + 2.5;

        // PATCH dano
        if (p == 0) missile.health = 120;
        else if (p == 1) missile.health = 140; //150 180;
        else if (p == 2) missile.health = 160; //180 220;
        else {
                missile.health = 180; //210 300;
                UUURRR_Sound();
             }

	missile.think = GrenadeExplode;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');
	setorigin (missile, self.origin);
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.voided=0;
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	local vector	dir;
	local entity	old;

	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);
	self.attack_finished = time + 0.2;
        self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16', dir);
	newmis.touch = superspike_touch;

        // PATCH

        // poder do supernail
        local float p;
        p = getpow(self, IT_SUPER_NAILGUN);

        // mais dano, mais rapido
        if (p == 0)
           {
                newmis.health = 25;
           }
        else if (p == 1)
           {
                newmis.health = 33;
           }
        else if (p == 2)
           {
                newmis.health = 40;
           }
        else if (p == 3)
           {
                newmis.health = 50;
           }

        // som de quad qdo poder=max
        if (p == 3)
	if (self.super_sound < time)
	   {
	        self.super_sound = time + 1;
		sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
	   }

        // ENDPAT

	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
};
/*
void(float ox) W_FireSpikes =
{
	local vector	dir;
	local entity	old;
	
	makevectors (self.v_angle);
	
	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;

    // ELOHIM_MOD - infinite ammo in practice mode
    if (!(elohim_playmode & ELOHIM_PRACTICE_MODE))
        self.currentammo = self.ammo_nails = self.ammo_nails - 1;
    // END_MOD

	dir = aim (self, 1000);
	launch_spike (self.origin + '0 0 16' + v_right*ox, dir);
    self.dest1_y = self.dest1_y + 9; // ELOHIM_MOD - stats

	self.punchangle_x = -2;
};
*/

// PATCH - lasergun

// toque do laser
void() LaserTouch =
{
	local vector org;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	//org = self.origin - 8*normalize(self.velocity);
        self.origin = self.origin - 8*normalize(self.velocity);
        org = self.origin;

	if (other.health)
	{
		SpawnBlood (org, self.health);
		T_Damage (other, self, self.owner, self.health);
	}

        T_FlameRadiusDamage(self, self.owner, self.max_health, self.health, other);

        // TD - BECOMEEXPLOSION - Fumacinha da bola de fogo
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();
};

// atira laser
void(vector org, vector dir) Fire_Laser =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
        newmis.angles_x = newmis.angles_x + 90;
        newmis.frame = 0;

	newmis.touch = LaserTouch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;

        setmodel (newmis, "progs/flame2.mdl");

	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org);

        local float p;
        p = getpow(self, IT_NAILGUN);

        // PATCH -- economiza um getpow no impacto pra saber qual frame do explosion usa
        newmis.frags = p;

        if (p == 0) { newmis.health = 25; newmis.max_health = 120; newmis.velocity = dir * 1000; }
        else if (p == 1) { newmis.health = 35; newmis.max_health = 140; newmis.velocity = dir * 1300; }
        else if (p == 2) { newmis.health = 45; newmis.max_health = 150; newmis.velocity = dir * 1300; newmis.frame = 1; }
        else {
                newmis.health = 50; newmis.max_health = 180;
                newmis.velocity = dir * 1600;
                newmis.frame = 1;
	        setorigin (newmis, org - v_right * 2);

	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
        newmis.angles_x = newmis.angles_x + 90;
        newmis.frame = 1;

	newmis.touch = SUB_Remove;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;

        setmodel (newmis, "progs/flame2.mdl");

	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org + dir * 12);
        newmis.velocity = dir * 1200;

        newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
        newmis.angles_x = newmis.angles_x + 90;
        newmis.frame = 1;

	newmis.touch = SUB_Remove;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;

        setmodel (newmis, "progs/flame2.mdl");

	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
	setorigin (newmis, org + v_right * 2);
        newmis.velocity = dir * 1200;

        }
};

// ENDPAT lasergun

void(float ox) W_FireSpikes =
{
	local vector	dir;
	local entity	old;

	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);
        // PATCH
        // FLAME GUN (4) comeca aqui
	makevectors (self.v_angle);

        local float p, nailsneeded;
        p = getpow(self, IT_NAILGUN);

        //v2.05 - 1 nail por nivel da flamegun
        nailsneeded = p+1;

        //if (p < 2) nailsneeded = 1;
        //      else nailsneeded = p;

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon ();
		W_SetCurrentAmmo ();
		return;
	}

        //if (config_SHAREWARE == 0)
        //   sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);
        //else

        sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	self.attack_finished = time + 0.2;

        self.ammo_nails = self.ammo_nails - nailsneeded;
        if (self.ammo_nails < 0)
           self.ammo_nails = 0;
        self.currentammo = self.ammo_nails;

	dir = aim (self, 1000);

        //dir = dir * -1;

        Fire_Laser (self.origin + '0 0 16' + v_right*ox , dir);
};


.float hit_z;
void() spike_touch =
{
local float rand;
local float damg;
	if (other == self.owner)
		return;

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

    //TD2.09: new knight spikes
    if (self.classname == "knightspike") {
	   if (other.health)
	   {
	      other.deathtype = "knightspike";
	      T_Damage (other, self.owner, self.owner.owner, 60 );
	   }
	   T_RadiusDamage (self.owner, self.owner.owner, 60, other, "knightspike");
	   self.origin = self.origin - 8*normalize(self.velocity);
	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
	multicast (self.origin, MULTICAST_PHS);
 
	remove(self);
       return;
    }

// hit something that bleeds
	if (other.takedamage)
	{
        //TD2.08: wizard spikes super-poison
        if (self.classname == "wizspike") {
           damg = 40;
        }
        else {
           damg = 9;
        }

		spawn_touchblood (damg);
		other.deathtype = "nail";
		T_Damage (other, self, self.owner, damg);
	}
	else
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);

		if (self.classname == "wizspike")
			WriteByte (MSG_MULTICAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_MULTICAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_MULTICAST, TE_SPIKE);
		WriteCoord (MSG_MULTICAST, self.origin_x);
		WriteCoord (MSG_MULTICAST, self.origin_y);
		WriteCoord (MSG_MULTICAST, self.origin_z);
		multicast (self.origin, MULTICAST_PHS);
	}

	remove(self);

};

void() superspike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (self.voided) {
		return;
	}
	self.voided = 1;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
                // PATCH BUG MALDITO!!
		other.deathtype = "supernail";
		T_Damage (other, self, self.owner, self.health);
	}
	else
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
		WriteByte (MSG_MULTICAST, TE_SUPERSPIKE);
		WriteCoord (MSG_MULTICAST, self.origin_x);
		WriteCoord (MSG_MULTICAST, self.origin_y);
		WriteCoord (MSG_MULTICAST, self.origin_z);
		multicast (self.origin, MULTICAST_PHS);
	}

	remove(self);

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
        //PATCH -- BUG CHATO!!!
        self.statustime = 0;

	// ELUAN - TD 2.11 - corrige o bug de n茫o conseguir dar respawn
	if(self.deadflag == DEAD_NO && self.health > 0)
		player_run ();		// get out of any weapon firing states

	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );

	if (self.weapon == IT_AXE)
	{
                local float mag;
                mag = selfmagic();
                //
                // PATCH -- armas MAGICAS (virus etc.)
                //
                if (mag == 26) // VIRUS
                   {
                        self.currentammo = floor(self.ammo_nails / 15);
		        self.weaponmodel = "progs/v_shot.mdl";
                        self.items = self.items | IT_NAILS;
                   }
                else if (mag == 27) // X SHELLS
                   {
                        self.currentammo = floor(self.ammo_shells / 2);
		        self.weaponmodel = "progs/v_shot.mdl";
                        self.items = self.items | IT_SHELLS;
                   }
                else // magias 1..9 -- machados
                    {
		        self.currentammo = 0;
		        self.weaponmodel = "progs/v_axe.mdl";
                    }
                self.weaponframe = 0;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		self.currentammo = self.ammo_shells;
		self.weaponmodel = "progs/v_shot2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_SHELLS;
	}
	else if (self.weapon == IT_NAILGUN)
	{
                // PATCH2
                self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail.mdl";
                self.items = self.items | IT_NAILS;
		self.weaponframe = 0;
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		self.currentammo = self.ammo_nails;
		self.weaponmodel = "progs/v_nail2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_NAILS;
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		self.currentammo = self.ammo_rockets;
		self.weaponmodel = "progs/v_rock2.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_ROCKETS;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		self.currentammo = self.ammo_cells;
		self.weaponmodel = "progs/v_light.mdl";
		self.weaponframe = 0;
		self.items = self.items | IT_CELLS;
	}
	else if (self.weapon == IT_EXTRA_WEAPON)
        {
                local float sw;
                sw = weapon2of(self);
                if (sw == 1)
                   {
                        self.currentammo = floor(self.ammo_rockets / 3);
		        self.weaponmodel = "progs/v_rock.mdl";
                        self.items = self.items | IT_ROCKETS;
                   }
                else if (sw == 2)
                   {
                        self.currentammo = floor(self.ammo_rockets / 5);
		        self.weaponmodel = "progs/v_rock.mdl";
                        self.items = self.items | IT_ROCKETS;
                   }
                else if (sw == 3)
                   {
                        self.currentammo = floor(self.ammo_rockets / 10);
		        self.weaponmodel = "progs/v_rock2.mdl";
                        self.items = self.items | IT_ROCKETS;
                   }
                else if (sw == 4)
                   {
		        self.currentammo = self.ammo_cells;
	            self.weaponmodel = "progs/v_light.mdl";
		        self.weaponframe = 0;
		        self.items = self.items | IT_CELLS;
                   }
                else if (sw == 5)
                   {
		        self.currentammo = self.ammo_shells;
		        self.weaponmodel = "progs/v_nail2.mdl";
		        self.weaponframe = 0;
		        self.items = self.items | IT_SHELLS;
                   }
        }
        else
	{
		self.currentammo = 0;
		self.weaponmodel = "";
		self.weaponframe = 0;
	}
};

float() W_BestWeapon =
{
	local	float	it;

        // PATCH 2.04
        // se a tesla esta carregando, NUNCA
        // trocar a arma!!
        if (self.tesla > 0) return self.weapon;

	it = self.items;

	if (self.waterlevel <= 1 && self.ammo_cells >= 1 && (it & IT_LIGHTNING) )
			return IT_LIGHTNING;
        if(self.ammo_nails >= 1 && (it & IT_SUPER_NAILGUN) )
		return IT_SUPER_NAILGUN;
	if(self.ammo_shells >= 2 && (it & IT_SUPER_SHOTGUN) )
		return IT_SUPER_SHOTGUN;
	if(self.ammo_nails >= 1 && (it & IT_NAILGUN) )
		return IT_NAILGUN;

        // CHANGEWEAPON: A NOVELA
        //
        // O FIX: a NAILGUN nunca troca pra ela, qdo o patch
        // estiver avancado poderia ser feito uma politica
        // de changeweapon baseada em cada arma especial...
        // o axe nunca troca pra ele, a nao ser quando e'
        // machado magico e nao magia, mas como nunca se
        // sabe...
        //
        // O DRAMA: o jogador nao tem uma arma que ele SEMPRE
        // pode mudar pra ela em ultima instancia
        //
        // A SOLUCAO: a SHOTGUN sempre e' selecionavel e
        // sempre atira, mas quando esta' sem municao, atira
        // 1 tiro de cada vez (intervalo de 0.5 da shotgun
        // normal do quake, e nao 0.1 da UZI do TD)

//	if(self.ammo_shells >= 0 && (it & IT_SHOTGUN) ) //matador
		return IT_SHOTGUN;
//	return IT_AXE;
};

float() W_CheckNoAmmo =
{
	if (self.currentammo > 0)
		return TRUE;

	if (self.weapon == IT_AXE)
           {
                // >25 PORQUE inclui tb as armas magicas (virus etc)
                // que gastam a sua currentammo tb...

                if (selfmagic() > 25) // e' arma especial?
                   {
                        if (selfmagic() == 32)
                           return TRUE; // pipebomb escapa...
                   }
                else
                    return TRUE; // machado mesmo
           }

        // PATCH -- pipebomb, sempre dah
        if (self.weapon == IT_EXTRA_WEAPON)
        if (weapon2of(self) == 2)
            return TRUE;

        // PATCH -- a nova shotgun, com tiro ilimitado
	if (self.weapon == IT_SHOTGUN)
		return TRUE;

	self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();

// drop the weapon down
	return FALSE;
};

/*
============
W_Attack

An attack impulse can be triggered now
============
*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_light1;
void()	player_rocket1;

void()	player_Tesla1;     // PATCH
void()	player_Chaingun1;  // PATCH
void()  player_laser1;     // PATCH

void() W_Attack =
{
	local	float	r;

    // MATADOR
    //if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
    //    return;
    // MATADOR
        // PATCH - com mirror shield ativado nao pode atacar
        if (self.effects & EF_BRIGHTFIELD) // MIRROR SHIELD ativado
           {
                ccenterprint(self, "Voce nao pode atacar enquanto\nestiver protegido pelo\nEspelho Protetor!", 2);
                self.messagetime = time + 3;
                return;
           }

	if (!W_CheckNoAmmo ())
		return;

        // spinal PATCH 2.07 -- runa camo nao mostra alguns ataques
        //
        self.camoattack = 0; // por default, mostra

    // ELOHIM_MOD - makevectors is not needed here
	makevectors	(self.v_angle);			// calculate forward angle for velocity
    // END_MOD
	self.show_hostile = time + 1;	// wake monsters up

	if (self.weapon == IT_AXE)
	{
                local float mag;
                mag = selfmagic();
                // PATCH -- ARMAS MAGICAS (26..30)
                if (mag == 26)     // VIRUS
                   {
                        player_shot1();
                        MW_FireVirus();
                        self.camoattack = 1; // patch 2.07 - ataque nao revela camuflagem!
                   }
                else if (mag == 27) // XSHELLS
                   {
                        player_shot1();
                        MW_FireXShotgun();
                   }
                else   // machado magico mesmo
                    {
                        // patch 2.07 - ataque nao revela camuflagem!
                        // mais especificamente, ataque com o GIBBER AXE (mag == 1)
                        if (mag == 1)
                           self.camoattack = 1;

                        sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);

                        //TD2.09: THROWING KNIGHT
                        if (mag == 5) {
                           player_knight_axe (); //player.qc
                        }
                        //TD2.08: TURBO GIBBER
                        //else if (runeof(self) == 3)
                        //TD2.09: FAST GIBBER SEMPRE (nao interessa runa)
                        mag = selfmagic();
                        if (mag == 1) {
                           //bprint("MAG 1\n");
                           player_axe1 ();
                        } else {
                          //bprint("NAO-magged\n");
		                   r = random();
		                   if (r < 0.25) player_axe1 ();
		                   else if (r<0.5) player_axeb1 ();
		                   else if (r<0.75) player_axec1 ();
		                   else player_axed1 ();
		                   self.attack_finished = time + 0.5;
                        }
                    }
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();

                // PATCH -- tempos diferentes
                if (self.ammo_shells < 1)
		   self.attack_finished = time + 0.5;
                else
                    self.attack_finished = time + 0.1;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
	}
	else if (self.weapon == IT_NAILGUN)
	{
	        player_laser1 ();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();

                // PATCH
                local float p;
                p = getpow(self, IT_GRENADE_LAUNCHER);

                if (p == 0) self.attack_finished = time + 0.6;
                else if (p == 1) self.attack_finished = time + 0.5;
                else if (p == 2) self.attack_finished = time + 0.5;
                else self.attack_finished = time + 0.4;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();

                // PATCH -- rocket: haste c/ powerup
                local float p;
                p = getpow(self, IT_ROCKET_LAUNCHER);

                if (p == 0) self.attack_finished = time + 0.8;
                else if (p == 1) self.attack_finished = time + 0.7;
                else if (p == 2) self.attack_finished = time + 0.6;
                else self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
                self.enemy = world; // PATCH p/ target-lock
                                    // alvo reseta qdo atira de novo
		player_light1();
		self.attack_finished = time + 0.1;
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
	}
        else if (self.weapon == IT_EXTRA_WEAPON)
        {
                local float sw;
                sw = weapon2of(self);
                if (sw == 1) { player_rocket1(); SW_FireMorteiro (); }
                else if (sw == 2) { player_rocket1(); SW_FirePipebomb (); }
                else if (sw == 3) { player_rocket1(); SW_FireSmart (); }
                else if (sw == 4) { player_Tesla1(); self.attack_finished = time + 0.1; }
                else if (sw == 5) player_Chaingun1();
        }
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
        //PATCH -- BUG CHATO!!!
        self.statustime = 0;

	local	float	it, am, fl;

	it = self.items;
	am = 0;

    // MATADOR
    //if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
    //    return;
    // MATADOR
	
	if (self.impulse == 1)
	{
	        fl = IT_AXE;

                // PATCH
                // ARMAS MAGICAS (VIRUS, etc.)

                local float mag;
                mag = selfmagic();

                if (mag == 26) // VIRUS
                   {
                        if (self.ammo_nails < 5)
                           am = 1;
                   }
                else if (mag == 27) // XSHELLS
                   {
                        if (self.ammo_shells < 2)
                           am = 1;
                   }

	}
	else if (self.impulse == 2)
	{
		fl = IT_SHOTGUN;
                // PATCH sempre pode
		//if (self.ammo_shells < 1)
		//	am = 1;
	}
	else if (self.impulse == 3)
	{
		fl = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}
	else if (self.impulse == 4)
	{
                fl = IT_NAILGUN;
                if (self.ammo_nails < 1)
                   am = 1;
	}
	else if (self.impulse == 5)
	{
		fl = IT_SUPER_NAILGUN;
                if (self.ammo_nails < 1)
			am = 1;
	}
	else if (self.impulse == 6)
	{
		fl = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 7)
	{
		fl = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (self.impulse == 8)
	{
		fl = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}
	else if (self.impulse == 20)         // PATCH : IT_EXTRA_WEAPON
	{
		fl = IT_EXTRA_WEAPON;

                local float sw;
                sw = weapon2of(self);

                if (sw == 1) { if (self.ammo_rockets < 3) am = 1; }
				//pipebomb sempre da'
                else if (sw == 3) { if (self.ammo_rockets < 10) am = 1; }
                else if (sw == 4) { if (self.ammo_cells < 1) am = 1; }
                else if (sw == 5) { if (self.ammo_shells < 1) am = 1; }
	}

	self.impulse = 0;

	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}
	
	if (am)
	{	// don't have the ammo
                // PATCH -- MSGS personalizadas para armas especiais
                // quando elas estiverem junto c/ as magias (TD CLASSICO)
                if (fl == IT_AXE)
                   {
                        local float m;
                        m = selfmagic();

                        // PATCH -- ARMAS MAGICAS

                        if (m == 26)
                           sprint(self, "Virus: precisa de 15 NAILS!\n");
                        else if (m == 27)
                             sprint(self, "Explosive Shotgun: precisa de SHELLS!\n");

                   }
                // PATCH -- MSGS personalizadas para armas especiais
                else if (fl == IT_EXTRA_WEAPON) //... arma especial como "9"
                   {
                        local float w2;
                        w2 = weapon2of(self);

                        if (w2 == 1)
                           sprint(self, "Morteiros: precisa de 3 ROCKETS!\n");
                        else if (w2 == 3)
                           sprint(self, "Smartbombs: precisa de 10 ROCKETS!\n");
                        else if (w2 == 4)
                           sprint(self, "Tesla Coil: precisa de CELLS!\n");
                        else if (w2 == 5)
                           sprint(self, "Chaingun: precisa de SHELLS!\n");
                   }
                else
		    sprint (self, "not enough ammo.\n");
		return;
	}

//
// set weapon, set ammo
//
	self.weapon = fl;
	W_SetCurrentAmmo ();
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
    if (deathmatch) // ELOHIM_MOD 'deathmatch || coop' => 'deathmatch'
		return;

	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_KEY1 | IT_KEY2;

	self.ammo_cells = 200;
	self.items = self.items | IT_LIGHTNING;

	self.weapon = IT_ROCKET_LAUNCHER;
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am;

	it = self.items;
	self.impulse = 0;

// ELUAN - TD 2.11 - mas 茅 pra mudar pras armas especiais!	
	while (1)
	{
		am = 0;

// 2.10 corrigido - agora n鉶 troca mais pro machado
		if (self.weapon == IT_AXE)
		{
			self.weapon = IT_SHOTGUN;
                        // PATCH -- SHOTGUN SEMPRE DAH
			//if (self.ammo_shells < 1)
			//	am = 1;
		}
		else if (self.weapon == IT_EXTRA_WEAPON)
		{
			self.weapon = IT_AXE;
                        // PATCH
			// ARMAS MAGICAS (VIRUS, etc.)

			local float mag;
			mag = selfmagic();

			// machados sempre OK
			if      (mag ==  1)  { am = 0; }
			else if (mag ==  2)  { am = 0; }
			else if (mag ==  3)  { am = 0; }
			else if (mag ==  4)  { am = 0; }

			else if (mag == 26) // VIRUS
			   {
				if (self.ammo_nails < 5)
				   am = 1;
			   }
			else if (mag == 27) // XSHELLS
			   {
				if (self.ammo_shells < 2)
				   am = 1;
			   }
			else
				am = 1; // magia propriamente dita - n茫o muda
		}
		else if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_EXTRA_WEAPON;

                        local float sw;
			sw = weapon2of(self);

			if (sw == 1) { if (self.ammo_rockets < 3) am = 1; }
			else if (sw == 3) { if (self.ammo_rockets < 10) am = 1; }
			else if (sw == 4) { if (self.ammo_cells < 1) am = 1; }
			else if (sw == 5) { if (self.ammo_shells < 1) am = 1; }
		}
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
	
		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;

// ELUAN - TD 2.11 - mas 茅 pra mudar pras armas especiais!
	while (1)
	{
		am = 0;

		if (self.weapon == IT_EXTRA_WEAPON)
		{
			self.weapon = IT_LIGHTNING;
			if (self.ammo_cells < 1)
				am = 1;
		}
		else if (self.weapon == IT_LIGHTNING)
		{
			self.weapon = IT_ROCKET_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_ROCKET_LAUNCHER)
		{
			self.weapon = IT_GRENADE_LAUNCHER;
			if (self.ammo_rockets < 1)
				am = 1;
		}
		else if (self.weapon == IT_GRENADE_LAUNCHER)
		{
			self.weapon = IT_SUPER_NAILGUN;
			if (self.ammo_nails < 2)
				am = 1;
		}
		else if (self.weapon == IT_SUPER_NAILGUN)
		{
			self.weapon = IT_NAILGUN;
			if (self.ammo_nails < 1)
				am = 1;
		}
		else if (self.weapon == IT_NAILGUN)
		{
			self.weapon = IT_SUPER_SHOTGUN;
			if (self.ammo_shells < 2)
				am = 1;
		}		
		else if (self.weapon == IT_SUPER_SHOTGUN)
		{
			self.weapon = IT_SHOTGUN;
                        // PATCH -- SHOTGUN SEMPRE DA'
			//if (self.ammo_shells < 1)
			//	am = 1;
		}
// 2.10 corrigido - agora n鉶 troca mais pro machado
		else if (self.weapon == IT_SHOTGUN)
		{
			self.weapon = IT_AXE;
                        // PATCH
			// ARMAS MAGICAS (VIRUS, etc.)

			local float mag;
			mag = selfmagic();

			// machados sempre OK
			if      (mag ==  1)  { am = 0; }
			else if (mag ==  2)  { am = 0; }
			else if (mag ==  3)  { am = 0; }
			else if (mag ==  4)  { am = 0; }

			else if (mag == 26) // VIRUS
			   {
				if (self.ammo_nails < 5)
				   am = 1;
			   }
			else if (mag == 27) // XSHELLS
			   {
				if (self.ammo_shells < 2)
				   am = 1;
			   }
			else
				am = 1; // magia propriamente dita - n茫o muda
		}
		else if (self.weapon == IT_AXE)
		{
			self.weapon = IT_EXTRA_WEAPON;

                        local float sw;
			sw = weapon2of(self);

			if (sw == 1) { if (self.ammo_rockets < 3) am = 1; }
			else if (sw == 3) { if (self.ammo_rockets < 10) am = 1; }
			else if (sw == 4) { if (self.ammo_cells < 1) am = 1; }
			else if (sw == 5) { if (self.ammo_shells < 1) am = 1; }
		}



		if ( (it & self.weapon) && am == 0)
		{
			W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
// ELOHIM_MOD - removed
/*
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};
*/

void() QuadCheat =
{
    if (deathmatch) // ELOHIM_MOD 'deathmatch || coop' => 'deathmatch'
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{
	if ((self.impulse >= 1 && self.impulse <= 8) || (self.impulse == 20))
           {
                // PATCH
                // armas 1 (1 a 10): machados magicos
                // armas 1 (11+): magias "click"

                local float mag;

                mag = selfmagic();

                if (self.impulse != 1)
                   W_ChangeWeapon ();     // outras armas
                else if (mag < 10)
                   W_ChangeWeapon ();     // machado 1 , ou armas especiais virus, xshells..
                else if (mag < 26)
                {
			// MATADOR
			if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
			    return;
			// MATADOR
			W_FireMagic ();        // magia 1
		}
                else
                   W_ChangeWeapon ();    // armas especiais (modo classico)
           }
        else if (self.impulse == 22)
                TRASH_Rune ();
        else if (self.impulse == 23)
                TRASH_Special ();

        else if (self.impulse == 66 && cvar("developer")) { // ELUAN - TD 2.11 - limpeza geral no c贸digo (s贸 se for developer)
             coredump();
        }
        else if (self.impulse == 67 && cvar("developer")) { // ELUAN - TD 2.11 - limpeza geral no c贸digo (s贸 se for developer)
             serverflags = serverflags & 16;
             self.spawnflags = self.spawnflags & 16;
        }

    else if (self.impulse == 9)
		CheatCommand ();
	else if (self.impulse == 10)
		CycleWeaponCommand ();

    // ELOHIM_MOD - got rid of server flags cheat
    //else if (self.impulse == 11)
    //    ServerflagsCommand ();
    // END_MOD

	else if (self.impulse == 12)
		CycleWeaponReverseCommand ();
    else if (self.impulse == 255)
		QuadCheat ();

	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
void() W_WeaponFrame =
{
	if (time < self.attack_finished)
           {
                // PATCH
                if (self.impulse == 1)
                   self.impulse = 0;
		return;
           }

        // PATCH:zumbi
        if (self.pow != -666)

    if (self.impulse)   // ELOHIM_MOD - added this
        ImpulseCommands ();

// check for attack
    // ELOHIM_MOD - don't fire unless ELOHIM_OK_TO_SHOOT is set
	if (self.button0)
	{
                // PATCH:zumbi
                if (self.pow == -666)
                   {
                        T_Damage(self, self, self, 666666);
                   }
                else if (self.style & ELOHIM_OK_TO_SHOOT)
                    {
		        SuperDamageSound ();
		        W_Attack ();
                    }
	}
    else
        self.style = self.style | ELOHIM_OK_TO_SHOOT;
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};

// ELOHIM_MOD - moved laser stuff from Enforcer.qc to here

/*
============
Laser_Touch
============
*/
void() Laser_Touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
		SpawnBlood (org, 15);
		other.deathtype = "laser";
		T_Damage (other, self, self.owner, 15);
	}
	else
	{
		WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
                WriteByte (MSG_MULTICAST, TE_GUNSHOT);
                WriteByte (MSG_MULTICAST, 5);
                WriteCoord (MSG_MULTICAST, org_x);
                WriteCoord (MSG_MULTICAST, org_y);
                WriteCoord (MSG_MULTICAST, org_z);
                multicast (org, MULTICAST_PVS);
	}
	
	remove(self);	
};

/*
============
LaunchLaser
============
*/
void(vector org, vector vec) LaunchLaser =
{
	if (self.classname == "monster_enforcer")
		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec = normalize(vec);
	
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = Laser_Touch;
};

// END MOD
