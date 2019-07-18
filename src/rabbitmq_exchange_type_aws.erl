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

-module(rabbit_exchange_type_aws).

-include("rabbit.hrl").

-behavior(rabbit_exchange_type).

-export([info/1, info/2]).
-export([ description/0, serialise_events/0, route/2 ]).
-export([ validate/1, validate_binding/2, create/2, delete/3, policy_changed/2,
	add_binding/3, removing_bindings/3, assert_args_equivalence/2 ]).

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

serialize_events() -> false.

route( #exchange{ name = X },
	#delivery{ message = Message#basic_message{ routing_keys = Routes }}) ->
	io:format("~p~n", [ Message ]),
	rabbitmq_aws_iot:route(Name,Routes,Message).
	
validate(X) -> 
	io:format("Validate Exchange ~p~n", [ X ] ),
	ok.
validate_binding(X,B) -> 
	io:format("Validate Binding ~p ~p ~n", [ X,B ]),
	ok.
create(_Tx, X) -> 
	io:format("Creating exchange ~p~n", [ X ]),
	ok.		%% TODO connect to aws iot
delete(_Tx, X, Bs) -> 
	io:format("Delete bindings ~p ~p~n", [ X, Bs ]),
	ok.	%% TODO remove aws iot connection

policy_changed(X1,X2) -> 
	io:format("Policy Change ~p to ~p~n",[ X1,X2 ]),
	ok.

add_binding(_Tx, X, B) -> 
	io:format("Adding Binding ~p ~p~n", [ X, B ]),
	ok.	%% TODO bind exchange to aws iot topic

remove_bindings(_Tx, X, Bs) -> 
	io:format("Removing Bindings ~p ~p~n", [ X,Bs ]),
	ok.

assert_args_equivalence(X, Args) -> 
	io:format("arg equivalence ~p ~p ~n", [ X, Args ]),
	rabbit_exchange:assert_args_equivalence(X, Args).


