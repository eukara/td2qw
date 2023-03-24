void() bubble_bob;

void(float runetype, vector pos) TossRune;
/*
==============================================================================

PLAYER

==============================================================================
*/

void()muzzleflash =
{
	WriteByte (MSG_MULTICAST, SVC_MUZZLEFLASH);
	WriteEntity (MSG_MULTICAST, self);
	multicast (self.origin, MULTICAST_PVS);
};

$cd id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

//
// running
//
$frame axrun1 axrun2 axrun3 axrun4 axrun5 axrun6

$frame rockrun1 rockrun2 rockrun3 rockrun4 rockrun5 rockrun6

//
// standing
//
$frame stand1 stand2 stand3 stand4 stand5

$frame axstnd1 axstnd2 axstnd3 axstnd4 axstnd5 axstnd6
$frame axstnd7 axstnd8 axstnd9 axstnd10 axstnd11 axstnd12


//
// pain
//
$frame axpain1 axpain2 axpain3 axpain4 axpain5 axpain6

$frame pain1 pain2 pain3 pain4 pain5 pain6


//
// death
//

$frame axdeth1 axdeth2 axdeth3 axdeth4 axdeth5 axdeth6
$frame axdeth7 axdeth8 axdeth9

$frame deatha1 deatha2 deatha3 deatha4 deatha5 deatha6 deatha7 deatha8
$frame deatha9 deatha10 deatha11

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame deathc1 deathc2 deathc3 deathc4 deathc5 deathc6 deathc7 deathc8
$frame deathc9 deathc10 deathc11 deathc12 deathc13 deathc14 deathc15

$frame deathd1 deathd2 deathd3 deathd4 deathd5 deathd6 deathd7
$frame deathd8 deathd9

$frame deathe1 deathe2 deathe3 deathe4 deathe5 deathe6 deathe7
$frame deathe8 deathe9

//
// attacks
//
$frame nailatt1 nailatt2

$frame light1 light2

$frame rockatt1 rockatt2 rockatt3 rockatt4 rockatt5 rockatt6

$frame shotatt1 shotatt2 shotatt3 shotatt4 shotatt5 shotatt6

$frame axatt1 axatt2 axatt3 axatt4 axatt5 axatt6

$frame axattb1 axattb2 axattb3 axattb4 axattb5 axattb6

$frame axattc1 axattc2 axattc3 axattc4 axattc5 axattc6

$frame axattd1 axattd2 axattd3 axattd4 axattd5 axattd6


/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_run;

void()	player_stand1 =[	$axstnd1,	player_stand1	]
{
        // PATCH - remendo fiend
        if (self.modelindex == model_fiend)
           {
                if (self.invisible_finished > time)
                        self.modelindex = model_eyes;
                else if (self.size_z < 50)
                        self.modelindex = model_head;
                else
                        self.modelindex = model_player;
           }

    //TD2.09: andando com weaponframe
    if (self.tknight == world)
	   self.weaponframe=0;

	if (self.velocity_x || self.velocity_y)
	{
		self.walkframe=0;
		player_run();
		return;
	}

	// zulukey
        if (self.items & IT_KEY1)
           {
                self.frame = $deathc15;
                return;
           }

        // PATCH
        // so fica com as frames de stand do machado
        // se o machado especial for MACHADO mesmo

	if ((self.weapon == IT_AXE) && (selfmagic() < 26))
	{
		if (self.walkframe >= 12)
			self.walkframe = 0;
		self.frame = $axstnd1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 5)
			self.walkframe = 0;
		self.frame = $stand1 + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;
};

// PATCH 2.04
// se a tesla esta carregando, nunca tirar
// da sequencia de animacao!!
void() player_run_mesmo;
void() player_run =
{
        // se a tesla esta carregando, nunca tirar
        // da sequencia de animacao!!
        if (self.tesla > 0) return;

        player_run_mesmo ();
};
void()	player_run_mesmo =[	$rockrun1,	player_run	]
{
        // PATCH - remendo fiend
        if (self.modelindex == model_fiend)
           {
                if (self.invisible_finished > time)
                        self.modelindex = model_eyes;
                else if (self.size_z < 50)
                        self.modelindex = model_head;
                else
                        self.modelindex = model_player;
           }

    //TD2.09: andando com weaponframe
    if (self.tknight == world)
	   self.weaponframe=0;

	if (!self.velocity_x && !self.velocity_y)
	{
		self.walkframe=0;
		player_stand1();
		return;
	}

        if (self.items & IT_KEY1)
           {
                self.frame = $deathc15;
                return;
           }

        // PATCH
        // so fica com as frames de run do machado
        // se o machado especial for MACHADO mesmo
	if ((self.weapon == IT_AXE) && (selfmagic() < 26))
	{
		if (self.walkframe >= 6)
			self.walkframe = 0;
		self.frame = $axrun1 + self.walkframe;
	}
	else
	{
		if (self.walkframe >= 6)
			self.walkframe = 0;
		self.frame = self.frame + self.walkframe;
	}
	self.walkframe = self.walkframe + 1;
};


