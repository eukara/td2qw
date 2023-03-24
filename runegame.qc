//
//  RUNAS (4 poderes especiais)
//
//  Black   = CAMUFLAGEM (invisibilidade total, se ficar parado)
//  Earth   = ARMADURA (resistencia x2)
//  Hell    = TURBO (velocidade e pulo maximo)
//  Elder   = REGEN (regenera energia e armadura)
//

// campo p/ nao exibir alguns ataques do camo
.float   camoattack;


float() crandom;
void() BecomeExplosion;

void() Rune_Touch =
{
    if (elohim_playmode & ELOHIM_MATCH_MODE && !(elohim_state & ELOHIM_MATCH_STARTED))
        return; //descomentar depois de testar...

        if (other.classname != "player")
           return;
        if (self.statustime > time)
           return;   // remendo.. para quando a runa sair do cara
              // e ele continuar vivo, ela nao tocar nele logo em
              // seguida
        if (other.pow == -666)
		   return;
        if (other.health <= 0) //TD2.08: nao pega runa se morto
           return;

        if (runeof(other) > 0)
           {
                // PATCH v2.05
                // ja da pra saber da runa olhando pra statusbar
                //self.statustime = time + 2;
                //sprint(other, "Voce ja possui uma runa!\n");
                return;
           }

        setrune(other, self.items);

        // patch v2.05 -> tambem e' besteira
        //sprint (other, "Voce pegou uma Runa!\n");

        if (self.items == 1)
           {
	            ceprint(other, "Voce pegou o\nÐïäåò äá Ãáíõæìáçåí!\n\n\n\nInvisibilidade Total!", 5, 6);
                sound (other, CHAN_AUTO, "items/inv1.wav", 1, ATTN_NORM);
           }
        else if (self.items == 2)
             {
                ceprint(other, "Voce pegou o\nÐïäåò äá Áòíáäõòá Íáçéãá!\n\n\n\nResistencia 2x Maior!", 5, 6);
                sound (other, CHAN_AUTO, "items/protect.wav", 1, ATTN_NORM);
             }
        else if (self.items == 3)
             {
                ceprint(other, "Voce pegou o\nÐïäåò äï Ôõòâï!\n\n\n\nVelocidade e Protecao!", 5, 6);
                sound (other, CHAN_AUTO, "boss1/sight1.wav", 1, ATTN_NORM);
             }
        else if (self.items == 4)
             {
                ceprint(other, "Voce pegou o\nÐïäåò äá Òåçåîåòáãáï!\n\n\n\nRegenera Energia e Armadura!", 5, 6);
                sound (other, CHAN_AUTO, "items/r_item2.wav", 1, ATTN_NORM);
             }

	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

        remove(self);
};

void() KickRunes;
void(float runetype, vector pos) TossRune =
{
        local entity rune;

        rune = spawn();
        rune.owner = world;
        rune.classname = "rune";

        rune.items = runetype;

        //local string ss;
        //ss = ftos(runetype);
        //bprint("TOSS RUNE --> ");
        //bprint(ss);
        //bprint("\n");

        //
        // PATCH -- SHAREWARE!!
        // se for shareware, usa a mesma runa para todas.. SuX!!
        //
               if (runetype == 1)      setmodel (rune, "progs/end2.mdl");
               else if (runetype == 2) setmodel (rune, "progs/end1.mdl");
               else if (runetype == 3) setmodel (rune, "progs/end3.mdl");
               else if (runetype == 4) setmodel (rune, "progs/end4.mdl");
        // ENDPAT

	rune.flags = FL_ITEM;		// make extra wide
	rune.solid = SOLID_TRIGGER;
	rune.movetype = MOVETYPE_TOSS;
	rune.velocity_x = crandom() * 250;
        rune.velocity_y = crandom() * 250;
        rune.velocity_z = 250;

	rune.touch = Rune_Touch;
        rune.think = KickRunes;

        rune.statustime = time + 1; // remendo - touch funciona
                                    // soh depois de 1 segundo

        rune.nextthink = time + 120;  // dura 2 minuto, depois joga ela em outro lugar
        setsize (rune, '-16 -16 0', '16 16 56');
        setorigin (rune, pos);
};

// coloca runas na fase
void() KickRunes =
{
        local entity spot;

        spot = find(world, classname, "info_player_deathmatch");
        while (random() > 0.04)
              spot = find (spot, classname, "info_player_deathmatch");

        TossRune (self.items, spot.origin);

        remove(self);
};

// joga fora runa
void() TRASH_Rune =
{
        local float r;
        r = runeof(self);

        if (r == 0) return;

        sprint(self, "Jogando RUNA fora...\n");
        stuffcmd(self, "bf\n");

        removerune(self);

        // 10s pra colocar em jogo de novo
        local entity runa;
        runa = spawn();
        runa.think = KickRunes;
        runa.nextthink = time + 10;
        runa.items = r;

        // se for a CAMO e o cara estiver invisivel,
        // coloca model apropriado pra nao dar pau
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

        self.statustime = 0;
};