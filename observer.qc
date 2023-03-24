//
// Observer.qc
//
// Contains code for handling observers.
//
// Fields used:
//
// .wait            - time to look for teleports when observing
// .trigger_field   - closest teleport entity; used when observing
// .t_width         - activation radius for closest teleport
// .dest            - stores destination for popping forward
// .dest1           - stores velocity for popping forward
// .movetarget      - player being watched in observer mode (world if none)
// .delay           - time to refresh head's up display for observing
// .speed           - z component of velocity from previous frame (for fly)
// .state           - unique player id
// .lip             - id of player being watched (0 if none)
//

// function declarations
void () SetNewParms2;
void () respawn;
void () PutClientInServer;
void (entity player) match_disconnect_notify;

//
//  S T A R T
//
//  Enter observer mode.
//
void () observer_start =
{
    self.style = self.style | ELOHIM_OBSERVER;
    if (self.deadflag != DEAD_NO)
    {
        if (self.deadflag >= DEAD_DEAD)
            respawn();
        return;
    }

    // Eluan - clear td stuff if we become observer after spawning
    self.magic = 0;
    self.ltime   = 0;   // magic charge
    self.magicstr = "        ";
    ClientDropStuff();

    self.takedamage = DAMAGE_NO;
    self.solid = SOLID_NOT;

    // get rid of powerups
    self.radsuit_finished = 0;
    self.invisible_finished = 0;
    self.invincible_finished = 0;
    self.super_damage_finished = 0;
    self.rad_time = 0;
    self.invisible_time = 0;
    self.invincible_time = 0;
    self.super_time = 0;
    self.effects = 0;

    // status bar stuff
    self.health = 666;
    self.items = 0;
    self.armorvalue = 0;
    self.ammo_shells = 0;
    self.ammo_nails = 0;
    self.ammo_rockets = 0;
    self.ammo_cells = 0;
    self.currentammo = 0;
    self.frags = -99;
    self.show_hostile = 0;

    // model and view offset
    self.model = string_null;
    self.modelindex = model_null;
    self.weaponmodel = string_null;
    setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
    self.view_ofs = '0 0 22';
    self.nextthink = -1;    // thinking is used to animate client models
    self.think = SUB_Null;

    // teleport stuff
    self.wait = time + 1;

    // which player is being watched
    self.delay = 0;

    stuffcmd(self, "color 0\n");
    stuffcmd(self, "team none\n");
    centerprint(self, "Observer mode on");

    self.movetype = MOVETYPE_NONE;
    self.view_ofs = '0 0 22';
    self.flags = self.flags - FL_ONGROUND;

    // Notify the match module that this player has become an observer
    if (elohim_playmode & ELOHIM_MATCH_MODE)
        match_disconnect_notify(self);
};

//
//  O B S E R V E R  E N D
//
//  Return to normal player mode.
//
void () observer_end =
{
    self.style = self.style - (self.style & ELOHIM_OBSERVER);
    self.frags = 0;

    if (!(elohim_playmode & ELOHIM_MATCH_MODE))
        centerprint(self, "Observer mode off");

    elohim_reset_stats();
    SetNewParms2();
    PutClientInServer();
};

//
//  I M P U L S E  C O M M A N D S
//
//  Called from observer_post_think to check for impulses.
//
void () observer_impulse_commands =
{
    if (self.impulse >= 20)
        elohim_impulse();
    self.impulse = 0;
};

//
//  C A N C E L  L E A V E
//
//  *Don't* leave the match.
//
void () observer_cancel_leave =
{
    local entity oself;

    if (self.owner.style & ELOHIM_CONFIRM_LEAVE)
    {
        self.owner.style = self.owner.style - ELOHIM_CONFIRM_LEAVE;
        sprint(self.owner, "Cancelled\n");
    }
    remove (self);
};

//
//  C O N F I R M
//
//  If someone enters the 'observer' impulse during a match, ask
//  them if they are sure they want to leave the match.
//
void () observer_confirm =
{
    if (self.style & ELOHIM_CONFIRM_LEAVE)
        return;

    sprint(self, "Sair da partida?  Escreva yes para confirmar.\n");
    self.style = self.style | ELOHIM_CONFIRM_LEAVE;
    utils_make_scheduled_event(observer_cancel_leave, 5);
};

//
//  C O N F I R M  L E A V E  R E S P O N S E
//
//  They entered yes or know in response to the above prompt.
//
void (float response) observer_confirm_leave_response =
{
    self.style = self.style - ELOHIM_CONFIRM_LEAVE;
    if (response)
        observer_start();
    else
        sprint(self, "Cancelled\n");
};

//
//  I M P U L S E
//
//  Called from elohim_impulse in elohim.qc to handle observer impulses.
//
void () observer_impulse =
{
    if (self.style & ELOHIM_OBSERVER)
    {
        if (self.impulse == 140)
        {
            if (!(elohim_playmode & ELOHIM_MATCH_MODE))
                observer_end();
        }
    }
    else
    {
        if (self.impulse == 140)
        {
            if ((elohim_playmode & ELOHIM_MATCH_MODE) &&
                (elohim_state & ELOHIM_MATCH_STARTED))
                observer_confirm();
            else
                observer_start();
        }
    }
};

//
//  P R E  T H I N K
//
//  Called from PlayerPreThink in client.qc
//
void () observer_pre_think =
{
};

//
//  P O S T  T H I N K
//
//  Called from PlayerPostThink in Client.qc
//
void () observer_post_think =
{
    if (self.impulse)
        observer_impulse_commands();
};