void()	player_shot1 =	[$shotatt1, player_shot2	] {self.weaponframe=1;
muzzleflash();
};
void()	player_shot2 =	[$shotatt2, player_shot3	] {self.weaponframe=2;};
void()	player_shot3 =	[$shotatt3, player_shot4	] {self.weaponframe=3;};
void()	player_shot4 =	[$shotatt4, player_shot5	] {self.weaponframe=4;};
void()	player_shot5 =	[$shotatt5, player_shot6	] {self.weaponframe=5;};
void()	player_shot6 =	[$shotatt6, player_run	] {self.weaponframe=6;};

//PATCH 2.08: gibber axe 2x mais rapido com turbo
//PATCH 2.09: gibber axe 2x mais rapido, incondicionalmente
void()   player_axe4 = {
         self.frame = $axatt4;
         self.weaponframe = 4;
         self.think = player_run;
         if (selfmagic() == 1)
            self.nextthink = time + 0.05;
         else
            self.nextthink = time + 0.1;
};
void()   player_axe3 = {
         self.frame = $axatt3;
         self.weaponframe = 3;
         self.think = player_axe4;
         W_FireAxe();
         if (selfmagic() == 1)
            self.nextthink = time + 0.05;
         else
            self.nextthink = time + 0.1;
};
void()   player_axe2 = {
         self.frame = $axatt2;
         self.weaponframe = 2;
         self.think = player_axe3;
         if (selfmagic() == 1)
            self.nextthink = time + 0.05;
         else
            self.nextthink = time + 0.1;
};
void()   player_axe1 = {
         local float f;
         f = $axatt1; if (self.frame == f) return;
         f = $axatt2; if (self.frame == f) return;
         f = $axatt3; if (self.frame == f) return;
         f = $axatt4; if (self.frame == f) return;
         self.frame = $axatt1;
         self.weaponframe = 1;
         self.think = player_axe2;
         if (selfmagic() == 1)
            self.nextthink = time + 0.05;
         else
            self.nextthink = time + 0.1;
};

/*
void()	player_axe1 =	[$axatt1, player_axe2	] {self.weaponframe=1;};
void()	player_axe2 =	[$axatt2, player_axe3	] {self.weaponframe=2;};
void()	player_axe3 =	[$axatt3, player_axe4	] {self.weaponframe=3;W_FireAxe();};
void()	player_axe4 =	[$axatt4, player_run	] {self.weaponframe=4;};
*/

void() player_kaxe1;
void() player_gaxe1;
void()  player_knight_axe = {

        if (self.tknight != world) return;  //ja tem um

        self.attack_finished = time + 0.7;

        player_kaxe1(); //throw knight

        //if (self.throw_knight == 0) {
        //   player_kaxe1(); //throw knight
        //}
        //else if (self.throw_knight == 1) {
        //   player_gaxe1(); //get him back
        //   self.throw_knight = 2;
        //}
};

void()	player_kaxe1 =	[$axatt1, player_kaxe2	] {self.weaponframe=1;};
void()	player_kaxe2 =	[$axatt2, player_kaxe3	] {self.weaponframe=2;};
void()	player_kaxe3 =	[$axatt3, player_kaxe4	] {self.weaponframe=3;W_FireAxe();};
void()	player_kaxe4 =	[$axatt4, player_run	]
{
    // segurando o machado
    self.weaponframe=4;
};

void()	player_gaxe1 =	[$axatt4, player_gaxe2	] {self.weaponframe=4;};
void()	player_gaxe2 =	[$axatt3, player_gaxe3	]
{
    self.weaponframe=3;
    // recolhe monstro
    // matar e' mais facil -- BUM!!
    self.tknight.health = 1;
    makeboom(self.tknight.origin, 50, 0);

    //apaga tknight para que nao fique setando weaponframe=4 no prethink
    self.tknight = world;
};
void()	player_gaxe3 =	[$axatt2, player_gaxe4	] {self.weaponframe=2;};
void()	player_gaxe4 =	[$axatt1, player_run	]
{
    // jogador fica sem poder atirar um pouco
    self.attack_finished = time + 0.5;
};


void()	player_axeb1 =	[$axattb1, player_axeb2	] {self.weaponframe=5;};
void()	player_axeb2 =	[$axattb2, player_axeb3	] {self.weaponframe=6;};
void()	player_axeb3 =	[$axattb3, player_axeb4	] {self.weaponframe=7;W_FireAxe();};
void()	player_axeb4 =	[$axattb4, player_run	] {self.weaponframe=8;};

