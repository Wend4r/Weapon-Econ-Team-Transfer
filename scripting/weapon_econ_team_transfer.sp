/**
 * vim: set ts=4 :
 * =============================================================================
 * SourceMod Weapon Econ Team Transfer
 * Transfers econ data to weapons from another team.
 *
 * Copyright (C) 2018-2020 Wend4r. All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 * 
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Version: $Id$
 */

#pragma semicolon 1

#include <sourcemod>
#include <cstrike>

#include <PTaH>

#pragma newdecls required
#pragma tabsize 4

// weapon_econ_transfer.sp
// SourcePawn Compiler 1.10
public Plugin myinfo =
{
	name = "Weapon Econ Team Transfer",
	description = "Transfers econ data to weapons from another team",
	author = "Wend4r",
	version = "1.1"
};

public void OnPluginStart()
{
	PTaH(PTaH_GiveNamedItemPre, Hook, OnGiveNamedItemPre);
}

Action OnGiveNamedItemPre(int iClient, char sClassname[64], CEconItemView &pItemView, bool &bIgnoredView, bool &bOriginNULL, float vecOrigin[3])
{
	int iTeam = GetClientTeam(iClient);

	// Spectator can also be given weapons by force.
	if(iTeam > 1)
	{
		CEconItemDefinition pDefinition = PTaH_GetItemDefinitionByName(sClassname);

		if(pDefinition)
		{
			CCSPlayerInventory pInventory = PTaH_GetPlayerInventory(iClient);

			// Value in abstractions class CCStrike15ItemDefinition regardless of the team always from default loadout.
			int iLoadout = pDefinition.GetLoadoutSlot();

			// If this item can be in loadout.
			if(iLoadout != -1)
			{
				CEconItemView pItemViewBuffer = pInventory.GetItemInLoadout(iTeam, iLoadout);

				// At, we make sure that the product is not exactly loaded from the inventory of the current team.
				if(pItemViewBuffer && pItemViewBuffer.GetItemDefinition() != pDefinition)
				{
					// If this weapon exists in the slots of the contrary team. It can also be default equip slot from CCSInventoryManager.
					if((pItemViewBuffer = pInventory.GetItemInLoadout(iTeam == CS_TEAM_CT ? CS_TEAM_T : CS_TEAM_CT, iLoadout)) && pItemViewBuffer.GetItemDefinition() == pDefinition)
					{
						pItemView = pItemViewBuffer;

						return Plugin_Changed;
					}
				}
			}
		}
	}

	return Plugin_Continue;
}