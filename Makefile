PROJECT = rabbitmq_aws_exchange
PROJECT_DESCRIPTION = RabbitMQ AWS IoT Exchange

DEPS = rabbit_common rabbit aws_iot_client
TEST_DEPS = rabbitmq_ct_helpers rabbitmq_ct_client_helpers amqp_client emqttc

DEP_EARLY_PLUGINS = rabbit_common/mk/rabbitmq-early-plugin.mk
DEP_PLUGINS = rabbit_common/mk/rabbitmq-plugin.mk

# FIXME: Use erlang.mk patched for RabbitMQ, while waiting for PRs to be
# reviewed and merged.

ERLANG_MK_REPO = https://github.com/rabbitmq/erlang.mk.git
ERLANG_MK_COMMIT = rabbitmq-tmp

dep_aws_iot_client = git https://github.com/cthulhuology/aws_iot_client.erl.git 

include rabbitmq-components.mk
include erlang.mk
