%% Copyright (c) 2018 EMQ Technologies Co., Ltd. All Rights Reserved.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%%     http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.

-module(esockd_acceptor_sup).

-behaviour(supervisor).

-export([start_link/5, start_acceptor/3, count_acceptors/1]).

-export([init/1]).

%%------------------------------------------------------------------------------
%% API
%%------------------------------------------------------------------------------

%% @doc Start Acceptor Supervisor.
-spec(start_link(ConnSup, AcceptStatsFun, BufferTuneFun, LimitFun, Logger) -> {ok, pid()} when
      ConnSup        :: pid(),
      AcceptStatsFun :: fun(),
      BufferTuneFun  :: esockd:tune_fun(),
      LimitFun       :: fun(),
      Logger         :: gen_logger:logmod()).
start_link(ConnSup, AcceptStatsFun, BufferTuneFun, LimitFun, Logger) ->
    supervisor:start_link(?MODULE, [ConnSup, AcceptStatsFun, BufferTuneFun, LimitFun, Logger]).

%% @doc Start a acceptor.
-spec(start_acceptor(AcceptorSup, LSock, SockFun) -> {ok, pid()} | {error, term()} | ignore when
      AcceptorSup :: pid(),
      LSock       :: inet:socket(),
      SockFun     :: esockd:sock_fun()).
start_acceptor(AcceptorSup, LSock, SockFun) ->
    supervisor:start_child(AcceptorSup, [LSock, SockFun]).

%% @doc Count Acceptors.
-spec(count_acceptors(AcceptorSup :: pid()) -> pos_integer()).
count_acceptors(AcceptorSup) ->
    length(supervisor:which_children(AcceptorSup)).

%%------------------------------------------------------------------------------
%% Supervisor callbacks
%%------------------------------------------------------------------------------

init([ConnSup, AcceptStatsFun, BufferTuneFun, LimitFun, Logger]) ->
    {ok, {{simple_one_for_one, 1000, 3600},
          [{acceptor, {esockd_acceptor, start_link, [ConnSup, AcceptStatsFun, BufferTuneFun, LimitFun, Logger]},
            transient, 5000, worker, [esockd_acceptor]}]}}.

