::=================================================================================
:: NicksCoop run server
:: https://www.moddb.com/mods/nickscoop-postal-2-coop
::
:: You can change server params by adding options: ?OPTION=VALUE
:: For example AdminPassword: ?AdminPassword=PASS
:: More information: https://wiki.beyondunreal.com/Legacy:Running_A_Dedicated_Server_With_UCC
:: Information about NicksCoop DedicatedServer:
:: http://steamcommunity.com/workshop/filedetails/discussion/737631813/1471967615883964375/
::=================================================================================

@echo off
:10
ucc server NicksCoopMapLoader.fuk?Game=NicksCoop.CoopGameInfo ini=Postal2CoOp.ini log=Server.log
goto 10