/** Double-include prevention */
#if defined _jailbots_included_
  #endinput
#endif
#define _jailbots_included_

/**
 * Make rebel for a specific bot
 *
 * @param bot     Bot player
 * @param player     Rebel player
 * @string SayNow     Phrase that bot say now - none = dont say anything - none is the value by default
 * @string SayOnDead     Phrase that bot say when he have killed to human player - none = dont say anything - none is the value by default
 * @noreturn          
 */
native JBOT_MakeRebel(bot, player, String:SayNow[]="none", String:SayOnDead[]="none");

/**
 * Check if a player is rebel for that bot
 *
 * @param bot     Bot player
 * @param player     Rebel player
 * @return true if is rebel or false if not is rebel for the bot
 */
native JBOT_IsRebel(bot, player);

/**
 * Make a no rebel status between bot and player
 *
 * @param bot     Bot player
 * @param player     Rebel player
 * @string SayNow     Phrase that bot say now - none = dont say anything - none is the value by default
 * @noreturn
 */
native JBOT_MakeNoRebel(bot, player, String:SayNow[]="none");

/**
 * Called when a player turns into a rebel for a bot.
 * @param bot   bot that see rebel.
 * @param client   Client rebel.
 */
forward JBOT_OnClientRebel(bot, client);