void()	player_axec1 =	[$axattc1, player_axec2	] {self.weaponframe=1;};
void()	player_axec2 =	[$axattc2, player_axec3	] {self.weaponframe=2;};
void()	player_axec3 =	[$axattc3, player_axec4	] {self.weaponframe=3;W_FireAxe();};
void()	player_axec4 =	[$axattc4, player_run	] {self.weaponframe=4;};

void()	player_axed1 =	[$axattd1, player_axed2	] {self.weaponframe=5;};
void()	player_axed2 =	[$axattd2, player_axed3	] {self.weaponframe=6;};
void()	player_axed3 =	[$axattd3, player_axed4	] {self.weaponframe=7;W_FireAxe();};
void()	player_axed4 =	[$axattd4, player_run	] {self.weaponframe=8;};


//============================================================================

void() player_nail1   =[$nailatt1, player_nail2  ]
{
	muzzleflash();

	if (!self.button0)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;
	SuperDamageSound();

        if (self.weapon == IT_NAILGUN)
                W_FireSpikes (4);
           else
                W_FireSuperSpikes ();
	self.attack_finished = time + 0.2;
};
void() player_nail2   =[$nailatt2, player_nail1  ]
{
	muzzleflash();

	if (!self.button0)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;
	SuperDamageSound();
        if (self.weapon == IT_NAILGUN)
                W_FireSpikes (-4);
           else
                W_FireSuperSpikes ();
	self.attack_finished = time + 0.2;
};


// PATCH
// arma 4 - lasergun
// player_laser1 --> 2x mais lento

void() player_laser1   =[$nailatt1, player_laser2  ]
{
	muzzleflash();

	if (!self.button0)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireSpikes (4);
	self.attack_finished = time + 0.2;
};
void() player_laser2   =[$nailatt1, player_laser3  ] {};
void() player_laser3   =[$nailatt2, player_laser4  ]
{
	muzzleflash();

	if (!self.button0)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 9)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireSpikes (-4);
	self.attack_finished = time + 0.2;
};
void() player_laser4   =[$nailatt2, player_laser1  ] {};

//
// PATCH -- SW 5 - CHAINGUN;
//
void()	player_Chaingun1 = [$nailatt1, player_Chaingun2]
{
	muzzleflash();

        self.attack_finished = time + 0.2;

	if (!self.button0)
		{player_run ();return;}

        self.weaponframe = self.weaponframe + 1;
        if (self.weaponframe < 0)
           self.weaponframe = 0;
        else if (self.weaponframe > 7)
           self.weaponframe = 0;

	SuperDamageSound();
        SW_FireChaingun();
};
void()	player_Chaingun2 = [$nailatt1, player_Chaingun1]
{
	muzzleflash();

        self.attack_finished = time + 0.2;

	if (!self.button0)
		{player_run ();return;}

        self.weaponframe = self.weaponframe + 1;
        if (self.weaponframe < 0)
           self.weaponframe = 0;
        else if (self.weaponframe > 7)
           self.weaponframe = 0;

	SuperDamageSound();
        SW_FireChaingun();
};
//
// ENDPAT -- sw 5 chaingun
//

void() player_rocket1   =[$rockatt1, player_rocket2  ] {self.weaponframe=1;
muzzleflash();};
void() player_rocket2   =[$rockatt2, player_rocket3  ] {self.weaponframe=2;};
void() player_rocket3   =[$rockatt3, player_rocket4  ] {self.weaponframe=3;};
void() player_rocket4   =[$rockatt4, player_rocket5  ] {self.weaponframe=4;};
void() player_rocket5   =[$rockatt5, player_rocket6  ] {self.weaponframe=5;};
void() player_rocket6   =[$rockatt6, player_run  ] {self.weaponframe=6;};
//============================================================================

void() player_light1   =[$light1, player_light2  ]
{
	muzzleflash();

	if (!self.button0)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
};
void() player_light2   =[$light2, player_light1  ]
{
	muzzleflash();

	if (!self.button0)
		{player_run ();return;}
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
		self.weaponframe = 1;
	SuperDamageSound();
	W_FireLightning();
	self.attack_finished = time + 0.2;
};

//
// PATCH -- ARMA ESPECIAL 4 - Tesla Coil
//

