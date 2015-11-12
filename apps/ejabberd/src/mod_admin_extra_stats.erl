%%%-------------------------------------------------------------------
%%% File    : mod_admin_extra_stats.erl
%%% Author  : Badlop <badlop@process-one.net>, Piotr Nosek <piotr.nosek@erlang-solutions.com>
%%% Purpose : Contributed administrative functions and commands
%%% Created : 10 Aug 2008 by Badlop <badlop@process-one.net>
%%%
%%%
%%% ejabberd, Copyright (C) 2002-2008   ProcessOne
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%%% 02111-1307 USA
%%%
%%%-------------------------------------------------------------------

-module(mod_admin_extra_stats).
-author('badlop@process-one.net').


-export([
    commands/0,

    stats/1, stats/2
    ]).

-include("ejabberd.hrl").
-include("ejabberd_commands.hrl").

%%%
%%% Register commands
%%%

-spec commands() -> [ejabberd_commands:cmd(),...].
commands() ->
    [
        #ejabberd_commands{name = stats, tags = [stats],
                           desc = "Get statistical value: registeredusers onlineusers onlineusersnode uptimeseconds",
                           module = ?MODULE, function = stats,
                           args = [{name, binary}],
                           result = {stat, restuple}},
        #ejabberd_commands{name = stats_host, tags = [stats],
                           desc = "Get statistical value for this host: registeredusers onlineusers",
                           module = ?MODULE, function = stats,
                           args = [{name, binary}, {host, binary}],
                           result = {stat, restuple}}
        ].

%%%
%%% Stats
%%%

-spec stats(binary()) -> {ok, integer()} | {wrong_command, string()}.
stats(Name) ->
    case Name of
        <<"uptimeseconds">> ->
            Secs = integer_to_list(trunc(element(1, erlang:statistics(wall_clock))/1000)),
            {ok, Secs};
        <<"registeredusers">> ->
            Registered = lists:sum([
                    ejabberd_auth:get_vh_registered_users_number(Server)
                    || Server <- ejabberd_config:get_global_option(hosts) ]),
            {ok, integer_to_list(Registered)};
        <<"onlineusersnode">> ->
            Online = integer_to_list(ejabberd_sm:get_node_sessions_number()),
            {ok, Online};
        <<"onlineusers">> ->
            Online = integer_to_list(ejabberd_sm:get_total_sessions_number()),
            {ok, Online};
        _ ->
            {wrong_command, io_lib:format("Wrong command name. To get a statistical value choose one of the"
            " following:~nregisteredusers~nonlineusers ~nonlineusersnode ~nuptimeseconds", [])}
    end.


-spec stats(binary(), ejabberd:server()) -> {ok, integer()} | {wrong_command, string()}.
stats(Name, Host) ->
    case Name of
        <<"registeredusers">> ->
            Registered = ejabberd_auth:get_vh_registered_users_number(Host),
            {ok, integer_to_list(Registered)};
        <<"onlineusers">> ->
            Online = ejabberd_sm:get_vh_session_number(Host),
            {ok, integer_to_list(Online)};
        _ ->
            {wrong_command, io_lib:format("Wrong command name. To get a "
                                          "statistical value choose one of the"
                                          " following:~nregisteredusers~nonlineusers", [])}
    end.
