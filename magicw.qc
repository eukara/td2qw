//
//    ARMAS MAGICAS
//

//
//  ARMA MAGICA 26 - VIRUS DARTS
//    MW_FireVirus ();
//
void(entity player, vector ponto) spawn_lumbriga;
void() Virus_ComeVitima =
{
    local vector lastpos;
    local entity e, oe, targ;

        if (self.enemy.health <= 0)
           {
                remove(self);
                return;
           }

        self.nextthink = time + 0.5;

        // PATCH 2.04 mirror reflete virus
        if (self.enemy.effects & EF_BRIGHTFIELD)
           {
                bprint(self.enemy.netname);
                bprint(" refletiu o VIRUS de ");
                bprint(self.owner.netname);
                bprint("!\n");
                // poing...
                local entity temp;
                temp = self.enemy;
                self.enemy = self.owner;
                self.owner = temp;

                // morto ou mirror on
                // (mirrorado se foi refletido mas o dono morreu,
                // pegou o mirror e ativou, ta os 2 com mirror)
                if ((self.enemy.health <= 0) || (self.enemy.effects & EF_BRIGHTFIELD))
                   {
                        remove(self);
                        return;
                   }

                ccenterprint(self.enemy, "Seu VIRUS foi refletido\nde volta para voce!!", 1);
                return;
           }

        // mata se chegar a menos de 50
        if (self.enemy.health <= 50)
           {
                self.enemy.armorvalue = 0;
                self.enemy.health = 1;
                self.health = 5000;   //BANG!
           }

        // ATTACKER = inflictor = VIRUS, p/ msg death ATTACKER.CLASSNAME == "virus"? then..
        lastpos = self.enemy.origin;
        T_Damage(self.enemy, self, self, self.health);

        //TD2.08:se matou inimigo, spawna wizard
        if (self.health == 5000)
        if (self.enemy.health <= 0) {
           spawn_lumbriga(self.owner, lastpos);

           //remove todos os outros virus que estao
           //atacando o jogador
           targ = self.enemy;
           e = find(world, classname, "td_temp");
           while (e) {
                oe = e;
                e = find(e, classname, "td_temp");
                if (oe.magic == 26)
                if (oe.enemy == targ)
                   remove(oe);
           }

           return;
        }

        SpawnBlood(self.enemy.origin + '0 0 16', self.health*12);

        self.frags = self.frags - self.health;  // virus enfraquece

        if (self.frags <= 0)
        if (self.enemy.health > 0) // ve se ta vivo antes de dar os parabens.. >:-)) mihuhuahuahuahu!!
           {
                //TD2.09 : virus de lombriga nao mostra mensagem
                if (self.ltime != 666)
                   ccenterprint(self.enemy, "O VIRUS foi eliminado pelo\nseu corpo!\n\nVoce sobreviveu!!!", 3);
                remove(self);
                return;
           }
};

void() Poison_Dart_Touch =
{
	if (other.classname == "player" && (other.style & ELOHIM_OBSERVER))
	   return;
        if ((elohim_playmode & ELOHIM_MATCH_MODE) && (other.qw_team == self.owner.qw_team))
           return;

        //other = self.owner;
        if (other.classname == "player")
           {
                // PATCH 2.04 mirror reflete virus
                if (other.effects & EF_BRIGHTFIELD)
                   {
                        bprint(other.netname);
                        bprint(" refletiu o VIRUS de ");
                        bprint(self.owner.netname);
                        bprint("!\n");
                        // poing...
                        local entity temp;
                        temp = other;
                        other = self.owner;
                        self.owner = temp;
                   }

                // morto ou mirror on
                // (mirrorado se foi refletido mas o dono morreu,
                // pegou o mirror e ativou, ta os 2 com mirror)
                if ((other.health <= 0) || (other.effects & EF_BRIGHTFIELD))
                   {
                        remove(self);
                        return;
                   }

                ccenterprint(other, "Voce esta' contaminado por um VIRUS!\nHaHaHaHa!!!", 1);

                local entity virus;
                virus = spawn();
                virus.owner = self.owner;

                remove(self);

                virus.classname = "td_temp";
                virus.magic = 26;  // virus ID

                virus.enemy = other; // hahaha.. si fudeu...
                virus.solid = SOLID_NOT;
                virus.movetype = MOVETYPE_NONE;
                virus.frags = 400;
                virus.health = 4;
                virus.think = Virus_ComeVitima;
                virus.nextthink = time + 1;
           }
        else
            remove(self);
};

void(vector org, vector dir) launch_spike;
void() MW_FireVirus =
{
        //TD
        //self.punchangle_x = -2;
        msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);
        self.ammo_nails = self.ammo_nails - 5;
        self.currentammo = floor(self.ammo_nails / 5);

	local vector	dir;
	local entity	old;

        // spinal PATCH v2.07 - camo faz virus nao emitir barulho
        if (runeof(self) != 1)
	   sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);

	self.attack_finished = time + 0.4;

        makevectors(self.v_angle);
	dir = v_forward; // era aim 1000
	launch_spike (self.origin + '0 0 16', dir);

	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
        newmis.velocity = newmis.velocity * 2;  // 2000
        newmis.touch = Poison_Dart_Touch; //h HEHehheheHeHEHEH!!
};

//
//  ARMA MAGICA 27 - EXPLOSIVE SHOTGUN
//    MW_FireXShotgun ();
//

void() ShellExplode =
{
        // OBS: MODIFICADO
        // dano da granada = health

	T_RadiusDamage (self, self.owner, self.health, world, "xshotgun");

        //sound (self ,CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);

	WriteByte (MSG_MULTICAST, SVC_TEMPENTITY);
	WriteByte (MSG_MULTICAST, TE_EXPLOSION);
	WriteCoord (MSG_MULTICAST, self.origin_x);
	WriteCoord (MSG_MULTICAST, self.origin_y);
	WriteCoord (MSG_MULTICAST, self.origin_z);
        multicast (self.origin, MULTICAST_PHS);

	BecomeExplosion ();
};

void() MW_FireXShotgun =
{
	local vector dir;

        //TD
	//self.punchangle_x = -2;
	msg_entity = self;
	WriteByte (MSG_ONE, SVC_SMALLKICK);

	self.ammo_shells = self.ammo_shells - 2;
        self.currentammo = floor(self.ammo_shells / 2);

        sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);
        self.attack_finished = time + 0.6;

        local vector direction,src;

        src = self.origin + '0 0 16';
        makevectors(self.v_angle);

	direction = v_forward + crandom() * 0.03 * v_right + crandom() * 0.02 * v_up;
	traceline (src, src + direction * 2048, FALSE, self);

        local   entity  boom;
        boom = spawn();
        boom.owner = self;
        boom.classname = "grenade";

        // health=dano da granada requer GrenadeExplode modificado

        if (trace_fraction >= 0.4)
           boom.health = 65;
        else
            boom.health = 105 * (1.1 - trace_fraction);

        boom.think = ShellExplode;
        boom.nextthink = time + 0.05;
        setorigin(boom, trace_endpos);
};