void() SW_TeslaFrame =
{
        muzzleflash();

        // ammo
        self.tesla = self.tesla + 1;
        self.currentammo = self.ammo_cells = self.ammo_cells - 1;

        // explode if under water
	if (self.waterlevel > 1)
	   {
                sound (self, CHAN_WEAPON, "weapons/lstart.wav", 1, ATTN_NORM);
                local float cells;
		cells = self.ammo_cells;
                cells = cells + self.tesla;
		self.ammo_cells = 0;
                self.tesla = 0;
		W_SetCurrentAmmo ();
		T_RadiusDamage (self, self, 35*cells, world, "tesla");
		return;
	   }

        // som
	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}

        // punch
	                msg_entity = self;
	                WriteByte (MSG_ONE, SVC_BIGKICK);

        // muda medidor do status
        if ((self.tesla == 1) || (self.tesla == 10) || (self.tesla == 20) || (self.tesla == 30) ||
           (self.tesla == 40) || (self.tesla == 50) || (self.tesla == 55))
                       self.statustime = 0;

        // perigo de sobrecarga a partir de 60
        if (self.tesla > 60)
           {
                local float chance;
                chance = self.tesla - 60;
                chance = chance / 70;

                if (random() < chance)
                   {
                        T_Damage(self, self, self, 50000);
                        self.ammo_cells = 0; // fica legal.. e usa o trecho de baixo p/ discharge
                   }
           }

        // verifica situacoes de tiro
        // -soltou o botao de tiro
        // -fim das cells
        // -mudanca de arma (modos classico e sw)
        if ( (!self.button0) || (self.ammo_cells < 1) || (self.weapon != IT_EXTRA_WEAPON) )
           {
                SW_FireTesla (self.tesla);
                self.tesla = 0;
                if (self.ammo_cells <= 0) self.weapon = W_BestWeapon ();
                W_SetCurrentAmmo ();
                player_run ();
                self.attack_finished = time + 0.4;
                return;
           }

        // animacao, quad..
	self.weaponframe = self.weaponframe + 1;
	if (self.weaponframe == 5)
	   self.weaponframe = 1;
	SuperDamageSound();
	self.attack_finished = time + 0.2;
};

void() player_Tesla1   =[$light1, player_Tesla2  ]
{
        SW_TeslaFrame ();
};

void() player_Tesla2   =[$light2, player_Tesla1  ]
{
        SW_TeslaFrame ();
};

//
//  FIM PATCH Tesla Coil
//

//============================================================================


void(float num_bubbles) DeathBubbles;

void() PainSound =
{
local float		rs;

	if (self.health < 0)
		return;

	if (self.flags & FL_FLY)
      self.waterlevel = fly_waterlevel (self);


	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

// water pain sounds
	if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
	{
		DeathBubbles(1);
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		return;
	}

// slime pain sounds
	if (self.watertype == CONTENT_SLIME)
	{
// FIX ME	put in some steam here
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);
		return;
	}

	if (self.pain_finished > time)
	{
		self.axhitme = 0;
		return;
	}
	self.pain_finished = time + 0.5;

// don't make multiple pain sounds right after each other

// ax pain sound
	if (self.axhitme == 1)
	{
		self.axhitme = 0;
		sound (self, CHAN_VOICE, "player/axhit1.wav", 1, ATTN_NORM);
		return;
	}


	rs = rint((random() * 5) + 1);

	self.noise = "";
	if (rs == 1)
		self.noise = "player/pain1.wav";
	else if (rs == 2)
		self.noise = "player/pain2.wav";
	else if (rs == 3)
		self.noise = "player/pain3.wav";
	else if (rs == 4)
		self.noise = "player/pain4.wav";
	else if (rs == 5)
		self.noise = "player/pain5.wav";
	else
		self.noise = "player/pain6.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	return;
};

void()	player_pain1 =	[	$pain1,	player_pain2	] {PainSound();self.weaponframe=0;};
void()	player_pain2 =	[	$pain2,	player_pain3	] {};
void()	player_pain3 =	[	$pain3,	player_pain4	] {};
void()	player_pain4 =	[	$pain4,	player_pain5	] {};
void()	player_pain5 =	[	$pain5,	player_pain6	] {};
void()	player_pain6 =	[	$pain6,	player_run	] {};

void()	player_axpain1 =	[	$axpain1,	player_axpain2	] {PainSound();self.weaponframe=0;};
void()	player_axpain2 =	[	$axpain2,	player_axpain3	] {};
void()	player_axpain3 =	[	$axpain3,	player_axpain4	] {};
void()	player_axpain4 =	[	$axpain4,	player_axpain5	] {};
void()	player_axpain5 =	[	$axpain5,	player_axpain6	] {};
void()	player_axpain6 =	[	$axpain6,	player_run	] {};

void() player_pain =
{
	if (self.weaponframe)
		return;

	if (self.invisible_finished > time)
		return;		// eyes don't have pain frames

        // PATCH
        if (self.modelindex != model_player)
           return;

	if (self.weapon == IT_AXE)
		player_axpain1 ();
	else
		player_pain1 ();
};

void() player_diea1;
void() player_dieb1;
void() player_diec1;
void() player_died1;
void() player_diee1;
void() player_die_ax1;

void() bubble_bob;

