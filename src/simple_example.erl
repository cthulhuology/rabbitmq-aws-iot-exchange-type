-module(simple_example).

-export([start/0]).

start() ->
    {ok, C} = emqttc:start_link([{host, "a1gbunxiefvk09-ats.iot.eu-central-1.amazonaws.com"}, { port, 8883 }, {client_id, <<"erlang">>}, { ssl, [ {cacertfile, "AmazonRootCA1.pem"}, { certfile, "erlang.crt"}, { keyfile, "erlang.key" } ]}]),
    receive
	{mqttc, C, connected} ->
    		{ ok, _ } = emqttc:sync_subscribe(C, <<"TopicA">>,qos0)
	after
		5000 -> io:format("Connection timeout ~n")
	end,
    emqttc:publish(C, <<"TopicA">>, <<"hello">>),
    receive
        {publish, Topic, Payload} ->
            io:format("Message Received from ~s: ~p~n", [Topic, Payload])
    after
        1000 ->
            io:format("Error: receive timeout!~n")
    end,
    emqttc:disconnect(C).
    
