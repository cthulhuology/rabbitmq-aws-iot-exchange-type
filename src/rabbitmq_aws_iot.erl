%%
%%
%%
%%
%%
%%
%%
%%
%%
%%

-module(rabbitmq_aws_iot).
-behavior(gen_server).
-export([ init/1, start_link/0, code_change/3, handle_info/2, handle_call/3, handle_cast/2]).
-export([route/3, connect/0, disconnect/0, bind/2 ]).

%%-----------------------------------------------------------------------------

connect() ->
	gen_server:call(?MODULE, connect).

disconnect() ->
	gen_server:call(?MODULE, disconnect).

route(Name,Routes,Message) ->
	io:format("route ~p ~p ~p~n", [ Name, Routes, Message ]),
	[ gen_server:cast(?MODULE, { Name, Route, Message }) || Route <- Routes ].

bind(Exchange,Topic) ->
	io:format("bind ~p ~p~n", [ Exchange, Topic ]),
	gen_server:cast(?MODULE, { bind, Exchange, Topic }).	


%%-----------------------------------------------------------------------------

init([]) ->
	[].

start_link() ->
	gen_server:start_link({ local, ?MODULE }, ?MODULE, [], []).

code_change(_OldVsn, State, _Extra) ->
	{ ok, State }.

handle_info({mqttc, _C, connected}, State) ->
	io:format("connected to AWS IoT~n"),
	{ noreply, [ { state, connected } | State ] };

handle_info(Message,State) ->
	io:format("info message ~p~n", [ Message ]),	
	{ noreply, State }.

handle_cast({route,Name,Route,Message}, State ) ->
	io:format("Routing ~p ~p ~p ~p~n", [ Name, Route, Message, State ]),
	Client = proplists:get_value(client,State),
	emqttc:publish(Client,Route,Message),
	{ noreply, State };

handle_cast({bind,_Exchange,Topic}, State ) ->
	Client = proplists:get_value(client,State),
	{ ok, _ } = emqttc:sync_subscribe(Client,Topic,qos0),
	{ noreply, State };

handle_cast(Message,State) ->
	io:format("info message ~p~n", [ Message ]),	
	{ noreply, State }.

handle_call(connect, _From, State) ->
	Config = application:get_all_env(rabbitmq_aws_iot),
	{ ok, Client } = emqttc:start_link(Config),
	{ reply, ok, [ {client, Client } | State ] };

handle_call(disconnect, _From, State) ->
	Client = proplists:get_value(client,State),
	emqttc:disconnect(Client),
	{ reply, ok, proplists:delete(client,State) };

handle_call(Message,From,State) ->
	io:format("call message ~p from ~p ~n", [ Message, From ]),
	{ reply, ok, State }.



