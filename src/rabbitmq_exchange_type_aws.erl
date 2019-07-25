%% rabbitmq_exchange_type_aws
%%

-module(rabbitmq_exchange_type_aws).

-include_lib("rabbit_common/include/rabbit.hrl").

-behavior(rabbit_exchange_type).

-export([info/1, info/2, publish/4 ]).
-export([ description/0, serialise_events/0, route/2 ]).
-export([ validate/1, validate_binding/2, create/2, delete/3, policy_changed/2,
	add_binding/3, remove_bindings/3, assert_args_equivalence/2 ]).

-rabbit_boot_step({ ?MODULE, [
	{ description, "exchange type aws" },
	{ mfa, { rabbit_registry, register, [ exchange, <<"aws">>, ?MODULE ]}},
	{ requires, rabbit_registry },
	{ enables, kernel_ready }]}).

%%-----------------------------------------------------------------------------

info(_X) -> [].
info(_X, _) -> [].

description() ->
	[{name, <<"aws">>},{ description, <<"AWS IoT forwarding MQTT forwarding exchange">>}].

serialise_events() -> false.

%% Send to AWS IoT and act like a fanout exchange
route( #exchange{ name = Name }, #delivery{ message = Message }) ->
	#basic_message{ routing_keys = Routes, content = Content } = Message,
	Payload = iolist_to_binary(lists:reverse(Content#content.payload_fragments_rev)),
	io:format("Route ~p ->  ~p~n", [ Payload, Routes ]),
	[  aws_iot_client:publish( Route, Payload) || Route <- Routes ],
	rabbit_router:match_routing_key(Name, ['_']).
	
validate(X) -> 
	io:format("Validate Exchange ~p~n", [ X ] ),
	ok.

validate_binding(X,B) -> 
	io:format("Validate Binding ~p ~p ~n", [ X,B ]),
	ok.

create(transaction, X) -> 
	io:format("Creating exchange ~p~n", [ X ]),
	aws_iot_client:start_link(),
	ok;		%% TODO connect to aws iot
create(Tx,X) ->
	io:format("create ~p ~p~n", [ Tx, X]),
	ok.

delete(_Tx, X, Bs) -> 
	io:format("Delete bindings ~p ~p~n", [ X, Bs ]),
	ok.	%% TODO remove aws iot connection

policy_changed(X1,X2) -> 
	io:format("Policy Change ~p to ~p~n",[ X1,X2 ]),
	ok.

add_binding(transaction, X, #binding{ key = Key } ) -> 
	io:format("Adding Binding ~p ~p~n", [ X, Key ]),
	%% todo fix subscribe to queue until connected
	aws_iot_client:subscribe(Key),
	ok;
add_binding(Tx,X,B) ->
	io:format("Binding ~p ~p ~p~n", [ Tx, X, B ]),
	ok.

remove_bindings(_Tx, X, Bs) -> 
	io:format("Removing Bindings ~p ~p~n", [ X,Bs ]),
	ok.

assert_args_equivalence(X, Args) -> 
	io:format("arg equivalence ~p ~p ~n", [ X, Args ]),
	rabbit_exchange:assert_args_equivalence(X, Args).

publish(Resource,Exchange,Topic,Message) ->
	io:format("Publishing ~p ~p ~p ~p~n", [ Resource, Exchange, Topic, Message ]),
	Res = rabbit_basic:publish({ resource, Resource, exchange, Exchange }, Topic, [], Message ),
	io:format("Result ~p~n", [Res]),
	ok.