void() DeathBubblesSpawn =
{
local entity	bubble;
   if (self.flags & FL_FLY)
      self.owner.waterlevel = fly_waterlevel (self.owner);

	if (self.owner.waterlevel != 3)
		return;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		remove(self);
};

void(float num_bubbles) DeathBubbles =
{
local entity	bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
	return;
};


void() DeathSound =
{
local float		rs;

   if (self.flags & FL_FLY)
      self.waterlevel = fly_waterlevel (self);

	// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}
	
	rs = rint ((random() * 4) + 1);
	if (rs == 1)
		self.noise = "player/death1.wav";
	if (rs == 2)
		self.noise = "player/death2.wav";
	if (rs == 3)
		self.noise = "player/death3.wav";
	if (rs == 4)
		self.noise = "player/death4.wav";
	if (rs == 5)
		self.noise = "player/death5.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	return;
};


void() PlayerDead =
{
	self.nextthink = -1;
// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;

    // ELOHIM_MOD - autorespawn after 5 seconds in match mode
    if (self.flags & FL_CLIENT) // impedir o amigo de tentar dar respawn
    if (self.pow != -666) // deixa o zumbi em paz
    if (elohim_playmode & ELOHIM_MATCH_MODE)
    {
        self.nextthink = time + 5;
        self.think = respawn;
    }
};

vector(float dm) VelocityForDamage =
{
	local vector v;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 200 + 100 * random();

	if (dm > -50)
	{
//		dprint ("level 1\n");
		v = v * 0.7;
	}
	else if (dm > -200)
	{
//		dprint ("level 3\n");
		v = v * 2;
	}
	else
		v = v * 10;

	return v;
};

void(string gibname, float dm) ThrowGib =
{
	local	entity new;

	new = spawn();
	new.origin = self.origin;
	setmodel (new, gibname);
	setsize (new, '0 0 0', '0 0 0');
	new.velocity = VelocityForDamage (dm);
	new.movetype = MOVETYPE_BOUNCE;
	new.solid = SOLID_NOT;
	new.avelocity_x = random()*600;
	new.avelocity_y = random()*600;
	new.avelocity_z = random()*600;
	new.think = SUB_Remove;
	new.ltime = time;

    // ELOHIM_MOD - remove sooner for low gibs
    if (elohim_playmode & ELOHIM_LOW_GIBS)
        new.nextthink = time + 3 + random() * 3;
    else
        new.nextthink = time + 10 + random()*10;
    // END_MOD

	new.frame = 0;
	new.flags = 0;
        // PATCH
        new.classname = "gib";
};

void(string gibname, float dm) ThrowHead =
{
	setmodel (self, gibname);
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.velocity = VelocityForDamage (dm);
	self.origin_z = self.origin_z - 24;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.avelocity = crandom() * '0 600 0';
};


