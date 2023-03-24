//
// Userdefs.qc
//
// This file contains customizations for the Elohim mod.
//

// Maximum number of suicides allowed per level in normal and match modes
float ELOHIM_MAX_SUICIDES = 10;

// Intro message
string USER_MOTD;

//
//  I N I T  W O R L D
//
//  Create all string constants
//
void () userdefs_init_world =
{
    // User defined maps
    array_set_user_map(0, "");
    array_set_user_map(1, "");
    array_set_user_map(2, "");
    array_set_user_map(3, "");
    array_set_user_map(4, "");
    array_set_user_map(5, "");
    array_set_user_map(6, "");
    array_set_user_map(7, "");
    array_set_user_map(8, "");
    array_set_user_map(9, "");

    // Intro message
    USER_MOTD = "no bots please";
};

