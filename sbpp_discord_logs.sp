#pragma semicolon 1

#include <cstrike>
#include <sdktools>
#include <sourcemod>
#include <discord>

#define PLUGIN_NAME "sbpp_discord_logs"
#define PLUGIN_AUTHOR "log-ical"
#define PLUGIN_DESCRIPTION "Prints SBPP logs to discord"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_URL ""

#define g_sSBPPAvatar ""

public Plugin:myinfo =
{
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version = PLUGIN_VERSION,
    url = PLUGIN_URL
}

ConVar g_cvDiscordWebhook; char g_sDiscordWebhook[256];

char lCommbanTypes[][] = {
    "",
    "muted",
    "gagged",
    "silenced"
};

char CommbanTypes[][] = {
    "",
    "Muted",
    "Gagged",
    "Silenced"
};

char sCommbanTypes[][] = {
    "",
    "Mute",
    "Gag",
    "Silence"
};

public void OnPluginStart()
{
    g_cvDiscordWebhook = CreateConVar("sbpp_logs_discordwebhook", "", "Webhook for discord channel");

    GetConVarString(g_cvDiscordWebhook, g_sDiscordWebhook, sizeof(g_sDiscordWebhook));
}

public void SBPP_OnBanPlayer(int admin, int target, int time, const char[] reason)
{
    DiscordWebHook hook = new DiscordWebHook(g_sDiscordWebhook);
    hook.SlackMode = true;

    hook.SetAvatar(g_sSBPPAvatar);
    
    hook.SetUsername("Player Banned");
    
    MessageEmbed Embed = new MessageEmbed();
    
    Embed.SetColor("#FF0000");
    
    char bsteamid[65];
    char bplayerName[512];
    GetClientAuthId(target, AuthId_SteamID64, bsteamid, sizeof(bsteamid));
    Format(bplayerName, sizeof(bplayerName), "[%N](http://www.steamcommunity.com/profiles/%s)", target, bsteamid);
    //Banned Player Link Embed


    char asteamid[65];
    char aplayerName[512];
    if(!IsValidClient(admin)) //if client index is <1 or bot
    {
        Format(aplayerName, sizeof(aplayerName), "CONSOLE");
    }
    else{
        GetClientAuthId(admin, AuthId_SteamID64, asteamid, sizeof(asteamid));
        Format(aplayerName, sizeof(aplayerName), "[%N](http://www.steamcommunity.com/profiles/%s)", admin, asteamid);
        //Admin Link Embed
    }

    char banMsg[512];
    Format(banMsg, sizeof(banMsg), "%s has been banned by %s", bplayerName, aplayerName);
    Embed.AddField("", banMsg, false);


    Embed.AddField("Reason: ", reason, true);
    char sTime[16];
    IntToString(time, sTime, sizeof(sTime));
    Embed.AddField("Length: ", sTime, true);
    char CurrentMap[64];
    GetCurrentMap(CurrentMap, sizeof(CurrentMap));
    Embed.AddField("Map: ", CurrentMap, true);
    char sRealTime[32];
    FormatTime(sRealTime, sizeof(sRealTime), "%m-%d-%Y %I:%M:%S", GetTime());  
    Embed.AddField("Time: ", sRealTime, true);
    char hostname[64];
    GetHostName(hostname, sizeof(hostname));
    Embed.SetFooter(hostname);
    Embed.SetFooterIcon(g_sSBPPAvatar);

    Embed.SetTitle("SourceBans");
    
    hook.Embed(Embed);

    hook.Send();
    delete hook;
}
public void SourceComms_OnBlockAdded(int admin, int target, int time, int type, char[] reason)
{
    if(type>3)
        return;
    DiscordWebHook hook = new DiscordWebHook(g_sDiscordWebhook);
    hook.SlackMode = true;

    hook.SetAvatar(g_sSBPPAvatar);
    
    char usrname[32];
    Format(usrname, sizeof(usrname), "Player %s", CommbanTypes[type]);
    hook.SetUsername(usrname);
    
    MessageEmbed Embed = new MessageEmbed();
    
    Embed.SetColor("#6495ED");
    
    char bsteamid[65];
    char bplayerName[512];
    GetClientAuthId(target, AuthId_SteamID64, bsteamid, sizeof(bsteamid));
    Format(bplayerName, sizeof(bplayerName), "[%N](http://www.steamcommunity.com/profiles/%s)", target, bsteamid);
    //Banned Player Link Embed


    char asteamid[65];
    char aplayerName[512];
    if(!IsValidClient(admin))
    {
        Format(aplayerName, sizeof(aplayerName), "CONSOLE");
    }
    else{
    GetClientAuthId(admin, AuthId_SteamID64, asteamid, sizeof(asteamid));
    Format(aplayerName, sizeof(aplayerName), "[%N](http://www.steamcommunity.com/profiles/%s)", admin, asteamid);
    //Admin Link Embed
    }

    char banMsg[512];
    Format(banMsg, sizeof(banMsg), "%s has been %s by %s", bplayerName, lCommbanTypes[type], aplayerName);
    Embed.AddField("", banMsg, false);


    Embed.AddField("Reason: ", reason, true);
    char sTime[16];
    IntToString(time, sTime, sizeof(sTime));
    Embed.AddField("Length: ", sTime, true);
    Embed.AddField("Type: ", sCommbanTypes[type], true);
    char CurrentMap[64];
    GetCurrentMap(CurrentMap, sizeof(CurrentMap));
    Embed.AddField("Map: ", CurrentMap, true);
    char sRealTime[32];
    FormatTime(sRealTime, sizeof(sRealTime), "%m-%d-%Y %I:%M:%S", GetTime()); 
    Embed.AddField("Time: ", sRealTime, true);


    char hostname[64];
    GetHostName(hostname, sizeof(hostname));
    Embed.SetFooter(hostname);
    Embed.SetFooterIcon(g_sSBPPAvatar);

    Embed.SetTitle("SourceComms");
    
    hook.Embed(Embed);

    hook.Send();
    delete hook;
}

stock bool IsValidClient(int client)
{
    if (client <= 0)
        return false;
    
    if (client > MaxClients)
        return false;
    
    if (!IsClientConnected(client))
        return false;
    
    if (IsFakeClient(client))
        return false;

    return IsClientInGame(client);
}

void GetHostName(char[] str, int size)
{
    static Handle hHostName;
    
    if(hHostName == INVALID_HANDLE)
    {
        if( (hHostName = FindConVar("hostname")) == INVALID_HANDLE)
        {
            return;
        }
    }
    GetConVarString(hHostName, str, size);
}  