void() GibPlayer =
{
    ThrowHead ("progs/h_player.mdl", self.health);

    // ELOHIM_MOD - check for no gibs and low gibs
    if (!(elohim_playmode & ELOHIM_NO_GIBS))
    {
        ThrowGib ("progs/gib1.mdl", self.health);
        ThrowGib ("progs/gib2.mdl", self.health);
        if (!(elohim_playmode & ELOHIM_LOW_GIBS))
            ThrowGib ("progs/gib3.mdl", self.health);
    }
    // END_MOD

	self.deadflag = DEAD_DEAD;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() player_revdie_gun1;

void() PlayerDie =
{
	local	float	i;

	        self.items = self.items - (self.items & IT_INVISIBILITY);
	        self.invisible_finished = 0;	// don't die as eyes
	        self.invincible_finished = 0;
	        self.super_damage_finished = 0;
	        self.radsuit_finished = 0;
	        self.modelindex = model_player;	// don't use eyes

    // ELOHIM_MOD - no paks in practice mode; '|| coop' removed
    if (deathmatch && !(elohim_playmode & ELOHIM_PRACTICE_MODE))
		DropBackpack();
    // END_MOD

                // PATCH - larga arma especial
                local float w2os;
                w2os = weapon2of(self);
                if (w2os > 0)
                   {
                        TossSpecial (w2os, self.origin);
                        // v2.063
                        //removeweapon2(self);
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

                // PATCH -- tava disfarcado de cabeca, conserta bbox
                if (self.size_z < 50)
                   {
                        self.modelindex = model_player;
                        setorigin (self, self.origin + '0 0 32');
                        setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
                   }
                // ENDPAT

                // PATCH - remove temps
                local entity e;
                e = find(world, classname, "td_temp");
                while (e) // ELUAN - TD 2.11 - consertado o bug de nascer com virus e outras coisas
                 {
                        local entity tmp;
                        tmp = e;

                        if (tmp.owner == self)   // restaura gamma ao tomar uma paulada
                        if (tmp.magic == 15)
                           stuffcmd(self, "gamma 0.5\n");
                           
                        e = find(e, classname, "td_temp");

                        if (tmp.magic != 13) // NAO REMOVE AMIGO em playerdie (fica)
                        if (tmp.magic != 19) // NAO REMOVE SUCKERBALL em playerdie (fica)
                        if (tmp.magic != 21) // NAO REMOVE DOBERMAN em playerdie (fica)
                        if (tmp.magic != 23) // NAO REMOVE NUKEBOX em playerdie (fica)
                        if (tmp.magic != 24) // NAO REMOVE MINAS em playerdie (fica)
                        if (tmp.magic != 26) // NAO REMOVE VIRUS em playerdie (fica)
                        if (tmp.magic != 226) // TD2.08: NAO REMOVE VIRUS LOMBRIGA em playerdie (fica)
                        if (tmp.owner == self)
                           remove(tmp);

			// remove virus
                        if (tmp.magic == 26)
			if (tmp.enemy == self)
			   remove(tmp);
                 }

	        self.weaponmodel="";
	        self.view_ofs = '0 0 -8';
	        self.deadflag = DEAD_DYING;
	        self.solid = SOLID_NOT;
	        self.flags = self.flags - (self.flags & FL_ONGROUND);
	        self.movetype = MOVETYPE_TOSS;
	        if (self.velocity_z < 10)
		   self.velocity_z = self.velocity_z + random()*300;

        if (self.pow == -666) // zumbie?
           {
                self.attack_finished = time + 4;

                player_revdie_gun1 ();
           }
        else
            {
    // ELOHIM_MOD - check for no gibs
	        if (self.health < -40 && !(elohim_playmode & ELOHIM_NO_GIBS)) // END_MOD
	        {
		        GibPlayer ();
        		PlayerDead(); // ELOHIM_MOD - check for match mode autorespawn
		        return;
	        }

	        DeathSound();

	        self.angles_x = 0;
	        self.angles_z = 0;


	        if (self.weapon == IT_AXE)
	           {
		        player_die_ax1 ();
		        return;
	           }

		i = 1 + floor(random()*6);
	        if (i == 1) player_diea1();
	        else if (i == 2) player_dieb1();
	        else if (i == 3) player_diec1();
	        else if (i == 4) player_died1();
	        else player_diee1();
           }
};

void() set_suicide_frame =
{	// used by klill command and diconnect command
	if (self.model != "progs/player.mdl")
		return;	// allready gibbed
	self.frame = $deatha11;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};


void()	player_diea1	=	[	$deatha1,	player_diea2	] {};
void()	player_diea2	=	[	$deatha2,	player_diea3	] {};
void()	player_diea3	=	[	$deatha3,	player_diea4	] {};
void()	player_diea4	=	[	$deatha4,	player_diea5	] {};
void()	player_diea5	=	[	$deatha5,	player_diea6	] {};
void()	player_diea6	=	[	$deatha6,	player_diea7	] {};
void()	player_diea7	=	[	$deatha7,	player_diea8	] {};
void()	player_diea8	=	[	$deatha8,	player_diea9	] {};
void()	player_diea9	=	[	$deatha9,	player_diea10	] {};
void()	player_diea10	=	[	$deatha10,	player_diea11	] {};
void()	player_diea11	=	[	$deatha11,	player_diea11 ] {PlayerDead();};

void()	player_dieb1	=	[	$deathb1,	player_dieb2	] {};
void()	player_dieb2	=	[	$deathb2,	player_dieb3	] {};
void()	player_dieb3	=	[	$deathb3,	player_dieb4	] {};
void()	player_dieb4	=	[	$deathb4,	player_dieb5	] {};
void()	player_dieb5	=	[	$deathb5,	player_dieb6	] {};
void()	player_dieb6	=	[	$deathb6,	player_dieb7	] {};
void()	player_dieb7	=	[	$deathb7,	player_dieb8	] {};
void()	player_dieb8	=	[	$deathb8,	player_dieb9	] {};
void()	player_dieb9	=	[	$deathb9,	player_dieb9	] {PlayerDead();};

void()	player_diec1	=	[	$deathc1,	player_diec2	] {};
void()	player_diec2	=	[	$deathc2,	player_diec3	] {};
void()	player_diec3	=	[	$deathc3,	player_diec4	] {};
void()	player_diec4	=	[	$deathc4,	player_diec5	] {};
void()	player_diec5	=	[	$deathc5,	player_diec6	] {};
void()	player_diec6	=	[	$deathc6,	player_diec7	] {};
void()	player_diec7	=	[	$deathc7,	player_diec8	] {};
void()	player_diec8	=	[	$deathc8,	player_diec9	] {};
void()	player_diec9	=	[	$deathc9,	player_diec10	] {};
void()	player_diec10	=	[	$deathc10,	player_diec11	] {};
void()	player_diec11	=	[	$deathc11,	player_diec12	] {};
void()	player_diec12	=	[	$deathc12,	player_diec13	] {};
void()	player_diec13	=	[	$deathc13,	player_diec14	] {};
void()	player_diec14	=	[	$deathc14,	player_diec15	] {};
void()	player_diec15	=	[	$deathc15,	player_diec15 ] {PlayerDead();};

void()	player_died1	=	[	$deathd1,	player_died2	] {};
void()	player_died2	=	[	$deathd2,	player_died3	] {};
void()	player_died3	=	[	$deathd3,	player_died4	] {};
void()	player_died4	=	[	$deathd4,	player_died5	] {};
void()	player_died5	=	[	$deathd5,	player_died6	] {};
void()	player_died6	=	[	$deathd6,	player_died7	] {};
void()	player_died7	=	[	$deathd7,	player_died8	] {};
void()	player_died8	=	[	$deathd8,	player_died9	] {};
void()	player_died9	=	[	$deathd9,	player_died9	] {PlayerDead();};

void()	player_diee1	=	[	$deathe1,	player_diee2	] {};
void()	player_diee2	=	[	$deathe2,	player_diee3	] {};
void()	player_diee3	=	[	$deathe3,	player_diee4	] {};
void()	player_diee4	=	[	$deathe4,	player_diee5	] {};
void()	player_diee5	=	[	$deathe5,	player_diee6	] {};
void()	player_diee6	=	[	$deathe6,	player_diee7	] {};
void()	player_diee7	=	[	$deathe7,	player_diee8	] {};
void()	player_diee8	=	[	$deathe8,	player_diee9	] {};
void()	player_diee9	=	[	$deathe9,	player_diee9	] {PlayerDead();};

void()	player_die_ax1	=	[	$axdeth1,	player_die_ax2	] {};
void()	player_die_ax2	=	[	$axdeth2,	player_die_ax3	] {};
void()	player_die_ax3	=	[	$axdeth3,	player_die_ax4	] {};
void()	player_die_ax4	=	[	$axdeth4,	player_die_ax5	] {};
void()	player_die_ax5	=	[	$axdeth5,	player_die_ax6	] {};
void()	player_die_ax6	=	[	$axdeth6,	player_die_ax7	] {};
void()	player_die_ax7	=	[	$axdeth7,	player_die_ax8	] {};
void()	player_die_ax8	=	[	$axdeth8,	player_die_ax9	] {};
void()	player_die_ax9	=	[	$axdeth9,	player_die_ax9	] {PlayerDead();};

void() ZUMBI_Touch =
{
        if (other != self.enemy)
           return;

        other.items = other.items - (other.items & IT_INVULNERABILITY);
        other.invincible_finished = 0;
        T_Damage(other, self, self, 50000);
	ThrowGib ("progs/gib1.mdl", -40);
	ThrowGib ("progs/gib1.mdl", -150);
	ThrowGib ("progs/gib2.mdl", -280);
	ThrowGib ("progs/gib2.mdl", -40);
	ThrowGib ("progs/gib3.mdl", -150);
	ThrowGib ("progs/gib3.mdl", -280);
	ThrowGib ("progs/gib3.mdl", -40);
	ThrowGib ("progs/gib2.mdl", -150);
	ThrowGib ("progs/gib1.mdl", -280);

        T_Damage(self, self, self, 666666);

        ceprint(self, "Parabens!\n\n\nVoce conseguiu se vingar\ndo seu assassino!\n\nBonus: 1 frag", 6, 5);
};

void() ZUMBI_Apontador_Aponta =
{
        self.nextthink = time + 0.05;

        // PATCH apontador serve para os sons do
        // zumbi tambem
        //
        if (self.owner.t_width < time)
           {
                self.owner.t_width = time + 1.2 + random() * 3.8;

                local float rr;
                rr = random();
                if (rr < 0.25) sound (self.owner, CHAN_AUTO, "zombie/z_idle.wav", 1, ATTN_NORM); else
                if (rr < 0.50) sound (self.owner, CHAN_AUTO, "zombie/z_idle1.wav", 1, ATTN_NORM); else
                if (rr < 0.75) sound (self.owner, CHAN_AUTO, "zombie/z_pain.wav", 1, ATTN_NORM); else
                               sound (self.owner, CHAN_AUTO, "zombie/z_pain1.wav", 1, ATTN_NORM);
           }

        local vector d, org;
        d = self.enemy.origin - self.origin;
        self.angles = vectoangles(d);

        makevectors(self.owner.v_angle);

        org = self.owner.origin;
        org = org + v_forward * 25 + v_right * 12 + '0 0 25';
        setorigin(self, org);
};

void()	player_revdie_gun1	=	[	$deatha1,	player_revdie_gun2 ] {};
void()	player_revdie_gun2	=	[	$deatha2,	player_revdie_gun3 ] {};
void()	player_revdie_gun3	=	[	$deatha3,	player_revdie_gun4 ] {};
void()	player_revdie_gun4	=	[	$deatha4,	player_revdie_gun5 ] {};
void()	player_revdie_gun5	=	[	$deatha5,	player_revdie_gun6 ] {};
void()	player_revdie_gun6	=	[	$deatha6,	player_revdie_gun7 ] {};
void()	player_revdie_gun7	=	[	$deatha7,	player_revdie_gun8 ] {};
void()	player_revdie_gun8	=	[	$deatha8,	player_revdie_gun9 ] {};
void()	player_revdie_gun9	=	[	$deatha9,	player_revdie_gun10 ] {};
void()	player_revdie_gun10     =	[	$deatha10,	player_revdie_gun11 ]
{
        self.max_health = 30;
        bprint(self.netname);
        bprint(" virou um ZUMBI VINGADOR!!\n");
        ceprint (self, "Voce virou um ÚÕÍÂÉ ÖÉÎÇÁÄÏÒ¡!\n\n\nEncoste no seu assassino\ne exploda-o em pedacos!!\n\n\nÁôéòå ðáòá äåóéóôéò\n\n\n", 10, 15);
};
void()  player_revdie_gun21;
void()	player_revdie_gun11	=	[	$deatha11,	player_revdie_gun11 ]
{
        self.max_health = self.max_health - 1;
        if (self.max_health <= 0)
           player_revdie_gun21();
};
void()	player_revdie_gun21	=	[	$deatha10,	player_revdie_gun22 ] {};
void()	player_revdie_gun22	=	[	$deatha9,	player_revdie_gun23 ] {};
void()	player_revdie_gun23	=	[	$deatha8,	player_revdie_gun24 ] {};
void()	player_revdie_gun24	=	[	$deatha7,	player_revdie_gun25 ] {};
void()	player_revdie_gun25	=	[	$deatha6,	player_revdie_gun26 ] {};
void()	player_revdie_gun26	=	[	$deatha5,	player_revdie_gun27 ] {};
void()	player_revdie_gun27	=	[	$deatha4,	player_revdie_gun28 ] {};
void()	player_revdie_gun28	=	[	$deatha3,	player_revdie_gun29 ] {};
void()	player_revdie_gun29	=	[	$deatha2,	player_revdie_gun30 ] {};
void()	player_revdie_gun30     =	[	$deatha1,	player_run ]
{
        ceprint (self.enemy, "C U I D A D O ! ! !\n\n\nVoce esta' na mira de um\nÚÕÍÂÉ ÖÉÎÇÁÄÏÒ¡!\n\n\nCorra e Reze!!!", 7, 10);

        bprint(self.netname);
        bprint(" ira' vingar-se de ");
        bprint(self.enemy.netname);
        bprint("!!!\n");

	ThrowGib ("progs/gib1.mdl", -40);
	ThrowGib ("progs/gib1.mdl", -150);
	ThrowGib ("progs/gib1.mdl", -280);
	ThrowGib ("progs/gib2.mdl", -40);
	ThrowGib ("progs/gib2.mdl", -150);
	ThrowGib ("progs/gib2.mdl", -280);
	ThrowGib ("progs/gib3.mdl", -40);
	ThrowGib ("progs/gib3.mdl", -150);
	ThrowGib ("progs/gib3.mdl", -280);
        sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);

        self.weapon = 0;
        self.weaponmodel = "";
        self.currentammo = 60;
        self.armorvalue = self.currentammo;

        self.magic = 0;
        self.items = 0;
        self.sitems = 0;
        self.ammo_shells = 0;
        self.ammo_rockets = 0;
        self.ammo_nails = 0;
        self.ammo_cells = 0;

 	self.classname = "player";
	self.health = 666;
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

        //CAMERA_ON();

	self.attack_finished = time;
        self.touch = ZUMBI_Touch;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	self.deadflag = DEAD_NO;
	self.pausetime = 0;

	self.view_ofs = '0 0 22';

        self.t_width = 0;  // PATCH p/ souns de zumbi
        self.modelindex = model_zombie; // ELUAN - TD 2.11 - consertado o bug de o zumbi travar em engines novas

        // Cria apontador
        local entity missile;

        missile = spawn();
        missile.owner = self;
        missile.enemy = self.enemy;
        missile.classname = "td_temp";
        missile.magic = -666;
        missile.movetype = MOVETYPE_NONE;
        missile.solid = SOLID_NOT;

        missile.think = ZUMBI_Apontador_Aponta;
        missile.nextthink = time + 0.1;

        setmodel(missile, "progs/missile.mdl");
        setsize(missile, '0 0 0', '0 0 0');

	player_stand1 ();
};
